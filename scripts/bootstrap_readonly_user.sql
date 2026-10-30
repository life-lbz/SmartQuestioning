-- 请使用管理员账号手工执行，并先替换数据库名与随机强密码。
-- root/root 仅用于本机初始化，不得写入应用配置。
CREATE USER IF NOT EXISTS 'data_agent_ro'@'127.0.0.1'
IDENTIFIED BY 'REPLACE_WITH_A_RANDOM_STRONG_PASSWORD';

GRANT SELECT, SHOW VIEW
ON replace_with_business_database.*
TO 'data_agent_ro'@'127.0.0.1';

FLUSH PRIVILEGES;
