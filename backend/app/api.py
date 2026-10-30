from typing import Any

from fastapi import APIRouter, Header, HTTPException, Query

from .config import Settings
from .database import QueryGateway
from .llm import EXAMPLE_QUESTIONS
from .metadata import MetadataCatalog
from .pipeline import QuestionPipeline
from .schemas import ApprovalRequest, QuestionCreate, QuestionRecord
from .store import QuestionStore


def create_router(
    settings: Settings,
    store: QuestionStore,
    pipeline: QuestionPipeline,
    catalog: MetadataCatalog,
    gateway: QueryGateway,
) -> APIRouter:
    router = APIRouter()

    @router.get("/health")
    async def health() -> dict[str, Any]:
        database = gateway.status()
        return {
            "status": "ok" if database["connected"] else "degraded",
            "database": database,
            "text_to_sql_mode": settings.text_to_sql_mode,
        }

    @router.get("/examples")
    async def examples() -> dict[str, list[str]]:
        return {"questions": EXAMPLE_QUESTIONS}

    @router.get("/metadata/tables")
    async def metadata_tables() -> dict[str, Any]:
        snapshot = catalog.snapshot()
        return {"database": settings.business_db_name, "tables": snapshot["tables"]}

    @router.post("/questions", response_model=QuestionRecord)
    async def create_question(
        payload: QuestionCreate, x_user: str = Header(default="local-user")
    ) -> QuestionRecord:
        return await pipeline.submit(
            question=payload.question,
            requested_by=x_user,
            preferred_chart=payload.preferred_chart,
        )

    @router.get("/questions/{question_id}", response_model=QuestionRecord)
    async def get_question(question_id: str) -> QuestionRecord:
        record = await store.get(question_id)
        if not record:
            raise HTTPException(status_code=404, detail="问数请求不存在")
        return record

    @router.post("/questions/{question_id}/approve", response_model=QuestionRecord)
    async def approve_question(
        question_id: str,
        payload: ApprovalRequest,
        chart: str = Query(default="auto"),
        x_role: str = Header(default="analyst"),
    ) -> QuestionRecord:
        record = await store.get(question_id)
        if not record:
            raise HTTPException(status_code=404, detail="问数请求不存在")
        try:
            return await pipeline.approve(record, payload.sql_hash, x_role, chart)
        except PermissionError as exc:
            raise HTTPException(status_code=403, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=409, detail=str(exc)) from exc

    @router.post("/questions/{question_id}/cancel", response_model=QuestionRecord)
    async def cancel_question(question_id: str) -> QuestionRecord:
        record = await store.get(question_id)
        if not record:
            raise HTTPException(status_code=404, detail="问数请求不存在")
        try:
            return await pipeline.cancel(record)
        except ValueError as exc:
            raise HTTPException(status_code=409, detail=str(exc)) from exc

    return router
