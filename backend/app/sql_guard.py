import re
from dataclasses import dataclass

from sqlglot import exp, parse

from .config import Settings
from .schemas import RiskAssessment, RiskLevel


class SqlRejected(ValueError):
    def __init__(self, reasons: list[str]) -> None:
        super().__init__("；".join(reasons))
        self.reasons = reasons


@dataclass(frozen=True)
class ValidatedQuery:
    sql: str
    tables: tuple[str, ...]
    risk: RiskAssessment


class SqlGuard:
    SYSTEM_SCHEMAS = {"mysql", "sys", "performance_schema", "information_schema"}
    FORBIDDEN_FUNCTIONS = {"SLEEP", "BENCHMARK", "LOAD_FILE"}
    FORBIDDEN_PATTERN = re.compile(
        r"\b(INTO\s+(?:OUTFILE|DUMPFILE)|FOR\s+UPDATE|LOCK\s+IN\s+SHARE\s+MODE)\b",
        re.IGNORECASE,
    )

    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    def validate(self, sql: str) -> ValidatedQuery:
        reasons: list[str] = []
        if not sql.strip():
            raise SqlRejected(["SQL 为空"])
        if "--" in sql or "/*" in sql or "#" in sql:
            reasons.append("不允许 SQL 注释")
        if self.FORBIDDEN_PATTERN.search(sql):
            reasons.append("包含锁定读取或文件输出能力")

        try:
            statements = [item for item in parse(sql, read="mysql") if item is not None]
        except Exception as exc:
            raise SqlRejected([f"SQL 解析失败：{exc}"]) from exc
        if len(statements) != 1:
            reasons.append("只允许单条 SQL")
        if reasons:
            raise SqlRejected(reasons)

        expression = statements[0]
        if not isinstance(expression, (exp.Select, exp.Union)):
            raise SqlRejected(["只允许 SELECT 或只读 WITH...SELECT"])

        forbidden_nodes = (
            exp.Insert,
            exp.Update,
            exp.Delete,
            exp.Create,
            exp.Drop,
            exp.Alter,
            exp.Command,
            exp.Transaction,
            exp.Into,
        )
        if any(expression.find(node_type) for node_type in forbidden_nodes):
            reasons.append("AST 中包含写入、管理或文件输出节点")

        functions = {
            str(node.name).upper()
            for node in expression.find_all(exp.Func)
            if getattr(node, "name", None)
        }
        dangerous_functions = sorted(functions & self.FORBIDDEN_FUNCTIONS)
        if dangerous_functions:
            reasons.append(f"包含危险函数：{', '.join(dangerous_functions)}")

        if any(expression.find_all(exp.Star)):
            reasons.append("禁止 SELECT *，必须显式选择字段")

        tables: list[str] = []
        cte_names = {cte.alias_or_name.lower() for cte in expression.find_all(exp.CTE)}
        for table in expression.find_all(exp.Table):
            table_name = table.name.lower()
            schema_name = (table.db or "").lower()
            if table_name in cte_names:
                continue
            if schema_name in self.SYSTEM_SCHEMAS:
                reasons.append(f"禁止访问系统库：{schema_name}")
            if self.settings.allowed_tables and table_name not in self.settings.allowed_tables:
                reasons.append(f"表不在访问白名单：{table_name}")
            tables.append(table_name)

        if not tables:
            reasons.append("查询未引用任何授权业务表")
        if reasons:
            raise SqlRejected(sorted(set(reasons)))

        limit = expression.args.get("limit")
        if limit is None:
            expression = expression.limit(self.settings.query_max_rows)
        else:
            limit_value = limit.expression
            if isinstance(limit_value, exp.Literal) and limit_value.is_int:
                if int(limit_value.this) > self.settings.query_max_rows:
                    expression.set(
                        "limit",
                        exp.Limit(expression=exp.Literal.number(self.settings.query_max_rows)),
                    )
            else:
                raise SqlRejected(["LIMIT 必须是固定整数"])

        joins = list(expression.find_all(exp.Join))
        subqueries = list(expression.find_all(exp.Subquery))
        windows = list(expression.find_all(exp.Window))
        risk_reasons: list[str] = []
        level = RiskLevel.L0
        if joins or subqueries or windows:
            level = RiskLevel.L1
            if joins:
                risk_reasons.append(f"包含 {len(joins)} 个 JOIN")
            if subqueries:
                risk_reasons.append(f"包含 {len(subqueries)} 个子查询")
            if windows:
                risk_reasons.append("包含窗口函数")
        if len(joins) >= 3:
            level = RiskLevel.L2
            risk_reasons.append("多大表连接需要管理员审批")

        return ValidatedQuery(
            sql=expression.sql(dialect="mysql", pretty=True),
            tables=tuple(sorted(set(tables))),
            risk=RiskAssessment(level=level, reasons=risk_reasons),
        )
