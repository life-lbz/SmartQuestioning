from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from pydantic import BaseModel, Field


def utc_now() -> datetime:
    return datetime.now(UTC)


class QuestionStatus(StrEnum):
    RECEIVED = "received"
    CONTEXT_READY = "context_ready"
    SQL_GENERATED = "sql_generated"
    SQL_VALIDATED = "sql_validated"
    COST_CHECKED = "cost_checked"
    APPROVAL_REQUIRED = "approval_required"
    EXECUTING = "executing"
    COMPLETED = "completed"
    REJECTED = "rejected"
    FAILED = "failed"
    CANCELLED = "cancelled"


class RiskLevel(StrEnum):
    L0 = "L0"
    L1 = "L1"
    L2 = "L2"
    L3 = "L3"


class QuestionCreate(BaseModel):
    question: str = Field(min_length=2, max_length=2000)
    conversation_id: str | None = None
    preferred_chart: str = "auto"


class ApprovalRequest(BaseModel):
    sql_hash: str


class GeneratedQuery(BaseModel):
    sql: str
    reasoning_summary: str
    assumptions: list[str] = Field(default_factory=list)
    parameters: dict[str, Any] = Field(default_factory=dict)
    suggested_chart: str = "auto"


class RiskAssessment(BaseModel):
    level: RiskLevel = RiskLevel.L0
    reasons: list[str] = Field(default_factory=list)
    estimated_rows: int | None = None


class ChartSpec(BaseModel):
    type: str = "table"
    title: str = "查询结果"
    xField: str | None = None
    yFields: list[str] = Field(default_factory=list)
    seriesNames: dict[str, str] = Field(default_factory=dict)
    smooth: bool = False
    stack: bool = False


class QueryResult(BaseModel):
    columns: list[str]
    rows: list[dict[str, Any]]
    row_count: int
    elapsed_ms: int
    truncated: bool = False


class TimelineEvent(BaseModel):
    status: QuestionStatus
    message: str
    at: datetime = Field(default_factory=utc_now)


class QuestionRecord(BaseModel):
    id: str
    question: str
    requested_by: str
    status: QuestionStatus = QuestionStatus.RECEIVED
    generated: GeneratedQuery | None = None
    normalized_sql: str | None = None
    sql_hash: str | None = None
    risk: RiskAssessment | None = None
    result: QueryResult | None = None
    chart: ChartSpec | None = None
    answer: str | None = None
    error: str | None = None
    timeline: list[TimelineEvent] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=utc_now)
    updated_at: datetime = Field(default_factory=utc_now)
