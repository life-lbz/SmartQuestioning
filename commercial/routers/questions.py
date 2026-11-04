"""查询提交、审批、历史、收藏等业务路由。"""
from __future__ import annotations
import asyncio
import csv
import io
import json as _json
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response

from backend.app.llm import EXAMPLE_QUESTIONS
from backend.app.schemas import ApprovalRequest, QuestionCreate

from ..deps import (
    Favorite, admin, can_query, current, owned,
    get_approval_lock, get_catalog, get_gateway,
    get_pipeline, get_query_slots, get_rate_limiter,
    get_repository, get_settings,
)

router = APIRouter(tags=['questions'])


# ---------------------------------------------------------------------------
# 提交 / 审批 / 取消 / 导出
# ---------------------------------------------------------------------------

@router.post('/api/v1/questions')
async def ask(
    payload: QuestionCreate,
    user=Depends(can_query),
    repo=Depends(get_repository),
    pipeline=Depends(get_pipeline),
    rate_limiter=Depends(get_rate_limiter),
    query_slots=Depends(get_query_slots),
):
    # per-user 速率限制：30 次/分钟，防止刷爆查询槽
    if not await rate_limiter.check(f'query:{user["username"]}', limit=30, window=60):
        raise HTTPException(429, '查询请求过于频繁，请稍后再试')
    async with query_slots:
        record = await pipeline.submit(payload.question, user['username'], payload.preferred_chart)
    await repo.event_async(user['username'], 'query', record.id, str(record.status))
    return record


@router.get('/api/v1/questions/{key}')
def detail(key: str, user=Depends(current), repo=Depends(get_repository)):
    return owned(key, user, repo)


@router.post('/api/v1/questions/{key}/approve')
async def approve(
    key: str,
    payload: ApprovalRequest,
    user=Depends(can_query),
    repo=Depends(get_repository),
    pipeline=Depends(get_pipeline),
    approval_lock=Depends(get_approval_lock),
    query_slots=Depends(get_query_slots),
):
    async with approval_lock:
        record = owned(key, user, repo)
        try:
            async with query_slots:
                result = await pipeline.approve(record, payload.sql_hash, user['role'])
        except PermissionError as e:
            raise HTTPException(403, str(e)) from e
        except ValueError as e:
            raise HTTPException(409, str(e)) from e
    await repo.event_async(user['username'], 'approve', key)
    return result


@router.post('/api/v1/questions/{key}/cancel')
async def cancel(
    key: str,
    user=Depends(can_query),
    repo=Depends(get_repository),
    pipeline=Depends(get_pipeline),
    approval_lock=Depends(get_approval_lock),
):
    async with approval_lock:
        record = owned(key, user, repo)
        try:
            result = await pipeline.cancel(record)
        except ValueError as e:
            raise HTTPException(409, str(e)) from e
    await repo.event_async(user['username'], 'cancel', key)
    return result


@router.get('/api/v1/questions/{key}/export')
def export(key: str, user=Depends(current), repo=Depends(get_repository)):
    record = owned(key, user, repo)
    if not record.result:
        raise HTTPException(409, '当前查询没有可导出的结果')
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(record.result.columns)

    def safe(value):
        if isinstance(value, str) and value.lstrip().startswith(('=', '+', '-', '@', '\t', '\r')):
            return "'" + value
        return value

    for row in record.result.rows:
        writer.writerow([safe(row.get(k)) for k in record.result.columns])
    repo.event(user['username'], 'export', key)
    return Response(
        '\ufeff' + out.getvalue(),
        media_type='text/csv',
        headers={'Content-Disposition': f'attachment; filename="{key}.csv"'},
    )


# ---------------------------------------------------------------------------
# 历史 / 元数据 / 示例
# ---------------------------------------------------------------------------

