"""路由聚合：所有 router 在 create_app 里统一 include。"""
from .auth import router as auth_router
from .questions import router as questions_router
from .admin import router as admin_router
from .system import router as system_router

__all__ = ['auth_router', 'questions_router', 'admin_router', 'system_router']
