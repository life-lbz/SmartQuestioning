# Vben Admin 工作台

## 入口

- 新后台：http://127.0.0.1:5180（官方 Vben Admin / Ant Design Vue 工作区）
- 后端：http://127.0.0.1:8011/docs
- `npm run dev` 已切换到新后台；`npm run dev:legacy` 仍运行旧界面。
- 新源码：`D:/uv/data_agent/frontend-vben/apps/web-antd/src/views/data-agent/`
- 官方来源：https://github.com/vbenjs/vue-vben-admin ，保留 MIT 许可。

## 本地重启

当前旧 `.venv` 的解释器指向另一台电脑。当前机器使用系统 Python 加载现有依赖：

```powershell
cd D:\uv\data_agent
$env:PYTHONPATH="$PWD\.venv\Lib\site-packages"
python -m uvicorn backend.app.main:app --host 127.0.0.1 --port 8011
# 另开终端
npm run dev
```

首次重新安装 Vben 工作区：

```powershell
cd D:\uv\data_agent\frontend-vben
pnpm install --ignore-scripts --no-frozen-lockfile
pnpm --filter @vben/node-utils stub
pnpm --filter @vben/vite-config stub
pnpm --filter @vben-core/shared stub
pnpm --filter @vben/web-antd dev
```

## 数据

本次仅追加演示数据，没有调用会清空表的初始化入口。

| 表 | 扩容前 | 扩容后 |
|---|---:|---:|
| regions | 4 | 4 |
| categories | 5 | 5 |
| products | 20 | 20 |
| customers | 60 | 2,000 |
| orders | 1,500 | 50,000 |
| order_items | 3,734 | 125,318 |
| 合计 | 5,323 | 177,347 |

时间范围扩展到 2026-10-30；全部为合成演示数据，不代表真实经营情况。
原始数据快照：`D:/uv/data_agent/.runtime/vben-migration/database-before.json`。
追加程序：`D:/uv/data_agent/scripts/expand_demo_database.py`，要求显式提供 `MYSQL_ROOT_PASSWORD`。
重复执行新增 0 行；原记录不覆盖，订单关联和金额汇总均检查通过。

## 验证与边界

验证记录、截图、种子补丁和回滚脚本位于 `D:/uv/data_agent/.runtime/vben-migration/`。
`ROLLBACK.sh TARGET_COPY` 只恢复指定种子文件副本，不回滚在线数据库。
SQL 白名单、成本检查、审批及只读数据库账户保持原有后端实现。
沿用原本无登录的本地 MVP 工作方式；不要直接公开到外网。
