"""系统健康检查。"""
from __future__ import annotations

from fastapi import APIRouter, Depends

from ..deps import current, get_gateway, get_settings

router = APIRouter(tags=['system'])


@router.get('/live')
def live():
    return {'status': 'ok'}


@router.get('/api/v1/health')
async def health(
    user=Depends(current),
    gateway=Depends(get_gateway),
    settings=Depends(get_settings),
):
    database = await gateway.status()
    return {
        'status': 'ok' if database['connected'] else 'degraded',
        'database': database,
        'text_to_sql_mode': settings.text_to_sql_mode,
    }
