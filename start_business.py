"""Run the built Smart Questioning platform without the development Vite server.

任何可用的 Python 环境（conda、uv venv、pip venv）都能直接执行本脚本，
不再依赖特定的虚拟环境路径。前提是 backend/commercial 依赖已安装，
且 ``frontend-vben/apps/web-business/dist/index.html`` 存在。
"""
from pathlib import Path
import argparse
import sys

ROOT = Path(__file__).resolve().parent

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Smart Questioning 企业数据平台（生产模式）')
    parser.add_argument('--port', type=int, default=8012)
    parser.add_argument('--host', default='0.0.0.0')
    args = parser.parse_args()

    dist = ROOT / 'frontend-vben' / 'apps' / 'web-business' / 'dist' / 'index.html'
    if not dist.exists():
        raise SystemExit('请先执行 npm run build:business 构建前端')

    runtime_db = ROOT / '.runtime' / 'platform' / 'initial-admin.txt'
    if runtime_db.exists():
        print('管理员初始凭据（仅首次创建时生成）：' + str(runtime_db))

    try:
        import uvicorn
    except ImportError:
        raise SystemExit('请先安装后端依赖（pip install -e . 或 uv sync）')

    sys.path.insert(0, str(ROOT))
    uvicorn.run(
        'commercial.main:app',
        host=args.host,
        port=args.port,
        app_dir=str(ROOT),
        access_log=False,
    )
