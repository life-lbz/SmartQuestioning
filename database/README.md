# 演示业务数据迁移

文件：`retail_demo_20261030.sql`，UTF-8，适用于 MySQL 8.0+。

## 数据口径

小型零售演示业务，非真实经营数据。固定种子 20261030，订单覆盖
2025-01-01 至 2026-10-29。包含 637 个客户、20 种商品、3,864 笔订单、
5,484 条明细；4 个区域、5 个品类。

已支付销售额 505,476.56 元，已支付订单平均客单价 149.33 元。
商品有不同的售价、成本和销售频次；低价快消商品更常见，电脑等高价商品低频购买。
包含复购、不同渠道、季节与周末差异，以及取消、退款和近期待付款记录。
金额、日期、状态和关联关系已执行校验；不是为了凑固定营收而直接缩放数字。

## 导入

**先备份目标环境。只导入新建的空数据库。** SQL 不含 `DROP`、`TRUNCATE`、
账号密码、授权语句或写死的数据库名称，不会自动覆盖现有业务表。

在 MySQL 客户端执行：

```sql
CREATE DATABASE data_agent_retail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE data_agent_retail;
SOURCE D:/uv/data_agent/database/retail_demo_20261030.sql;
```

迁移到其他机器时，将 SOURCE 路径改为实际文件位置。需要有建表和插入权限；
DDL 不是事务性的，失败时请在另一个新空库重试，不要继续使用部分导入的库。

随后将后端 `.env` 中 `BUSINESS_DB_NAME` 改为目标库名，配置目标服务器地址
及只读账号。数据库管理员应单独创建应用账号，仅授予此业务库的
`SELECT, SHOW VIEW` 权限；不要给应用 root 账号。

## 迁移范围

SQL 包含 6 张业务表的结构、索引、外键和完整数据，不包含平台用户、密码散列、
会话、收藏或审批历史。平台 SQLite 应单独使用 SQLite backup API 备份，
不能只复制正在写入的数据库文件而忽略 WAL。

本机新库：`data_agent_retail_20261030`。旧库 `data_agent_demo` 保留不变。
原平台历史保留于 `.runtime/platform/platform.sqlite3`；新平台使用
`.runtime/platform/retail-platform.sqlite3`，保留用户、收藏和审计，避免旧数据集的
查询快照误显示为新结果。新增查询会重新读取新业务库。

`retail_demo_20261030.validation.json` 记录 SHA-256、行数、金额一致性和实际
重新导入到独立校验库后的逐表内容哈希。生成脚本是
`scripts/create_retail_dataset.py`，重复执行会拒绝覆盖已经存在的目标库。

本次仅整理演示业务数据，不代表生产安全、备份恢复、容量和运维验收已经完成。

## 本机回退

旧业务库和原平台 SQLite 均未删除。需要回退时，将 `.env` 的
`BUSINESS_DB_NAME` 改回 `data_agent_demo`，启动前设置环境变量
`PLATFORM_DB_PATH=D:/uv/data_agent/.runtime/platform/platform.sqlite3`，再重启后端。
新库导出文件不受回退影响。不要在运行中直接替换 SQLite 文件。
