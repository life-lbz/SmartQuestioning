"""Create and seed the local Data Agent demo database.

Required environment variable: MYSQL_ROOT_PASSWORD
Optional: MYSQL_HOST, MYSQL_PORT, DATA_AGENT_RO_PASSWORD
"""

from __future__ import annotations

import os
import random
from datetime import date, datetime, time, timedelta
from decimal import Decimal

import pymysql


DATABASE = "data_agent_demo"
READONLY_USER = "data_agent_ro"
DEFAULT_READONLY_PASSWORD = ""


def build_seed_data() -> dict[str, list[tuple[object, ...]]]:
    rng = random.Random(20260820)
    regions = [(1, "华东"), (2, "华南"), (3, "华北"), (4, "西部")]
    categories = [
        (1, "办公设备"),
        (2, "数码配件"),
        (3, "家居用品"),
        (4, "食品饮料"),
        (5, "运动户外"),
    ]
    product_names = {
        1: ["轻薄笔记本", "商务显示器", "机械键盘", "无线鼠标"],
        2: ["移动硬盘", "降噪耳机", "多口充电器", "高清摄像头"],
        3: ["护眼台灯", "人体工学椅", "收纳套装", "恒温水杯"],
        4: ["精品咖啡豆", "每日坚果", "低糖麦片", "气泡饮料"],
        5: ["瑜伽垫", "城市背包", "运动手环", "折叠水壶"],
    }
    products: list[tuple[object, ...]] = []
    product_id = 1
    for category_id, names in product_names.items():
        for offset, name in enumerate(names):
            price = Decimal(str(79 + category_id * 53 + offset * 37))
            if name in {"轻薄笔记本", "商务显示器", "人体工学椅"}:
                price *= Decimal("8")
            cost = (price * Decimal(str(rng.uniform(0.52, 0.72)))).quantize(Decimal("0.01"))
            products.append((product_id, name, category_id, price, cost, 1))
            product_id += 1

    surnames = "王李张刘陈杨黄赵周吴徐孙马朱胡郭何高林罗"
    given_names = ["明", "华", "芳", "强", "敏", "静", "磊", "洋", "娜", "超", "宇", "婷"]
    segments = ["个人", "小微企业", "中型企业", "大型企业"]
    customers: list[tuple[object, ...]] = []
    for customer_id in range(1, 61):
        name = f"{surnames[(customer_id - 1) % len(surnames)]}{given_names[(customer_id * 7) % len(given_names)]}"
        region_id = (customer_id % 4) + 1
        segment = segments[(customer_id * 3) % len(segments)]
        registered_at = date(2024, 6, 1) + timedelta(days=rng.randint(0, 700))
        customers.append((customer_id, name, region_id, segment, registered_at))

    orders: list[tuple[object, ...]] = []
    order_items: list[tuple[object, ...]] = []
    start = date(2025, 1, 1)
    end = date(2026, 8, 20)
    date_span = (end - start).days
    channels = ["官网", "小程序", "线下门店", "企业采购"]
    statuses = ["PAID", "PAID", "PAID", "PAID", "PAID", "REFUNDED", "CANCELLED", "PENDING"]
    item_id = 1
    product_lookup = {int(row[0]): row for row in products}

    for order_id in range(1, 1501):
        customer_id = rng.randint(1, len(customers))
        created_date = start + timedelta(days=rng.randint(0, date_span))
        created_at = datetime.combine(created_date, time(rng.randint(8, 21), rng.randint(0, 59)))
        status = rng.choice(statuses)
        channel = rng.choices(channels, weights=[36, 30, 18, 16], k=1)[0]
        total = Decimal("0")
        selected_products = rng.sample(range(1, len(products) + 1), rng.randint(1, 4))
        pending_items: list[tuple[int, int, Decimal, Decimal]] = []
        for selected_id in selected_products:
            quantity = rng.randint(1, 4)
            unit_price = Decimal(product_lookup[selected_id][3])
            discount = Decimal(str(rng.choice([0, 0, 0, 0.05, 0.1, 0.15])))
            line_total = (unit_price * quantity * (Decimal("1") - discount)).quantize(
                Decimal("0.01")
            )
            total += line_total
            pending_items.append((selected_id, quantity, unit_price, discount))
        paid_at = created_at + timedelta(minutes=rng.randint(2, 240)) if status == "PAID" else None
        orders.append(
            (
                order_id,
                f"DA{created_date:%Y%m%d}{order_id:06d}",
                customer_id,
                status,
                created_at,
                paid_at,
                total,
                channel,
            )
        )
        for selected_id, quantity, unit_price, discount in pending_items:
            order_items.append(
                (item_id, order_id, selected_id, quantity, unit_price, discount)
            )
            item_id += 1

    return {
        "regions": regions,
        "categories": categories,
        "products": products,
        "customers": customers,
        "orders": orders,
        "order_items": order_items,
    }


