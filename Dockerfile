# 多阶段构建：前端由 node 构建，后端由 python 镜像承载
#
#   构建：  docker build -t smart-questioning .
#   运行：  docker run -p 8012:8012 -v $(pwd)/.runtime:/app/.runtime \
#                 --env-file .env smart-questioning
#
#   .runtime 里的 SQLite 与 initial-admin.txt 会持久化到宿主机卷

# -----------------------------------------------------------
# Stage 1: 构建前端（pnpm + Vite）
# -----------------------------------------------------------
FROM node:20-alpine AS frontend-build
WORKDIR /build

# 只复制锁文件和 package.json，利用 Docker 缓存层
COPY frontend-vben/package.json ./frontend-vben/package.json
COPY frontend-vben/pnpm-lock.yaml ./frontend-vben/pnpm-lock.yaml
COPY frontend-vben/pnpm-workspace.yaml ./frontend-vben/pnpm-workspace.yaml

# 先装 pnpm
RUN npm install -g pnpm@11.16.0

# 再复制其余源码，pnpm install + build
COPY frontend-vben/ ./frontend-vben/
RUN cd frontend-vben && pnpm install --frozen-lockfile && pnpm --filter @smart-questioning/web build

# -----------------------------------------------------------
# Stage 2: 最终运行镜像
# -----------------------------------------------------------
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# 装 backend 依赖
COPY pyproject.toml ./
COPY uv.lock ./
RUN pip install --upgrade pip \
 && pip install "fastapi>=0.116,<1" "httpx>=0.28,<1" "pydantic-settings>=2.10,<3" \
                "pymysql>=1.1,<2" "sqlalchemy>=2.0,<3" "sqlglot>=27,<30" \
                "uvicorn[standard]>=0.35,<1"

# 复制后端与前端构建产物
COPY backend ./backend
COPY commercial ./commercial
COPY database ./database
COPY scripts ./scripts
COPY start_business.py ./

COPY --from=frontend-build /build/frontend-vben/apps/web-business/dist \
     ./frontend-vben/apps/web-business/dist

EXPOSE 8012

# 启动前显式检查 dist 和依赖
CMD ["python", "start_business.py", "--host", "0.0.0.0", "--port", "8012"]
