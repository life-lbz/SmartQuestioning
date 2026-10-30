import json
import time
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from sqlalchemy import URL, create_engine, text
from sqlalchemy.engine import Engine

from .config import Settings
from .schemas import QueryResult


def create_business_engine(settings: Settings) -> Engine | None:
    if settings.mock_mode:
        return None
    if not settings.business_db_name or not settings.business_db_password:
        raise RuntimeError("真实模式下必须配置业务数据库名和只读账号密码")
    url = URL.create(
        "mysql+pymysql",
        username=settings.business_db_user,
        password=settings.business_db_password,
        host=settings.business_db_host,
        port=settings.business_db_port,
        database=settings.business_db_name,
        query={"charset": "utf8mb4"},
    )
    return create_engine(
        url,
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=5,
        pool_recycle=1800,
        connect_args={
            "connect_timeout": 5,
            "read_timeout": settings.query_timeout_seconds,
        },
    )


def _json_value(value: Any) -> Any:
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    return value


class QueryGateway:
    def __init__(self, settings: Settings, engine: Engine | None) -> None:
        self.settings = settings
        self.engine = engine

    def status(self) -> dict[str, Any]:
        if self.settings.mock_mode or self.engine is None:
            return {"connected": False, "mode": "mock", "name": None, "version": None}
        try:
            with self.engine.connect() as connection:
                version = str(connection.execute(text("SELECT VERSION()")).scalar_one())
            return {
                "connected": True,
                "mode": "mysql",
                "name": self.settings.business_db_name,
                "version": version,
            }
        except Exception as exc:
            return {
                "connected": False,
                "mode": "mysql",
                "name": self.settings.business_db_name,
                "version": None,
                "error": str(exc),
            }

    def explain(self, sql: str, parameters: dict[str, Any]) -> int | None:
        if self.settings.mock_mode or self.engine is None:
            return 12_000
        with self.engine.connect() as connection:
            row = connection.execute(text(f"EXPLAIN FORMAT=JSON {sql}"), parameters).scalar_one()
        plan = json.loads(row) if isinstance(row, str) else row
        estimates: list[int] = []

        def visit(value: Any) -> None:
            if isinstance(value, dict):
                for key, child in value.items():
                    if key in {"rows_examined_per_scan", "rows_produced_per_join"}:
                        try:
                            estimates.append(int(child))
                        except (TypeError, ValueError):
                            pass
                    visit(child)
            elif isinstance(value, list):
                for child in value:
                    visit(child)

        visit(plan)
        return max(estimates, default=None)

    def execute(
        self, sql: str, parameters: dict[str, Any], *, approved: bool = False
    ) -> QueryResult:
        if self.settings.mock_mode or self.engine is None:
            return self._mock_execute(sql)
        timeout_ms = 1000 * (
            self.settings.query_approved_timeout_seconds
            if approved
            else self.settings.query_timeout_seconds
        )
        started = time.perf_counter()
        with self.engine.connect() as connection:
            connection.exec_driver_sql(f"SET SESSION MAX_EXECUTION_TIME = {timeout_ms}")
            result = connection.execute(text(sql), parameters)
            columns = list(result.keys())
            raw_rows = result.mappings().fetchmany(self.settings.query_max_rows + 1)
        truncated = len(raw_rows) > self.settings.query_max_rows
        rows = [
            {key: _json_value(value) for key, value in dict(row).items()}
            for row in raw_rows[: self.settings.query_max_rows]
        ]
        elapsed_ms = round((time.perf_counter() - started) * 1000)
        return QueryResult(
            columns=columns,
            rows=rows,
            row_count=len(rows),
            elapsed_ms=elapsed_ms,
            truncated=truncated,
        )

    @staticmethod
    def _mock_execute(sql: str) -> QueryResult:
        if "month" in sql.lower():
            rows = [
                {"month": "2026-01", "paid_gmv": 100.0},
                {"month": "2026-02", "paid_gmv": 120.0},
                {"month": "2026-03", "paid_gmv": 140.0},
                {"month": "2026-04", "paid_gmv": 130.0},
                {"month": "2026-05", "paid_gmv": 150.0},
                {"month": "2026-06", "paid_gmv": 160.0},
            ]
            return QueryResult(columns=["month", "paid_gmv"], rows=rows, row_count=6, elapsed_ms=1)
        rows = [{"paid_order_count": 10}]
        return QueryResult(columns=["paid_order_count"], rows=rows, row_count=1, elapsed_ms=1)
