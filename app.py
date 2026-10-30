"""Local development entry point: run with `python app.py`."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent


def ensure_project_python() -> None:
    """Prefer the project's virtualenv, then verify dependencies are available."""
    venv_python = PROJECT_ROOT / ".venv" / "Scripts" / "python.exe"
    if venv_python.exists() and Path(sys.executable).resolve() != venv_python.resolve():
        command = [str(venv_python), str(Path(__file__).resolve()), *sys.argv[1:]]
        try:
            result = subprocess.run(command, cwd=PROJECT_ROOT, check=False)
        except KeyboardInterrupt:
            raise SystemExit(130) from None
        raise SystemExit(result.returncode)

    try:
        import uvicorn  # noqa: F401

        return
    except ModuleNotFoundError:
        raise SystemExit("缺少后端依赖，请先在项目根目录执行：uv sync")


def main() -> None:
    ensure_project_python()
    import uvicorn

    parser = argparse.ArgumentParser(description="启动 Data Agent 后端")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--no-reload", action="store_true", help="关闭开发热更新")
    args = parser.parse_args()

    uvicorn.run(
        "backend.app.main:app",
        host=args.host,
        port=args.port,
        reload=not args.no_reload,
        app_dir=str(PROJECT_ROOT),
    )


if __name__ == "__main__":
    main()
