import asyncio
from collections.abc import Iterable

from .schemas import QuestionRecord, utc_now


class QuestionStore:
    """In-memory MVP store. Replace with a repository without changing the pipeline API."""

    def __init__(self) -> None:
        self._records: dict[str, QuestionRecord] = {}
        self._lock = asyncio.Lock()

    async def save(self, record: QuestionRecord) -> QuestionRecord:
        async with self._lock:
            record.updated_at = utc_now()
            self._records[record.id] = record
            return record.model_copy(deep=True)

    async def get(self, question_id: str) -> QuestionRecord | None:
        async with self._lock:
            record = self._records.get(question_id)
            return record.model_copy(deep=True) if record else None

    async def list(self) -> Iterable[QuestionRecord]:
        async with self._lock:
            return [item.model_copy(deep=True) for item in self._records.values()]
