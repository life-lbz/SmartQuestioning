import pytest
from app.config import Settings
from app.schemas import RiskLevel
from app.sql_guard import SqlGuard, SqlRejected


@pytest.fixture
def guard() -> SqlGuard:
    settings = Settings(
        mock_mode=True,
        allowed_tables={"orders", "customers"},
        query_max_rows=100,
    )
    return SqlGuard(settings)


def test_accepts_and_limits_safe_select(guard: SqlGuard) -> None:
    validated = guard.validate("SELECT id, amount FROM orders WHERE status = 'PAID'")
    assert "LIMIT 100" in validated.sql
    assert validated.tables == ("orders",)
    assert validated.risk.level == RiskLevel.L0


@pytest.mark.parametrize(
    "sql",
    [
        "DELETE FROM orders WHERE id = 1",
        "DROP TABLE orders",
        "SELECT id FROM orders; SELECT id FROM customers",
        "SELECT * FROM orders",
        "SELECT user FROM mysql.user",
        "SELECT LOAD_FILE('C:/secret.txt') FROM orders",
        "SELECT id FROM secret_orders",
        "SELECT id FROM orders INTO OUTFILE 'x.csv'",
        "SELECT id FROM orders FOR UPDATE",
    ],
)
def test_rejects_dangerous_sql(guard: SqlGuard, sql: str) -> None:
    with pytest.raises(SqlRejected):
        guard.validate(sql)


def test_join_requires_approval(guard: SqlGuard) -> None:
    validated = guard.validate(
        "SELECT o.id, c.id AS customer_id FROM orders o "
        "JOIN customers c ON c.id = o.customer_id LIMIT 20"
    )
    assert validated.risk.level == RiskLevel.L1
