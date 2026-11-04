import threading
import time
from typing import Any

from sqlalchemy import text
from sqlalchemy.engine import Engine

from .config import Settings

DEMO_CATALOG: dict[str, Any] = {
    "dialect": "mysql",
    "tables": [
        {
            "name": "orders",
            "description": "订单事实表，一行代表一笔订单",
            "columns": [
                {"name": "id", "type": "bigint", "description": "订单ID"},
                {"name": "created_at", "type": "datetime", "description": "下单时间"},
                {"name": "amount", "type": "decimal(12,2)", "description": "实付金额"},
                {"name": "status", "type": "varchar(32)", "description": "订单状态"},
            ],
        }
    ],
    "metrics": {
        "paid_gmv": {
            "expression": "SUM(orders.amount)",
            "filter": "orders.status = 'PAID'",
            "description": "已支付订单实付金额合计",
        }
    },
}


class MetadataCatalog:
    """数据库元数据快照，mock 模式返回内置 DEMO_CATALOG，
    真实模式查询 information_schema 并做 TTL 缓存（默认 5 分钟）。

    缓存放在实例内，同进程共享。应用实例化后若数据库 schema 变化，
    调 invalidate() 或等 TTL 过期即可刷新。
    """

    CACHE_TTL_SECONDS = 300

    def __init__(self, settings: Settings, engine: Engine | None) -> None:
        self.settings = settings
        self.engine = engine
        self._cache: dict[str, Any] | None = None
        self._cache_at: float = 0.0
        self._lock = threading.Lock()

    def invalidate(self) -> None:
        with self._lock:
            self._cache = None
            self._cache_at = 0.0

    def snapshot(self) -> dict[str, Any]:
        # mock 模式或无 engine 时不走缓存，每次直接返回 DEMO_CATALOG
        if self.settings.mock_mode or self.engine is None:
            return DEMO_CATALOG

        now = time.time()
        with self._lock:
            if self._cache is not None and (now - self._cache_at) < self.CACHE_TTL_SECONDS:
                return self._cache

        fresh = self._build_snapshot()

        with self._lock:
            # 双重检查：构建期间可能已有其他线程写入
            if self._cache is None or (time.time() - self._cache_at) >= self.CACHE_TTL_SECONDS:
                self._cache = fresh
                self._cache_at = time.time()
            return self._cache

    def _build_snapshot(self) -> dict[str, Any]:
        sql = text(
            """
            SELECT c.table_name, c.column_name, c.data_type, c.column_comment,
                   t.table_comment
            FROM information_schema.columns c
            JOIN information_schema.tables t
              ON t.table_schema = c.table_schema AND t.table_name = c.table_name
            WHERE c.table_schema = :schema_name
            ORDER BY c.table_name, c.ordinal_position
            """
        )
        tables: dict[str, dict[str, Any]] = {}
        with self.engine.connect() as connection:
            for row in connection.execute(sql, {"schema_name": self.settings.business_db_name}):
                table_name = str(row[0])
                if (
                    self.settings.allowed_tables
                    and table_name.lower() not in self.settings.allowed_tables
                ):
                    continue
                table = tables.setdefault(
                    table_name,
                    {
                        "name": table_name,
                        "description": str(row[4] or ""),
                        "columns": [],
                    },
                )
                table["columns"].append(
                    {
                        "name": str(row[1]),
                        "type": str(row[2]),
                        "description": str(row[3] or ""),
                    }
                )
        return {"dialect": "mysql", "tables": list(tables.values()), "metrics": {}}
