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
    def __init__(self, settings: Settings, engine: Engine | None) -> None:
        self.settings = settings
        self.engine = engine

    def snapshot(self) -> dict[str, Any]:
        if self.settings.mock_mode or self.engine is None:
            return DEMO_CATALOG

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