def main() -> None:
    root_password = os.getenv("MYSQL_ROOT_PASSWORD")
    if not root_password:
        raise SystemExit("请通过 MYSQL_ROOT_PASSWORD 环境变量提供 MySQL root 密码")
    host = os.getenv("MYSQL_HOST", "127.0.0.1")
    port = int(os.getenv("MYSQL_PORT", "3306"))
    readonly_password = os.getenv("DATA_AGENT_RO_PASSWORD", DEFAULT_READONLY_PASSWORD)
    if not readonly_password:
        raise SystemExit("请通过 DATA_AGENT_RO_PASSWORD 提供只读账号密码")

    connection = pymysql.connect(
        host=host,
        port=port,
        user="root",
        password=root_password,
        charset="utf8mb4",
        autocommit=False,
    )
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                f"CREATE DATABASE IF NOT EXISTS `{DATABASE}` "
                "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
            cursor.execute(f"USE `{DATABASE}`")
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS regions (
                    id INT PRIMARY KEY,
                    name VARCHAR(32) NOT NULL UNIQUE COMMENT '销售区域'
                ) COMMENT='销售区域维表'
                """
            )
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS categories (
                    id INT PRIMARY KEY,
                    name VARCHAR(64) NOT NULL UNIQUE COMMENT '商品品类'
                ) COMMENT='商品品类维表'
                """
            )
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS customers (
                    id BIGINT PRIMARY KEY,
                    name VARCHAR(64) NOT NULL COMMENT '客户名称',
                    region_id INT NOT NULL COMMENT '所属区域',
                    segment VARCHAR(32) NOT NULL COMMENT '客户分层',
                    registered_at DATE NOT NULL COMMENT '注册日期',
                    CONSTRAINT fk_customers_region FOREIGN KEY (region_id) REFERENCES regions(id),
                    INDEX idx_customers_region (region_id),
                    INDEX idx_customers_segment (segment)
                ) COMMENT='客户维表'
                """
            )
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS products (
                    id BIGINT PRIMARY KEY,
                    name VARCHAR(128) NOT NULL COMMENT '商品名称',
                    category_id INT NOT NULL COMMENT '所属品类',
                    unit_price DECIMAL(12,2) NOT NULL COMMENT '标准售价',
                    cost_price DECIMAL(12,2) NOT NULL COMMENT '单位成本',
                    active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否在售',
                    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id),
                    INDEX idx_products_category (category_id)
                ) COMMENT='商品维表'
                """
            )
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS orders (
                    id BIGINT PRIMARY KEY,
                    order_no VARCHAR(32) NOT NULL UNIQUE COMMENT '订单编号',
                    customer_id BIGINT NOT NULL COMMENT '客户ID',
                    status VARCHAR(20) NOT NULL COMMENT '订单状态',
                    created_at DATETIME NOT NULL COMMENT '下单时间',
                    paid_at DATETIME NULL COMMENT '支付时间',
                    amount DECIMAL(14,2) NOT NULL COMMENT '订单实付金额',
                    channel VARCHAR(32) NOT NULL COMMENT '下单渠道',
                    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
                    INDEX idx_orders_created_status (created_at, status),
                    INDEX idx_orders_customer (customer_id),
                    INDEX idx_orders_channel (channel)
                ) COMMENT='订单事实表，一行代表一笔订单'
                """
            )
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS order_items (
                    id BIGINT PRIMARY KEY,
                    order_id BIGINT NOT NULL COMMENT '订单ID',
                    product_id BIGINT NOT NULL COMMENT '商品ID',
                    quantity INT NOT NULL COMMENT '购买数量',
                    unit_price DECIMAL(12,2) NOT NULL COMMENT '成交单价',
                    discount DECIMAL(5,4) NOT NULL DEFAULT 0 COMMENT '折扣比例',
                    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id),
                    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(id),
                    INDEX idx_items_order (order_id),
                    INDEX idx_items_product (product_id)
                ) COMMENT='订单商品明细表'
                """
            )

            cursor.execute("SET FOREIGN_KEY_CHECKS=0")
            for table in ("order_items", "orders", "products", "customers", "categories", "regions"):
                cursor.execute(f"TRUNCATE TABLE `{table}`")
            cursor.execute("SET FOREIGN_KEY_CHECKS=1")

            data = build_seed_data()
            cursor.executemany("INSERT INTO regions (id,name) VALUES (%s,%s)", data["regions"])
            cursor.executemany(
                "INSERT INTO categories (id,name) VALUES (%s,%s)", data["categories"]
            )
            cursor.executemany(
                "INSERT INTO customers (id,name,region_id,segment,registered_at) "
                "VALUES (%s,%s,%s,%s,%s)",
                data["customers"],
            )
            cursor.executemany(
                "INSERT INTO products "
                "(id,name,category_id,unit_price,cost_price,active) VALUES (%s,%s,%s,%s,%s,%s)",
                data["products"],
            )
            cursor.executemany(
                "INSERT INTO orders "
                "(id,order_no,customer_id,status,created_at,paid_at,amount,channel) "
                "VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                data["orders"],
            )
            cursor.executemany(
                "INSERT INTO order_items "
                "(id,order_id,product_id,quantity,unit_price,discount) "
                "VALUES (%s,%s,%s,%s,%s,%s)",
                data["order_items"],
            )

            cursor.execute(
                f"CREATE USER IF NOT EXISTS '{READONLY_USER}'@'127.0.0.1' IDENTIFIED BY %s",
                (readonly_password,),
            )
            cursor.execute(
                f"ALTER USER '{READONLY_USER}'@'127.0.0.1' IDENTIFIED BY %s",
                (readonly_password,),
            )
            cursor.execute(
                f"GRANT SELECT, SHOW VIEW ON `{DATABASE}`.* TO '{READONLY_USER}'@'127.0.0.1'"
            )
        connection.commit()
    finally:
        connection.close()

    print(f"Database: {DATABASE}")
    for table, rows in data.items():
        print(f"{table}: {len(rows)} rows")
    print(f"Read-only user: {READONLY_USER}@127.0.0.1")


if __name__ == "__main__":
    main()
