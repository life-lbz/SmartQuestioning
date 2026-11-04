"""中间件链路 e2e 测试：request-id / CORS / 全局异常 / 速率限制。

这些测试验证的是 FastAPI application 装配后的整体行为，
而不是单个函数的单元测试。
"""
import pytest
from fastapi.testclient import TestClient
from commercial.main import create_app


@pytest.fixture
def setup(tmp_path, monkeypatch):
    monkeypatch.setenv('PLATFORM_ADMIN_PASSWORD', 'Correct-Password-2026!')
    from backend.app.config import Settings
    monkeypatch.setattr(
        'commercial.main.get_settings',
        lambda: Settings(
            _env_file=None,
            mock_mode=True,
            allowed_tables={'orders'},
            app_cors_origins=['http://localhost:5173'],
        ),
    )
    app = create_app(tmp_path / 'platform.sqlite3')
    with TestClient(app) as client:
        yield app, client


def login(client, name='admin', password='Correct-Password-2026!'):
    response = client.post('/api/v1/auth/login', json={'username': name, 'password': password})
    assert response.status_code == 200, response.text
    return {'X-CSRF-Token': response.json()['csrf_token']}


# ---------------------------------------------------------------------------
# 1. request_logger 中间件给所有响应加 X-Request-ID
# ---------------------------------------------------------------------------
def test_request_logger_adds_request_id_header(setup):
    _, client = setup
    # 登录成功的响应有 X-Request-ID
    r = client.post('/api/v1/auth/login', json={'username': 'admin', 'password': 'Correct-Password-2026!'})
    assert r.status_code == 200
    assert 'X-Request-ID' in r.headers
    assert len(r.headers['X-Request-ID']) == 16

    # 登录失败的响应也有 X-Request-ID
    r2 = client.post('/api/v1/auth/login', json={'username': 'admin', 'password': 'wrong'})
    assert r2.status_code == 401
    assert 'X-Request-ID' in r2.headers

    # /live 健康检查也有（因为 GET /live 会被 request_logger 记录）
    r3 = client.get('/live')
    assert r3.status_code == 200
    assert 'X-Request-ID' in r3.headers


# ---------------------------------------------------------------------------
# 2. CORS 只允许白名单 origin
# ---------------------------------------------------------------------------
def test_cors_whitelist_rejects_non_whitelisted_origin(setup):
    app, client = setup
    # 白名单 origin 允许
    r = client.options(
        '/api/v1/auth/login',
        headers={
            'Origin': 'http://localhost:5173',
            'Access-Control-Request-Method': 'POST',
        },
    )
    assert r.status_code in (200, 204)
    assert 'Access-Control-Allow-Origin' in r.headers
    assert r.headers['Access-Control-Allow-Origin'] == 'http://localhost:5173'

    # 非白名单 origin 被拦截
    r2 = client.options(
        '/api/v1/auth/login',
        headers={
            'Origin': 'http://evil.com',
            'Access-Control-Request-Method': 'POST',
        },
    )
    # CORSMiddleware 对非白名单 origin 不返回 CORS 头，浏览器会拦截
    assert 'Access-Control-Allow-Origin' not in r2.headers


def test_cors_effective_only_when_configured(tmp_path, monkeypatch):
    """显式设空列表时，CORSMiddleware 不挂载。默认 settings 自带 localhost:5173。"""
    monkeypatch.setenv('PLATFORM_ADMIN_PASSWORD', 'Correct-Password-2026!')
    from backend.app.config import Settings
    monkeypatch.setattr(
        'commercial.main.get_settings',
        lambda: Settings(
            _env_file=None,
            mock_mode=True,
            allowed_tables={'orders'},
            app_cors_origins=[],  # 显式空列表
        ),
    )
    app = create_app(tmp_path / 'platform.sqlite3')
    middleware_names = [mw.cls.__name__ for mw in app.user_middleware]
    assert 'CORSMiddleware' not in middleware_names


# ---------------------------------------------------------------------------
# 3. 全局异常处理器把未捕获异常包成统一格式
# ---------------------------------------------------------------------------
def test_global_exception_handler_returns_consistent_format(tmp_path, monkeypatch):
    monkeypatch.setenv('PLATFORM_ADMIN_PASSWORD', 'Correct-Password-2026!')
    from backend.app.config import Settings
    monkeypatch.setattr(
        'commercial.main.get_settings',
        lambda: Settings(
            _env_file=None,
            mock_mode=True,
            allowed_tables={'orders'},
        ),
    )
    app = create_app(tmp_path / 'platform.sqlite3')

    # 直接在 app 上注册 boom 路由，跳过 include_router 流程，
    # 避免动态添加的路由在 scope 里没有正确绑定 exception handlers
    from fastapi import APIRouter
    boom_router = APIRouter()

    @boom_router.get('/api/v1/boom')
    def boom():
        raise RuntimeError('boom!')

    app.include_router(boom_router)
    # 移到路由表第一个位置（FastAPI 按注册顺序匹配，避免被静态文件 catch-all 拦截）
    boom_route = app.routes[-1]
    app.routes.remove(boom_route)
    app.routes.insert(0, boom_route)

    with TestClient(app, raise_server_exceptions=False) as client:
        r = client.get('/api/v1/boom')
        assert r.status_code == 500
        body = r.json()
        assert body['detail'] == '内部错误'
        assert 'request_id' in body
        assert len(body['request_id']) == 16


# ---------------------------------------------------------------------------
# 4. 速率限制超过阈值返回 429
# ---------------------------------------------------------------------------
def test_login_rate_limiter_blocks_after_exceeding(setup):
    _, client = setup
    # 连续 5 次失败会先触发内层失败锁（5 次/15 分钟），返回 429。
    # 这时候外层 IP 速率限制（60 次/分钟）还没到。
    # 所以这里验证的是：连续失败会触发 429（由内层或外层触发）。
    # 验证点：第 6 次请求肯定不是 401，而是 429（被某层拦住）。
    for _ in range(5):
        client.post('/api/v1/auth/login', json={'username': 'unknown', 'password': 'bad'})
    r = client.post('/api/v1/auth/login', json={'username': 'unknown', 'password': 'bad'})
    assert r.status_code == 429
    detail = r.json()['detail']
    assert '频繁' in detail or '次数过多' in detail
