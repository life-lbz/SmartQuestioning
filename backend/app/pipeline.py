import hashlib
import uuid

from .config import Settings
from .database import QueryGateway
from .llm import TextToSqlProvider
from .metadata import MetadataCatalog
from .schemas import (
    QuestionRecord,
    QuestionStatus,
    RiskAssessment,
    RiskLevel,
    TimelineEvent,
)
from .sql_guard import SqlGuard, SqlRejected
from .store import QuestionStore
from .visualization import build_chart_spec


class QuestionPipeline:
    def __init__(
        self,
        settings: Settings,
        store: QuestionStore,
        catalog: MetadataCatalog,
        provider: TextToSqlProvider,
        guard: SqlGuard,
        gateway: QueryGateway,
    ) -> None:
        self.settings = settings
        self.store = store
        self.catalog = catalog
        self.provider = provider
        self.guard = guard
        self.gateway = gateway

    async def submit(
        self, question: str, requested_by: str, preferred_chart: str = "auto"
    ) -> QuestionRecord:
        record = QuestionRecord(
            id=f"q_{uuid.uuid4().hex[:16]}",
            question=question.strip(),
            requested_by=requested_by,
        )
        self._transition(record, QuestionStatus.RECEIVED, "已接收问题")
        await self.store.save(record)
        try:
            context = self.catalog.snapshot()
            self._transition(record, QuestionStatus.CONTEXT_READY, "已加载授权的数据结构")
            record.generated = await self.provider.generate(record.question, context)
            self._transition(record, QuestionStatus.SQL_GENERATED, "已生成候选 SQL")

            validated = self.guard.validate(record.generated.sql)
            record.normalized_sql = validated.sql
            record.sql_hash = self._hash(record.normalized_sql, record.generated.parameters)
            record.risk = validated.risk
            self._transition(record, QuestionStatus.SQL_VALIDATED, "SQL 安全校验通过")

            estimated_rows = self.gateway.explain(
                record.normalized_sql, record.generated.parameters
            )
            record.risk = self._merge_cost_risk(record.risk, estimated_rows)
            self._transition(record, QuestionStatus.COST_CHECKED, "已完成查询成本预检")

            if record.risk.level in {RiskLevel.L1, RiskLevel.L2}:
                self._transition(record, QuestionStatus.APPROVAL_REQUIRED, "查询需要人工确认后执行")
                return await self.store.save(record)
            return await self._execute(record, preferred_chart=preferred_chart, approved=False)
        except SqlRejected as exc:
            record.risk = RiskAssessment(level=RiskLevel.L3, reasons=exc.reasons)
            record.error = str(exc)
            self._transition(record, QuestionStatus.REJECTED, "SQL 触及禁止边界，已拒绝")
        except Exception as exc:
            record.error = str(exc)
            self._transition(record, QuestionStatus.FAILED, "处理失败")
        return await self.store.save(record)

    async def approve(
        self,
        record: QuestionRecord,
        sql_hash: str,
        role: str,
        preferred_chart: str = "auto",
    ) -> QuestionRecord:
        if record.status != QuestionStatus.APPROVAL_REQUIRED:
            raise ValueError("当前请求不在待审批状态")
        if record.sql_hash != sql_hash:
            raise ValueError("SQL 已变化或审批哈希不匹配")
        if record.risk and record.risk.level == RiskLevel.L2 and role != "admin":
            raise PermissionError("L2 查询仅数据管理员可审批")
        return await self._execute(record, preferred_chart=preferred_chart, approved=True)

    async def cancel(self, record: QuestionRecord) -> QuestionRecord:
        if record.status in {
            QuestionStatus.COMPLETED,
            QuestionStatus.REJECTED,
            QuestionStatus.FAILED,
        }:
            raise ValueError("已结束的请求不能取消")
        self._transition(record, QuestionStatus.CANCELLED, "用户已取消查询")
        return await self.store.save(record)

    async def _execute(
        self, record: QuestionRecord, preferred_chart: str, approved: bool
    ) -> QuestionRecord:
        assert record.generated and record.normalized_sql
        self._transition(record, QuestionStatus.EXECUTING, "正在通过只读网关执行")
        await self.store.save(record)
        record.result = self.gateway.execute(
            record.normalized_sql, record.generated.parameters, approved=approved
        )
        record.chart = build_chart_spec(
            record.result,
            title=record.question,
            preferred=preferred_chart,
            suggested=record.generated.suggested_chart,
        )
        record.answer = self._build_answer(record)
        self._transition(record, QuestionStatus.COMPLETED, "查询与可视化已完成")
        return await self.store.save(record)

    def _merge_cost_risk(self, risk: RiskAssessment, estimated_rows: int | None) -> RiskAssessment:
        level = risk.level
        reasons = list(risk.reasons)
        if estimated_rows is not None and estimated_rows >= self.settings.query_l2_scan_rows:
            level = RiskLevel.L2
            reasons.append(f"预计扫描 {estimated_rows:,} 行，超过高风险阈值")
        elif estimated_rows is not None and estimated_rows >= self.settings.query_l1_scan_rows:
            if level == RiskLevel.L0:
                level = RiskLevel.L1
            reasons.append(f"预计扫描 {estimated_rows:,} 行，需要确认")
        return RiskAssessment(level=level, reasons=reasons, estimated_rows=estimated_rows)

    @staticmethod
    def _hash(sql: str, parameters: dict[str, object]) -> str:
        payload = f"{sql}\n{sorted(parameters.items())}".encode()
        return f"sha256:{hashlib.sha256(payload).hexdigest()}"

    @staticmethod
    def _transition(record: QuestionRecord, status: QuestionStatus, message: str) -> None:
        record.status = status
        record.timeline.append(TimelineEvent(status=status, message=message))

    @staticmethod
    def _build_answer(record: QuestionRecord) -> str:
        assert record.result and record.generated
        if not record.result.rows:
            return "查询完成，但当前条件下没有数据。"
        if record.result.row_count == 1 and len(record.result.columns) == 1:
            value = record.result.rows[0][record.result.columns[0]]
            return f"查询结果为 {value}。"
        suffix = "，结果已按上限截断" if record.result.truncated else ""
        if record.chart and record.chart.type == "line":
            return (
                f"已获得 {record.result.row_count} 个时间点{suffix}。"
                f"{record.generated.reasoning_summary}。"
            )
        if record.chart and record.chart.type == "bar" and record.result.columns:
            first_row = record.result.rows[0]
            dimension = first_row.get(record.result.columns[0])
            metric_column = record.chart.yFields[0] if record.chart.yFields else None
            metric = first_row.get(metric_column) if metric_column else None
            if dimension is not None and metric is not None:
                return (
                    f"共得到 {record.result.row_count} 组结果{suffix}，"
                    f"排名第一的是 {dimension}（{metric_column}={metric}）。"
                )
        return (
            f"已获得 {record.result.row_count} 行结果{suffix}。"
            f"{record.generated.reasoning_summary}。"
        )
