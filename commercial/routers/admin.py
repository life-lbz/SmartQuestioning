"""管理员后台：用户管理 + 审计日志。"""
from __future__ import annotations
import sqlite3
import time
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query

from ..deps import UserCreate, UserUpdate, admin, get_repository
from ..repository import password_hash

router = APIRouter(prefix='/api/v1', tags=['admin'])


@router.get('/users')
def users(user=Depends(admin), repo=Depends(get_repository)):
    with repo.connect() as c:
        rows = c.execute(
            'SELECT id,username,display_name,role,active,created_at FROM users ORDER BY id'
        ).fetchall()
    return {'items': [dict(row) for row in rows]}


@router.post('/users')
def add_user(payload: UserCreate, user=Depends(admin), repo=Depends(get_repository)):
    try:
        with repo.connect() as c:
            c.execute(
                'INSERT INTO users(username,display_name,role,password_hash,created_at) VALUES (?,?,?,?,?)',
                (payload.username, payload.display_name, payload.role,
                 password_hash(payload.password), time.time()),
            )
    except sqlite3.IntegrityError as e:
        raise HTTPException(409, '用户名已存在') from e
    repo.event(user['username'], 'user_created', payload.username, payload.role)
    return {'ok': True}


@router.patch('/users/{key}')
def update_user(key: int, payload: UserUpdate, user=Depends(admin), repo=Depends(get_repository)):
    with repo.connect() as c:
        c.execute('BEGIN IMMEDIATE')
        target = c.execute('SELECT * FROM users WHERE id=?', (key,)).fetchone()
        if not target:
            raise HTTPException(404, '用户不存在')
        active = target['active'] if payload.active is None else int(payload.active)
        role = payload.role or target['role']
        if (
            target['role'] == 'admin' and target['active']
            and (not active or role != 'admin')
        ):
            if c.execute(
                "SELECT COUNT(*) FROM users WHERE role='admin' AND active=1"
            ).fetchone()[0] <= 1:
                raise HTTPException(409, '不能停用或降级最后一位管理员')
        c.execute('UPDATE users SET active=?,role=? WHERE id=?', (active, role, key))
        c.execute('DELETE FROM sessions WHERE user_id=?', (key,))
    repo.event(user['username'], 'user_updated', key, f'{role},active={active}')
    return {'ok': True}


@router.get('/audit')
def audit(
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
    user=Depends(admin),
    repo=Depends(get_repository),
):
    with repo.connect() as c:
        total = c.execute('SELECT COUNT(*) FROM audit').fetchone()[0]
        rows = c.execute(
            'SELECT * FROM audit ORDER BY id DESC LIMIT ? OFFSET ?',
            (page_size, (page - 1) * page_size),
        ).fetchall()
    return {'total': total, 'items': [dict(row) for row in rows]}
