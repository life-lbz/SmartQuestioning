from functools import lru_cache
from typing import Annotated

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False, extra="ignore"
    )

    app_env: str = "development"
    app_secret_key: str = "development-only-change-me"
    app_cors_origins: Annotated[list[str], NoDecode] = Field(
        default_factory=lambda: ["http://localhost:5173"]
    )
    mock_mode: bool = False
    text_to_sql_mode: str = "rules"

    business_db_host: str = "127.0.0.1"
    business_db_port: int = 3306
    business_db_name: str = ""
    business_db_user: str = "data_agent_ro"
    business_db_password: str = ""

    llm_base_url: str = ""
    llm_api_key: str = ""
    llm_model: str = ""

    query_max_rows: int = 1000
    query_timeout_seconds: int = 15
    query_approved_timeout_seconds: int = 60
    query_result_max_bytes: int = 5 * 1024 * 1024
    query_l1_scan_rows: int = 100_000
    query_l2_scan_rows: int = 1_000_000
    allowed_tables: Annotated[set[str], NoDecode] = Field(default_factory=set)

    @field_validator("app_cors_origins", mode="before")
    @classmethod
    def parse_origins(cls, value: object) -> object:
        if isinstance(value, str):
            return [item.strip() for item in value.split(",") if item.strip()]
        return value

    @field_validator("allowed_tables", mode="before")
    @classmethod
    def parse_allowed_tables(cls, value: object) -> object:
        if isinstance(value, str):
            return {item.strip().lower() for item in value.split(",") if item.strip()}
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()
