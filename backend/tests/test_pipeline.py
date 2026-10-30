import pytest
from app.config import Settings
from app.database import QueryGateway
from app.llm import TextToSqlProvider
from app.metadata import MetadataCatalog
from app.pipeline import QuestionPipeline
from app.schemas import QuestionStatus
from app.sql_guard import SqlGuard
from app.store import QuestionStore


@pytest.mark.asyncio
async def test_mock_pipeline_completes() -> None:
    settings = Settings(mock_mode=True, allowed_tables={"orders"})
    store = QuestionStore()
    pipeline = QuestionPipeline(
        settings,
        store,
        MetadataCatalog(settings, None),
        TextToSqlProvider(settings),
        SqlGuard(settings),
        QueryGateway(settings, None),
    )

    record = await pipeline.submit("今年每个月销售额趋势", "tester")

    assert record.status == QuestionStatus.COMPLETED
    assert record.result is not None
    assert record.result.row_count == 6
    assert record.chart is not None
    assert record.chart.type == "line"
    assert record.sql_hash and record.sql_hash.startswith("sha256:")
