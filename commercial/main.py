from __future__ import annotations
import asyncio
import csv
import io
import logging
import os
import re
import secrets
import sqlite3
import time
import uuid
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Literal

import httpx
from fastapi import Depends, FastAPI, HTTPException, Query, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from sqlalchemy import text

from backend.app.config import get_settings
from backend.app.database import QueryGateway, create_business_engine
from backend.app.llm import EXAMPLE_QUESTIONS, TextToSqlProvider
from backend.app.metadata import MetadataCatalog
from backend.app.pipeline import QuestionPipeline
from backend.app.schemas import ApprovalRequest, QuestionCreate
from backend.app.sql_guard import SqlGuard
from .repository import Repository, password_hash, password_matches, token_hash
from .routers import auth_router, admin_router, questions_router, system_router

logger = logging.getLogger("smart-questioning")


# ---------------------------------------------------------------------------
# 简易内存速率限制（滑动窗口，进程内共享；多 worker 部署时换 Redis）
# ---------------------------------------------------------------------------
class _RateLimiter:
    """按 key 计数最近 window 秒内的调用次数，超过 limit 拒绝。"""

    def __init__(self) -> None:
        self._buckets: dict[str, list[float]] = {}
        self._lock = asyncio.Lock()

    async def check(self, key: str, limit: int, window: int) -> bool:
        now = time.time()
        cutoff = now - window
        async with self._lock:
            bucket = self._buckets.get(key) or []
            bucket = [t for t in bucket if t >= cutoff]
            if len(bucket) >= limit:
                self._buckets[key] = bucket
                return False
            bucket.append(now)
            self._buckets[key] = bucket
            return True


rate_limiter = _RateLimiter()

class Login(BaseModel):
    username: str = Field(min_length=1,max_length=64)
    password: str = Field(min_length=1,max_length=256)

class UserCreate(BaseModel):
    username: str = Field(pattern=r'^[a-zA-Z0-9_.-]{3,40}$')
    display_name: str = Field(min_length=1,max_length=60)
    password: str = Field(min_length=12,max_length=256)
    role: Literal['admin','analyst','viewer'] = 'analyst'

class UserUpdate(BaseModel):
    active: bool | None = None
    role: Literal['admin','analyst','viewer'] | None = None

class PasswordChange(BaseModel):
    current_password: str = Field(max_length=256)
    new_password: str = Field(min_length=12,max_length=256)

class Favorite(BaseModel):
    title: str = Field(min_length=1,max_length=100)
    question: str = Field(min_length=2,max_length=2000)

def create_app(path: Path | None = None):
    settings = get_settings()

    # ---- 日志初始化 ----
    logging.basicConfig(
        level=getattr(logging, settings.app_log_level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    repository = Repository(path or Path(os.getenv('PLATFORM_DB_PATH', str(Path(__file__).resolve().parents[1]/'.runtime/platform/retail-platform.sqlite3'))))
    engine = create_business_engine(settings)
    gateway = QueryGateway(settings, engine)
    catalog = MetadataCatalog(settings, engine)

    # LLM 客户端在 lifespan 中创建，供 provider 复用
    llm_provider = TextToSqlProvider(settings)
    pipeline = QuestionPipeline(settings, repository, catalog, llm_provider, SqlGuard(settings), gateway)

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        # 准备 LLM 常驻 httpx 客户端
        app.state.llm_client = httpx.AsyncClient(timeout=60)
        llm_provider.bind_client(app.state.llm_client)
        logger.info("Smart Questioning 启动, mode=%s env=%s",
                     "mock" if settings.mock_mode else "mysql", settings.app_env)
        try:
            yield
        finally:
            await app.state.llm_client.aclose()
            logger.info("Smart Questioning 关闭")

    app = FastAPI(
        title='Smart Questioning Internal Platform',
        version='1.0.0',
        docs_url=None, redoc_url=None, openapi_url=None,
        lifespan=lifespan,
    )
    # 所有跨模块共享对象集中托管在 app.state，路由通过 deps 依赖注入获取。
    app.state.repository = repository
    app.state.settings = settings
    app.state.gateway = gateway
    app.state.catalog = catalog
    app.state.pipeline = pipeline
    app.state.rate_limiter = rate_limiter
    app.state.approval_lock = asyncio.Lock()
    app.state.query_slots = asyncio.Semaphore(4)

    # ---- CORS ----
    if settings.app_cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.app_cors_origins,
            allow_credentials=True,
            allow_methods=['*'],
            allow_headers=['*'],
        )

    # ---- 安全头 ----
    @app.middleware('http')
    async def security_headers(request: Request, call_next):
        response = await call_next(request)
        response.headers['Cache-Control'] = 'no-store'
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['Referrer-Policy'] = 'same-origin'
        return response

    # ---- 请求耗时 + request-id 日志 ----
    @app.middleware('http')
    async def request_logger(request: Request, call_next):
        rid = request.headers.get('X-Request-ID') or uuid.uuid4().hex[:16]
        request.state.rid = rid
        started = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            elapsed = round((time.perf_counter() - started) * 1000)
            logger.exception("[rid=%s] %s %s failed after %dms", rid, request.method, request.url.path, elapsed)
            raise
        elapsed = round((time.perf_counter() - started) * 1000)
        status = response.status_code
        if request.url.path.startswith('/api') or request.method != 'GET':
            logger.info("[rid=%s] %s %s -> %d %dms user=%s",
                        rid, request.method, request.url.path, status, elapsed,
                        request.state.user if hasattr(request.state, 'user') else '-')
        response.headers['X-Request-ID'] = rid
        return response

    # ---- 全局异常处理 ----
    @app.exception_handler(Exception)
    async def handle_exception(request: Request, exc: Exception):
        rid = getattr(request.state, 'rid', '-')
        logger.exception("[rid=%s] unhandled on %s %s: %s", rid, request.method, request.url.path, exc)
        return JSONResponse(
            status_code=500,
            content={'detail': '内部错误', 'request_id': rid},
        )

    @app.exception_handler(sqlite3.IntegrityError)
    async def handle_sqlite_integrity(request: Request, exc: sqlite3.IntegrityError):
        logger.warning("sqlite integrity violation: %s", exc)
        return JSONResponse(status_code=409, content={'detail': '数据冲突，请检查后重试'})

    # ---- 注册路由 ----
    app.include_router(system_router)
    app.include_router(auth_router)
    app.include_router(questions_router)
    app.include_router(admin_router)

    # ---- 静态前端回退 ----
    dist = Path(__file__).resolve().parents[1] / 'frontend-vben/apps/web-business/dist'

    @app.get('/{asset:path}', include_in_schema=False)
    def frontend(asset: str):
        if asset.startswith('api/') or not dist.exists():
            raise HTTPException(404, '页面不存在，请先构建前端')
        resolved = (dist / asset).resolve()
        if not resolved.is_relative_to(dist.resolve()):
            raise HTTPException(404, '页面不存在')
        if resolved.is_file():
            return FileResponse(resolved)
        if '.' in Path(asset).name:
            raise HTTPException(404, '文件不存在')
        return FileResponse(dist / 'index.html')

    return app

app=create_app() if os.getenv('PLATFORM_NO_DEFAULT_APP')!='1' else None
