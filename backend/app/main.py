from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import create_router
from .config import get_settings
from .database import QueryGateway, create_business_engine
from .llm import TextToSqlProvider
from .metadata import MetadataCatalog
from .pipeline import QuestionPipeline
from .sql_guard import SqlGuard
from .store import QuestionStore

settings = get_settings()
engine = create_business_engine(settings)
store = QuestionStore()
catalog = MetadataCatalog(settings, engine)
provider = TextToSqlProvider(settings)
guard = SqlGuard(settings)
gateway = QueryGateway(settings, engine)
pipeline = QuestionPipeline(settings, store, catalog, provider, guard, gateway)


@asynccontextmanager
async def lifespan(_: FastAPI):
    yield
    if engine is not None:
        engine.dispose()


app = FastAPI(
    title="Data Agent API",
    version="0.1.0",
    description="Controlled and auditable Text-to-SQL API",
    lifespan=lifespan,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.app_cors_origins,
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "X-User", "X-Role"],
)
app.include_router(create_router(settings, store, pipeline, catalog, gateway), prefix="/api/v1")
