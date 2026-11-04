"""认证与账号管理路由。"""
from __future__ import annotations
import asyncio
import os

from fastapi import APIRouter, Depends, HTTPException, Request, Response

from ..deps import (
    Login, PasswordChange, admin, current,
    get_rate_limiter, get_repository,
)
from ..repository import (
    LoginBlockedError, LoginFailedError,
    password_hash, password_matches, token_hash,
)

router = APIRouter(prefix='/api/v1/auth', tags=['auth'])


@router.post('/login')
async def login(
    payload: Login,
    request: Request,
    response: Response,
    repo=Depends(get_repository),
    rate_limiter=Depends(get_rate_limiter),
):
    # 外层 per-IP 速率限制（60 次/分钟），配合内层失败锁（5 次/15 分钟）
    ip = request.client.host if request.client else 'local'
    if not await rate_limiter.check(f'login:{ip}', limit=60, window=60):
        raise HTTPException(429, '请求过于频繁，请稍后再试')

    identity = f'{ip}:{payload.username.lower()}'

    try:
        token, csrf, user_dict = await asyncio.to_thread(
            repo.login_sync, identity, payload.username, payload.password,
        )
    except LoginBlockedError as e:
        raise HTTPException(429, str(e)) from e
    except LoginFailedError as e:
        await repo.event_async(payload.username, 'login_failed')
        raise HTTPException(401, str(e)) from e

    response.set_cookie(
        'smart_questioning_session', token,
        httponly=True, samesite='strict',
        secure=os.getenv('PLATFORM_HTTPS') == '1',
        max_age=28800, path='/',
    )
    await repo.event_async(user_dict['username'], 'login')
    return {'user': user_dict, 'csrf_token': csrf}


@router.get('/me')
def me(user=Depends(current)):
    return {'user': {k: v for k, v in user.items() if k != 'csrf'}, 'csrf_token': user['csrf']}


@router.post('/logout')
def logout(request: Request, response: Response, user=Depends(current), repo=Depends(get_repository)):
    with repo.connect() as c:
        c.execute('DELETE FROM sessions WHERE token=?',
                  (token_hash(request.cookies.get('smart_questioning_session', '')),))
    response.delete_cookie('smart_questioning_session', path='/')
    repo.event(user['username'], 'logout')
    return {'ok': True}


@router.post('/password')
def change_password(payload: PasswordChange, user=Depends(current), repo=Depends(get_repository)):
    with repo.connect() as c:
        row = c.execute('SELECT password_hash FROM users WHERE id=?', (user['id'],)).fetchone()
        if not password_matches(payload.current_password, row[0]):
            raise HTTPException(400, '当前密码不正确')
        c.execute('UPDATE users SET password_hash=? WHERE id=?',
                  (password_hash(payload.new_password), user['id']))
        c.execute('DELETE FROM sessions WHERE user_id=?', (user['id'],))
    repo.event(user['username'], 'password_changed')
    return {'ok': True}