@router.get('/api/v1/history')
def history(
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
    search: Annotated[str, Query(max_length=200)] = '',
    status: str = '',
    user=Depends(current),
    repo=Depends(get_repository),
):
    clauses = ['1=1']
    values = []
    if user['role'] != 'admin':
        clauses.append('owner=?')
        values.append(user['username'])
    if search:
        clauses.append("json_extract(body,'$.question') LIKE ?")
        values.append('%' + search + '%')
    if status:
        clauses.append('status=?')
        values.append(status)
    where = ' AND '.join(clauses)
    with repo.connect() as c:
        total = c.execute(f'SELECT COUNT(*) FROM questions WHERE {where}', values).fetchone()[0]
        rows = c.execute(
            f'SELECT body FROM questions WHERE {where} ORDER BY created_at DESC LIMIT ? OFFSET ?',
            [*values, page_size, (page - 1) * page_size],
        ).fetchall()
    return {'total': total, 'items': [_json.loads(row['body']) for row in rows]}


@router.get('/api/v1/examples')
def examples(user=Depends(current)):
    return {'questions': EXAMPLE_QUESTIONS}


@router.get('/api/v1/metadata/tables')
def metadata(user=Depends(current), catalog=Depends(get_catalog), settings=Depends(get_settings)):
    return {'database': settings.business_db_name, 'tables': catalog.snapshot()['tables']}


# ---------------------------------------------------------------------------
# 收藏
# ---------------------------------------------------------------------------

@router.get('/api/v1/favorites')
def favorites(user=Depends(current), repo=Depends(get_repository)):
    with repo.connect() as c:
        rows = c.execute('SELECT id,title,question FROM favorites WHERE owner=? ORDER BY id DESC',
                         (user['username'],)).fetchall()
    return {'items': [dict(row) for row in rows]}


@router.post('/api/v1/favorites')
def save_favorite(payload: Favorite, user=Depends(current), repo=Depends(get_repository)):
    with repo.connect() as c:
        c.execute(
            'INSERT INTO favorites(owner,title,question) VALUES (?,?,?) ON CONFLICT(owner,title) DO UPDATE SET question=excluded.question',
            (user['username'], payload.title, payload.question),
        )
    repo.event(user['username'], 'favorite_saved', payload.title)
    return {'ok': True}


@router.delete('/api/v1/favorites/{key}')
def delete_favorite(key: int, user=Depends(current), repo=Depends(get_repository)):
    with repo.connect() as c:
        c.execute('DELETE FROM favorites WHERE id=? AND owner=?', (key, user['username']))
    repo.event(user['username'], 'favorite_deleted', key)
    return {'ok': True}


# ---------------------------------------------------------------------------
# 概览（混合 SQLite + MySQL）
# ---------------------------------------------------------------------------

@router.get('/api/v1/overview')
def overview(
    user=Depends(current),
    repo=Depends(get_repository),
    gateway=Depends(get_gateway),
):
    # 先从 SQLite 拿平台侧统计
    with repo.connect() as c:
        condition = '1=1' if user['role'] == 'admin' else 'owner=?'
        params = () if user['role'] == 'admin' else (user['username'],)
        states = {
            row['status']: row['n']
            for row in c.execute(
                f'SELECT status, COUNT(*) n FROM questions WHERE {condition} GROUP BY status', params
            )
        }
        fav_count = c.execute('SELECT COUNT(*) FROM favorites WHERE owner=?', (user['username'],)).fetchone()[0]

    # 再查业务库（mock 模式下 gateway 不查真实库，走 fallback）
    try:
        import asyncio
        from sqlalchemy import text
        engine = gateway.engine
        if engine is not None:
            with engine.connect() as c:
                metrics = dict(
                    c.execute(text(
                        "SELECT COUNT(*) orders, "
                        "SUM(CASE WHEN status='PAID' THEN amount ELSE 0 END) revenue, "
                        "COUNT(DISTINCT customer_id) customers "
                        "FROM orders"
                    )).mappings().one()
                )
                trend = [
                    dict(row)
                    for row in c.execute(text(
                        "SELECT DATE_FORMAT(created_at,'%Y-%m') month, "
                        "ROUND(SUM(amount),2) revenue "
                        "FROM orders WHERE status='PAID' "
                        "GROUP BY month ORDER BY month"
                    )).mappings()
                ]
        else:
            metrics = {'orders': 0, 'revenue': 0, 'customers': 0}
            trend = []
    except Exception:
        metrics = {'orders': 0, 'revenue': 0, 'customers': 0}
        trend = []

    return {
        'states': states,
        'favorite_count': fav_count,
        'business_metrics': metrics,
        'business_trend': trend,
    }
