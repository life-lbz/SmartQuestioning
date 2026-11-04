"""依赖注入：从 app.state 拉取共享对象 + 身份/权限守卫 + Pydantic 数据模型。

路由文件通过 ``Depends(get_repository)`` 等方式引用，避免模块级全局变量。
"""
from __future__ import annotations
import secrets
from typing import Annotated, Literal

from fastapi import Depends, HTTPException, Request
from pydantic import BaseModel, Field

from .repository import token_hash


# ---------------------------------------------------------------------------
# app.state 访问器
# ---------------------------------------------------------------------------

def get_repository(request: Request):
    return request.app.state.repository


def get_settings(request: Request):
    return request.app.state.settings


def get_gateway(request: Request):
    return request.app.state.gateway


def get_catalog(request: Request):
    return request.app.state.catalog


def get_pipeline(request: Request):
    return request.app.state.pipeline


def get_rate_limiter(request: Request):
    return request.app.state.rate_limiter


def get_approval_lock(request: Request):
    return request.app.state.approval_lock


def get_query_slots(request: Request):
    return request.app.state.query_slots


# ---------------------------------------------------------------------------
# 身份 / 权限守卫
# ---------------------------------------------------------------------------

async def current(request: Request, repo=Depends(get_repository)):
    """已登录用户。非 GET/HEAD/OPTIONS 请求额外校验 CSRF。"""
    user = repo.session(request.cookies.get('smart_questioning_session', ''))
    if not user:
        raise HTTPException(401, '请先登录')
    request.state.user = user['username']
    if request.method not in ('GET', 'HEAD', 'OPTIONS'):
        if not secrets.compare_digest(request.headers.get('X-CSRF-Token', ''), user['csrf']):
            raise HTTPException(403, '请求校验失败，请刷新后重试')
    return user


async def admin(user=Depends(current)):
    if user['role'] != 'admin':
        raise HTTPException(403, '需要管理员权限')
    return user


async def can_query(user=Depends(current)):
    if user['role'] == 'viewer':
        raise HTTPException(403, '浏览员不能执行查询')
    return user


def owned(key: str, user, repo=Depends(get_repository)):
    """查询归属守卫：只有 owner 或 admin 能访问。同步函数，供同步/async 路由通用。"""
    record = repo.get_question(key)
    if not record or (record.requested_by != user['username'] and user['role'] != 'admin'):
        raise HTTPException(404, '查询记录不存在')
    return record


# ---------------------------------------------------------------------------
# Pydantic 数据模型（旧位置：main.py）
# ---------------------------------------------------------------------------

class Login(BaseModel):
    username: str
    password: str


class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(min_length=12)


class Favorite(BaseModel):
    title: str
    question: str


class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=32)
    display_name: str
    role: Literal['admin', 'analyst', 'viewer']
    password: str = Field(min_length=12)


class UserUpdate(BaseModel):
    display_name: str | None = None
    role: Literal['admin', 'analyst', 'viewer'] | None = None
    active: bool | None = None
