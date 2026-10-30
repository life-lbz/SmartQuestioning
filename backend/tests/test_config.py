from pathlib import Path

from app.config import Settings


def test_comma_separated_settings_from_env_file(tmp_path: Path) -> None:
    env_file = tmp_path / ".env"
    env_file.write_text(
        "APP_CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173\n"
        "ALLOWED_TABLES=orders,customers\n",
        encoding="utf-8",
    )

    settings = Settings(_env_file=env_file)

    assert settings.app_cors_origins == [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ]
    assert settings.allowed_tables == {"orders", "customers"}
