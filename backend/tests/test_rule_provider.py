import pytest
from app.config import Settings
from app.llm import EXAMPLE_QUESTIONS, TextToSqlProvider


@pytest.mark.asyncio
@pytest.mark.parametrize("question", EXAMPLE_QUESTIONS)
async def test_every_example_generates_read_only_sql(question: str) -> None:
    provider = TextToSqlProvider(Settings(mock_mode=False, text_to_sql_mode="rules"))

    generated = await provider.generate(question, {"tables": []})

    assert generated.sql.lstrip().upper().startswith("SELECT")
    assert generated.suggested_chart in {"metric", "line", "bar", "table"}
    assert generated.reasoning_summary
