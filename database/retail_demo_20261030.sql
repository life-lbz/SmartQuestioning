-- Synthetic small-retailer demo. UTF-8. MySQL 8.0+.
-- Import into a NEW EMPTY database; no users, secrets, DROP or TRUNCATE.
-- Cutoff 2026-10-29; seed 20261030.
SET NAMES utf8mb4;

CREATE TABLE `regions` (
  `id` int(11) NOT NULL,
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '销售区域',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='销售区域维表';

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品品类',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品品类维表';

CREATE TABLE `products` (
  `id` bigint(20) NOT NULL,
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称',
  `category_id` int(11) NOT NULL COMMENT '所属品类',
  `unit_price` decimal(12,2) NOT NULL COMMENT '标准售价',
  `cost_price` decimal(12,2) NOT NULL COMMENT '单位成本',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否在售',
  PRIMARY KEY (`id`),
  KEY `idx_products_category` (`category_id`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品维表';

CREATE TABLE `customers` (
  `id` bigint(20) NOT NULL,
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '客户名称',
  `region_id` int(11) NOT NULL COMMENT '所属区域',
  `segment` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '客户分层',
  `registered_at` date NOT NULL COMMENT '注册日期',
  PRIMARY KEY (`id`),
  KEY `idx_customers_region` (`region_id`),
  KEY `idx_customers_segment` (`segment`),
  CONSTRAINT `fk_customers_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户维表';

CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL,
  `order_no` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint(20) NOT NULL COMMENT '客户ID',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单状态',
  `created_at` datetime NOT NULL COMMENT '下单时间',
  `paid_at` datetime DEFAULT NULL COMMENT '支付时间',
  `amount` decimal(14,2) NOT NULL COMMENT '订单实付金额',
  `channel` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '下单渠道',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `idx_orders_created_status` (`created_at`,`status`),
  KEY `idx_orders_customer` (`customer_id`),
  KEY `idx_orders_channel` (`channel`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单事实表，一行代表一笔订单';

CREATE TABLE `order_items` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `quantity` int(11) NOT NULL COMMENT '购买数量',
  `unit_price` decimal(12,2) NOT NULL COMMENT '成交单价',
  `discount` decimal(5,4) NOT NULL DEFAULT '0.0000' COMMENT '折扣比例',
  PRIMARY KEY (`id`),
  KEY `idx_items_order` (`order_id`),
  KEY `idx_items_product` (`product_id`),
  CONSTRAINT `fk_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单商品明细表';

START TRANSACTION;

INSERT INTO `regions` VALUES (1,'华东');

INSERT INTO `regions` VALUES (2,'华南');

INSERT INTO `regions` VALUES (3,'华北');

INSERT INTO `regions` VALUES (4,'西部');

INSERT INTO `categories` VALUES (1,'办公设备');

INSERT INTO `categories` VALUES (2,'数码配件');

INSERT INTO `categories` VALUES (3,'家居用品');

INSERT INTO `categories` VALUES (4,'食品饮料');

INSERT INTO `categories` VALUES (5,'运动户外');

INSERT INTO `products` VALUES (1,'轻薄笔记本',1,4299,2876.31,1);

INSERT INTO `products` VALUES (2,'商务显示器',1,899,604.17,1);

INSERT INTO `products` VALUES (3,'机械键盘',1,169,123.89,1);

INSERT INTO `products` VALUES (4,'无线鼠标',1,59,33.48,1);

INSERT INTO `products` VALUES (5,'移动硬盘',2,399,286.74,1);

INSERT INTO `products` VALUES (6,'降噪耳机',2,299,202.79,1);

INSERT INTO `products` VALUES (7,'多口充电器',2,89,54.50,1);

INSERT INTO `products` VALUES (8,'高清摄像头',2,159,97.63,1);

INSERT INTO `products` VALUES (9,'护眼台灯',3,129,80.99,1);

INSERT INTO `products` VALUES (10,'人体工学椅',3,699,449.11,1);

INSERT INTO `products` VALUES (11,'收纳套装',3,39,29.48,1);

INSERT INTO `products` VALUES (12,'恒温水杯',3,79,46.58,1);

INSERT INTO `products` VALUES (13,'精品咖啡豆',4,68,39.21,1);

INSERT INTO `products` VALUES (14,'每日坚果',4,39.9,24.61,1);

INSERT INTO `products` VALUES (15,'低糖麦片',4,32.9,22.85,1);

INSERT INTO `products` VALUES (16,'气泡饮料',4,24.9,18.53,1);

INSERT INTO `products` VALUES (17,'瑜伽垫',5,69,44.73,1);

INSERT INTO `products` VALUES (18,'城市背包',5,159,102.28,1);

INSERT INTO `products` VALUES (19,'运动手环',5,199,124.34,1);

INSERT INTO `products` VALUES (20,'折叠水壶',5,39,29.46,1);

INSERT INTO `customers` VALUES (1,'演示客户0001',1,'个人','2025-07-03');

INSERT INTO `customers` VALUES (2,'演示客户0002',2,'个人','2025-03-10');

INSERT INTO `customers` VALUES (3,'演示客户0003',1,'个人','2026-03-05');

INSERT INTO `customers` VALUES (4,'演示客户0004',2,'个人','2026-02-13');

INSERT INTO `customers` VALUES (5,'演示客户0005',1,'个人','2026-03-12');

INSERT INTO `customers` VALUES (6,'演示客户0006',1,'个人','2025-08-08');

INSERT INTO `customers` VALUES (7,'演示客户0007',1,'个人','2025-10-13');

INSERT INTO `customers` VALUES (8,'演示客户0008',4,'个人','2025-01-09');

INSERT INTO `customers` VALUES (9,'演示客户0009',4,'个人','2025-08-17');

INSERT INTO `customers` VALUES (10,'演示客户0010',3,'小微企业','2025-01-18');

INSERT INTO `customers` VALUES (11,'演示客户0011',4,'个人','2025-01-09');

INSERT INTO `customers` VALUES (12,'演示客户0012',1,'个人','2025-06-12');

INSERT INTO `customers` VALUES (13,'演示客户0013',3,'个人','2025-04-29');

INSERT INTO `customers` VALUES (14,'演示客户0014',3,'个人','2025-04-08');

INSERT INTO `customers` VALUES (15,'演示客户0015',2,'个人','2025-03-17');

INSERT INTO `customers` VALUES (16,'演示客户0016',3,'个人','2026-04-05');

INSERT INTO `customers` VALUES (17,'演示客户0017',4,'个人','2025-01-15');

INSERT INTO `customers` VALUES (18,'演示客户0018',2,'个人','2026-01-04');

INSERT INTO `customers` VALUES (19,'演示客户0019',1,'个人','2025-12-26');

INSERT INTO `customers` VALUES (20,'演示客户0020',1,'个人','2025-10-13');

INSERT INTO `customers` VALUES (21,'演示客户0021',4,'个人','2026-05-19');

INSERT INTO `customers` VALUES (22,'演示客户0022',3,'个人','2025-04-30');

INSERT INTO `customers` VALUES (23,'演示客户0023',1,'个人','2025-03-11');

INSERT INTO `customers` VALUES (24,'演示客户0024',1,'个人','2025-11-01');

INSERT INTO `customers` VALUES (25,'演示客户0025',1,'个人','2026-02-19');

INSERT INTO `customers` VALUES (26,'演示客户0026',4,'小微企业','2025-07-07');

INSERT INTO `customers` VALUES (27,'演示客户0027',4,'个人','2025-11-29');

INSERT INTO `customers` VALUES (28,'演示客户0028',1,'个人','2025-03-10');

INSERT INTO `customers` VALUES (29,'演示客户0029',4,'小微企业','2025-04-30');

INSERT INTO `customers` VALUES (30,'演示客户0030',1,'个人','2026-04-09');

INSERT INTO `customers` VALUES (31,'演示客户0031',1,'个人','2025-02-22');

INSERT INTO `customers` VALUES (32,'演示客户0032',2,'个人','2024-12-10');

INSERT INTO `customers` VALUES (33,'演示客户0033',3,'小微企业','2025-01-27');

INSERT INTO `customers` VALUES (34,'演示客户0034',2,'个人','2025-01-03');

INSERT INTO `customers` VALUES (35,'演示客户0035',2,'个人','2025-02-14');

INSERT INTO `customers` VALUES (36,'演示客户0036',3,'小微企业','2025-05-30');

INSERT INTO `customers` VALUES (37,'演示客户0037',2,'个人','2025-03-16');

INSERT INTO `customers` VALUES (38,'演示客户0038',3,'个人','2025-11-02');

INSERT INTO `customers` VALUES (39,'演示客户0039',4,'个人','2025-12-24');

INSERT INTO `customers` VALUES (40,'演示客户0040',1,'个人','2025-02-28');

INSERT INTO `customers` VALUES (41,'演示客户0041',2,'小微企业','2026-01-23');

INSERT INTO `customers` VALUES (42,'演示客户0042',1,'个人','2025-01-06');

INSERT INTO `customers` VALUES (43,'演示客户0043',1,'个人','2025-04-20');

INSERT INTO `customers` VALUES (44,'演示客户0044',1,'个人','2025-06-25');

INSERT INTO `customers` VALUES (45,'演示客户0045',1,'个人','2025-10-17');

INSERT INTO `customers` VALUES (46,'演示客户0046',2,'个人','2026-05-09');

INSERT INTO `customers` VALUES (47,'演示客户0047',4,'个人','2025-02-26');

INSERT INTO `customers` VALUES (48,'演示客户0048',1,'个人','2026-01-07');

INSERT INTO `customers` VALUES (49,'演示客户0049',3,'个人','2025-02-15');

INSERT INTO `customers` VALUES (50,'演示客户0050',1,'个人','2024-12-20');

INSERT INTO `customers` VALUES (51,'演示客户0051',3,'小微企业','2025-07-15');

INSERT INTO `customers` VALUES (52,'演示客户0052',4,'个人','2025-10-29');

INSERT INTO `customers` VALUES (53,'演示客户0053',3,'个人','2025-11-17');

INSERT INTO `customers` VALUES (54,'演示客户0054',2,'个人','2025-08-18');

INSERT INTO `customers` VALUES (55,'演示客户0055',3,'个人','2026-06-21');

INSERT INTO `customers` VALUES (56,'演示客户0056',1,'个人','2025-09-14');

INSERT INTO `customers` VALUES (57,'演示客户0057',3,'个人','2025-02-03');

INSERT INTO `customers` VALUES (58,'演示客户0058',3,'中型企业','2025-12-15');

INSERT INTO `customers` VALUES (59,'演示客户0059',1,'个人','2026-04-28');

INSERT INTO `customers` VALUES (60,'演示客户0060',2,'个人','2024-10-22');

INSERT INTO `customers` VALUES (61,'演示客户0061',2,'个人','2025-07-19');

INSERT INTO `customers` VALUES (62,'演示客户0062',3,'个人','2025-06-15');

INSERT INTO `customers` VALUES (63,'演示客户0063',2,'小微企业','2026-03-26');

INSERT INTO `customers` VALUES (64,'演示客户0064',1,'个人','2025-02-28');

INSERT INTO `customers` VALUES (65,'演示客户0065',2,'小微企业','2025-11-21');

INSERT INTO `customers` VALUES (66,'演示客户0066',4,'个人','2024-12-31');

INSERT INTO `customers` VALUES (67,'演示客户0067',3,'个人','2025-06-16');

INSERT INTO `customers` VALUES (68,'演示客户0068',1,'个人','2025-03-15');

INSERT INTO `customers` VALUES (69,'演示客户0069',1,'个人','2025-12-17');

INSERT INTO `customers` VALUES (70,'演示客户0070',3,'个人','2026-03-17');

INSERT INTO `customers` VALUES (71,'演示客户0071',2,'个人','2025-09-27');

INSERT INTO `customers` VALUES (72,'演示客户0072',3,'中型企业','2025-05-02');

INSERT INTO `customers` VALUES (73,'演示客户0073',4,'个人','2026-05-10');

INSERT INTO `customers` VALUES (74,'演示客户0074',4,'个人','2025-04-04');

INSERT INTO `customers` VALUES (75,'演示客户0075',3,'个人','2026-04-23');

INSERT INTO `customers` VALUES (76,'演示客户0076',1,'个人','2026-05-01');

INSERT INTO `customers` VALUES (77,'演示客户0077',1,'小微企业','2025-07-14');

INSERT INTO `customers` VALUES (78,'演示客户0078',1,'个人','2025-10-20');

INSERT INTO `customers` VALUES (79,'演示客户0079',1,'个人','2024-12-25');

INSERT INTO `customers` VALUES (80,'演示客户0080',3,'个人','2026-03-09');

INSERT INTO `customers` VALUES (81,'演示客户0081',3,'小微企业','2025-07-25');

INSERT INTO `customers` VALUES (82,'演示客户0082',3,'个人','2025-01-31');

INSERT INTO `customers` VALUES (83,'演示客户0083',3,'个人','2025-07-13');

INSERT INTO `customers` VALUES (84,'演示客户0084',4,'个人','2026-02-18');

INSERT INTO `customers` VALUES (85,'演示客户0085',2,'个人','2025-11-28');

INSERT INTO `customers` VALUES (86,'演示客户0086',1,'个人','2025-03-20');

INSERT INTO `customers` VALUES (87,'演示客户0087',1,'个人','2025-08-28');

INSERT INTO `customers` VALUES (88,'演示客户0088',2,'个人','2025-10-20');

INSERT INTO `customers` VALUES (89,'演示客户0089',3,'个人','2025-10-27');

INSERT INTO `customers` VALUES (90,'演示客户0090',3,'个人','2024-12-31');

INSERT INTO `customers` VALUES (91,'演示客户0091',1,'小微企业','2025-07-17');

INSERT INTO `customers` VALUES (92,'演示客户0092',4,'个人','2025-08-03');

INSERT INTO `customers` VALUES (93,'演示客户0093',2,'个人','2025-11-10');

INSERT INTO `customers` VALUES (94,'演示客户0094',2,'个人','2025-06-17');

INSERT INTO `customers` VALUES (95,'演示客户0095',2,'小微企业','2025-02-28');

INSERT INTO `customers` VALUES (96,'演示客户0096',2,'小微企业','2025-03-26');

INSERT INTO `customers` VALUES (97,'演示客户0097',1,'个人','2025-05-13');

INSERT INTO `customers` VALUES (98,'演示客户0098',1,'个人','2026-05-03');

INSERT INTO `customers` VALUES (99,'演示客户0099',2,'个人','2024-11-30');

INSERT INTO `customers` VALUES (100,'演示客户0100',1,'个人','2025-06-25');

INSERT INTO `customers` VALUES (101,'演示客户0101',1,'个人','2025-10-22');

INSERT INTO `customers` VALUES (102,'演示客户0102',3,'个人','2025-12-26');

INSERT INTO `customers` VALUES (103,'演示客户0103',1,'个人','2026-01-03');

INSERT INTO `customers` VALUES (104,'演示客户0104',2,'个人','2025-01-26');

INSERT INTO `customers` VALUES (105,'演示客户0105',2,'小微企业','2025-09-27');

INSERT INTO `customers` VALUES (106,'演示客户0106',3,'个人','2025-07-03');

INSERT INTO `customers` VALUES (107,'演示客户0107',1,'个人','2025-02-18');

INSERT INTO `customers` VALUES (108,'演示客户0108',2,'个人','2025-10-28');

INSERT INTO `customers` VALUES (109,'演示客户0109',2,'小微企业','2025-03-20');

INSERT INTO `customers` VALUES (110,'演示客户0110',1,'个人','2025-10-12');

INSERT INTO `customers` VALUES (111,'演示客户0111',2,'个人','2024-10-16');

INSERT INTO `customers` VALUES (112,'演示客户0112',2,'个人','2025-09-30');

INSERT INTO `customers` VALUES (113,'演示客户0113',1,'个人','2026-06-05');

INSERT INTO `customers` VALUES (114,'演示客户0114',1,'个人','2025-05-16');

INSERT INTO `customers` VALUES (115,'演示客户0115',1,'个人','2025-05-08');

INSERT INTO `customers` VALUES (116,'演示客户0116',1,'个人','2025-06-07');

INSERT INTO `customers` VALUES (117,'演示客户0117',1,'个人','2025-10-21');

INSERT INTO `customers` VALUES (118,'演示客户0118',2,'个人','2026-01-06');

INSERT INTO `customers` VALUES (119,'演示客户0119',3,'个人','2026-04-14');

INSERT INTO `customers` VALUES (120,'演示客户0120',1,'个人','2026-06-10');

INSERT INTO `customers` VALUES (121,'演示客户0121',1,'个人','2025-09-14');

INSERT INTO `customers` VALUES (122,'演示客户0122',1,'个人','2025-09-29');

INSERT INTO `customers` VALUES (123,'演示客户0123',1,'个人','2025-04-02');

INSERT INTO `customers` VALUES (124,'演示客户0124',1,'个人','2025-08-28');

INSERT INTO `customers` VALUES (125,'演示客户0125',1,'个人','2024-12-02');

INSERT INTO `customers` VALUES (126,'演示客户0126',1,'个人','2025-07-18');

INSERT INTO `customers` VALUES (127,'演示客户0127',1,'个人','2025-05-28');

INSERT INTO `customers` VALUES (128,'演示客户0128',1,'个人','2026-05-05');

INSERT INTO `customers` VALUES (129,'演示客户0129',1,'个人','2024-12-05');

INSERT INTO `customers` VALUES (130,'演示客户0130',1,'个人','2025-06-05');

INSERT INTO `customers` VALUES (131,'演示客户0131',2,'个人','2025-02-27');

INSERT INTO `customers` VALUES (132,'演示客户0132',1,'个人','2026-03-22');

INSERT INTO `customers` VALUES (133,'演示客户0133',2,'个人','2025-08-18');

INSERT INTO `customers` VALUES (134,'演示客户0134',1,'个人','2026-02-01');

INSERT INTO `customers` VALUES (135,'演示客户0135',1,'个人','2026-02-14');

INSERT INTO `customers` VALUES (136,'演示客户0136',1,'个人','2025-07-16');

INSERT INTO `customers` VALUES (137,'演示客户0137',2,'个人','2025-06-02');

INSERT INTO `customers` VALUES (138,'演示客户0138',1,'个人','2025-09-15');

INSERT INTO `customers` VALUES (139,'演示客户0139',1,'小微企业','2025-08-15');

INSERT INTO `customers` VALUES (140,'演示客户0140',1,'小微企业','2025-08-08');

INSERT INTO `customers` VALUES (141,'演示客户0141',1,'个人','2025-10-20');

INSERT INTO `customers` VALUES (142,'演示客户0142',2,'个人','2025-07-28');

INSERT INTO `customers` VALUES (143,'演示客户0143',3,'个人','2025-04-13');

INSERT INTO `customers` VALUES (144,'演示客户0144',3,'个人','2025-09-22');

INSERT INTO `customers` VALUES (145,'演示客户0145',1,'小微企业','2025-07-15');

INSERT INTO `customers` VALUES (146,'演示客户0146',3,'个人','2025-02-27');

INSERT INTO `customers` VALUES (147,'演示客户0147',3,'个人','2025-07-02');

INSERT INTO `customers` VALUES (148,'演示客户0148',4,'小微企业','2025-07-26');

INSERT INTO `customers` VALUES (149,'演示客户0149',2,'个人','2025-05-16');

INSERT INTO `customers` VALUES (150,'演示客户0150',2,'个人','2026-01-14');

INSERT INTO `customers` VALUES (151,'演示客户0151',1,'个人','2025-05-22');

INSERT INTO `customers` VALUES (152,'演示客户0152',1,'个人','2026-02-08');

INSERT INTO `customers` VALUES (153,'演示客户0153',1,'个人','2025-03-24');

INSERT INTO `customers` VALUES (154,'演示客户0154',3,'个人','2024-12-02');

INSERT INTO `customers` VALUES (155,'演示客户0155',1,'个人','2026-01-24');

INSERT INTO `customers` VALUES (156,'演示客户0156',1,'个人','2025-05-23');

INSERT INTO `customers` VALUES (157,'演示客户0157',2,'中型企业','2025-05-30');

INSERT INTO `customers` VALUES (158,'演示客户0158',3,'个人','2025-11-08');

INSERT INTO `customers` VALUES (159,'演示客户0159',1,'个人','2025-08-09');

INSERT INTO `customers` VALUES (160,'演示客户0160',3,'个人','2025-11-01');

INSERT INTO `customers` VALUES (161,'演示客户0161',2,'个人','2025-12-22');

INSERT INTO `customers` VALUES (162,'演示客户0162',2,'个人','2025-09-10');

INSERT INTO `customers` VALUES (163,'演示客户0163',2,'个人','2025-05-24');

INSERT INTO `customers` VALUES (164,'演示客户0164',1,'个人','2025-05-09');

INSERT INTO `customers` VALUES (165,'演示客户0165',4,'个人','2025-04-11');

INSERT INTO `customers` VALUES (166,'演示客户0166',3,'个人','2025-02-26');

INSERT INTO `customers` VALUES (167,'演示客户0167',1,'个人','2025-04-03');

INSERT INTO `customers` VALUES (168,'演示客户0168',2,'个人','2025-08-02');

INSERT INTO `customers` VALUES (169,'演示客户0169',3,'个人','2025-05-27');

INSERT INTO `customers` VALUES (170,'演示客户0170',1,'个人','2025-09-19');

INSERT INTO `customers` VALUES (171,'演示客户0171',3,'个人','2025-07-15');

INSERT INTO `customers` VALUES (172,'演示客户0172',2,'小微企业','2025-05-06');

INSERT INTO `customers` VALUES (173,'演示客户0173',3,'个人','2025-10-29');

INSERT INTO `customers` VALUES (174,'演示客户0174',1,'个人','2025-06-12');

INSERT INTO `customers` VALUES (175,'演示客户0175',1,'个人','2025-03-01');

INSERT INTO `customers` VALUES (176,'演示客户0176',3,'个人','2025-03-22');

INSERT INTO `customers` VALUES (177,'演示客户0177',1,'个人','2025-04-10');

INSERT INTO `customers` VALUES (178,'演示客户0178',1,'个人','2024-12-12');

INSERT INTO `customers` VALUES (179,'演示客户0179',4,'个人','2025-05-20');

INSERT INTO `customers` VALUES (180,'演示客户0180',2,'个人','2025-04-13');

INSERT INTO `customers` VALUES (181,'演示客户0181',3,'个人','2026-02-15');

INSERT INTO `customers` VALUES (182,'演示客户0182',2,'个人','2025-02-08');

INSERT INTO `customers` VALUES (183,'演示客户0183',1,'个人','2025-07-22');

INSERT INTO `customers` VALUES (184,'演示客户0184',1,'个人','2025-04-18');

INSERT INTO `customers` VALUES (185,'演示客户0185',2,'个人','2025-07-13');

INSERT INTO `customers` VALUES (186,'演示客户0186',1,'个人','2025-04-04');

INSERT INTO `customers` VALUES (187,'演示客户0187',1,'小微企业','2025-04-04');

INSERT INTO `customers` VALUES (188,'演示客户0188',1,'小微企业','2025-11-25');

INSERT INTO `customers` VALUES (189,'演示客户0189',4,'个人','2026-02-28');

INSERT INTO `customers` VALUES (190,'演示客户0190',1,'个人','2025-04-02');

INSERT INTO `customers` VALUES (191,'演示客户0191',2,'个人','2026-02-03');

INSERT INTO `customers` VALUES (192,'演示客户0192',1,'个人','2025-05-06');

INSERT INTO `customers` VALUES (193,'演示客户0193',1,'个人','2024-12-05');

INSERT INTO `customers` VALUES (194,'演示客户0194',2,'个人','2026-03-09');

INSERT INTO `customers` VALUES (195,'演示客户0195',1,'个人','2025-11-28');

INSERT INTO `customers` VALUES (196,'演示客户0196',1,'个人','2025-01-18');

INSERT INTO `customers` VALUES (197,'演示客户0197',2,'个人','2025-02-20');

INSERT INTO `customers` VALUES (198,'演示客户0198',3,'个人','2026-01-25');

INSERT INTO `customers` VALUES (199,'演示客户0199',3,'小微企业','2025-04-07');

INSERT INTO `customers` VALUES (200,'演示客户0200',4,'个人','2026-01-18');

INSERT INTO `customers` VALUES (201,'演示客户0201',3,'个人','2026-04-17');

INSERT INTO `customers` VALUES (202,'演示客户0202',3,'个人','2025-04-27');

INSERT INTO `customers` VALUES (203,'演示客户0203',2,'个人','2026-01-27');

INSERT INTO `customers` VALUES (204,'演示客户0204',2,'小微企业','2025-04-23');

INSERT INTO `customers` VALUES (205,'演示客户0205',1,'个人','2025-04-30');

INSERT INTO `customers` VALUES (206,'演示客户0206',3,'个人','2025-10-03');

INSERT INTO `customers` VALUES (207,'演示客户0207',4,'个人','2025-02-05');

INSERT INTO `customers` VALUES (208,'演示客户0208',1,'个人','2025-09-22');

INSERT INTO `customers` VALUES (209,'演示客户0209',1,'个人','2025-11-04');

INSERT INTO `customers` VALUES (210,'演示客户0210',1,'个人','2025-02-11');

INSERT INTO `customers` VALUES (211,'演示客户0211',2,'个人','2025-11-06');

INSERT INTO `customers` VALUES (212,'演示客户0212',3,'小微企业','2026-01-30');

INSERT INTO `customers` VALUES (213,'演示客户0213',1,'个人','2025-12-10');

INSERT INTO `customers` VALUES (214,'演示客户0214',3,'个人','2025-09-11');

INSERT INTO `customers` VALUES (215,'演示客户0215',4,'个人','2026-05-03');

INSERT INTO `customers` VALUES (216,'演示客户0216',2,'小微企业','2024-12-31');

INSERT INTO `customers` VALUES (217,'演示客户0217',2,'个人','2025-04-29');

INSERT INTO `customers` VALUES (218,'演示客户0218',3,'个人','2025-05-04');

INSERT INTO `customers` VALUES (219,'演示客户0219',2,'个人','2025-01-18');

INSERT INTO `customers` VALUES (220,'演示客户0220',2,'小微企业','2026-05-01');

INSERT INTO `customers` VALUES (221,'演示客户0221',1,'个人','2025-09-20');

INSERT INTO `customers` VALUES (222,'演示客户0222',2,'个人','2025-08-12');

INSERT INTO `customers` VALUES (223,'演示客户0223',2,'个人','2026-04-26');

INSERT INTO `customers` VALUES (224,'演示客户0224',1,'小微企业','2025-09-22');

INSERT INTO `customers` VALUES (225,'演示客户0225',1,'个人','2025-08-06');

INSERT INTO `customers` VALUES (226,'演示客户0226',3,'个人','2024-11-27');

INSERT INTO `customers` VALUES (227,'演示客户0227',1,'小微企业','2025-06-14');

INSERT INTO `customers` VALUES (228,'演示客户0228',1,'小微企业','2025-06-11');

INSERT INTO `customers` VALUES (229,'演示客户0229',3,'个人','2025-06-23');

INSERT INTO `customers` VALUES (230,'演示客户0230',4,'小微企业','2026-04-05');

INSERT INTO `customers` VALUES (231,'演示客户0231',3,'个人','2025-11-25');

INSERT INTO `customers` VALUES (232,'演示客户0232',1,'个人','2025-08-04');

INSERT INTO `customers` VALUES (233,'演示客户0233',4,'个人','2025-04-07');

INSERT INTO `customers` VALUES (234,'演示客户0234',1,'个人','2024-10-26');

INSERT INTO `customers` VALUES (235,'演示客户0235',2,'个人','2025-04-23');

INSERT INTO `customers` VALUES (236,'演示客户0236',1,'个人','2025-08-13');

INSERT INTO `customers` VALUES (237,'演示客户0237',1,'个人','2025-07-05');

INSERT INTO `customers` VALUES (238,'演示客户0238',1,'个人','2025-08-08');

INSERT INTO `customers` VALUES (239,'演示客户0239',2,'个人','2025-02-27');

INSERT INTO `customers` VALUES (240,'演示客户0240',2,'个人','2025-10-26');

INSERT INTO `customers` VALUES (241,'演示客户0241',2,'个人','2024-11-24');

INSERT INTO `customers` VALUES (242,'演示客户0242',3,'个人','2026-02-05');

INSERT INTO `customers` VALUES (243,'演示客户0243',4,'个人','2025-10-28');

INSERT INTO `customers` VALUES (244,'演示客户0244',1,'个人','2025-03-08');

INSERT INTO `customers` VALUES (245,'演示客户0245',2,'个人','2025-07-11');

INSERT INTO `customers` VALUES (246,'演示客户0246',2,'个人','2025-09-13');

INSERT INTO `customers` VALUES (247,'演示客户0247',2,'个人','2025-09-11');

INSERT INTO `customers` VALUES (248,'演示客户0248',1,'中型企业','2025-08-29');

INSERT INTO `customers` VALUES (249,'演示客户0249',4,'小微企业','2026-03-13');

INSERT INTO `customers` VALUES (250,'演示客户0250',2,'个人','2025-09-30');

INSERT INTO `customers` VALUES (251,'演示客户0251',1,'个人','2025-06-20');

INSERT INTO `customers` VALUES (252,'演示客户0252',1,'个人','2025-12-11');

INSERT INTO `customers` VALUES (253,'演示客户0253',3,'个人','2024-12-30');

INSERT INTO `customers` VALUES (254,'演示客户0254',2,'个人','2025-01-15');

INSERT INTO `customers` VALUES (255,'演示客户0255',2,'个人','2025-01-29');

INSERT INTO `customers` VALUES (256,'演示客户0256',1,'个人','2025-02-15');

INSERT INTO `customers` VALUES (257,'演示客户0257',4,'个人','2025-06-01');

INSERT INTO `customers` VALUES (258,'演示客户0258',2,'个人','2025-03-23');

INSERT INTO `customers` VALUES (259,'演示客户0259',1,'个人','2025-01-19');

INSERT INTO `customers` VALUES (260,'演示客户0260',1,'个人','2025-01-11');

INSERT INTO `customers` VALUES (261,'演示客户0261',3,'个人','2025-04-15');

INSERT INTO `customers` VALUES (262,'演示客户0262',4,'个人','2025-10-22');

INSERT INTO `customers` VALUES (263,'演示客户0263',1,'个人','2026-03-03');

INSERT INTO `customers` VALUES (264,'演示客户0264',4,'小微企业','2025-11-18');

INSERT INTO `customers` VALUES (265,'演示客户0265',2,'个人','2025-01-07');

INSERT INTO `customers` VALUES (266,'演示客户0266',1,'个人','2026-01-30');

INSERT INTO `customers` VALUES (267,'演示客户0267',2,'个人','2026-05-19');

INSERT INTO `customers` VALUES (268,'演示客户0268',3,'个人','2025-01-02');

INSERT INTO `customers` VALUES (269,'演示客户0269',2,'个人','2025-12-31');

INSERT INTO `customers` VALUES (270,'演示客户0270',1,'个人','2025-07-23');

INSERT INTO `customers` VALUES (271,'演示客户0271',1,'个人','2025-03-25');

INSERT INTO `customers` VALUES (272,'演示客户0272',2,'个人','2025-03-03');

INSERT INTO `customers` VALUES (273,'演示客户0273',1,'个人','2025-10-26');

INSERT INTO `customers` VALUES (274,'演示客户0274',1,'个人','2026-03-22');

INSERT INTO `customers` VALUES (275,'演示客户0275',2,'个人','2025-06-03');

INSERT INTO `customers` VALUES (276,'演示客户0276',4,'小微企业','2026-02-14');

INSERT INTO `customers` VALUES (277,'演示客户0277',1,'个人','2025-08-09');

INSERT INTO `customers` VALUES (278,'演示客户0278',3,'个人','2025-08-29');

INSERT INTO `customers` VALUES (279,'演示客户0279',3,'个人','2025-08-14');

INSERT INTO `customers` VALUES (280,'演示客户0280',3,'个人','2025-12-28');

INSERT INTO `customers` VALUES (281,'演示客户0281',2,'个人','2025-10-25');

INSERT INTO `customers` VALUES (282,'演示客户0282',2,'小微企业','2026-03-27');

INSERT INTO `customers` VALUES (283,'演示客户0283',1,'个人','2025-12-02');

INSERT INTO `customers` VALUES (284,'演示客户0284',4,'个人','2026-04-13');

INSERT INTO `customers` VALUES (285,'演示客户0285',3,'个人','2025-08-21');

INSERT INTO `customers` VALUES (286,'演示客户0286',1,'个人','2026-02-27');

INSERT INTO `customers` VALUES (287,'演示客户0287',1,'个人','2025-12-20');

INSERT INTO `customers` VALUES (288,'演示客户0288',1,'个人','2025-12-29');

INSERT INTO `customers` VALUES (289,'演示客户0289',1,'小微企业','2025-01-13');

INSERT INTO `customers` VALUES (290,'演示客户0290',1,'个人','2025-04-01');

INSERT INTO `customers` VALUES (291,'演示客户0291',1,'个人','2025-04-23');

INSERT INTO `customers` VALUES (292,'演示客户0292',2,'个人','2026-04-05');

INSERT INTO `customers` VALUES (293,'演示客户0293',2,'个人','2025-12-05');

INSERT INTO `customers` VALUES (294,'演示客户0294',1,'个人','2025-10-27');

INSERT INTO `customers` VALUES (295,'演示客户0295',1,'小微企业','2025-07-14');

INSERT INTO `customers` VALUES (296,'演示客户0296',2,'个人','2025-04-20');

INSERT INTO `customers` VALUES (297,'演示客户0297',2,'小微企业','2025-04-24');

INSERT INTO `customers` VALUES (298,'演示客户0298',1,'个人','2025-05-12');

INSERT INTO `customers` VALUES (299,'演示客户0299',3,'个人','2024-12-28');

INSERT INTO `customers` VALUES (300,'演示客户0300',1,'个人','2025-05-21');

INSERT INTO `customers` VALUES (301,'演示客户0301',2,'个人','2026-03-22');

INSERT INTO `customers` VALUES (302,'演示客户0302',1,'小微企业','2026-02-13');

INSERT INTO `customers` VALUES (303,'演示客户0303',2,'个人','2025-11-22');

INSERT INTO `customers` VALUES (304,'演示客户0304',2,'小微企业','2026-05-07');

INSERT INTO `customers` VALUES (305,'演示客户0305',1,'个人','2025-02-22');

INSERT INTO `customers` VALUES (306,'演示客户0306',2,'个人','2026-05-22');

INSERT INTO `customers` VALUES (307,'演示客户0307',3,'个人','2026-02-22');

INSERT INTO `customers` VALUES (308,'演示客户0308',1,'个人','2025-03-03');

INSERT INTO `customers` VALUES (309,'演示客户0309',4,'个人','2025-08-08');

INSERT INTO `customers` VALUES (310,'演示客户0310',4,'个人','2026-04-02');

INSERT INTO `customers` VALUES (311,'演示客户0311',2,'个人','2025-08-12');

INSERT INTO `customers` VALUES (312,'演示客户0312',1,'个人','2025-05-26');

INSERT INTO `customers` VALUES (313,'演示客户0313',3,'个人','2025-07-29');

INSERT INTO `customers` VALUES (314,'演示客户0314',1,'小微企业','2026-01-11');

INSERT INTO `customers` VALUES (315,'演示客户0315',2,'个人','2025-10-04');

INSERT INTO `customers` VALUES (316,'演示客户0316',2,'小微企业','2025-01-13');

INSERT INTO `customers` VALUES (317,'演示客户0317',1,'个人','2026-01-27');

INSERT INTO `customers` VALUES (318,'演示客户0318',2,'小微企业','2025-06-28');

INSERT INTO `customers` VALUES (319,'演示客户0319',2,'个人','2026-06-07');

INSERT INTO `customers` VALUES (320,'演示客户0320',4,'小微企业','2025-01-28');

INSERT INTO `customers` VALUES (321,'演示客户0321',1,'个人','2025-04-23');

INSERT INTO `customers` VALUES (322,'演示客户0322',1,'个人','2025-02-17');

INSERT INTO `customers` VALUES (323,'演示客户0323',2,'个人','2025-01-13');

INSERT INTO `customers` VALUES (324,'演示客户0324',1,'个人','2025-07-26');

INSERT INTO `customers` VALUES (325,'演示客户0325',2,'个人','2026-03-24');

INSERT INTO `customers` VALUES (326,'演示客户0326',1,'个人','2024-11-17');

INSERT INTO `customers` VALUES (327,'演示客户0327',2,'个人','2024-12-01');

INSERT INTO `customers` VALUES (328,'演示客户0328',1,'个人','2025-12-22');

INSERT INTO `customers` VALUES (329,'演示客户0329',1,'小微企业','2025-12-03');

INSERT INTO `customers` VALUES (330,'演示客户0330',1,'小微企业','2025-02-22');

INSERT INTO `customers` VALUES (331,'演示客户0331',1,'小微企业','2026-01-27');

INSERT INTO `customers` VALUES (332,'演示客户0332',1,'中型企业','2025-06-24');

INSERT INTO `customers` VALUES (333,'演示客户0333',3,'小微企业','2025-12-15');

INSERT INTO `customers` VALUES (334,'演示客户0334',1,'个人','2025-12-31');

INSERT INTO `customers` VALUES (335,'演示客户0335',3,'个人','2026-02-28');

INSERT INTO `customers` VALUES (336,'演示客户0336',2,'小微企业','2025-05-11');

INSERT INTO `customers` VALUES (337,'演示客户0337',2,'个人','2025-04-28');

INSERT INTO `customers` VALUES (338,'演示客户0338',1,'个人','2025-04-21');

INSERT INTO `customers` VALUES (339,'演示客户0339',3,'个人','2025-03-21');

INSERT INTO `customers` VALUES (340,'演示客户0340',1,'个人','2026-02-23');

INSERT INTO `customers` VALUES (341,'演示客户0341',3,'个人','2024-12-14');

INSERT INTO `customers` VALUES (342,'演示客户0342',3,'个人','2026-05-15');

INSERT INTO `customers` VALUES (343,'演示客户0343',1,'个人','2025-02-16');

INSERT INTO `customers` VALUES (344,'演示客户0344',1,'个人','2026-01-24');

INSERT INTO `customers` VALUES (345,'演示客户0345',2,'个人','2026-07-01');

INSERT INTO `customers` VALUES (346,'演示客户0346',4,'个人','2026-01-22');

INSERT INTO `customers` VALUES (347,'演示客户0347',3,'个人','2026-03-18');

INSERT INTO `customers` VALUES (348,'演示客户0348',1,'小微企业','2025-07-05');

INSERT INTO `customers` VALUES (349,'演示客户0349',1,'个人','2025-10-11');

INSERT INTO `customers` VALUES (350,'演示客户0350',1,'个人','2025-07-08');

INSERT INTO `customers` VALUES (351,'演示客户0351',1,'个人','2025-12-03');

INSERT INTO `customers` VALUES (352,'演示客户0352',1,'个人','2025-04-09');

INSERT INTO `customers` VALUES (353,'演示客户0353',2,'个人','2026-04-14');

INSERT INTO `customers` VALUES (354,'演示客户0354',3,'个人','2025-02-02');

INSERT INTO `customers` VALUES (355,'演示客户0355',3,'个人','2025-10-18');

INSERT INTO `customers` VALUES (356,'演示客户0356',1,'个人','2025-02-21');

INSERT INTO `customers` VALUES (357,'演示客户0357',2,'个人','2025-05-12');

INSERT INTO `customers` VALUES (358,'演示客户0358',3,'个人','2025-11-22');

INSERT INTO `customers` VALUES (359,'演示客户0359',1,'个人','2025-02-05');

INSERT INTO `customers` VALUES (360,'演示客户0360',1,'个人','2025-09-12');

INSERT INTO `customers` VALUES (361,'演示客户0361',4,'个人','2025-09-07');

INSERT INTO `customers` VALUES (362,'演示客户0362',1,'个人','2026-01-22');

INSERT INTO `customers` VALUES (363,'演示客户0363',1,'个人','2025-06-03');

INSERT INTO `customers` VALUES (364,'演示客户0364',2,'个人','2025-03-16');

INSERT INTO `customers` VALUES (365,'演示客户0365',2,'个人','2025-05-09');

INSERT INTO `customers` VALUES (366,'演示客户0366',3,'个人','2025-08-08');

INSERT INTO `customers` VALUES (367,'演示客户0367',1,'个人','2025-07-11');

INSERT INTO `customers` VALUES (368,'演示客户0368',2,'个人','2025-03-16');

INSERT INTO `customers` VALUES (369,'演示客户0369',3,'中型企业','2026-04-10');

INSERT INTO `customers` VALUES (370,'演示客户0370',2,'小微企业','2024-12-19');

INSERT INTO `customers` VALUES (371,'演示客户0371',1,'个人','2025-07-18');

INSERT INTO `customers` VALUES (372,'演示客户0372',2,'小微企业','2025-07-11');

INSERT INTO `customers` VALUES (373,'演示客户0373',4,'个人','2025-12-14');

INSERT INTO `customers` VALUES (374,'演示客户0374',3,'个人','2025-03-25');

INSERT INTO `customers` VALUES (375,'演示客户0375',3,'个人','2026-02-03');

INSERT INTO `customers` VALUES (376,'演示客户0376',1,'个人','2025-07-02');

INSERT INTO `customers` VALUES (377,'演示客户0377',3,'个人','2026-03-02');

INSERT INTO `customers` VALUES (378,'演示客户0378',2,'个人','2025-07-26');

INSERT INTO `customers` VALUES (379,'演示客户0379',3,'个人','2025-10-25');

INSERT INTO `customers` VALUES (380,'演示客户0380',3,'个人','2025-12-19');

INSERT INTO `customers` VALUES (381,'演示客户0381',4,'小微企业','2025-01-22');

INSERT INTO `customers` VALUES (382,'演示客户0382',1,'个人','2025-01-19');

INSERT INTO `customers` VALUES (383,'演示客户0383',1,'个人','2025-10-20');

INSERT INTO `customers` VALUES (384,'演示客户0384',4,'小微企业','2025-02-20');

INSERT INTO `customers` VALUES (385,'演示客户0385',2,'个人','2025-04-24');

INSERT INTO `customers` VALUES (386,'演示客户0386',1,'个人','2026-01-02');

INSERT INTO `customers` VALUES (387,'演示客户0387',1,'小微企业','2026-01-17');

INSERT INTO `customers` VALUES (388,'演示客户0388',2,'小微企业','2025-01-22');

INSERT INTO `customers` VALUES (389,'演示客户0389',2,'个人','2026-03-07');

INSERT INTO `customers` VALUES (390,'演示客户0390',1,'小微企业','2025-01-08');

INSERT INTO `customers` VALUES (391,'演示客户0391',1,'个人','2026-01-01');

INSERT INTO `customers` VALUES (392,'演示客户0392',4,'个人','2025-10-29');

INSERT INTO `customers` VALUES (393,'演示客户0393',4,'个人','2025-04-26');

INSERT INTO `customers` VALUES (394,'演示客户0394',1,'个人','2026-03-25');

INSERT INTO `customers` VALUES (395,'演示客户0395',1,'个人','2025-02-19');

INSERT INTO `customers` VALUES (396,'演示客户0396',2,'个人','2025-02-27');

INSERT INTO `customers` VALUES (397,'演示客户0397',1,'个人','2024-12-11');

INSERT INTO `customers` VALUES (398,'演示客户0398',4,'个人','2025-02-25');

INSERT INTO `customers` VALUES (399,'演示客户0399',3,'个人','2025-01-22');

INSERT INTO `customers` VALUES (400,'演示客户0400',4,'小微企业','2026-04-17');

INSERT INTO `customers` VALUES (401,'演示客户0401',4,'个人','2025-12-01');

INSERT INTO `customers` VALUES (402,'演示客户0402',1,'个人','2025-04-17');

INSERT INTO `customers` VALUES (403,'演示客户0403',1,'个人','2025-11-02');

INSERT INTO `customers` VALUES (404,'演示客户0404',1,'个人','2025-07-11');

INSERT INTO `customers` VALUES (405,'演示客户0405',1,'中型企业','2025-04-22');

INSERT INTO `customers` VALUES (406,'演示客户0406',3,'个人','2026-03-03');

INSERT INTO `customers` VALUES (407,'演示客户0407',2,'个人','2026-02-09');

INSERT INTO `customers` VALUES (408,'演示客户0408',1,'个人','2026-01-12');

INSERT INTO `customers` VALUES (409,'演示客户0409',3,'个人','2024-10-19');

INSERT INTO `customers` VALUES (410,'演示客户0410',4,'个人','2025-11-24');

INSERT INTO `customers` VALUES (411,'演示客户0411',2,'个人','2025-03-30');

INSERT INTO `customers` VALUES (412,'演示客户0412',3,'小微企业','2025-04-05');

INSERT INTO `customers` VALUES (413,'演示客户0413',2,'个人','2026-02-25');

INSERT INTO `customers` VALUES (414,'演示客户0414',4,'个人','2024-12-19');

INSERT INTO `customers` VALUES (415,'演示客户0415',1,'个人','2025-10-20');

INSERT INTO `customers` VALUES (416,'演示客户0416',3,'个人','2025-01-06');

INSERT INTO `customers` VALUES (417,'演示客户0417',1,'个人','2025-06-06');

INSERT INTO `customers` VALUES (418,'演示客户0418',3,'个人','2025-05-15');

INSERT INTO `customers` VALUES (419,'演示客户0419',2,'个人','2025-08-06');

INSERT INTO `customers` VALUES (420,'演示客户0420',3,'个人','2026-03-15');

INSERT INTO `customers` VALUES (421,'演示客户0421',1,'个人','2025-02-06');

INSERT INTO `customers` VALUES (422,'演示客户0422',4,'个人','2025-08-09');

INSERT INTO `customers` VALUES (423,'演示客户0423',1,'个人','2024-12-25');

INSERT INTO `customers` VALUES (424,'演示客户0424',2,'个人','2025-08-20');

INSERT INTO `customers` VALUES (425,'演示客户0425',1,'个人','2025-05-09');

INSERT INTO `customers` VALUES (426,'演示客户0426',1,'个人','2025-12-13');

INSERT INTO `customers` VALUES (427,'演示客户0427',1,'小微企业','2025-06-05');

INSERT INTO `customers` VALUES (428,'演示客户0428',2,'个人','2025-08-18');

INSERT INTO `customers` VALUES (429,'演示客户0429',2,'个人','2025-02-16');

INSERT INTO `customers` VALUES (430,'演示客户0430',1,'小微企业','2024-12-06');

INSERT INTO `customers` VALUES (431,'演示客户0431',3,'个人','2025-08-31');

INSERT INTO `customers` VALUES (432,'演示客户0432',1,'个人','2025-02-19');

INSERT INTO `customers` VALUES (433,'演示客户0433',1,'小微企业','2026-03-13');

INSERT INTO `customers` VALUES (434,'演示客户0434',2,'个人','2026-06-04');

INSERT INTO `customers` VALUES (435,'演示客户0435',1,'小微企业','2025-04-13');

INSERT INTO `customers` VALUES (436,'演示客户0436',3,'个人','2026-02-14');

INSERT INTO `customers` VALUES (437,'演示客户0437',2,'个人','2025-07-15');

INSERT INTO `customers` VALUES (438,'演示客户0438',2,'个人','2024-10-18');

INSERT INTO `customers` VALUES (439,'演示客户0439',2,'个人','2025-04-18');

INSERT INTO `customers` VALUES (440,'演示客户0440',1,'个人','2025-10-01');

INSERT INTO `customers` VALUES (441,'演示客户0441',2,'个人','2025-01-16');

INSERT INTO `customers` VALUES (442,'演示客户0442',2,'中型企业','2026-02-13');

INSERT INTO `customers` VALUES (443,'演示客户0443',1,'小微企业','2025-10-15');

INSERT INTO `customers` VALUES (444,'演示客户0444',2,'个人','2025-05-30');

INSERT INTO `customers` VALUES (445,'演示客户0445',1,'个人','2025-03-16');

INSERT INTO `customers` VALUES (446,'演示客户0446',1,'个人','2025-02-24');

INSERT INTO `customers` VALUES (447,'演示客户0447',4,'个人','2025-01-17');

INSERT INTO `customers` VALUES (448,'演示客户0448',2,'个人','2026-01-14');

INSERT INTO `customers` VALUES (449,'演示客户0449',4,'个人','2025-01-14');

INSERT INTO `customers` VALUES (450,'演示客户0450',1,'个人','2025-06-29');

INSERT INTO `customers` VALUES (451,'演示客户0451',3,'个人','2025-02-21');

INSERT INTO `customers` VALUES (452,'演示客户0452',4,'个人','2025-05-13');

INSERT INTO `customers` VALUES (453,'演示客户0453',1,'个人','2025-02-11');

INSERT INTO `customers` VALUES (454,'演示客户0454',2,'个人','2025-02-11');

INSERT INTO `customers` VALUES (455,'演示客户0455',2,'个人','2025-01-21');

INSERT INTO `customers` VALUES (456,'演示客户0456',3,'小微企业','2025-08-31');

INSERT INTO `customers` VALUES (457,'演示客户0457',1,'个人','2025-05-04');

INSERT INTO `customers` VALUES (458,'演示客户0458',3,'个人','2025-02-04');

INSERT INTO `customers` VALUES (459,'演示客户0459',4,'中型企业','2025-06-14');

INSERT INTO `customers` VALUES (460,'演示客户0460',1,'个人','2025-02-06');

INSERT INTO `customers` VALUES (461,'演示客户0461',4,'个人','2025-05-01');

INSERT INTO `customers` VALUES (462,'演示客户0462',1,'个人','2025-08-08');

INSERT INTO `customers` VALUES (463,'演示客户0463',2,'个人','2026-04-10');

INSERT INTO `customers` VALUES (464,'演示客户0464',1,'个人','2025-04-01');

INSERT INTO `customers` VALUES (465,'演示客户0465',3,'个人','2026-04-08');

INSERT INTO `customers` VALUES (466,'演示客户0466',3,'个人','2025-01-19');

INSERT INTO `customers` VALUES (467,'演示客户0467',1,'个人','2026-06-08');

INSERT INTO `customers` VALUES (468,'演示客户0468',3,'个人','2025-06-13');

INSERT INTO `customers` VALUES (469,'演示客户0469',4,'个人','2025-03-01');

INSERT INTO `customers` VALUES (470,'演示客户0470',4,'个人','2024-11-08');

INSERT INTO `customers` VALUES (471,'演示客户0471',1,'个人','2025-08-24');

INSERT INTO `customers` VALUES (472,'演示客户0472',2,'个人','2025-12-06');

INSERT INTO `customers` VALUES (473,'演示客户0473',2,'个人','2025-03-18');

INSERT INTO `customers` VALUES (474,'演示客户0474',2,'个人','2025-05-22');

INSERT INTO `customers` VALUES (475,'演示客户0475',3,'个人','2024-11-17');

INSERT INTO `customers` VALUES (476,'演示客户0476',2,'个人','2025-06-25');

INSERT INTO `customers` VALUES (477,'演示客户0477',3,'个人','2026-06-02');

INSERT INTO `customers` VALUES (478,'演示客户0478',2,'小微企业','2025-09-21');

INSERT INTO `customers` VALUES (479,'演示客户0479',2,'个人','2025-05-12');

INSERT INTO `customers` VALUES (480,'演示客户0480',2,'小微企业','2025-09-27');

INSERT INTO `customers` VALUES (481,'演示客户0481',3,'个人','2025-08-11');

INSERT INTO `customers` VALUES (482,'演示客户0482',1,'个人','2025-05-22');

INSERT INTO `customers` VALUES (483,'演示客户0483',3,'个人','2024-11-17');

INSERT INTO `customers` VALUES (484,'演示客户0484',4,'小微企业','2025-07-08');

INSERT INTO `customers` VALUES (485,'演示客户0485',3,'小微企业','2025-01-29');

INSERT INTO `customers` VALUES (486,'演示客户0486',3,'个人','2025-08-25');

INSERT INTO `customers` VALUES (487,'演示客户0487',3,'小微企业','2025-12-02');

INSERT INTO `customers` VALUES (488,'演示客户0488',4,'个人','2025-07-31');

INSERT INTO `customers` VALUES (489,'演示客户0489',1,'个人','2025-04-26');

INSERT INTO `customers` VALUES (490,'演示客户0490',3,'个人','2025-05-14');

INSERT INTO `customers` VALUES (491,'演示客户0491',2,'中型企业','2026-02-28');

INSERT INTO `customers` VALUES (492,'演示客户0492',1,'小微企业','2025-05-10');

INSERT INTO `customers` VALUES (493,'演示客户0493',3,'小微企业','2025-10-26');

INSERT INTO `customers` VALUES (494,'演示客户0494',1,'小微企业','2025-10-26');

INSERT INTO `customers` VALUES (495,'演示客户0495',3,'个人','2025-04-24');

INSERT INTO `customers` VALUES (496,'演示客户0496',4,'个人','2025-12-20');

INSERT INTO `customers` VALUES (497,'演示客户0497',3,'个人','2026-06-06');

INSERT INTO `customers` VALUES (498,'演示客户0498',3,'个人','2025-06-08');

INSERT INTO `customers` VALUES (499,'演示客户0499',1,'个人','2026-03-31');

INSERT INTO `customers` VALUES (500,'演示客户0500',3,'小微企业','2025-06-08');

INSERT INTO `customers` VALUES (501,'演示客户0501',1,'中型企业','2025-10-26');

INSERT INTO `customers` VALUES (502,'演示客户0502',1,'个人','2025-04-12');

INSERT INTO `customers` VALUES (503,'演示客户0503',4,'个人','2025-08-20');

INSERT INTO `customers` VALUES (504,'演示客户0504',2,'个人','2024-12-27');

INSERT INTO `customers` VALUES (505,'演示客户0505',4,'个人','2025-01-26');

INSERT INTO `customers` VALUES (506,'演示客户0506',3,'个人','2026-03-03');

INSERT INTO `customers` VALUES (507,'演示客户0507',1,'小微企业','2025-01-28');

INSERT INTO `customers` VALUES (508,'演示客户0508',1,'个人','2025-11-08');

INSERT INTO `customers` VALUES (509,'演示客户0509',1,'个人','2025-06-19');

INSERT INTO `customers` VALUES (510,'演示客户0510',2,'个人','2026-04-18');

INSERT INTO `customers` VALUES (511,'演示客户0511',4,'个人','2025-10-16');

INSERT INTO `customers` VALUES (512,'演示客户0512',2,'个人','2025-08-16');

INSERT INTO `customers` VALUES (513,'演示客户0513',4,'个人','2026-03-07');

INSERT INTO `customers` VALUES (514,'演示客户0514',2,'个人','2025-04-27');

INSERT INTO `customers` VALUES (515,'演示客户0515',1,'个人','2025-10-08');

INSERT INTO `customers` VALUES (516,'演示客户0516',2,'个人','2025-07-12');

INSERT INTO `customers` VALUES (517,'演示客户0517',1,'小微企业','2025-03-14');

INSERT INTO `customers` VALUES (518,'演示客户0518',3,'小微企业','2025-11-12');

INSERT INTO `customers` VALUES (519,'演示客户0519',3,'个人','2025-05-03');

INSERT INTO `customers` VALUES (520,'演示客户0520',4,'个人','2025-06-18');

INSERT INTO `customers` VALUES (521,'演示客户0521',2,'个人','2025-09-24');

INSERT INTO `customers` VALUES (522,'演示客户0522',3,'个人','2025-08-22');

INSERT INTO `customers` VALUES (523,'演示客户0523',3,'个人','2025-05-19');

INSERT INTO `customers` VALUES (524,'演示客户0524',3,'小微企业','2025-04-28');

INSERT INTO `customers` VALUES (525,'演示客户0525',2,'个人','2024-10-19');

INSERT INTO `customers` VALUES (526,'演示客户0526',2,'个人','2025-10-12');

INSERT INTO `customers` VALUES (527,'演示客户0527',1,'个人','2025-09-12');

INSERT INTO `customers` VALUES (528,'演示客户0528',1,'个人','2026-02-26');

INSERT INTO `customers` VALUES (529,'演示客户0529',4,'个人','2025-03-01');

INSERT INTO `customers` VALUES (530,'演示客户0530',4,'个人','2024-11-25');

INSERT INTO `customers` VALUES (531,'演示客户0531',2,'个人','2025-11-27');

INSERT INTO `customers` VALUES (532,'演示客户0532',1,'个人','2025-02-17');

INSERT INTO `customers` VALUES (533,'演示客户0533',3,'小微企业','2025-04-20');

INSERT INTO `customers` VALUES (534,'演示客户0534',1,'个人','2025-04-15');

INSERT INTO `customers` VALUES (535,'演示客户0535',2,'个人','2025-09-14');

INSERT INTO `customers` VALUES (536,'演示客户0536',1,'个人','2024-11-22');

INSERT INTO `customers` VALUES (537,'演示客户0537',2,'小微企业','2026-07-02');

INSERT INTO `customers` VALUES (538,'演示客户0538',1,'个人','2026-01-26');

INSERT INTO `customers` VALUES (539,'演示客户0539',1,'个人','2025-03-13');

INSERT INTO `customers` VALUES (540,'演示客户0540',2,'个人','2025-06-18');

INSERT INTO `customers` VALUES (541,'演示客户0541',1,'个人','2024-10-22');

INSERT INTO `customers` VALUES (542,'演示客户0542',3,'个人','2025-04-02');

INSERT INTO `customers` VALUES (543,'演示客户0543',2,'个人','2025-07-13');

INSERT INTO `customers` VALUES (544,'演示客户0544',1,'个人','2025-05-16');

INSERT INTO `customers` VALUES (545,'演示客户0545',2,'个人','2025-11-09');

INSERT INTO `customers` VALUES (546,'演示客户0546',1,'小微企业','2025-05-23');

INSERT INTO `customers` VALUES (547,'演示客户0547',1,'个人','2024-11-19');

INSERT INTO `customers` VALUES (548,'演示客户0548',3,'个人','2025-03-12');

INSERT INTO `customers` VALUES (549,'演示客户0549',1,'个人','2025-03-13');

INSERT INTO `customers` VALUES (550,'演示客户0550',1,'个人','2025-06-27');

INSERT INTO `customers` VALUES (551,'演示客户0551',2,'小微企业','2025-10-28');

INSERT INTO `customers` VALUES (552,'演示客户0552',1,'个人','2025-02-19');

INSERT INTO `customers` VALUES (553,'演示客户0553',3,'个人','2024-10-28');

INSERT INTO `customers` VALUES (554,'演示客户0554',3,'个人','2025-02-27');

INSERT INTO `customers` VALUES (555,'演示客户0555',3,'个人','2025-02-05');

INSERT INTO `customers` VALUES (556,'演示客户0556',3,'个人','2025-02-18');

INSERT INTO `customers` VALUES (557,'演示客户0557',2,'小微企业','2025-03-21');

INSERT INTO `customers` VALUES (558,'演示客户0558',2,'个人','2025-07-03');

INSERT INTO `customers` VALUES (559,'演示客户0559',3,'个人','2025-08-25');

INSERT INTO `customers` VALUES (560,'演示客户0560',2,'个人','2025-06-17');

INSERT INTO `customers` VALUES (561,'演示客户0561',1,'个人','2025-09-15');

INSERT INTO `customers` VALUES (562,'演示客户0562',4,'个人','2025-06-06');

INSERT INTO `customers` VALUES (563,'演示客户0563',3,'个人','2024-12-03');

INSERT INTO `customers` VALUES (564,'演示客户0564',3,'个人','2025-02-01');

INSERT INTO `customers` VALUES (565,'演示客户0565',2,'个人','2025-07-18');

INSERT INTO `customers` VALUES (566,'演示客户0566',1,'个人','2025-07-08');

INSERT INTO `customers` VALUES (567,'演示客户0567',1,'小微企业','2024-12-27');

INSERT INTO `customers` VALUES (568,'演示客户0568',2,'个人','2025-07-02');

INSERT INTO `customers` VALUES (569,'演示客户0569',1,'个人','2026-03-26');

INSERT INTO `customers` VALUES (570,'演示客户0570',1,'个人','2025-05-22');

INSERT INTO `customers` VALUES (571,'演示客户0571',2,'个人','2025-10-15');

INSERT INTO `customers` VALUES (572,'演示客户0572',2,'个人','2025-02-22');

INSERT INTO `customers` VALUES (573,'演示客户0573',2,'个人','2025-05-16');

INSERT INTO `customers` VALUES (574,'演示客户0574',3,'小微企业','2024-12-18');

INSERT INTO `customers` VALUES (575,'演示客户0575',1,'个人','2025-04-30');

INSERT INTO `customers` VALUES (576,'演示客户0576',1,'小微企业','2025-05-30');

INSERT INTO `customers` VALUES (577,'演示客户0577',3,'个人','2025-10-07');

INSERT INTO `customers` VALUES (578,'演示客户0578',4,'个人','2025-09-11');

INSERT INTO `customers` VALUES (579,'演示客户0579',3,'个人','2025-03-10');

INSERT INTO `customers` VALUES (580,'演示客户0580',2,'个人','2025-01-14');

INSERT INTO `customers` VALUES (581,'演示客户0581',1,'个人','2026-06-02');

INSERT INTO `customers` VALUES (582,'演示客户0582',1,'个人','2025-01-25');

INSERT INTO `customers` VALUES (583,'演示客户0583',2,'个人','2025-05-14');

INSERT INTO `customers` VALUES (584,'演示客户0584',1,'个人','2025-03-13');

INSERT INTO `customers` VALUES (585,'演示客户0585',4,'个人','2025-08-06');

INSERT INTO `customers` VALUES (586,'演示客户0586',1,'个人','2025-06-02');

INSERT INTO `customers` VALUES (587,'演示客户0587',1,'个人','2025-03-08');

INSERT INTO `customers` VALUES (588,'演示客户0588',3,'小微企业','2025-09-10');

INSERT INTO `customers` VALUES (589,'演示客户0589',2,'个人','2025-12-09');

INSERT INTO `customers` VALUES (590,'演示客户0590',1,'个人','2025-01-28');

INSERT INTO `customers` VALUES (591,'演示客户0591',1,'个人','2025-04-04');

INSERT INTO `customers` VALUES (592,'演示客户0592',1,'个人','2025-05-26');

INSERT INTO `customers` VALUES (593,'演示客户0593',1,'个人','2024-12-16');

INSERT INTO `customers` VALUES (594,'演示客户0594',3,'个人','2025-11-01');

INSERT INTO `customers` VALUES (595,'演示客户0595',1,'个人','2025-01-31');

INSERT INTO `customers` VALUES (596,'演示客户0596',2,'个人','2025-08-21');

INSERT INTO `customers` VALUES (597,'演示客户0597',4,'个人','2025-06-20');

INSERT INTO `customers` VALUES (598,'演示客户0598',2,'个人','2025-09-02');

INSERT INTO `customers` VALUES (599,'演示客户0599',2,'个人','2025-07-04');

INSERT INTO `customers` VALUES (600,'演示客户0600',2,'个人','2025-01-25');

INSERT INTO `customers` VALUES (601,'演示客户0601',3,'个人','2025-05-04');

INSERT INTO `customers` VALUES (602,'演示客户0602',4,'小微企业','2024-12-21');

INSERT INTO `customers` VALUES (603,'演示客户0603',2,'个人','2025-09-17');

INSERT INTO `customers` VALUES (604,'演示客户0604',1,'中型企业','2026-07-12');

INSERT INTO `customers` VALUES (605,'演示客户0605',1,'个人','2025-12-07');

INSERT INTO `customers` VALUES (606,'演示客户0606',2,'个人','2025-11-18');

INSERT INTO `customers` VALUES (607,'演示客户0607',2,'个人','2026-01-15');

INSERT INTO `customers` VALUES (608,'演示客户0608',1,'个人','2025-04-15');

INSERT INTO `customers` VALUES (609,'演示客户0609',1,'个人','2025-02-05');

INSERT INTO `customers` VALUES (610,'演示客户0610',3,'个人','2025-01-04');

INSERT INTO `customers` VALUES (611,'演示客户0611',4,'个人','2025-08-02');

INSERT INTO `customers` VALUES (612,'演示客户0612',1,'个人','2025-03-24');

INSERT INTO `customers` VALUES (613,'演示客户0613',3,'个人','2025-03-25');

INSERT INTO `customers` VALUES (614,'演示客户0614',1,'个人','2025-03-13');

INSERT INTO `customers` VALUES (615,'演示客户0615',2,'个人','2025-06-14');

INSERT INTO `customers` VALUES (616,'演示客户0616',1,'个人','2025-08-20');

INSERT INTO `customers` VALUES (617,'演示客户0617',2,'个人','2025-03-29');

INSERT INTO `customers` VALUES (618,'演示客户0618',3,'小微企业','2025-04-24');

INSERT INTO `customers` VALUES (619,'演示客户0619',2,'个人','2025-06-13');

INSERT INTO `customers` VALUES (620,'演示客户0620',2,'中型企业','2025-04-04');

INSERT INTO `customers` VALUES (621,'演示客户0621',1,'个人','2025-07-03');

INSERT INTO `customers` VALUES (622,'演示客户0622',1,'个人','2025-02-17');

INSERT INTO `customers` VALUES (623,'演示客户0623',2,'个人','2025-01-08');

INSERT INTO `customers` VALUES (624,'演示客户0624',1,'个人','2025-03-11');

INSERT INTO `customers` VALUES (625,'演示客户0625',2,'小微企业','2025-04-17');

INSERT INTO `customers` VALUES (626,'演示客户0626',1,'个人','2025-07-31');

INSERT INTO `customers` VALUES (627,'演示客户0627',1,'个人','2025-07-05');

INSERT INTO `customers` VALUES (628,'演示客户0628',1,'小微企业','2026-05-06');

INSERT INTO `customers` VALUES (629,'演示客户0629',1,'小微企业','2026-02-27');

INSERT INTO `customers` VALUES (630,'演示客户0630',2,'个人','2025-09-27');

INSERT INTO `customers` VALUES (631,'演示客户0631',2,'个人','2025-01-05');

INSERT INTO `customers` VALUES (632,'演示客户0632',1,'个人','2025-08-21');

INSERT INTO `customers` VALUES (633,'演示客户0633',4,'个人','2025-12-25');

INSERT INTO `customers` VALUES (634,'演示客户0634',2,'个人','2025-04-26');

INSERT INTO `customers` VALUES (635,'演示客户0635',1,'个人','2025-10-21');

INSERT INTO `customers` VALUES (636,'演示客户0636',3,'个人','2026-06-02');

INSERT INTO `customers` VALUES (637,'演示客户0637',1,'个人','2025-02-11');

INSERT INTO `orders` VALUES (1,'RT20250103000001',60,'PAID','2025-01-03 13:06:18','2025-01-03 13:39:18',129.00,'小程序');

INSERT INTO `orders` VALUES (2,'RT20250104000002',504,'PAID','2025-01-04 21:03:51','2025-01-04 21:25:51',39.00,'官网');

INSERT INTO `orders` VALUES (3,'RT20250106000003',504,'PAID','2025-01-06 17:49:49','2025-01-06 18:35:49',22.41,'小程序');

INSERT INTO `orders` VALUES (4,'RT20250108000004',553,'PAID','2025-01-08 18:37:03','2025-01-08 18:39:03',32.90,'企业采购');

INSERT INTO `orders` VALUES (5,'RT20250108000005',547,'PAID','2025-01-08 22:21:17','2025-01-08 23:29:17',39.90,'小程序');

INSERT INTO `orders` VALUES (6,'RT20250111000006',111,'PAID','2025-01-11 14:21:29','2025-01-11 15:23:29',32.90,'线下门店');

INSERT INTO `orders` VALUES (7,'RT20250111000007',8,'PAID','2025-01-11 15:36:00','2025-01-11 16:31:00',39.00,'线下门店');

INSERT INTO `orders` VALUES (8,'RT20250112000008',226,'CANCELLED','2025-01-12 17:14:04',NULL,69.00,'小程序');

INSERT INTO `orders` VALUES (9,'RT20250114000009',547,'PAID','2025-01-14 11:12:57','2025-01-14 11:27:57',39.90,'企业采购');

INSERT INTO `orders` VALUES (10,'RT20250116000010',34,'PAID','2025-01-16 14:43:31','2025-01-16 15:35:31',39.90,'小程序');

INSERT INTO `orders` VALUES (11,'RT20250118000011',623,'PAID','2025-01-18 16:42:28','2025-01-18 17:14:28',23.66,'小程序');

INSERT INTO `orders` VALUES (12,'RT20250121000012',79,'PAID','2025-01-21 13:29:19','2025-01-21 14:11:19',31.26,'官网');

INSERT INTO `orders` VALUES (13,'RT20250123000013',409,'PAID','2025-01-23 10:52:36','2025-01-23 12:03:36',399.00,'线下门店');

INSERT INTO `orders` VALUES (14,'RT20250125000014',567,'PAID','2025-01-25 11:42:04','2025-01-25 11:50:04',53.10,'小程序');

INSERT INTO `orders` VALUES (15,'RT20250125000015',8,'PAID','2025-01-25 12:48:38','2025-01-25 13:23:38',75.05,'官网');

INSERT INTO `orders` VALUES (16,'RT20250201000016',455,'REFUNDED','2025-02-01 11:41:37','2025-02-01 11:47:37',197.00,'官网');

INSERT INTO `orders` VALUES (17,'RT20250201000017',178,'PAID','2025-02-01 17:27:47','2025-02-01 18:16:47',386.15,'官网');

INSERT INTO `orders` VALUES (18,'RT20250203000018',11,'PAID','2025-02-03 20:56:58','2025-02-03 21:19:58',68.00,'企业采购');

INSERT INTO `orders` VALUES (19,'RT20250208000019',593,'PAID','2025-02-08 19:57:58','2025-02-08 20:13:58',39.90,'官网');

INSERT INTO `orders` VALUES (20,'RT20250209000020',125,'PAID','2025-02-09 15:38:09','2025-02-09 16:06:09',100.90,'小程序');

INSERT INTO `orders` VALUES (21,'RT20250211000021',414,'PAID','2025-02-11 19:09:47','2025-02-11 19:31:47',24.90,'小程序');

INSERT INTO `orders` VALUES (22,'RT20250219000022',449,'PAID','2025-02-19 19:10:32','2025-02-19 19:11:32',64.80,'小程序');

INSERT INTO `orders` VALUES (23,'RT20250221000023',475,'PAID','2025-02-21 21:57:34','2025-02-21 23:09:34',105.00,'小程序');

INSERT INTO `orders` VALUES (24,'RT20250222000024',590,'PAID','2025-02-22 18:02:27','2025-02-22 18:10:27',59.00,'线下门店');

INSERT INTO `orders` VALUES (25,'RT20250224000025',384,'PAID','2025-02-24 13:39:00','2025-02-24 13:50:00',39.90,'线下门店');

INSERT INTO `orders` VALUES (26,'RT20250224000026',609,'PAID','2025-02-24 19:36:12','2025-02-24 20:23:12',71.90,'官网');

INSERT INTO `orders` VALUES (27,'RT20250228000027',354,'PAID','2025-02-28 11:30:10','2025-02-28 12:37:10',283.80,'线下门店');

INSERT INTO `orders` VALUES (28,'RT20250301000028',475,'PAID','2025-03-01 17:29:35','2025-03-01 17:44:35',24.90,'小程序');

INSERT INTO `orders` VALUES (29,'RT20250301000029',219,'PAID','2025-03-01 18:06:23','2025-03-01 18:12:23',302.10,'小程序');

INSERT INTO `orders` VALUES (30,'RT20250301000030',430,'PAID','2025-03-01 18:08:03','2025-03-01 18:32:03',271.68,'小程序');

INSERT INTO `orders` VALUES (31,'RT20250301000031',146,'PAID','2025-03-01 20:31:20','2025-03-01 21:01:20',399.00,'小程序');

INSERT INTO `orders` VALUES (32,'RT20250303000032',34,'PAID','2025-03-03 18:52:01','2025-03-03 18:59:01',169.00,'线下门店');

INSERT INTO `orders` VALUES (33,'RT20250303000033',60,'REFUNDED','2025-03-03 21:49:04','2025-03-03 22:01:04',63.90,'小程序');

INSERT INTO `orders` VALUES (34,'RT20250304000034',175,'CANCELLED','2025-03-04 14:07:55',NULL,199.55,'线下门店');

INSERT INTO `orders` VALUES (35,'RT20250304000035',399,'PAID','2025-03-04 16:04:22','2025-03-04 16:05:22',430.90,'小程序');

INSERT INTO `orders` VALUES (36,'RT20250305000036',541,'PAID','2025-03-05 18:36:18','2025-03-05 19:02:18',24.90,'官网');

INSERT INTO `orders` VALUES (37,'RT20250307000037',90,'CANCELLED','2025-03-07 15:58:57',NULL,54.92,'小程序');

INSERT INTO `orders` VALUES (38,'RT20250307000038',475,'PAID','2025-03-07 18:33:46','2025-03-07 19:18:46',68.00,'官网');

INSERT INTO `orders` VALUES (39,'RT20250308000039',146,'PAID','2025-03-08 10:17:41','2025-03-08 10:42:41',53.10,'小程序');

INSERT INTO `orders` VALUES (40,'RT20250308000040',82,'PAID','2025-03-08 18:35:18','2025-03-08 19:02:18',64.60,'小程序');

INSERT INTO `orders` VALUES (41,'RT20250308000041',532,'PAID','2025-03-08 22:34:49','2025-03-08 23:30:49',32.90,'线下门店');

INSERT INTO `orders` VALUES (42,'RT20250311000042',308,'PAID','2025-03-11 17:09:35','2025-03-11 17:42:35',79.80,'小程序');

INSERT INTO `orders` VALUES (43,'RT20250315000043',35,'PAID','2025-03-15 10:29:37','2025-03-15 10:50:37',143.10,'线下门店');

INSERT INTO `orders` VALUES (44,'RT20250315000044',396,'PAID','2025-03-15 18:18:18','2025-03-15 18:42:18',29.61,'小程序');

INSERT INTO `orders` VALUES (45,'RT20250316000045',552,'PAID','2025-03-16 14:08:12','2025-03-16 14:20:12',39.90,'线下门店');

INSERT INTO `orders` VALUES (46,'RT20250316000046',10,'PAID','2025-03-16 15:06:43','2025-03-16 15:20:43',374.90,'企业采购');

INSERT INTO `orders` VALUES (47,'RT20250317000047',289,'PAID','2025-03-17 12:54:06','2025-03-17 13:07:06',438.90,'小程序');

INSERT INTO `orders` VALUES (48,'RT20250317000048',409,'PAID','2025-03-17 15:22:24','2025-03-17 16:18:24',114.91,'企业采购');

INSERT INTO `orders` VALUES (49,'RT20250318000049',397,'PAID','2025-03-18 12:31:01','2025-03-18 13:25:01',39.00,'官网');

INSERT INTO `orders` VALUES (50,'RT20250318000050',548,'PAID','2025-03-18 19:27:56','2025-03-18 19:51:56',39.90,'小程序');

INSERT INTO `orders` VALUES (51,'RT20250319000051',341,'PAID','2025-03-19 10:35:38','2025-03-19 11:35:38',37.91,'官网');

INSERT INTO `orders` VALUES (52,'RT20250319000052',552,'PAID','2025-03-19 15:45:09','2025-03-19 16:26:09',68.00,'线下门店');

INSERT INTO `orders` VALUES (53,'RT20250319000053',146,'PAID','2025-03-19 16:11:03','2025-03-19 16:24:03',39.90,'官网');

INSERT INTO `orders` VALUES (54,'RT20250319000054',272,'PAID','2025-03-19 21:27:40','2025-03-19 22:41:40',103.60,'小程序');

INSERT INTO `orders` VALUES (55,'RT20250320000055',34,'PAID','2025-03-20 12:41:47','2025-03-20 13:36:47',201.96,'官网');

INSERT INTO `orders` VALUES (56,'RT20250320000056',445,'PAID','2025-03-20 20:25:19','2025-03-20 21:28:19',249.38,'线下门店');

INSERT INTO `orders` VALUES (57,'RT20250321000057',370,'PAID','2025-03-21 19:22:32','2025-03-21 19:59:32',132.56,'线下门店');

INSERT INTO `orders` VALUES (58,'RT20250322000058',455,'PAID','2025-03-22 19:19:01','2025-03-22 19:40:01',184.00,'小程序');

INSERT INTO `orders` VALUES (59,'RT20250322000059',34,'PAID','2025-03-22 19:43:50','2025-03-22 20:43:50',39.00,'官网');

INSERT INTO `orders` VALUES (60,'RT20250323000060',354,'PAID','2025-03-23 11:43:20','2025-03-23 12:11:20',337.00,'小程序');

INSERT INTO `orders` VALUES (61,'RT20250323000061',86,'PAID','2025-03-23 16:32:25','2025-03-23 16:37:25',62.51,'小程序');

INSERT INTO `orders` VALUES (62,'RT20250323000062',2,'PAID','2025-03-23 18:13:27','2025-03-23 19:10:27',39.00,'小程序');

INSERT INTO `orders` VALUES (63,'RT20250324000063',111,'PAID','2025-03-24 15:42:57','2025-03-24 15:51:57',71.82,'线下门店');

INSERT INTO `orders` VALUES (64,'RT20250325000064',416,'PAID','2025-03-25 18:16:39','2025-03-25 18:33:39',107.95,'官网');

INSERT INTO `orders` VALUES (65,'RT20250326000065',50,'PAID','2025-03-26 17:20:40','2025-03-26 18:08:40',32.90,'小程序');

INSERT INTO `orders` VALUES (66,'RT20250326000066',381,'PAID','2025-03-26 18:57:11','2025-03-26 19:58:11',39.00,'官网');

INSERT INTO `orders` VALUES (67,'RT20250329000067',339,'REFUNDED','2025-03-29 18:30:31','2025-03-29 19:36:31',68.00,'小程序');

INSERT INTO `orders` VALUES (68,'RT20250329000068',216,'PAID','2025-03-29 21:25:49','2025-03-29 21:34:49',118.80,'线下门店');

INSERT INTO `orders` VALUES (69,'RT20250330000069',176,'PAID','2025-03-30 11:17:06','2025-03-30 12:30:06',98.00,'小程序');

INSERT INTO `orders` VALUES (70,'RT20250330000070',182,'PAID','2025-03-30 12:26:54','2025-03-30 13:40:54',129.00,'小程序');

INSERT INTO `orders` VALUES (71,'RT20250330000071',23,'PAID','2025-03-30 13:53:54','2025-03-30 14:45:54',147.00,'小程序');

INSERT INTO `orders` VALUES (72,'RT20250330000072',466,'CANCELLED','2025-03-30 17:51:50',NULL,35.91,'线下门店');

INSERT INTO `orders` VALUES (73,'RT20250331000073',536,'PAID','2025-03-31 21:09:55','2025-03-31 22:01:55',127.87,'小程序');

INSERT INTO `orders` VALUES (74,'RT20250401000074',359,'PAID','2025-04-01 11:47:21','2025-04-01 12:21:21',89.00,'线下门店');

INSERT INTO `orders` VALUES (75,'RT20250402000075',580,'CANCELLED','2025-04-02 10:38:05',NULL,159.00,'官网');

INSERT INTO `orders` VALUES (76,'RT20250404000076',50,'PAID','2025-04-04 12:28:12','2025-04-04 13:01:12',114.95,'官网');

INSERT INTO `orders` VALUES (77,'RT20250405000077',239,'PAID','2025-04-05 19:14:40','2025-04-05 19:19:40',391.00,'小程序');

INSERT INTO `orders` VALUES (78,'RT20250407000078',398,'REFUNDED','2025-04-07 10:12:13','2025-04-07 11:15:13',32.90,'小程序');

INSERT INTO `orders` VALUES (79,'RT20250407000079',384,'PAID','2025-04-07 21:13:38','2025-04-07 21:51:38',39.00,'小程序');

INSERT INTO `orders` VALUES (80,'RT20250408000080',260,'PAID','2025-04-08 12:55:38','2025-04-08 13:10:38',56.56,'小程序');

INSERT INTO `orders` VALUES (81,'RT20250409000081',473,'CANCELLED','2025-04-09 12:00:09',NULL,37.91,'小程序');

INSERT INTO `orders` VALUES (82,'RT20250409000082',23,'PAID','2025-04-09 19:42:53','2025-04-09 20:41:53',76.95,'官网');

INSERT INTO `orders` VALUES (83,'RT20250409000083',239,'PAID','2025-04-09 22:52:29','2025-04-10 00:02:29',68.00,'线下门店');

INSERT INTO `orders` VALUES (84,'RT20250410000084',370,'PAID','2025-04-10 18:16:02','2025-04-10 18:47:02',78.00,'线下门店');

INSERT INTO `orders` VALUES (85,'RT20250410000085',32,'PAID','2025-04-10 20:38:45','2025-04-10 21:43:45',75.05,'官网');

INSERT INTO `orders` VALUES (86,'RT20250411000086',339,'CANCELLED','2025-04-11 12:47:52',NULL,23.66,'小程序');

INSERT INTO `orders` VALUES (87,'RT20250411000087',290,'PAID','2025-04-11 13:24:05','2025-04-11 13:48:05',39.90,'线下门店');

INSERT INTO `orders` VALUES (88,'RT20250411000088',356,'REFUNDED','2025-04-11 17:52:59','2025-04-11 18:43:59',39.00,'小程序');

INSERT INTO `orders` VALUES (89,'RT20250411000089',34,'PAID','2025-04-11 20:36:18','2025-04-11 21:43:18',338.00,'小程序');

INSERT INTO `orders` VALUES (90,'RT20250412000090',146,'PAID','2025-04-12 19:53:38','2025-04-12 20:11:38',247.00,'官网');

INSERT INTO `orders` VALUES (91,'RT20250413000091',265,'PAID','2025-04-13 12:20:29','2025-04-13 13:17:29',39.90,'官网');

INSERT INTO `orders` VALUES (92,'RT20250414000092',207,'PAID','2025-04-14 12:11:31','2025-04-14 12:40:31',79.00,'线下门店');

INSERT INTO `orders` VALUES (93,'RT20250414000093',37,'PAID','2025-04-14 13:32:39','2025-04-14 13:37:39',137.00,'小程序');

INSERT INTO `orders` VALUES (94,'RT20250415000094',330,'PAID','2025-04-15 12:46:27','2025-04-15 13:15:27',32.90,'小程序');

INSERT INTO `orders` VALUES (95,'RT20250415000095',129,'PAID','2025-04-15 14:05:17','2025-04-15 14:53:17',173.05,'线下门店');

INSERT INTO `orders` VALUES (96,'RT20250416000096',57,'PAID','2025-04-16 11:54:38','2025-04-16 12:43:38',61.20,'线下门店');

INSERT INTO `orders` VALUES (97,'RT20250416000097',17,'PAID','2025-04-16 15:18:52','2025-04-16 15:19:52',68.00,'线下门店');

INSERT INTO `orders` VALUES (98,'RT20250417000098',435,'PAID','2025-04-17 16:58:53','2025-04-17 18:04:53',117.15,'小程序');

INSERT INTO `orders` VALUES (99,'RT20250417000099',473,'PAID','2025-04-17 17:27:09','2025-04-17 18:05:09',32.90,'线下门店');

INSERT INTO `orders` VALUES (100,'RT20250417000100',453,'PAID','2025-04-17 19:26:11','2025-04-17 19:42:11',129.00,'小程序');

INSERT INTO `orders` VALUES (101,'RT20250418000101',435,'PAID','2025-04-18 11:34:21','2025-04-18 12:30:21',59.00,'官网');

INSERT INTO `orders` VALUES (102,'RT20250419000102',244,'PAID','2025-04-19 18:44:02','2025-04-19 18:50:02',75.05,'线下门店');

INSERT INTO `orders` VALUES (103,'RT20250420000103',305,'PAID','2025-04-20 10:38:44','2025-04-20 11:13:44',35.10,'小程序');

INSERT INTO `orders` VALUES (104,'RT20250420000104',547,'PAID','2025-04-20 17:01:13','2025-04-20 17:23:13',39.90,'官网');

INSERT INTO `orders` VALUES (105,'RT20250421000105',530,'PAID','2025-04-21 13:29:48','2025-04-21 13:37:48',71.82,'小程序');

INSERT INTO `orders` VALUES (106,'RT20250421000106',90,'PAID','2025-04-21 19:11:03','2025-04-21 20:05:03',39.00,'小程序');

INSERT INTO `orders` VALUES (107,'RT20250422000107',381,'PAID','2025-04-22 12:38:57','2025-04-22 13:48:57',39.90,'线下门店');

INSERT INTO `orders` VALUES (108,'RT20250425000108',268,'PAID','2025-04-25 11:55:39','2025-04-25 13:00:39',75.81,'小程序');

INSERT INTO `orders` VALUES (109,'RT20250427000109',199,'PAID','2025-04-27 13:48:12','2025-04-27 14:43:12',59.00,'企业采购');

INSERT INTO `orders` VALUES (110,'RT20250427000110',529,'PAID','2025-04-27 18:28:25','2025-04-27 19:17:25',272.10,'线下门店');

INSERT INTO `orders` VALUES (111,'RT20250427000111',96,'PAID','2025-04-27 21:46:47','2025-04-27 22:37:47',299.00,'线下门店');

INSERT INTO `orders` VALUES (112,'RT20250428000112',123,'PAID','2025-04-28 20:45:26','2025-04-28 21:56:26',327.10,'官网');

INSERT INTO `orders` VALUES (113,'RT20250503000113',259,'PAID','2025-05-03 18:01:27','2025-05-03 18:05:27',367.65,'官网');

INSERT INTO `orders` VALUES (114,'RT20250505000114',364,'PAID','2025-05-05 09:35:02','2025-05-05 10:20:02',201.90,'小程序');

INSERT INTO `orders` VALUES (115,'RT20250505000115',74,'PAID','2025-05-05 10:18:54','2025-05-05 11:21:54',79.00,'小程序');

INSERT INTO `orders` VALUES (116,'RT20250505000116',421,'PAID','2025-05-05 12:34:10','2025-05-05 12:57:10',699.00,'小程序');

INSERT INTO `orders` VALUES (117,'RT20250505000117',90,'PAID','2025-05-05 15:00:57','2025-05-05 15:27:57',29.61,'官网');

INSERT INTO `orders` VALUES (118,'RT20250505000118',439,'PAID','2025-05-05 16:22:02','2025-05-05 16:58:02',364.00,'官网');

INSERT INTO `orders` VALUES (119,'RT20250506000119',184,'PAID','2025-05-06 10:59:50','2025-05-06 11:18:50',63.90,'官网');

INSERT INTO `orders` VALUES (120,'RT20250506000120',533,'PAID','2025-05-06 20:07:55','2025-05-06 20:16:55',99.26,'线下门店');

INSERT INTO `orders` VALUES (121,'RT20250506000121',165,'CANCELLED','2025-05-06 20:40:34',NULL,231.90,'企业采购');

INSERT INTO `orders` VALUES (122,'RT20250508000122',43,'PAID','2025-05-08 11:35:53','2025-05-08 11:36:53',65.80,'线下门店');

INSERT INTO `orders` VALUES (123,'RT20250508000123',31,'CANCELLED','2025-05-08 19:30:40',NULL,167.00,'线下门店');

INSERT INTO `orders` VALUES (124,'RT20250509000124',166,'PAID','2025-05-09 09:13:34','2025-05-09 09:25:34',78.00,'官网');

INSERT INTO `orders` VALUES (125,'RT20250509000125',354,'PAID','2025-05-09 14:13:49','2025-05-09 15:17:49',103.71,'线下门店');

INSERT INTO `orders` VALUES (126,'RT20250509000126',519,'PAID','2025-05-09 15:02:29','2025-05-09 16:12:29',507.00,'线下门店');

INSERT INTO `orders` VALUES (127,'RT20250509000127',352,'REFUNDED','2025-05-09 18:08:05','2025-05-09 19:05:05',39.00,'小程序');

INSERT INTO `orders` VALUES (128,'RT20250509000128',153,'PAID','2025-05-09 18:48:43','2025-05-09 19:52:43',118.90,'小程序');

INSERT INTO `orders` VALUES (129,'RT20250509000129',258,'REFUNDED','2025-05-09 19:09:10','2025-05-09 20:05:10',359.10,'线下门店');

INSERT INTO `orders` VALUES (130,'RT20250510000130',321,'PAID','2025-05-10 11:35:30','2025-05-10 12:28:30',160.55,'官网');

INSERT INTO `orders` VALUES (131,'RT20250510000131',184,'PAID','2025-05-10 13:37:14','2025-05-10 14:31:14',68.00,'官网');

INSERT INTO `orders` VALUES (132,'RT20250513000132',107,'PAID','2025-05-13 14:36:08','2025-05-13 15:02:08',24.90,'小程序');

INSERT INTO `orders` VALUES (133,'RT20250513000133',352,'CANCELLED','2025-05-13 19:17:11',NULL,383.55,'小程序');

INSERT INTO `orders` VALUES (134,'RT20250514000134',390,'PAID','2025-05-14 15:40:36','2025-05-14 15:45:36',89.00,'小程序');

INSERT INTO `orders` VALUES (135,'RT20250514000135',72,'PAID','2025-05-14 18:55:12','2025-05-14 19:03:12',24.90,'线下门店');

INSERT INTO `orders` VALUES (136,'RT20250515000136',390,'PAID','2025-05-15 16:23:04','2025-05-15 17:00:04',109.20,'小程序');

INSERT INTO `orders` VALUES (137,'RT20250515000137',322,'PAID','2025-05-15 16:46:20','2025-05-15 17:29:20',152.91,'小程序');

INSERT INTO `orders` VALUES (138,'RT20250515000138',154,'CANCELLED','2025-05-15 19:37:11',NULL,62.10,'线下门店');

INSERT INTO `orders` VALUES (139,'RT20250516000139',216,'PAID','2025-05-16 11:11:22','2025-05-16 11:57:22',57.80,'线下门店');

INSERT INTO `orders` VALUES (140,'RT20250516000140',226,'PAID','2025-05-16 13:22:42','2025-05-16 13:24:42',24.90,'小程序');

INSERT INTO `orders` VALUES (141,'RT20250516000141',8,'PAID','2025-05-16 17:40:34','2025-05-16 18:54:34',39.00,'小程序');

INSERT INTO `orders` VALUES (142,'RT20250516000142',219,'PAID','2025-05-16 19:11:05','2025-05-16 19:46:05',129.00,'企业采购');

INSERT INTO `orders` VALUES (143,'RT20250517000143',235,'CANCELLED','2025-05-17 11:59:41',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (144,'RT20250517000144',575,'PAID','2025-05-17 19:24:24','2025-05-17 19:44:24',59.00,'小程序');

INSERT INTO `orders` VALUES (145,'RT20250518000145',182,'PAID','2025-05-18 12:42:45','2025-05-18 13:52:45',91.90,'小程序');

INSERT INTO `orders` VALUES (146,'RT20250518000146',601,'PAID','2025-05-18 15:26:21','2025-05-18 15:42:21',786.00,'小程序');

INSERT INTO `orders` VALUES (147,'RT20250519000147',393,'PAID','2025-05-19 15:38:35','2025-05-19 15:54:35',39.00,'线下门店');

INSERT INTO `orders` VALUES (148,'RT20250519000148',430,'CANCELLED','2025-05-19 18:10:38',NULL,190.55,'小程序');

INSERT INTO `orders` VALUES (149,'RT20250520000149',2,'REFUNDED','2025-05-20 16:32:01','2025-05-20 16:38:01',32.90,'官网');

INSERT INTO `orders` VALUES (150,'RT20250521000150',8,'CANCELLED','2025-05-21 11:30:15',NULL,287.05,'官网');

INSERT INTO `orders` VALUES (151,'RT20250522000151',356,'REFUNDED','2025-05-22 12:26:06','2025-05-22 12:51:06',318.00,'官网');

INSERT INTO `orders` VALUES (152,'RT20250523000152',22,'CANCELLED','2025-05-23 21:06:25',NULL,37.05,'官网');

INSERT INTO `orders` VALUES (153,'RT20250524000153',99,'CANCELLED','2025-05-24 10:52:18',NULL,228.55,'线下门店');

INSERT INTO `orders` VALUES (154,'RT20250524000154',469,'PAID','2025-05-24 16:13:01','2025-05-24 16:35:01',169.00,'官网');

INSERT INTO `orders` VALUES (155,'RT20250525000155',259,'PAID','2025-05-25 12:35:00','2025-05-25 12:59:00',57.80,'线下门店');

INSERT INTO `orders` VALUES (156,'RT20250525000156',258,'PAID','2025-05-25 14:03:05','2025-05-25 14:48:05',23.66,'线下门店');

INSERT INTO `orders` VALUES (157,'RT20250527000157',608,'CANCELLED','2025-05-27 12:59:02',NULL,107.90,'线下门店');

INSERT INTO `orders` VALUES (158,'RT20250527000158',514,'CANCELLED','2025-05-27 18:23:36',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (159,'RT20250528000159',49,'PAID','2025-05-28 13:52:01','2025-05-28 14:55:01',31.26,'线下门店');

INSERT INTO `orders` VALUES (160,'RT20250529000160',22,'PAID','2025-05-29 13:28:41','2025-05-29 13:54:41',159.00,'官网');

INSERT INTO `orders` VALUES (161,'RT20250529000161',28,'PAID','2025-05-29 16:27:15','2025-05-29 16:46:15',89.00,'小程序');

INSERT INTO `orders` VALUES (162,'RT20250530000162',573,'PAID','2025-05-30 18:28:02','2025-05-30 18:36:02',68.00,'小程序');

INSERT INTO `orders` VALUES (163,'RT20250531000163',322,'PAID','2025-05-31 12:12:30','2025-05-31 13:11:30',39.00,'小程序');

INSERT INTO `orders` VALUES (164,'RT20250531000164',449,'PAID','2025-05-31 18:32:44','2025-05-31 18:41:44',70.81,'线下门店');

INSERT INTO `orders` VALUES (165,'RT20250601000165',385,'PAID','2025-06-01 11:35:17','2025-06-01 12:16:17',71.16,'线下门店');

INSERT INTO `orders` VALUES (166,'RT20250601000166',272,'PAID','2025-06-01 12:21:39','2025-06-01 13:01:39',32.90,'企业采购');

INSERT INTO `orders` VALUES (167,'RT20250601000167',580,'PAID','2025-06-01 15:41:26','2025-06-01 16:31:26',39.90,'官网');

INSERT INTO `orders` VALUES (168,'RT20250601000168',146,'PAID','2025-06-01 16:30:59','2025-06-01 16:52:59',237.00,'小程序');

INSERT INTO `orders` VALUES (169,'RT20250601000169',90,'CANCELLED','2025-06-01 20:57:13',NULL,112.10,'小程序');

INSERT INTO `orders` VALUES (170,'RT20250602000170',205,'REFUNDED','2025-06-02 12:01:38','2025-06-02 12:28:38',113.10,'小程序');

INSERT INTO `orders` VALUES (171,'RT20250602000171',72,'REFUNDED','2025-06-02 15:25:56','2025-06-02 15:30:56',79.80,'线下门店');

INSERT INTO `orders` VALUES (172,'RT20250602000172',40,'PAID','2025-06-02 17:22:59','2025-06-02 17:48:59',31.26,'小程序');

INSERT INTO `orders` VALUES (173,'RT20250603000173',186,'CANCELLED','2025-06-03 11:23:40',NULL,267.00,'线下门店');

INSERT INTO `orders` VALUES (174,'RT20250603000174',28,'PAID','2025-06-03 16:19:23','2025-06-03 17:28:23',150.90,'小程序');

INSERT INTO `orders` VALUES (175,'RT20250603000175',187,'PAID','2025-06-03 17:09:07','2025-06-03 17:22:07',80.21,'线下门店');

INSERT INTO `orders` VALUES (176,'RT20250604000176',452,'PAID','2025-06-04 14:21:19','2025-06-04 15:12:19',118.00,'线下门店');

INSERT INTO `orders` VALUES (177,'RT20250605000177',68,'PAID','2025-06-05 18:40:54','2025-06-05 19:25:54',798.00,'官网');

INSERT INTO `orders` VALUES (178,'RT20250605000178',123,'PAID','2025-06-05 18:57:15','2025-06-05 20:06:15',39.00,'小程序');

INSERT INTO `orders` VALUES (179,'RT20250606000179',202,'PAID','2025-06-06 12:16:02','2025-06-06 12:23:02',69.00,'官网');

INSERT INTO `orders` VALUES (180,'RT20250606000180',582,'PAID','2025-06-06 14:23:01','2025-06-06 14:43:01',103.60,'官网');

INSERT INTO `orders` VALUES (181,'RT20250606000181',22,'PAID','2025-06-06 17:21:01','2025-06-06 18:00:01',59.00,'小程序');

INSERT INTO `orders` VALUES (182,'RT20250607000182',296,'PAID','2025-06-07 13:53:50','2025-06-07 14:21:50',39.90,'小程序');

INSERT INTO `orders` VALUES (183,'RT20250607000183',180,'PAID','2025-06-07 16:49:16','2025-06-07 17:10:16',35.10,'小程序');

INSERT INTO `orders` VALUES (184,'RT20250608000184',244,'PAID','2025-06-08 13:17:09','2025-06-08 14:00:09',32.90,'小程序');

INSERT INTO `orders` VALUES (185,'RT20250608000185',580,'PAID','2025-06-08 19:07:04','2025-06-08 19:58:04',39.90,'线下门店');

INSERT INTO `orders` VALUES (186,'RT20250609000186',572,'PAID','2025-06-09 11:57:04','2025-06-09 12:36:04',144.40,'线下门店');

INSERT INTO `orders` VALUES (187,'RT20250609000187',68,'PAID','2025-06-09 12:05:35','2025-06-09 12:09:35',59.00,'小程序');

INSERT INTO `orders` VALUES (188,'RT20250610000188',495,'PAID','2025-06-10 09:14:04','2025-06-10 09:58:04',24.90,'小程序');

INSERT INTO `orders` VALUES (189,'RT20250610000189',42,'PAID','2025-06-10 13:20:36','2025-06-10 14:24:36',106.20,'小程序');

INSERT INTO `orders` VALUES (190,'RT20250610000190',330,'PAID','2025-06-10 15:50:10','2025-06-10 16:47:10',37.91,'官网');

INSERT INTO `orders` VALUES (191,'RT20250610000191',35,'PAID','2025-06-10 18:25:06','2025-06-10 18:53:06',24.90,'小程序');

INSERT INTO `orders` VALUES (192,'RT20250611000192',28,'PAID','2025-06-11 12:58:44','2025-06-11 13:49:44',37.05,'小程序');

INSERT INTO `orders` VALUES (193,'RT20250611000193',219,'PAID','2025-06-11 16:39:32','2025-06-11 17:18:32',84.55,'企业采购');

INSERT INTO `orders` VALUES (194,'RT20250612000194',586,'PAID','2025-06-12 09:55:21','2025-06-12 10:54:21',8620.41,'小程序');

INSERT INTO `orders` VALUES (195,'RT20250612000195',257,'PAID','2025-06-12 15:45:25','2025-06-12 15:53:25',89.00,'小程序');

INSERT INTO `orders` VALUES (196,'RT20250612000196',14,'REFUNDED','2025-06-12 17:33:18','2025-06-12 18:27:18',129.00,'线下门店');

INSERT INTO `orders` VALUES (197,'RT20250613000197',553,'PAID','2025-06-13 10:10:59','2025-06-13 10:17:59',61.20,'线下门店');

INSERT INTO `orders` VALUES (198,'RT20250613000198',427,'PAID','2025-06-13 14:11:27','2025-06-13 14:17:27',325.67,'官网');

INSERT INTO `orders` VALUES (199,'RT20250613000199',218,'PAID','2025-06-13 14:47:44','2025-06-13 15:58:44',79.00,'线下门店');

INSERT INTO `orders` VALUES (200,'RT20250613000200',12,'PAID','2025-06-13 16:26:32','2025-06-13 16:51:32',39.00,'线下门店');

INSERT INTO `orders` VALUES (201,'RT20250613000201',457,'PAID','2025-06-13 16:42:12','2025-06-13 17:48:12',129.00,'小程序');

INSERT INTO `orders` VALUES (202,'RT20250613000202',432,'PAID','2025-06-13 19:39:25','2025-06-13 20:31:25',72.80,'线下门店');

INSERT INTO `orders` VALUES (203,'RT20250614000203',312,'PAID','2025-06-14 11:37:15','2025-06-14 12:31:15',169.10,'线下门店');

INSERT INTO `orders` VALUES (204,'RT20250614000204',297,'PAID','2025-06-14 14:31:35','2025-06-14 15:41:35',75.05,'小程序');

INSERT INTO `orders` VALUES (205,'RT20250614000205',483,'PAID','2025-06-14 15:06:53','2025-06-14 15:33:53',39.00,'企业采购');

INSERT INTO `orders` VALUES (206,'RT20250614000206',13,'PAID','2025-06-14 18:04:17','2025-06-14 18:47:17',169.00,'官网');

INSERT INTO `orders` VALUES (207,'RT20250615000207',432,'PAID','2025-06-15 19:46:45','2025-06-15 20:11:45',212.91,'线下门店');

INSERT INTO `orders` VALUES (208,'RT20250616000208',186,'PAID','2025-06-16 15:30:00','2025-06-16 15:37:00',158.00,'小程序');

INSERT INTO `orders` VALUES (209,'RT20250616000209',235,'PAID','2025-06-16 18:48:12','2025-06-16 18:51:12',24.90,'小程序');

INSERT INTO `orders` VALUES (210,'RT20250617000210',536,'PAID','2025-06-17 12:46:06','2025-06-17 13:29:06',79.00,'线下门店');

INSERT INTO `orders` VALUES (211,'RT20250618000211',49,'PAID','2025-06-18 10:06:55','2025-06-18 10:26:55',150.90,'小程序');

INSERT INTO `orders` VALUES (212,'RT20250618000212',116,'PAID','2025-06-18 16:43:01','2025-06-18 17:31:01',35.10,'官网');

INSERT INTO `orders` VALUES (213,'RT20250618000213',447,'PAID','2025-06-18 20:16:51','2025-06-18 21:11:51',178.00,'小程序');

INSERT INTO `orders` VALUES (214,'RT20250618000214',207,'PAID','2025-06-18 22:55:06','2025-06-18 23:36:06',399.00,'小程序');

INSERT INTO `orders` VALUES (215,'RT20250619000215',289,'PAID','2025-06-19 17:54:32','2025-06-19 18:18:32',39.00,'线下门店');

INSERT INTO `orders` VALUES (216,'RT20250620000216',417,'PAID','2025-06-20 13:07:46','2025-06-20 13:39:46',56.05,'小程序');

INSERT INTO `orders` VALUES (217,'RT20250620000217',33,'PAID','2025-06-20 13:27:51','2025-06-20 13:46:51',247.90,'小程序');

INSERT INTO `orders` VALUES (218,'RT20250621000218',2,'PAID','2025-06-21 16:03:56','2025-06-21 17:17:56',37.05,'小程序');

INSERT INTO `orders` VALUES (219,'RT20250621000219',12,'PAID','2025-06-21 16:13:56','2025-06-21 16:37:56',178.00,'小程序');

INSERT INTO `orders` VALUES (220,'RT20250621000220',228,'PAID','2025-06-21 16:52:39','2025-06-21 17:52:39',117.90,'小程序');

INSERT INTO `orders` VALUES (221,'RT20250621000221',474,'PAID','2025-06-21 17:29:30','2025-06-21 17:39:30',68.00,'小程序');

INSERT INTO `orders` VALUES (222,'RT20250621000222',60,'PAID','2025-06-21 18:02:26','2025-06-21 19:10:26',24.90,'企业采购');

INSERT INTO `orders` VALUES (223,'RT20250621000223',552,'PAID','2025-06-21 20:50:25','2025-06-21 21:54:25',35.91,'线下门店');

INSERT INTO `orders` VALUES (224,'RT20250621000224',163,'PAID','2025-06-21 21:00:42','2025-06-21 21:25:42',37.05,'企业采购');

INSERT INTO `orders` VALUES (225,'RT20250622000225',43,'REFUNDED','2025-06-22 09:01:17','2025-06-22 10:15:17',299.00,'线下门店');

INSERT INTO `orders` VALUES (226,'RT20250622000226',184,'PAID','2025-06-22 11:19:12','2025-06-22 12:13:12',62.10,'小程序');

INSERT INTO `orders` VALUES (227,'RT20250622000227',464,'PAID','2025-06-22 12:27:16','2025-06-22 12:57:16',68.00,'官网');

INSERT INTO `orders` VALUES (228,'RT20250622000228',174,'PAID','2025-06-22 12:42:50','2025-06-22 13:36:50',59.00,'线下门店');

INSERT INTO `orders` VALUES (229,'RT20250622000229',421,'CANCELLED','2025-06-22 18:54:38',NULL,53.10,'小程序');

INSERT INTO `orders` VALUES (230,'RT20250622000230',169,'PAID','2025-06-22 19:09:33','2025-06-22 19:28:33',72.80,'官网');

INSERT INTO `orders` VALUES (231,'RT20250622000231',217,'PAID','2025-06-22 19:16:19','2025-06-22 19:40:19',83.90,'线下门店');

INSERT INTO `orders` VALUES (232,'RT20250622000232',204,'PAID','2025-06-22 19:18:25','2025-06-22 20:13:25',68.00,'官网');

INSERT INTO `orders` VALUES (233,'RT20250623000233',399,'CANCELLED','2025-06-23 16:51:07',NULL,118.00,'官网');

INSERT INTO `orders` VALUES (234,'RT20250623000234',192,'PAID','2025-06-23 21:27:35','2025-06-23 22:18:35',59.00,'小程序');

INSERT INTO `orders` VALUES (235,'RT20250624000235',327,'PAID','2025-06-24 12:42:33','2025-06-24 12:59:33',61.20,'线下门店');

INSERT INTO `orders` VALUES (236,'RT20250624000236',330,'PAID','2025-06-24 18:56:51','2025-06-24 19:27:51',59.00,'小程序');

INSERT INTO `orders` VALUES (237,'RT20250624000237',156,'REFUNDED','2025-06-24 19:00:30','2025-06-24 20:11:30',39.00,'小程序');

INSERT INTO `orders` VALUES (238,'RT20250624000238',505,'PAID','2025-06-24 20:45:18','2025-06-24 21:16:18',158.00,'小程序');

INSERT INTO `orders` VALUES (239,'RT20250624000239',416,'PAID','2025-06-24 20:46:01','2025-06-24 20:49:01',68.00,'官网');

INSERT INTO `orders` VALUES (240,'RT20250625000240',97,'PAID','2025-06-25 10:46:46','2025-06-25 11:44:46',68.00,'小程序');

INSERT INTO `orders` VALUES (241,'RT20250625000241',489,'PAID','2025-06-25 14:58:44','2025-06-25 15:53:44',68.00,'线下门店');

INSERT INTO `orders` VALUES (242,'RT20250625000242',239,'PAID','2025-06-25 20:50:36','2025-06-25 22:00:36',178.00,'线下门店');

INSERT INTO `orders` VALUES (243,'RT20250625000243',336,'PAID','2025-06-25 21:26:30','2025-06-25 22:31:30',101.10,'线下门店');

INSERT INTO `orders` VALUES (244,'RT20250626000244',439,'PAID','2025-06-26 08:07:49','2025-06-26 09:12:49',185.00,'小程序');

INSERT INTO `orders` VALUES (245,'RT20250626000245',125,'CANCELLED','2025-06-26 11:10:30',NULL,159.00,'企业采购');

INSERT INTO `orders` VALUES (246,'RT20250626000246',326,'PAID','2025-06-26 14:44:10','2025-06-26 15:18:10',68.00,'官网');

INSERT INTO `orders` VALUES (247,'RT20250626000247',600,'PAID','2025-06-26 15:27:13','2025-06-26 16:06:13',39.90,'小程序');

INSERT INTO `orders` VALUES (248,'RT20250626000248',28,'PAID','2025-06-26 20:19:45','2025-06-26 20:31:45',56.05,'线下门店');

INSERT INTO `orders` VALUES (249,'RT20250627000249',461,'PAID','2025-06-27 13:46:14','2025-06-27 13:51:14',237.00,'官网');

INSERT INTO `orders` VALUES (250,'RT20250627000250',452,'PAID','2025-06-27 16:09:26','2025-06-27 16:26:26',68.00,'线下门店');

INSERT INTO `orders` VALUES (251,'RT20250628000251',14,'PAID','2025-06-28 19:36:01','2025-06-28 20:16:01',39.00,'线下门店');

INSERT INTO `orders` VALUES (252,'RT20250629000252',244,'REFUNDED','2025-06-29 12:47:01','2025-06-29 12:55:01',31.26,'线下门店');

INSERT INTO `orders` VALUES (253,'RT20250629000253',29,'CANCELLED','2025-06-29 12:56:47',NULL,76.91,'小程序');

INSERT INTO `orders` VALUES (254,'RT20250629000254',514,'PAID','2025-06-29 13:15:31','2025-06-29 14:18:31',169.90,'小程序');

INSERT INTO `orders` VALUES (255,'RT20250629000255',327,'PAID','2025-06-29 13:59:17','2025-06-29 14:45:17',64.80,'小程序');

INSERT INTO `orders` VALUES (256,'RT20250629000256',591,'REFUNDED','2025-06-29 19:14:48','2025-06-29 20:18:48',37.05,'小程序');

INSERT INTO `orders` VALUES (257,'RT20250629000257',316,'PAID','2025-06-29 19:22:58','2025-06-29 20:25:58',124.80,'小程序');

INSERT INTO `orders` VALUES (258,'RT20250629000258',254,'PAID','2025-06-29 20:58:31','2025-06-29 21:35:31',23.66,'小程序');

INSERT INTO `orders` VALUES (259,'RT20250630000259',49,'PAID','2025-06-30 10:38:09','2025-06-30 11:27:09',118.00,'小程序');

INSERT INTO `orders` VALUES (260,'RT20250630000260',332,'PAID','2025-06-30 16:12:22','2025-06-30 17:21:22',79.00,'小程序');

INSERT INTO `orders` VALUES (261,'RT20250630000261',300,'PAID','2025-06-30 17:22:36','2025-06-30 18:29:36',56.05,'小程序');

INSERT INTO `orders` VALUES (262,'RT20250630000262',622,'CANCELLED','2025-06-30 19:52:07',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (263,'RT20250701000263',357,'PAID','2025-07-01 19:04:52','2025-07-01 19:08:52',39.90,'小程序');

INSERT INTO `orders` VALUES (264,'RT20250701000264',64,'PAID','2025-07-01 19:24:12','2025-07-01 20:12:12',736.91,'小程序');

INSERT INTO `orders` VALUES (265,'RT20250702000265',115,'REFUNDED','2025-07-02 09:45:56','2025-07-02 10:41:56',64.60,'小程序');

INSERT INTO `orders` VALUES (266,'RT20250702000266',254,'CANCELLED','2025-07-02 18:36:29',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (267,'RT20250702000267',151,'PAID','2025-07-02 20:53:03','2025-07-02 21:42:03',32.90,'小程序');

INSERT INTO `orders` VALUES (268,'RT20250703000268',60,'REFUNDED','2025-07-03 08:40:17','2025-07-03 09:39:17',74.10,'线下门店');

INSERT INTO `orders` VALUES (269,'RT20250703000269',405,'PAID','2025-07-03 12:32:01','2025-07-03 12:52:01',148.17,'小程序');

INSERT INTO `orders` VALUES (270,'RT20250703000270',364,'PAID','2025-07-03 14:01:46','2025-07-03 14:52:46',32.90,'小程序');

INSERT INTO `orders` VALUES (271,'RT20250704000271',43,'CANCELLED','2025-07-04 10:31:44',NULL,24.90,'官网');

INSERT INTO `orders` VALUES (272,'RT20250704000272',23,'PAID','2025-07-04 14:47:48','2025-07-04 14:51:48',131.86,'线下门店');

INSERT INTO `orders` VALUES (273,'RT20250704000273',37,'PAID','2025-07-04 15:04:23','2025-07-04 15:06:23',68.00,'线下门店');

INSERT INTO `orders` VALUES (274,'RT20250704000274',602,'PAID','2025-07-04 20:18:09','2025-07-04 20:29:09',68.00,'小程序');

INSERT INTO `orders` VALUES (275,'RT20250705000275',534,'PAID','2025-07-05 13:44:01','2025-07-05 14:18:01',96.80,'线下门店');

INSERT INTO `orders` VALUES (276,'RT20250706000276',582,'PAID','2025-07-06 17:45:45','2025-07-06 18:21:45',37.05,'小程序');

INSERT INTO `orders` VALUES (277,'RT20250707000277',151,'PAID','2025-07-07 13:42:17','2025-07-07 14:12:17',146.90,'线下门店');

INSERT INTO `orders` VALUES (278,'RT20250708000278',570,'CANCELLED','2025-07-08 08:33:12',NULL,59.00,'线下门店');

INSERT INTO `orders` VALUES (279,'RT20250708000279',192,'PAID','2025-07-08 11:07:54','2025-07-08 11:37:54',238.90,'官网');

INSERT INTO `orders` VALUES (280,'RT20250708000280',244,'PAID','2025-07-08 18:55:30','2025-07-08 19:54:30',126.05,'线下门店');

INSERT INTO `orders` VALUES (281,'RT20250708000281',178,'PAID','2025-07-08 19:00:09','2025-07-08 19:40:09',122.55,'小程序');

INSERT INTO `orders` VALUES (282,'RT20250708000282',143,'PAID','2025-07-08 20:13:41','2025-07-08 21:21:41',37.05,'线下门店');

INSERT INTO `orders` VALUES (283,'RT20250709000283',557,'PAID','2025-07-09 10:06:18','2025-07-09 10:49:18',68.00,'小程序');

INSERT INTO `orders` VALUES (284,'RT20250709000284',169,'PAID','2025-07-09 14:10:57','2025-07-09 15:21:57',89.00,'官网');

INSERT INTO `orders` VALUES (285,'RT20250709000285',13,'PAID','2025-07-09 18:01:34','2025-07-09 19:14:34',159.00,'线下门店');

INSERT INTO `orders` VALUES (286,'RT20250709000286',241,'PAID','2025-07-09 21:38:52','2025-07-09 22:35:52',192.00,'线下门店');

INSERT INTO `orders` VALUES (287,'RT20250710000287',115,'PAID','2025-07-10 11:18:51','2025-07-10 12:10:51',39.00,'线下门店');

INSERT INTO `orders` VALUES (288,'RT20250710000288',423,'PAID','2025-07-10 11:55:25','2025-07-10 12:34:25',64.60,'小程序');

INSERT INTO `orders` VALUES (289,'RT20250710000289',14,'CANCELLED','2025-07-10 16:41:29',NULL,24.90,'线下门店');

INSERT INTO `orders` VALUES (290,'RT20250710000290',374,'PAID','2025-07-10 17:37:54','2025-07-10 18:28:54',120.20,'小程序');

INSERT INTO `orders` VALUES (291,'RT20250710000291',43,'PAID','2025-07-10 17:58:40','2025-07-10 18:29:40',68.00,'官网');

INSERT INTO `orders` VALUES (292,'RT20250711000292',22,'CANCELLED','2025-07-11 15:40:47',NULL,318.00,'小程序');

INSERT INTO `orders` VALUES (293,'RT20250712000293',509,'PAID','2025-07-12 10:22:45','2025-07-12 10:50:45',24.90,'官网');

INSERT INTO `orders` VALUES (294,'RT20250712000294',576,'PAID','2025-07-12 12:21:52','2025-07-12 13:03:52',53.10,'小程序');

INSERT INTO `orders` VALUES (295,'RT20250713000295',127,'PAID','2025-07-13 10:24:38','2025-07-13 10:34:38',39.00,'官网');

INSERT INTO `orders` VALUES (296,'RT20250714000296',322,'PAID','2025-07-14 11:05:17','2025-07-14 11:38:17',435.91,'线下门店');

INSERT INTO `orders` VALUES (297,'RT20250714000297',186,'PAID','2025-07-14 16:44:36','2025-07-14 17:00:36',116.05,'小程序');

INSERT INTO `orders` VALUES (298,'RT20250714000298',109,'PAID','2025-07-14 17:37:45','2025-07-14 18:27:45',284.05,'小程序');

INSERT INTO `orders` VALUES (299,'RT20250717000299',326,'PAID','2025-07-17 10:38:48','2025-07-17 11:02:48',138.00,'线下门店');

INSERT INTO `orders` VALUES (300,'RT20250717000300',519,'PAID','2025-07-17 10:44:39','2025-07-17 11:43:39',96.05,'小程序');

INSERT INTO `orders` VALUES (301,'RT20250717000301',432,'PAID','2025-07-17 12:22:04','2025-07-17 12:32:04',49.80,'线下门店');

INSERT INTO `orders` VALUES (302,'RT20250717000302',429,'PAID','2025-07-17 18:22:58','2025-07-17 18:30:58',158.00,'小程序');

INSERT INTO `orders` VALUES (303,'RT20250717000303',156,'PAID','2025-07-17 18:34:13','2025-07-17 18:38:13',151.05,'小程序');

INSERT INTO `orders` VALUES (304,'RT20250717000304',459,'CANCELLED','2025-07-17 18:49:11',NULL,206.91,'小程序');

INSERT INTO `orders` VALUES (305,'RT20250718000305',423,'CANCELLED','2025-07-18 17:34:19',NULL,89.00,'企业采购');

INSERT INTO `orders` VALUES (306,'RT20250718000306',163,'PAID','2025-07-18 18:59:17','2025-07-18 19:27:17',78.00,'小程序');

INSERT INTO `orders` VALUES (307,'RT20250719000307',322,'PAID','2025-07-19 18:53:08','2025-07-19 19:11:08',37.91,'线下门店');

INSERT INTO `orders` VALUES (308,'RT20250719000308',368,'PAID','2025-07-19 20:29:24','2025-07-19 21:38:24',68.00,'线下门店');

INSERT INTO `orders` VALUES (309,'RT20250720000309',12,'PAID','2025-07-20 11:10:44','2025-07-20 11:21:44',159.00,'小程序');

INSERT INTO `orders` VALUES (310,'RT20250720000310',94,'PAID','2025-07-20 12:04:16','2025-07-20 13:05:16',79.00,'官网');

INSERT INTO `orders` VALUES (311,'RT20250720000311',26,'PAID','2025-07-20 17:27:44','2025-07-20 17:41:44',39.90,'小程序');

INSERT INTO `orders` VALUES (312,'RT20250720000312',573,'REFUNDED','2025-07-20 18:05:01','2025-07-20 18:34:01',63.90,'小程序');

INSERT INTO `orders` VALUES (313,'RT20250721000313',237,'PAID','2025-07-21 08:44:58','2025-07-21 09:43:58',183.90,'线下门店');

INSERT INTO `orders` VALUES (314,'RT20250721000314',176,'PAID','2025-07-21 13:13:34','2025-07-21 13:24:34',151.05,'官网');

INSERT INTO `orders` VALUES (315,'RT20250721000315',197,'PAID','2025-07-21 14:27:12','2025-07-21 15:34:12',24.90,'小程序');

INSERT INTO `orders` VALUES (316,'RT20250721000316',129,'PAID','2025-07-21 18:01:00','2025-07-21 18:39:00',32.90,'小程序');

INSERT INTO `orders` VALUES (317,'RT20250721000317',253,'PAID','2025-07-21 19:14:22','2025-07-21 19:35:22',39.90,'小程序');

INSERT INTO `orders` VALUES (318,'RT20250721000318',416,'PAID','2025-07-21 19:56:32','2025-07-21 20:57:32',68.00,'小程序');

INSERT INTO `orders` VALUES (319,'RT20250721000319',226,'PAID','2025-07-21 19:58:35','2025-07-21 20:46:35',63.90,'官网');

INSERT INTO `orders` VALUES (320,'RT20250722000320',368,'PAID','2025-07-22 11:53:07','2025-07-22 12:40:07',147.00,'小程序');

INSERT INTO `orders` VALUES (321,'RT20250722000321',568,'PAID','2025-07-22 16:31:16','2025-07-22 17:25:16',39.90,'小程序');

INSERT INTO `orders` VALUES (322,'RT20250722000322',100,'PAID','2025-07-22 19:21:49','2025-07-22 20:22:49',299.00,'小程序');

INSERT INTO `orders` VALUES (323,'RT20250722000323',259,'PAID','2025-07-22 20:50:20','2025-07-22 21:30:20',90.41,'线下门店');

INSERT INTO `orders` VALUES (324,'RT20250724000324',147,'PAID','2025-07-24 18:51:01','2025-07-24 20:06:01',39.00,'小程序');

INSERT INTO `orders` VALUES (325,'RT20250724000325',125,'PAID','2025-07-24 19:21:55','2025-07-24 20:18:55',59.00,'小程序');

INSERT INTO `orders` VALUES (326,'RT20250724000326',251,'PAID','2025-07-24 19:50:22','2025-07-24 19:52:22',32.90,'线下门店');

INSERT INTO `orders` VALUES (327,'RT20250725000327',62,'PAID','2025-07-25 15:35:58','2025-07-25 16:00:58',270.06,'小程序');

INSERT INTO `orders` VALUES (328,'RT20250726000328',409,'PAID','2025-07-26 16:08:45','2025-07-26 16:44:45',39.00,'小程序');

INSERT INTO `orders` VALUES (329,'RT20250726000329',148,'PAID','2025-07-26 17:25:31','2025-07-26 18:35:31',79.00,'线下门店');

INSERT INTO `orders` VALUES (330,'RT20250726000330',36,'PAID','2025-07-26 17:49:55','2025-07-26 18:56:55',103.46,'线下门店');

INSERT INTO `orders` VALUES (331,'RT20250726000331',154,'PAID','2025-07-26 20:37:57','2025-07-26 21:05:57',78.00,'小程序');

INSERT INTO `orders` VALUES (332,'RT20250727000332',68,'PAID','2025-07-27 10:20:20','2025-07-27 11:24:20',158.00,'小程序');

INSERT INTO `orders` VALUES (333,'RT20250728000333',425,'PAID','2025-07-28 10:05:26','2025-07-28 10:06:26',69.00,'线下门店');

INSERT INTO `orders` VALUES (334,'RT20250728000334',57,'PAID','2025-07-28 13:35:48','2025-07-28 14:20:48',37.05,'官网');

INSERT INTO `orders` VALUES (335,'RT20250728000335',546,'PAID','2025-07-28 15:21:57','2025-07-28 15:40:57',39.90,'官网');

INSERT INTO `orders` VALUES (336,'RT20250728000336',197,'PAID','2025-07-28 16:16:00','2025-07-28 17:13:00',213.55,'小程序');

INSERT INTO `orders` VALUES (337,'RT20250728000337',261,'PAID','2025-07-28 19:33:55','2025-07-28 19:50:55',117.00,'官网');

INSERT INTO `orders` VALUES (338,'RT20250729000338',233,'PAID','2025-07-29 17:11:13','2025-07-29 17:40:13',39.90,'官网');

INSERT INTO `orders` VALUES (339,'RT20250730000339',323,'CANCELLED','2025-07-30 17:19:47',NULL,121.90,'小程序');

INSERT INTO `orders` VALUES (340,'RT20250730000340',125,'PAID','2025-07-30 20:17:21','2025-07-30 21:25:21',24.90,'官网');

INSERT INTO `orders` VALUES (341,'RT20250731000341',1,'PAID','2025-07-31 14:01:52','2025-07-31 14:03:52',63.90,'企业采购');

INSERT INTO `orders` VALUES (342,'RT20250731000342',378,'PAID','2025-07-31 15:37:01','2025-07-31 16:11:01',169.00,'小程序');

INSERT INTO `orders` VALUES (343,'RT20250731000343',44,'PAID','2025-07-31 19:02:27','2025-07-31 19:50:27',68.00,'线下门店');

INSERT INTO `orders` VALUES (344,'RT20250731000344',40,'PAID','2025-07-31 20:37:38','2025-07-31 21:00:38',89.00,'企业采购');

INSERT INTO `orders` VALUES (345,'RT20250731000345',597,'CANCELLED','2025-07-31 20:49:25',NULL,39.90,'小程序');

INSERT INTO `orders` VALUES (346,'RT20250801000346',489,'PAID','2025-08-01 21:59:02','2025-08-01 22:01:02',89.00,'官网');

INSERT INTO `orders` VALUES (347,'RT20250802000347',502,'PAID','2025-08-02 10:34:21','2025-08-02 11:06:21',32.90,'线下门店');

INSERT INTO `orders` VALUES (348,'RT20250802000348',614,'PAID','2025-08-02 15:29:29','2025-08-02 16:28:29',59.00,'线下门店');

INSERT INTO `orders` VALUES (349,'RT20250802000349',62,'PAID','2025-08-02 17:21:43','2025-08-02 17:47:43',128.00,'官网');

INSERT INTO `orders` VALUES (350,'RT20250802000350',62,'CANCELLED','2025-08-02 18:05:19',NULL,68.00,'官网');

INSERT INTO `orders` VALUES (351,'RT20250802000351',154,'PAID','2025-08-02 20:39:28','2025-08-02 20:45:28',39.90,'小程序');

INSERT INTO `orders` VALUES (352,'RT20250803000352',299,'PAID','2025-08-03 18:49:43','2025-08-03 19:52:43',436.05,'官网');

INSERT INTO `orders` VALUES (353,'RT20250803000353',439,'PAID','2025-08-03 20:20:49','2025-08-03 21:18:49',39.90,'线下门店');

INSERT INTO `orders` VALUES (354,'RT20250804000354',183,'PAID','2025-08-04 11:23:45','2025-08-04 12:07:45',128.90,'线下门店');

INSERT INTO `orders` VALUES (355,'RT20250804000355',326,'PAID','2025-08-04 15:45:28','2025-08-04 15:50:28',227.00,'小程序');

INSERT INTO `orders` VALUES (356,'RT20250804000356',332,'PAID','2025-08-04 16:25:20','2025-08-04 16:57:20',84.55,'小程序');

INSERT INTO `orders` VALUES (357,'RT20250804000357',109,'PAID','2025-08-04 18:47:29','2025-08-04 19:20:29',125.05,'小程序');

INSERT INTO `orders` VALUES (358,'RT20250804000358',62,'PAID','2025-08-04 19:59:19','2025-08-04 20:53:19',79.00,'小程序');

INSERT INTO `orders` VALUES (359,'RT20250805000359',151,'PAID','2025-08-05 14:31:54','2025-08-05 14:43:54',39.00,'小程序');

INSERT INTO `orders` VALUES (360,'RT20250805000360',42,'PAID','2025-08-05 15:03:44','2025-08-05 15:04:44',79.00,'小程序');

INSERT INTO `orders` VALUES (361,'RT20250805000361',107,'PAID','2025-08-05 20:59:17','2025-08-05 22:05:17',233.10,'小程序');

INSERT INTO `orders` VALUES (362,'RT20250806000362',245,'REFUNDED','2025-08-06 13:55:20','2025-08-06 14:58:20',32.90,'官网');

INSERT INTO `orders` VALUES (363,'RT20250806000363',412,'PAID','2025-08-06 18:38:25','2025-08-06 18:45:25',71.82,'线下门店');

INSERT INTO `orders` VALUES (364,'RT20250806000364',479,'PAID','2025-08-06 19:27:46','2025-08-06 20:39:46',72.80,'官网');

INSERT INTO `orders` VALUES (365,'RT20250806000365',12,'PAID','2025-08-06 20:26:31','2025-08-06 20:42:31',169.00,'线下门店');

INSERT INTO `orders` VALUES (366,'RT20250806000366',136,'REFUNDED','2025-08-06 21:59:22','2025-08-06 22:43:22',56.05,'小程序');

INSERT INTO `orders` VALUES (367,'RT20250806000367',585,'PAID','2025-08-06 22:04:31','2025-08-06 22:06:31',59.00,'线下门店');

INSERT INTO `orders` VALUES (368,'RT20250807000368',564,'PAID','2025-08-07 08:33:43','2025-08-07 09:38:43',127.00,'官网');

INSERT INTO `orders` VALUES (369,'RT20250808000369',40,'PAID','2025-08-08 10:35:48','2025-08-08 11:49:48',37.91,'小程序');

INSERT INTO `orders` VALUES (370,'RT20250808000370',462,'PAID','2025-08-08 11:29:16','2025-08-08 12:32:16',71.90,'小程序');

INSERT INTO `orders` VALUES (371,'RT20250808000371',15,'PAID','2025-08-08 12:26:58','2025-08-08 13:03:58',138.00,'线下门店');

INSERT INTO `orders` VALUES (372,'RT20250808000372',321,'PAID','2025-08-08 14:12:52','2025-08-08 14:25:52',59.00,'小程序');

INSERT INTO `orders` VALUES (373,'RT20250808000373',62,'CANCELLED','2025-08-08 18:01:45',NULL,202.10,'线下门店');

INSERT INTO `orders` VALUES (374,'RT20250809000374',202,'PAID','2025-08-09 11:24:02','2025-08-09 12:23:02',65.55,'线下门店');

INSERT INTO `orders` VALUES (375,'RT20250809000375',143,'PAID','2025-08-09 13:54:53','2025-08-09 13:56:53',56.05,'官网');

INSERT INTO `orders` VALUES (376,'RT20250809000376',341,'PAID','2025-08-09 15:11:33','2025-08-09 16:07:33',24.90,'官网');

INSERT INTO `orders` VALUES (377,'RT20250810000377',261,'PAID','2025-08-10 12:22:30','2025-08-10 12:49:30',39.00,'线下门店');

INSERT INTO `orders` VALUES (378,'RT20250810000378',627,'PAID','2025-08-10 12:38:08','2025-08-10 13:03:08',39.00,'线下门店');

INSERT INTO `orders` VALUES (379,'RT20250810000379',495,'PAID','2025-08-10 13:50:51','2025-08-10 15:00:51',284.05,'官网');

INSERT INTO `orders` VALUES (380,'RT20250810000380',190,'PAID','2025-08-10 15:40:59','2025-08-10 16:09:59',89.00,'官网');

INSERT INTO `orders` VALUES (381,'RT20250810000381',11,'PAID','2025-08-10 17:13:14','2025-08-10 17:21:14',59.00,'小程序');

INSERT INTO `orders` VALUES (382,'RT20250810000382',91,'PAID','2025-08-10 19:15:07','2025-08-10 20:25:07',100.90,'小程序');

INSERT INTO `orders` VALUES (383,'RT20250810000383',455,'PAID','2025-08-10 20:11:50','2025-08-10 20:26:50',89.00,'小程序');

INSERT INTO `orders` VALUES (384,'RT20250811000384',244,'PAID','2025-08-11 20:31:24','2025-08-11 21:38:24',157.00,'小程序');

INSERT INTO `orders` VALUES (385,'RT20250812000385',17,'PAID','2025-08-12 12:25:14','2025-08-12 12:56:14',93.86,'小程序');

INSERT INTO `orders` VALUES (386,'RT20250812000386',129,'PAID','2025-08-12 15:08:07','2025-08-12 15:30:07',204.00,'小程序');

INSERT INTO `orders` VALUES (387,'RT20250812000387',40,'PAID','2025-08-12 19:22:09','2025-08-12 20:12:09',37.05,'小程序');

INSERT INTO `orders` VALUES (388,'RT20250813000388',466,'PAID','2025-08-13 16:10:07','2025-08-13 16:53:07',159.00,'小程序');

INSERT INTO `orders` VALUES (389,'RT20250813000389',553,'PAID','2025-08-13 17:21:28','2025-08-13 18:34:28',155.65,'小程序');

INSERT INTO `orders` VALUES (390,'RT20250813000390',14,'PAID','2025-08-13 20:48:15','2025-08-13 21:40:15',169.00,'线下门店');

INSERT INTO `orders` VALUES (391,'RT20250814000391',237,'PAID','2025-08-14 09:07:59','2025-08-14 09:14:59',68.00,'小程序');

INSERT INTO `orders` VALUES (392,'RT20250814000392',96,'PAID','2025-08-14 10:53:41','2025-08-14 11:14:41',37.05,'线下门店');

INSERT INTO `orders` VALUES (393,'RT20250815000393',495,'PAID','2025-08-15 10:05:23','2025-08-15 10:56:23',39.00,'线下门店');

INSERT INTO `orders` VALUES (394,'RT20250815000394',204,'PAID','2025-08-15 20:49:41','2025-08-15 22:04:41',92.90,'官网');

INSERT INTO `orders` VALUES (395,'RT20250816000395',580,'PAID','2025-08-16 10:20:28','2025-08-16 10:52:28',39.90,'线下门店');

INSERT INTO `orders` VALUES (396,'RT20250816000396',1,'PAID','2025-08-16 11:46:38','2025-08-16 12:30:38',108.00,'小程序');

INSERT INTO `orders` VALUES (397,'RT20250816000397',611,'PAID','2025-08-16 19:23:52','2025-08-16 20:23:52',32.90,'小程序');

INSERT INTO `orders` VALUES (398,'RT20250816000398',114,'PAID','2025-08-16 19:27:09','2025-08-16 19:29:09',65.55,'小程序');

INSERT INTO `orders` VALUES (399,'RT20250816000399',539,'PAID','2025-08-16 19:52:33','2025-08-16 20:54:33',78.00,'线下门店');

INSERT INTO `orders` VALUES (400,'RT20250816000400',541,'PAID','2025-08-16 20:16:06','2025-08-16 21:16:06',321.10,'线下门店');

INSERT INTO `orders` VALUES (401,'RT20250816000401',482,'PAID','2025-08-16 20:53:45','2025-08-16 21:42:45',108.21,'线下门店');

INSERT INTO `orders` VALUES (402,'RT20250817000402',126,'PAID','2025-08-17 10:32:02','2025-08-17 10:58:02',39.00,'线下门店');

INSERT INTO `orders` VALUES (403,'RT20250817000403',422,'PAID','2025-08-17 18:08:26','2025-08-17 18:40:26',323.00,'小程序');

INSERT INTO `orders` VALUES (404,'RT20250818000404',218,'PAID','2025-08-18 09:51:16','2025-08-18 10:56:16',189.05,'企业采购');

INSERT INTO `orders` VALUES (405,'RT20250818000405',163,'PAID','2025-08-18 14:18:45','2025-08-18 15:24:45',318.00,'小程序');

INSERT INTO `orders` VALUES (406,'RT20250818000406',86,'PAID','2025-08-18 16:09:10','2025-08-18 16:57:10',89.00,'线下门店');

INSERT INTO `orders` VALUES (407,'RT20250818000407',308,'PAID','2025-08-18 18:22:12','2025-08-18 19:05:12',79.80,'企业采购');

INSERT INTO `orders` VALUES (408,'RT20250818000408',290,'PAID','2025-08-18 19:29:17','2025-08-18 20:13:17',24.90,'线下门店');

INSERT INTO `orders` VALUES (409,'RT20250819000409',590,'PAID','2025-08-19 11:26:55','2025-08-19 12:05:55',69.00,'小程序');

INSERT INTO `orders` VALUES (410,'RT20250819000410',222,'PAID','2025-08-19 13:19:05','2025-08-19 13:50:05',39.90,'小程序');

INSERT INTO `orders` VALUES (411,'RT20250819000411',390,'PAID','2025-08-19 14:35:09','2025-08-19 15:34:09',79.80,'线下门店');

INSERT INTO `orders` VALUES (412,'RT20250819000412',339,'PAID','2025-08-19 15:06:45','2025-08-19 16:16:45',168.90,'官网');

INSERT INTO `orders` VALUES (413,'RT20250819000413',154,'PAID','2025-08-19 18:35:28','2025-08-19 19:44:28',24.90,'小程序');

INSERT INTO `orders` VALUES (414,'RT20250819000414',171,'PAID','2025-08-19 19:08:41','2025-08-19 20:08:41',218.00,'小程序');

INSERT INTO `orders` VALUES (415,'RT20250820000415',104,'PAID','2025-08-20 19:43:45','2025-08-20 20:47:45',35.10,'官网');

INSERT INTO `orders` VALUES (416,'RT20250821000416',590,'PAID','2025-08-21 11:49:37','2025-08-21 11:59:37',69.00,'线下门店');

INSERT INTO `orders` VALUES (417,'RT20250821000417',156,'PAID','2025-08-21 12:34:05','2025-08-21 12:41:05',185.45,'小程序');

INSERT INTO `orders` VALUES (418,'RT20250821000418',305,'PAID','2025-08-21 13:56:40','2025-08-21 14:40:40',69.00,'小程序');

INSERT INTO `orders` VALUES (419,'RT20250821000419',364,'PAID','2025-08-21 15:58:41','2025-08-21 17:08:41',92.90,'官网');

INSERT INTO `orders` VALUES (420,'RT20250821000420',238,'PAID','2025-08-21 16:08:46','2025-08-21 16:21:46',84.55,'官网');

INSERT INTO `orders` VALUES (421,'RT20250822000421',29,'PAID','2025-08-22 10:50:07','2025-08-22 11:29:07',39.00,'官网');

INSERT INTO `orders` VALUES (422,'RT20250822000422',145,'CANCELLED','2025-08-22 15:43:41',NULL,173.05,'小程序');

INSERT INTO `orders` VALUES (423,'RT20250822000423',498,'PAID','2025-08-22 16:06:48','2025-08-22 16:28:48',65.55,'官网');

INSERT INTO `orders` VALUES (424,'RT20250823000424',289,'PAID','2025-08-23 09:20:04','2025-08-23 09:55:04',37.05,'小程序');

INSERT INTO `orders` VALUES (425,'RT20250823000425',116,'PAID','2025-08-23 15:04:54','2025-08-23 15:32:54',468.81,'官网');

INSERT INTO `orders` VALUES (426,'RT20250824000426',81,'PAID','2025-08-24 09:26:29','2025-08-24 10:20:29',84.55,'线下门店');

INSERT INTO `orders` VALUES (427,'RT20250824000427',300,'PAID','2025-08-24 12:34:33','2025-08-24 13:48:33',399.00,'官网');

INSERT INTO `orders` VALUES (428,'RT20250824000428',175,'PAID','2025-08-24 17:21:55','2025-08-24 18:17:55',59.00,'线下门店');

INSERT INTO `orders` VALUES (429,'RT20250824000429',190,'PAID','2025-08-24 18:55:03','2025-08-24 19:15:03',367.20,'小程序');

INSERT INTO `orders` VALUES (430,'RT20250824000430',97,'PAID','2025-08-24 19:05:38','2025-08-24 19:36:38',223.60,'官网');

INSERT INTO `orders` VALUES (431,'RT20250825000431',388,'PAID','2025-08-25 14:21:46','2025-08-25 14:47:46',32.90,'小程序');

INSERT INTO `orders` VALUES (432,'RT20250825000432',169,'PAID','2025-08-25 15:24:56','2025-08-25 15:42:56',111.80,'小程序');

INSERT INTO `orders` VALUES (433,'RT20250825000433',350,'PAID','2025-08-25 15:39:33','2025-08-25 16:24:33',23.66,'官网');

INSERT INTO `orders` VALUES (434,'RT20250825000434',255,'REFUNDED','2025-08-25 18:51:54','2025-08-25 19:51:54',68.00,'小程序');

INSERT INTO `orders` VALUES (435,'RT20250825000435',483,'PAID','2025-08-25 21:30:51','2025-08-25 22:20:51',69.00,'小程序');

INSERT INTO `orders` VALUES (436,'RT20250826000436',419,'PAID','2025-08-26 14:19:00','2025-08-26 15:14:00',89.00,'官网');

INSERT INTO `orders` VALUES (437,'RT20250826000437',275,'PAID','2025-08-26 17:45:56','2025-08-26 18:59:56',231.90,'官网');

INSERT INTO `orders` VALUES (438,'RT20250826000438',505,'PAID','2025-08-26 18:44:56','2025-08-26 19:23:56',89.00,'官网');

INSERT INTO `orders` VALUES (439,'RT20250827000439',51,'PAID','2025-08-27 11:21:02','2025-08-27 12:31:02',122.40,'小程序');

INSERT INTO `orders` VALUES (440,'RT20250827000440',343,'PAID','2025-08-27 14:34:21','2025-08-27 15:19:21',37.91,'线下门店');

INSERT INTO `orders` VALUES (441,'RT20250827000441',595,'PAID','2025-08-27 16:00:04','2025-08-27 16:23:04',158.00,'线下门店');

INSERT INTO `orders` VALUES (442,'RT20250827000442',489,'PAID','2025-08-27 19:18:10','2025-08-27 19:41:10',828.00,'小程序');

INSERT INTO `orders` VALUES (443,'RT20250827000443',136,'PAID','2025-08-27 20:33:40','2025-08-27 20:42:40',79.00,'小程序');

INSERT INTO `orders` VALUES (444,'RT20250828000444',585,'PAID','2025-08-28 09:46:06','2025-08-28 10:06:06',163.72,'线下门店');

INSERT INTO `orders` VALUES (445,'RT20250828000445',339,'CANCELLED','2025-08-28 12:37:59',NULL,59.00,'线下门店');

INSERT INTO `orders` VALUES (446,'RT20250828000446',454,'PAID','2025-08-28 14:29:17','2025-08-28 15:15:17',79.00,'小程序');

INSERT INTO `orders` VALUES (447,'RT20250828000447',359,'PAID','2025-08-28 18:23:33','2025-08-28 19:37:33',129.00,'官网');

INSERT INTO `orders` VALUES (448,'RT20250829000448',136,'PAID','2025-08-29 19:23:30','2025-08-29 20:34:30',326.00,'小程序');

INSERT INTO `orders` VALUES (449,'RT20250830000449',460,'PAID','2025-08-30 11:11:45','2025-08-30 12:21:45',327.90,'小程序');

INSERT INTO `orders` VALUES (450,'RT20250830000450',600,'PAID','2025-08-30 18:26:47','2025-08-30 18:40:47',86.85,'线下门店');

INSERT INTO `orders` VALUES (451,'RT20250831000451',248,'PAID','2025-08-31 16:54:22','2025-08-31 17:36:22',267.00,'线下门店');

INSERT INTO `orders` VALUES (452,'RT20250831000452',176,'PAID','2025-08-31 18:12:16','2025-08-31 18:21:16',278.15,'小程序');

INSERT INTO `orders` VALUES (453,'RT20250831000453',632,'PAID','2025-08-31 19:03:51','2025-08-31 19:50:51',207.90,'小程序');

INSERT INTO `orders` VALUES (454,'RT20250831000454',343,'PAID','2025-08-31 20:48:54','2025-08-31 21:05:54',24.90,'小程序');

INSERT INTO `orders` VALUES (455,'RT20250831000455',568,'PAID','2025-08-31 20:50:27','2025-08-31 21:19:27',428.00,'小程序');

INSERT INTO `orders` VALUES (456,'RT20250831000456',184,'PAID','2025-08-31 21:48:17','2025-08-31 23:03:17',435.05,'线下门店');

INSERT INTO `orders` VALUES (457,'RT20250901000457',308,'PAID','2025-09-01 09:31:39','2025-09-01 09:53:39',68.00,'小程序');

INSERT INTO `orders` VALUES (458,'RT20250901000458',1,'PAID','2025-09-01 16:35:34','2025-09-01 16:39:34',65.55,'线下门店');

INSERT INTO `orders` VALUES (459,'RT20250901000459',564,'PAID','2025-09-01 17:38:02','2025-09-01 18:46:02',75.81,'小程序');

INSERT INTO `orders` VALUES (460,'RT20250901000460',290,'PAID','2025-09-01 18:15:58','2025-09-01 19:18:58',79.00,'线下门店');

INSERT INTO `orders` VALUES (461,'RT20250901000461',54,'PAID','2025-09-01 18:33:06','2025-09-01 19:44:06',74.91,'小程序');

INSERT INTO `orders` VALUES (462,'RT20250902000462',6,'PAID','2025-09-02 12:28:14','2025-09-02 12:42:14',118.00,'小程序');

INSERT INTO `orders` VALUES (463,'RT20250902000463',177,'PAID','2025-09-02 15:42:57','2025-09-02 16:50:57',24.90,'小程序');

INSERT INTO `orders` VALUES (464,'RT20250902000464',74,'PAID','2025-09-02 16:32:14','2025-09-02 17:06:14',359.10,'小程序');

INSERT INTO `orders` VALUES (465,'RT20250903000465',92,'PAID','2025-09-03 11:08:37','2025-09-03 11:34:37',59.00,'线下门店');

INSERT INTO `orders` VALUES (466,'RT20250903000466',587,'PAID','2025-09-03 11:59:38','2025-09-03 13:10:38',72.80,'小程序');

INSERT INTO `orders` VALUES (467,'RT20250903000467',254,'PAID','2025-09-03 12:48:01','2025-09-03 13:06:01',99.26,'线下门店');

INSERT INTO `orders` VALUES (468,'RT20250903000468',290,'PAID','2025-09-03 12:59:06','2025-09-03 13:00:06',684.10,'小程序');

INSERT INTO `orders` VALUES (469,'RT20250903000469',311,'PAID','2025-09-03 15:37:08','2025-09-03 15:43:08',84.55,'官网');

INSERT INTO `orders` VALUES (470,'RT20250903000470',533,'PAID','2025-09-03 20:48:07','2025-09-03 22:01:07',169.00,'线下门店');

INSERT INTO `orders` VALUES (471,'RT20250903000471',543,'PAID','2025-09-03 21:55:13','2025-09-03 22:22:13',120.26,'官网');

INSERT INTO `orders` VALUES (472,'RT20250904000472',312,'PAID','2025-09-04 10:40:59','2025-09-04 11:24:59',39.90,'小程序');

INSERT INTO `orders` VALUES (473,'RT20250904000473',15,'PAID','2025-09-04 13:39:19','2025-09-04 13:50:19',89.00,'小程序');

INSERT INTO `orders` VALUES (474,'RT20250904000474',627,'CANCELLED','2025-09-04 15:46:03',NULL,762.90,'小程序');

INSERT INTO `orders` VALUES (475,'RT20250904000475',489,'PAID','2025-09-04 16:22:23','2025-09-04 17:21:23',129.00,'小程序');

INSERT INTO `orders` VALUES (476,'RT20250905000476',64,'REFUNDED','2025-09-05 11:15:48','2025-09-05 12:13:48',32.90,'小程序');

INSERT INTO `orders` VALUES (477,'RT20250905000477',291,'PAID','2025-09-05 14:06:35','2025-09-05 14:43:35',96.05,'小程序');

INSERT INTO `orders` VALUES (478,'RT20250905000478',576,'PAID','2025-09-05 14:21:19','2025-09-05 14:42:19',92.90,'官网');

INSERT INTO `orders` VALUES (479,'RT20250905000479',275,'PAID','2025-09-05 14:53:50','2025-09-05 15:04:50',79.00,'官网');

INSERT INTO `orders` VALUES (480,'RT20250905000480',608,'PAID','2025-09-05 15:06:12','2025-09-05 15:46:12',35.10,'小程序');

INSERT INTO `orders` VALUES (481,'RT20250905000481',107,'PAID','2025-09-05 17:19:26','2025-09-05 18:24:26',24.90,'小程序');

INSERT INTO `orders` VALUES (482,'RT20250905000482',149,'PAID','2025-09-05 20:27:36','2025-09-05 21:07:36',39.00,'官网');

INSERT INTO `orders` VALUES (483,'RT20250906000483',382,'CANCELLED','2025-09-06 09:30:43',NULL,70.81,'官网');

INSERT INTO `orders` VALUES (484,'RT20250906000484',352,'REFUNDED','2025-09-06 11:42:20','2025-09-06 12:34:20',89.00,'企业采购');

INSERT INTO `orders` VALUES (485,'RT20250906000485',42,'PAID','2025-09-06 13:31:08','2025-09-06 14:21:08',69.00,'线下门店');

INSERT INTO `orders` VALUES (486,'RT20250906000486',298,'PAID','2025-09-06 14:22:43','2025-09-06 15:35:43',143.10,'线下门店');

INSERT INTO `orders` VALUES (487,'RT20250906000487',570,'PAID','2025-09-06 21:04:28','2025-09-06 22:10:28',24.90,'小程序');

INSERT INTO `orders` VALUES (488,'RT20250907000488',279,'PAID','2025-09-07 11:24:31','2025-09-07 11:28:31',79.80,'线下门店');

INSERT INTO `orders` VALUES (489,'RT20250907000489',114,'PAID','2025-09-07 12:24:13','2025-09-07 12:38:13',31.26,'官网');

INSERT INTO `orders` VALUES (490,'RT20250907000490',617,'CANCELLED','2025-09-07 17:04:48',NULL,35.91,'小程序');

INSERT INTO `orders` VALUES (491,'RT20250907000491',256,'PAID','2025-09-07 19:27:10','2025-09-07 20:03:10',184.21,'官网');

INSERT INTO `orders` VALUES (492,'RT20250908000492',175,'PAID','2025-09-08 19:06:49','2025-09-08 19:52:49',31.26,'官网');

INSERT INTO `orders` VALUES (493,'RT20250908000493',2,'CANCELLED','2025-09-08 20:47:55',NULL,69.00,'官网');

INSERT INTO `orders` VALUES (494,'RT20250909000494',90,'PAID','2025-09-09 12:02:04','2025-09-09 12:37:04',68.00,'官网');

INSERT INTO `orders` VALUES (495,'RT20250909000495',612,'PAID','2025-09-09 12:20:42','2025-09-09 12:44:42',59.00,'小程序');

INSERT INTO `orders` VALUES (496,'RT20250909000496',147,'PAID','2025-09-09 13:27:57','2025-09-09 14:27:57',217.00,'官网');

INSERT INTO `orders` VALUES (497,'RT20250909000497',179,'REFUNDED','2025-09-09 14:46:51','2025-09-09 15:21:51',190.95,'线下门店');

INSERT INTO `orders` VALUES (498,'RT20250909000498',417,'PAID','2025-09-09 16:00:01','2025-09-09 17:14:01',92.90,'线下门店');

INSERT INTO `orders` VALUES (499,'RT20250909000499',44,'PAID','2025-09-09 19:51:54','2025-09-09 20:58:54',89.00,'线下门店');

INSERT INTO `orders` VALUES (500,'RT20250910000500',414,'PAID','2025-09-10 16:10:57','2025-09-10 16:28:57',88.80,'官网');

INSERT INTO `orders` VALUES (501,'RT20250910000501',91,'PAID','2025-09-10 17:36:45','2025-09-10 17:57:45',443.71,'小程序');

INSERT INTO `orders` VALUES (502,'RT20250911000502',540,'PAID','2025-09-11 12:26:23','2025-09-11 13:00:23',138.00,'小程序');

INSERT INTO `orders` VALUES (503,'RT20250911000503',311,'PAID','2025-09-11 15:18:16','2025-09-11 16:27:16',59.00,'小程序');

INSERT INTO `orders` VALUES (504,'RT20250911000504',26,'PAID','2025-09-11 17:03:46','2025-09-11 17:06:46',24.90,'官网');

INSERT INTO `orders` VALUES (505,'RT20250911000505',509,'PAID','2025-09-11 20:25:30','2025-09-11 21:21:30',188.35,'线下门店');

INSERT INTO `orders` VALUES (506,'RT20250911000506',572,'PAID','2025-09-11 20:34:33','2025-09-11 20:59:33',37.91,'小程序');

INSERT INTO `orders` VALUES (507,'RT20250912000507',466,'PAID','2025-09-12 19:24:26','2025-09-12 20:23:26',39.90,'官网');

INSERT INTO `orders` VALUES (508,'RT20250912000508',35,'PAID','2025-09-12 21:50:00','2025-09-12 22:23:00',169.00,'小程序');

INSERT INTO `orders` VALUES (509,'RT20250913000509',585,'PAID','2025-09-13 15:34:53','2025-09-13 15:49:53',138.00,'官网');

INSERT INTO `orders` VALUES (510,'RT20250913000510',504,'PAID','2025-09-13 16:19:51','2025-09-13 17:32:51',461.51,'小程序');

INSERT INTO `orders` VALUES (511,'RT20250913000511',202,'PAID','2025-09-13 16:34:07','2025-09-13 17:37:07',32.90,'线下门店');

INSERT INTO `orders` VALUES (512,'RT20250913000512',175,'PAID','2025-09-13 18:46:21','2025-09-13 19:24:21',326.00,'小程序');

INSERT INTO `orders` VALUES (513,'RT20250913000513',90,'PAID','2025-09-13 21:11:27','2025-09-13 22:11:27',367.00,'线下门店');

INSERT INTO `orders` VALUES (514,'RT20250913000514',414,'PAID','2025-09-13 22:17:27','2025-09-13 22:46:27',64.60,'线下门店');

INSERT INTO `orders` VALUES (515,'RT20250914000515',466,'PAID','2025-09-14 12:59:39','2025-09-14 13:24:39',159.00,'线下门店');

INSERT INTO `orders` VALUES (516,'RT20250914000516',554,'PAID','2025-09-14 13:08:06','2025-09-14 13:09:06',23.66,'小程序');

INSERT INTO `orders` VALUES (517,'RT20250914000517',254,'PAID','2025-09-14 15:01:40','2025-09-14 15:04:40',39.00,'线下门店');

INSERT INTO `orders` VALUES (518,'RT20250914000518',364,'PAID','2025-09-14 15:42:44','2025-09-14 16:29:44',107.90,'官网');

INSERT INTO `orders` VALUES (519,'RT20250914000519',156,'PAID','2025-09-14 18:31:14','2025-09-14 19:14:14',69.00,'小程序');

INSERT INTO `orders` VALUES (520,'RT20250914000520',109,'PAID','2025-09-14 20:19:16','2025-09-14 21:02:16',155.95,'线下门店');

INSERT INTO `orders` VALUES (521,'RT20250915000521',341,'PAID','2025-09-15 17:05:31','2025-09-15 17:09:31',37.05,'线下门店');

INSERT INTO `orders` VALUES (522,'RT20250915000522',396,'CANCELLED','2025-09-15 17:16:12',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (523,'RT20250916000523',459,'CANCELLED','2025-09-16 10:36:47',NULL,59.00,'官网');

INSERT INTO `orders` VALUES (524,'RT20250916000524',414,'PAID','2025-09-16 17:46:07','2025-09-16 18:54:07',32.90,'线下门店');

INSERT INTO `orders` VALUES (525,'RT20250916000525',364,'PAID','2025-09-16 18:38:43','2025-09-16 18:47:43',1107.80,'线下门店');

INSERT INTO `orders` VALUES (526,'RT20250917000526',318,'PAID','2025-09-17 12:31:10','2025-09-17 13:31:10',118.00,'小程序');

INSERT INTO `orders` VALUES (527,'RT20250917000527',87,'PAID','2025-09-17 21:06:12','2025-09-17 21:45:12',32.90,'线下门店');

INSERT INTO `orders` VALUES (528,'RT20250918000528',614,'PAID','2025-09-18 12:00:40','2025-09-18 12:20:40',183.90,'小程序');

INSERT INTO `orders` VALUES (529,'RT20250918000529',193,'PAID','2025-09-18 13:15:31','2025-09-18 13:44:31',291.55,'线下门店');

INSERT INTO `orders` VALUES (530,'RT20250918000530',17,'PAID','2025-09-18 14:40:50','2025-09-18 14:52:50',189.10,'官网');

INSERT INTO `orders` VALUES (531,'RT20250918000531',56,'PAID','2025-09-18 17:01:32','2025-09-18 17:45:32',39.00,'线下门店');

INSERT INTO `orders` VALUES (532,'RT20250919000532',151,'PAID','2025-09-19 14:12:49','2025-09-19 14:44:49',74.10,'小程序');

INSERT INTO `orders` VALUES (533,'RT20250919000533',376,'REFUNDED','2025-09-19 18:27:47','2025-09-19 18:55:47',248.00,'小程序');

INSERT INTO `orders` VALUES (534,'RT20250919000534',601,'PAID','2025-09-19 19:55:48','2025-09-19 20:12:48',59.00,'线下门店');

INSERT INTO `orders` VALUES (535,'RT20250919000535',202,'PAID','2025-09-19 20:54:33','2025-09-19 21:38:33',78.00,'官网');

INSERT INTO `orders` VALUES (536,'RT20250920000536',356,'PAID','2025-09-20 17:11:03','2025-09-20 17:42:03',49.80,'线下门店');

INSERT INTO `orders` VALUES (537,'RT20250921000537',579,'PAID','2025-09-21 10:10:21','2025-09-21 10:18:21',140.16,'小程序');

INSERT INTO `orders` VALUES (538,'RT20250922000538',34,'PAID','2025-09-22 17:42:03','2025-09-22 18:06:03',89.00,'企业采购');

INSERT INTO `orders` VALUES (539,'RT20250922000539',245,'PAID','2025-09-22 18:58:43','2025-09-22 19:49:43',75.00,'小程序');

INSERT INTO `orders` VALUES (540,'RT20250923000540',459,'PAID','2025-09-23 17:55:10','2025-09-23 18:09:10',24.90,'小程序');

INSERT INTO `orders` VALUES (541,'RT20250923000541',566,'PAID','2025-09-23 18:16:03','2025-09-23 18:32:03',56.05,'小程序');

INSERT INTO `orders` VALUES (542,'RT20250923000542',10,'PAID','2025-09-23 18:43:13','2025-09-23 18:46:13',241.91,'小程序');

INSERT INTO `orders` VALUES (543,'RT20250923000543',124,'PAID','2025-09-23 18:58:33','2025-09-23 19:02:33',79.00,'小程序');

INSERT INTO `orders` VALUES (544,'RT20250923000544',208,'PAID','2025-09-23 22:47:31','2025-09-23 23:57:31',158.00,'官网');

INSERT INTO `orders` VALUES (545,'RT20250924000545',423,'PAID','2025-09-24 13:22:14','2025-09-24 14:06:14',63.90,'小程序');

INSERT INTO `orders` VALUES (546,'RT20250924000546',248,'PAID','2025-09-24 15:46:43','2025-09-24 16:56:43',189.80,'小程序');

INSERT INTO `orders` VALUES (547,'RT20250924000547',430,'PAID','2025-09-24 18:55:23','2025-09-24 19:40:23',166.00,'线下门店');

INSERT INTO `orders` VALUES (548,'RT20250925000548',336,'PAID','2025-09-25 18:00:03','2025-09-25 18:13:03',39.00,'小程序');

INSERT INTO `orders` VALUES (549,'RT20250926000549',32,'PAID','2025-09-26 10:22:46','2025-09-26 10:24:46',153.90,'小程序');

INSERT INTO `orders` VALUES (550,'RT20250926000550',130,'REFUNDED','2025-09-26 12:28:36','2025-09-26 13:35:36',24.90,'官网');

INSERT INTO `orders` VALUES (551,'RT20250926000551',278,'PAID','2025-09-26 14:38:58','2025-09-26 15:09:58',31.26,'小程序');

INSERT INTO `orders` VALUES (552,'RT20250926000552',540,'PAID','2025-09-26 14:52:05','2025-09-26 15:37:05',59.00,'线下门店');

INSERT INTO `orders` VALUES (553,'RT20250927000553',129,'PAID','2025-09-27 12:06:38','2025-09-27 12:24:38',98.45,'线下门店');

INSERT INTO `orders` VALUES (554,'RT20250927000554',82,'PAID','2025-09-27 16:50:43','2025-09-27 16:52:43',136.00,'小程序');

INSERT INTO `orders` VALUES (555,'RT20250927000555',94,'PAID','2025-09-27 18:50:05','2025-09-27 19:11:05',39.90,'线下门店');

INSERT INTO `orders` VALUES (556,'RT20250927000556',378,'PAID','2025-09-27 18:53:41','2025-09-27 19:03:41',166.00,'官网');

INSERT INTO `orders` VALUES (557,'RT20250927000557',153,'PAID','2025-09-27 19:26:42','2025-09-27 20:30:42',238.80,'官网');

INSERT INTO `orders` VALUES (558,'RT20250929000558',241,'PAID','2025-09-29 14:31:32','2025-09-29 15:20:32',79.00,'线下门店');

INSERT INTO `orders` VALUES (559,'RT20250929000559',227,'PAID','2025-09-29 15:48:07','2025-09-29 16:07:07',39.00,'小程序');

INSERT INTO `orders` VALUES (560,'RT20250929000560',202,'PAID','2025-09-29 17:27:19','2025-09-29 18:04:19',114.05,'线下门店');

INSERT INTO `orders` VALUES (561,'RT20250929000561',66,'CANCELLED','2025-09-29 20:43:47',NULL,160.55,'小程序');

INSERT INTO `orders` VALUES (562,'RT20250930000562',430,'PAID','2025-09-30 13:15:35','2025-09-30 13:51:35',39.90,'小程序');

INSERT INTO `orders` VALUES (563,'RT20250930000563',136,'PAID','2025-09-30 13:17:05','2025-09-30 14:10:05',185.00,'小程序');

INSERT INTO `orders` VALUES (564,'RT20250930000564',614,'PAID','2025-09-30 17:50:06','2025-09-30 18:54:06',39.00,'线下门店');

INSERT INTO `orders` VALUES (565,'RT20251002000565',548,'PAID','2025-10-02 12:02:04','2025-10-02 12:28:04',79.00,'小程序');

INSERT INTO `orders` VALUES (566,'RT20251002000566',167,'CANCELLED','2025-10-02 13:02:03',NULL,150.10,'线下门店');

INSERT INTO `orders` VALUES (567,'RT20251002000567',99,'PAID','2025-10-02 15:11:15','2025-10-02 15:33:15',98.00,'线下门店');

INSERT INTO `orders` VALUES (568,'RT20251002000568',61,'PAID','2025-10-02 18:38:44','2025-10-02 19:45:44',151.05,'小程序');

INSERT INTO `orders` VALUES (569,'RT20251002000569',235,'CANCELLED','2025-10-02 18:42:16',NULL,399.00,'企业采购');

INSERT INTO `orders` VALUES (570,'RT20251003000570',95,'PAID','2025-10-03 09:45:52','2025-10-03 10:12:52',37.91,'线下门店');

INSERT INTO `orders` VALUES (571,'RT20251003000571',512,'PAID','2025-10-03 10:10:19','2025-10-03 10:20:19',49.80,'官网');

INSERT INTO `orders` VALUES (572,'RT20251003000572',23,'PAID','2025-10-03 11:29:08','2025-10-03 12:34:08',147.80,'官网');

INSERT INTO `orders` VALUES (573,'RT20251003000573',608,'CANCELLED','2025-10-03 13:54:45',NULL,299.00,'小程序');

INSERT INTO `orders` VALUES (574,'RT20251003000574',527,'PAID','2025-10-03 15:05:36','2025-10-03 15:17:36',64.60,'官网');

INSERT INTO `orders` VALUES (575,'RT20251003000575',43,'PAID','2025-10-03 15:08:10','2025-10-03 15:34:10',62.66,'官网');

INSERT INTO `orders` VALUES (576,'RT20251003000576',236,'PAID','2025-10-03 15:10:51','2025-10-03 15:58:51',24.90,'小程序');

INSERT INTO `orders` VALUES (577,'RT20251003000577',509,'PAID','2025-10-03 20:26:52','2025-10-03 21:28:52',71.90,'官网');

INSERT INTO `orders` VALUES (578,'RT20251004000578',637,'PAID','2025-10-04 13:37:01','2025-10-04 14:08:01',39.90,'线下门店');

INSERT INTO `orders` VALUES (579,'RT20251005000579',138,'PAID','2025-10-05 12:18:06','2025-10-05 13:32:06',59.00,'官网');

INSERT INTO `orders` VALUES (580,'RT20251005000580',100,'PAID','2025-10-05 14:13:48','2025-10-05 14:37:48',59.00,'小程序');

INSERT INTO `orders` VALUES (581,'RT20251005000581',47,'PAID','2025-10-05 15:00:18','2025-10-05 15:48:18',79.00,'小程序');

INSERT INTO `orders` VALUES (582,'RT20251005000582',533,'PAID','2025-10-05 17:44:08','2025-10-05 18:12:08',146.00,'官网');

INSERT INTO `orders` VALUES (583,'RT20251005000583',185,'PAID','2025-10-05 19:18:42','2025-10-05 19:27:42',159.00,'线下门店');

INSERT INTO `orders` VALUES (584,'RT20251005000584',248,'PAID','2025-10-05 20:48:50','2025-10-05 22:00:50',148.00,'小程序');

INSERT INTO `orders` VALUES (585,'RT20251006000585',82,'PAID','2025-10-06 18:11:02','2025-10-06 19:23:02',159.00,'官网');

INSERT INTO `orders` VALUES (586,'RT20251006000586',179,'PAID','2025-10-06 20:29:22','2025-10-06 21:41:22',72.80,'小程序');

INSERT INTO `orders` VALUES (587,'RT20251008000587',357,'PAID','2025-10-08 12:38:43','2025-10-08 12:52:43',78.90,'小程序');

INSERT INTO `orders` VALUES (588,'RT20251008000588',270,'PAID','2025-10-08 13:59:12','2025-10-08 15:12:12',129.00,'小程序');

INSERT INTO `orders` VALUES (589,'RT20251008000589',305,'REFUNDED','2025-10-08 16:15:10','2025-10-08 16:48:10',89.00,'官网');

INSERT INTO `orders` VALUES (590,'RT20251008000590',166,'PAID','2025-10-08 16:25:37','2025-10-08 17:03:37',159.00,'线下门店');

INSERT INTO `orders` VALUES (591,'RT20251008000591',388,'PAID','2025-10-08 16:52:31','2025-10-08 17:13:31',31.26,'小程序');

INSERT INTO `orders` VALUES (592,'RT20251008000592',83,'PAID','2025-10-08 17:07:27','2025-10-08 17:57:27',64.80,'小程序');

INSERT INTO `orders` VALUES (593,'RT20251008000593',315,'PAID','2025-10-08 19:41:21','2025-10-08 20:36:21',37.91,'小程序');

INSERT INTO `orders` VALUES (594,'RT20251009000594',107,'PAID','2025-10-09 15:53:49','2025-10-09 16:27:49',82.70,'小程序');

INSERT INTO `orders` VALUES (595,'RT20251009000595',479,'PAID','2025-10-09 21:25:59','2025-10-09 21:59:59',158.00,'线下门店');

INSERT INTO `orders` VALUES (596,'RT20251010000596',168,'CANCELLED','2025-10-10 11:54:40',NULL,84.55,'线下门店');

INSERT INTO `orders` VALUES (597,'RT20251010000597',441,'PAID','2025-10-10 13:21:37','2025-10-10 14:26:37',37.05,'小程序');

INSERT INTO `orders` VALUES (598,'RT20251011000598',248,'REFUNDED','2025-10-11 10:24:32','2025-10-11 11:34:32',37.91,'小程序');

INSERT INTO `orders` VALUES (599,'RT20251011000599',179,'PAID','2025-10-11 13:50:15','2025-10-11 14:36:15',167.26,'官网');

INSERT INTO `orders` VALUES (600,'RT20251011000600',483,'PAID','2025-10-11 14:09:54','2025-10-11 14:20:54',59.00,'官网');

INSERT INTO `orders` VALUES (601,'RT20251011000601',256,'PAID','2025-10-11 19:37:54','2025-10-11 19:57:54',119.70,'小程序');

INSERT INTO `orders` VALUES (602,'RT20251011000602',68,'PAID','2025-10-11 19:42:49','2025-10-11 20:53:49',35.91,'小程序');

INSERT INTO `orders` VALUES (603,'RT20251011000603',22,'PAID','2025-10-11 19:58:02','2025-10-11 20:40:02',69.00,'小程序');

INSERT INTO `orders` VALUES (604,'RT20251011000604',428,'PAID','2025-10-11 20:47:39','2025-10-11 21:36:39',68.00,'线下门店');

INSERT INTO `orders` VALUES (605,'RT20251012000605',320,'PAID','2025-10-12 10:58:07','2025-10-12 11:38:07',266.00,'小程序');

INSERT INTO `orders` VALUES (606,'RT20251012000606',285,'PAID','2025-10-12 14:40:30','2025-10-12 15:54:30',39.00,'官网');

INSERT INTO `orders` VALUES (607,'RT20251012000607',60,'PAID','2025-10-12 15:48:58','2025-10-12 16:06:58',37.91,'官网');

INSERT INTO `orders` VALUES (608,'RT20251012000608',199,'PAID','2025-10-12 17:33:08','2025-10-12 18:01:08',53.10,'小程序');

INSERT INTO `orders` VALUES (609,'RT20251012000609',338,'PAID','2025-10-12 20:33:44','2025-10-12 21:13:44',49.80,'小程序');

INSERT INTO `orders` VALUES (610,'RT20251013000610',468,'PAID','2025-10-13 13:43:41','2025-10-13 14:25:41',64.60,'官网');

INSERT INTO `orders` VALUES (611,'RT20251013000611',474,'CANCELLED','2025-10-13 13:47:34',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (612,'RT20251013000612',423,'PAID','2025-10-13 16:55:48','2025-10-13 18:03:48',299.00,'线下门店');

INSERT INTO `orders` VALUES (613,'RT20251013000613',153,'PAID','2025-10-13 18:41:01','2025-10-13 19:48:01',337.00,'线下门店');

INSERT INTO `orders` VALUES (614,'RT20251014000614',563,'PAID','2025-10-14 11:11:33','2025-10-14 11:24:33',68.00,'官网');

INSERT INTO `orders` VALUES (615,'RT20251014000615',578,'PAID','2025-10-14 22:52:54','2025-10-14 22:56:54',79.80,'小程序');

INSERT INTO `orders` VALUES (616,'RT20251015000616',484,'PAID','2025-10-15 17:27:57','2025-10-15 18:10:57',379.05,'官网');

INSERT INTO `orders` VALUES (617,'RT20251016000617',185,'PAID','2025-10-16 11:19:05','2025-10-16 11:20:05',39.90,'线下门店');

INSERT INTO `orders` VALUES (618,'RT20251016000618',87,'PAID','2025-10-16 13:04:32','2025-10-16 14:14:32',117.00,'小程序');

INSERT INTO `orders` VALUES (619,'RT20251016000619',13,'PAID','2025-10-16 14:33:55','2025-10-16 15:23:55',208.00,'官网');

INSERT INTO `orders` VALUES (620,'RT20251017000620',216,'PAID','2025-10-17 11:47:26','2025-10-17 12:39:26',47.31,'线下门店');

INSERT INTO `orders` VALUES (621,'RT20251017000621',435,'PAID','2025-10-17 13:48:47','2025-10-17 14:22:47',123.55,'小程序');

INSERT INTO `orders` VALUES (622,'RT20251017000622',43,'PAID','2025-10-17 17:13:26','2025-10-17 18:06:26',157.00,'小程序');

INSERT INTO `orders` VALUES (623,'RT20251017000623',385,'PAID','2025-10-17 17:31:05','2025-10-17 18:05:05',37.91,'小程序');

INSERT INTO `orders` VALUES (624,'RT20251017000624',45,'PAID','2025-10-17 18:14:55','2025-10-17 19:00:55',78.00,'小程序');

INSERT INTO `orders` VALUES (625,'RT20251017000625',26,'PAID','2025-10-17 18:42:32','2025-10-17 18:56:32',24.90,'小程序');

INSERT INTO `orders` VALUES (626,'RT20251017000626',178,'PAID','2025-10-17 19:10:53','2025-10-17 19:11:53',59.00,'小程序');

INSERT INTO `orders` VALUES (627,'RT20251018000627',192,'PAID','2025-10-18 18:52:17','2025-10-18 20:02:17',62.51,'小程序');

INSERT INTO `orders` VALUES (628,'RT20251018000628',94,'PAID','2025-10-18 19:28:26','2025-10-18 20:15:26',71.82,'小程序');

INSERT INTO `orders` VALUES (629,'RT20251019000629',352,'PAID','2025-10-19 12:38:34','2025-10-19 13:24:34',100.71,'官网');

INSERT INTO `orders` VALUES (630,'RT20251019000630',439,'PAID','2025-10-19 13:23:03','2025-10-19 14:09:03',399.00,'官网');

INSERT INTO `orders` VALUES (631,'RT20251019000631',236,'PAID','2025-10-19 19:38:42','2025-10-19 20:43:42',32.90,'企业采购');

INSERT INTO `orders` VALUES (632,'RT20251019000632',277,'REFUNDED','2025-10-19 21:07:33','2025-10-19 22:20:33',32.90,'小程序');

INSERT INTO `orders` VALUES (633,'RT20251020000633',190,'PAID','2025-10-20 14:36:42','2025-10-20 15:26:42',138.00,'官网');

INSERT INTO `orders` VALUES (634,'RT20251020000634',318,'PAID','2025-10-20 15:54:06','2025-10-20 16:32:06',55.31,'官网');

INSERT INTO `orders` VALUES (635,'RT20251020000635',125,'PAID','2025-10-20 19:20:00','2025-10-20 19:54:00',24.90,'官网');

INSERT INTO `orders` VALUES (636,'RT20251020000636',121,'REFUNDED','2025-10-20 22:03:23','2025-10-20 22:14:23',104.50,'线下门店');

INSERT INTO `orders` VALUES (637,'RT20251021000637',104,'CANCELLED','2025-10-21 13:37:43',NULL,438.00,'小程序');

INSERT INTO `orders` VALUES (638,'RT20251021000638',23,'PAID','2025-10-21 14:21:28','2025-10-21 15:22:28',809.10,'小程序');

INSERT INTO `orders` VALUES (639,'RT20251021000639',567,'PAID','2025-10-21 16:16:45','2025-10-21 17:14:45',159.00,'官网');

INSERT INTO `orders` VALUES (640,'RT20251021000640',552,'PAID','2025-10-21 17:54:01','2025-10-21 18:56:01',37.91,'线下门店');

INSERT INTO `orders` VALUES (641,'RT20251021000641',214,'PAID','2025-10-21 18:02:38','2025-10-21 18:09:38',102.90,'小程序');

INSERT INTO `orders` VALUES (642,'RT20251022000642',163,'PAID','2025-10-22 08:39:22','2025-10-22 08:55:22',436.05,'官网');

INSERT INTO `orders` VALUES (643,'RT20251022000643',549,'PAID','2025-10-22 09:22:32','2025-10-22 10:16:32',169.00,'线下门店');

INSERT INTO `orders` VALUES (644,'RT20251022000644',184,'PAID','2025-10-22 13:05:18','2025-10-22 13:12:18',91.90,'小程序');

INSERT INTO `orders` VALUES (645,'RT20251022000645',7,'PAID','2025-10-22 15:02:21','2025-10-22 15:37:21',79.00,'小程序');

INSERT INTO `orders` VALUES (646,'RT20251022000646',418,'PAID','2025-10-22 15:33:24','2025-10-22 16:21:24',138.00,'小程序');

INSERT INTO `orders` VALUES (647,'RT20251022000647',190,'PAID','2025-10-22 15:34:29','2025-10-22 15:59:29',487.10,'线下门店');

INSERT INTO `orders` VALUES (648,'RT20251023000648',83,'CANCELLED','2025-10-23 08:03:54',NULL,137.00,'线下门店');

INSERT INTO `orders` VALUES (649,'RT20251023000649',34,'PAID','2025-10-23 11:18:34','2025-10-23 11:38:34',68.00,'官网');

INSERT INTO `orders` VALUES (650,'RT20251023000650',122,'PAID','2025-10-23 11:30:33','2025-10-23 12:39:33',59.00,'官网');

INSERT INTO `orders` VALUES (651,'RT20251023000651',609,'PAID','2025-10-23 14:49:14','2025-10-23 15:34:14',72.80,'线下门店');

INSERT INTO `orders` VALUES (652,'RT20251023000652',577,'PAID','2025-10-23 18:32:16','2025-10-23 19:19:16',238.00,'小程序');

INSERT INTO `orders` VALUES (653,'RT20251024000653',23,'PAID','2025-10-24 13:31:43','2025-10-24 14:20:43',68.00,'官网');

INSERT INTO `orders` VALUES (654,'RT20251024000654',229,'PAID','2025-10-24 13:41:14','2025-10-24 13:48:14',32.90,'小程序');

INSERT INTO `orders` VALUES (655,'RT20251024000655',51,'PAID','2025-10-24 16:06:38','2025-10-24 17:04:38',92.90,'小程序');

INSERT INTO `orders` VALUES (656,'RT20251024000656',109,'PAID','2025-10-24 17:25:13','2025-10-24 18:22:13',320.10,'小程序');

INSERT INTO `orders` VALUES (657,'RT20251024000657',142,'PAID','2025-10-24 17:45:55','2025-10-24 17:47:55',69.00,'官网');

INSERT INTO `orders` VALUES (658,'RT20251025000658',246,'PAID','2025-10-25 15:49:25','2025-10-25 16:19:25',105.91,'官网');

INSERT INTO `orders` VALUES (659,'RT20251025000659',419,'PAID','2025-10-25 16:16:47','2025-10-25 17:05:47',24.90,'官网');

INSERT INTO `orders` VALUES (660,'RT20251025000660',214,'PAID','2025-10-25 16:38:19','2025-10-25 17:34:19',39.90,'小程序');

INSERT INTO `orders` VALUES (661,'RT20251025000661',291,'PAID','2025-10-25 17:52:00','2025-10-25 18:54:00',65.55,'小程序');

INSERT INTO `orders` VALUES (662,'RT20251026000662',164,'PAID','2025-10-26 10:47:48','2025-10-26 11:15:48',39.00,'官网');

INSERT INTO `orders` VALUES (663,'RT20251026000663',601,'PAID','2025-10-26 12:24:19','2025-10-26 12:54:19',32.90,'小程序');

INSERT INTO `orders` VALUES (664,'RT20251026000664',168,'PAID','2025-10-26 13:37:21','2025-10-26 14:35:21',79.00,'线下门店');

INSERT INTO `orders` VALUES (665,'RT20251026000665',575,'PAID','2025-10-26 13:48:06','2025-10-26 14:21:06',98.70,'小程序');

INSERT INTO `orders` VALUES (666,'RT20251026000666',460,'PAID','2025-10-26 15:58:40','2025-10-26 16:03:40',181.70,'线下门店');

INSERT INTO `orders` VALUES (667,'RT20251026000667',460,'PAID','2025-10-26 17:15:25','2025-10-26 17:53:25',37.05,'线下门店');

INSERT INTO `orders` VALUES (668,'RT20251026000668',383,'PAID','2025-10-26 17:24:27','2025-10-26 18:39:27',35.91,'企业采购');

INSERT INTO `orders` VALUES (669,'RT20251026000669',130,'PAID','2025-10-26 18:44:44','2025-10-26 19:35:44',862.60,'线下门店');

INSERT INTO `orders` VALUES (670,'RT20251026000670',363,'PAID','2025-10-26 19:52:43','2025-10-26 20:45:43',68.00,'线下门店');

INSERT INTO `orders` VALUES (671,'RT20251026000671',88,'CANCELLED','2025-10-26 21:18:05',NULL,138.00,'线下门店');

INSERT INTO `orders` VALUES (672,'RT20251027000672',159,'PAID','2025-10-27 15:49:57','2025-10-27 16:33:57',138.22,'小程序');

INSERT INTO `orders` VALUES (673,'RT20251027000673',478,'PAID','2025-10-27 19:32:53','2025-10-27 19:38:53',71.90,'线下门店');

INSERT INTO `orders` VALUES (674,'RT20251027000674',414,'REFUNDED','2025-10-27 19:52:11','2025-10-27 20:22:11',160.55,'官网');

INSERT INTO `orders` VALUES (675,'RT20251028000675',79,'PAID','2025-10-28 16:57:01','2025-10-28 17:06:01',128.90,'小程序');

INSERT INTO `orders` VALUES (676,'RT20251028000676',94,'PAID','2025-10-28 18:59:20','2025-10-28 20:13:20',79.80,'官网');

INSERT INTO `orders` VALUES (677,'RT20251028000677',503,'PAID','2025-10-28 19:28:53','2025-10-28 19:30:53',758.10,'官网');

INSERT INTO `orders` VALUES (678,'RT20251028000678',620,'PAID','2025-10-28 20:06:37','2025-10-28 20:18:37',39.00,'官网');

INSERT INTO `orders` VALUES (679,'RT20251028000679',504,'PAID','2025-10-28 22:23:43','2025-10-28 22:31:43',24.90,'小程序');

INSERT INTO `orders` VALUES (680,'RT20251029000680',101,'PAID','2025-10-29 13:30:31','2025-10-29 14:36:31',39.90,'官网');

INSERT INTO `orders` VALUES (681,'RT20251029000681',101,'PAID','2025-10-29 14:49:38','2025-10-29 15:39:38',455.05,'官网');

INSERT INTO `orders` VALUES (682,'RT20251029000682',192,'PAID','2025-10-29 15:49:44','2025-10-29 17:03:44',118.00,'线下门店');

INSERT INTO `orders` VALUES (683,'RT20251029000683',312,'PAID','2025-10-29 16:25:32','2025-10-29 16:50:32',103.71,'线下门店');

INSERT INTO `orders` VALUES (684,'RT20251029000684',512,'CANCELLED','2025-10-29 16:28:49',NULL,166.90,'小程序');

INSERT INTO `orders` VALUES (685,'RT20251030000685',74,'PAID','2025-10-30 09:53:53','2025-10-30 10:15:53',56.05,'官网');

INSERT INTO `orders` VALUES (686,'RT20251030000686',614,'PAID','2025-10-30 13:53:09','2025-10-30 14:00:09',198.90,'官网');

INSERT INTO `orders` VALUES (687,'RT20251030000687',246,'REFUNDED','2025-10-30 15:17:19','2025-10-30 15:25:19',39.00,'小程序');

INSERT INTO `orders` VALUES (688,'RT20251030000688',244,'PAID','2025-10-30 16:58:06','2025-10-30 17:05:06',167.00,'线下门店');

INSERT INTO `orders` VALUES (689,'RT20251030000689',543,'PAID','2025-10-30 19:18:19','2025-10-30 19:46:19',68.00,'企业采购');

INSERT INTO `orders` VALUES (690,'RT20251031000690',97,'PAID','2025-10-31 16:34:18','2025-10-31 16:55:18',39.00,'小程序');

INSERT INTO `orders` VALUES (691,'RT20251031000691',492,'PAID','2025-10-31 18:03:53','2025-10-31 19:11:53',32.90,'小程序');

INSERT INTO `orders` VALUES (692,'RT20251031000692',144,'PAID','2025-10-31 18:24:23','2025-10-31 18:40:23',39.00,'官网');

INSERT INTO `orders` VALUES (693,'RT20251031000693',204,'PAID','2025-10-31 19:25:05','2025-10-31 20:03:05',138.00,'线下门店');

INSERT INTO `orders` VALUES (694,'RT20251031000694',89,'PAID','2025-10-31 20:06:33','2025-10-31 20:15:33',69.00,'小程序');

INSERT INTO `orders` VALUES (695,'RT20251031000695',20,'PAID','2025-10-31 20:14:35','2025-10-31 20:53:35',128.00,'官网');

INSERT INTO `orders` VALUES (696,'RT20251101000696',560,'PAID','2025-11-01 11:01:33','2025-11-01 11:27:33',111.15,'小程序');

INSERT INTO `orders` VALUES (697,'RT20251101000697',588,'PAID','2025-11-01 11:03:31','2025-11-01 12:09:31',136.00,'线下门店');

INSERT INTO `orders` VALUES (698,'RT20251101000698',232,'PAID','2025-11-01 11:11:22','2025-11-01 11:38:22',277.90,'线下门店');

INSERT INTO `orders` VALUES (699,'RT20251101000699',454,'PAID','2025-11-01 12:08:06','2025-11-01 12:52:06',39.90,'线下门店');

INSERT INTO `orders` VALUES (700,'RT20251101000700',443,'PAID','2025-11-01 16:26:25','2025-11-01 16:43:25',177.90,'线下门店');

INSERT INTO `orders` VALUES (701,'RT20251101000701',585,'PAID','2025-11-01 16:52:48','2025-11-01 18:02:48',282.95,'企业采购');

INSERT INTO `orders` VALUES (702,'RT20251101000702',366,'CANCELLED','2025-11-01 17:11:32',NULL,78.00,'小程序');

INSERT INTO `orders` VALUES (703,'RT20251101000703',108,'REFUNDED','2025-11-01 19:06:07','2025-11-01 20:18:07',59.00,'官网');

INSERT INTO `orders` VALUES (704,'RT20251101000704',318,'PAID','2025-11-01 19:37:23','2025-11-01 20:21:23',112.10,'线下门店');

INSERT INTO `orders` VALUES (705,'RT20251102000705',141,'PAID','2025-11-02 11:53:07','2025-11-02 12:54:07',39.00,'小程序');

INSERT INTO `orders` VALUES (706,'RT20251102000706',476,'PAID','2025-11-02 13:08:56','2025-11-02 13:25:56',59.00,'官网');

INSERT INTO `orders` VALUES (707,'RT20251102000707',162,'PAID','2025-11-02 15:10:22','2025-11-02 15:34:22',299.00,'小程序');

INSERT INTO `orders` VALUES (708,'RT20251102000708',229,'PAID','2025-11-02 17:20:49','2025-11-02 18:21:49',116.10,'官网');

INSERT INTO `orders` VALUES (709,'RT20251102000709',275,'PAID','2025-11-02 17:32:50','2025-11-02 18:24:50',37.91,'小程序');

INSERT INTO `orders` VALUES (710,'RT20251102000710',87,'PAID','2025-11-02 17:39:50','2025-11-02 18:08:50',39.00,'线下门店');

INSERT INTO `orders` VALUES (711,'RT20251102000711',561,'PAID','2025-11-02 21:09:47','2025-11-02 21:31:47',39.90,'小程序');

INSERT INTO `orders` VALUES (712,'RT20251103000712',501,'PAID','2025-11-03 13:31:24','2025-11-03 14:24:24',167.26,'企业采购');

INSERT INTO `orders` VALUES (713,'RT20251103000713',96,'CANCELLED','2025-11-03 16:13:51',NULL,108.17,'官网');

INSERT INTO `orders` VALUES (714,'RT20251103000714',49,'PAID','2025-11-03 17:37:10','2025-11-03 18:38:10',161.40,'小程序');

INSERT INTO `orders` VALUES (715,'RT20251103000715',480,'PAID','2025-11-03 17:48:26','2025-11-03 17:51:26',285.90,'小程序');

INSERT INTO `orders` VALUES (716,'RT20251103000716',35,'PAID','2025-11-03 19:36:47','2025-11-03 20:29:47',118.00,'小程序');

INSERT INTO `orders` VALUES (717,'RT20251104000717',123,'PAID','2025-11-04 15:25:49','2025-11-04 15:53:49',68.00,'线下门店');

INSERT INTO `orders` VALUES (718,'RT20251104000718',218,'PAID','2025-11-04 15:45:10','2025-11-04 15:46:10',124.56,'线下门店');

INSERT INTO `orders` VALUES (719,'RT20251104000719',124,'PAID','2025-11-04 16:50:56','2025-11-04 16:57:56',346.31,'官网');

INSERT INTO `orders` VALUES (720,'RT20251104000720',279,'PAID','2025-11-04 17:16:02','2025-11-04 18:00:02',24.90,'小程序');

INSERT INTO `orders` VALUES (721,'RT20251104000721',599,'PAID','2025-11-04 18:11:56','2025-11-04 18:59:56',56.56,'小程序');

INSERT INTO `orders` VALUES (722,'RT20251104000722',296,'PAID','2025-11-04 18:50:08','2025-11-04 19:45:08',143.10,'小程序');

INSERT INTO `orders` VALUES (723,'RT20251104000723',631,'PAID','2025-11-04 20:48:26','2025-11-04 21:18:26',128.00,'线下门店');

INSERT INTO `orders` VALUES (724,'RT20251105000724',364,'PAID','2025-11-05 10:01:17','2025-11-05 11:08:17',71.10,'企业采购');

INSERT INTO `orders` VALUES (725,'RT20251105000725',308,'PAID','2025-11-05 10:11:13','2025-11-05 11:04:13',68.00,'线下门店');

INSERT INTO `orders` VALUES (726,'RT20251105000726',594,'PAID','2025-11-05 16:22:49','2025-11-05 16:38:49',98.70,'小程序');

INSERT INTO `orders` VALUES (727,'RT20251105000727',627,'CANCELLED','2025-11-05 16:55:29',NULL,978.00,'官网');

INSERT INTO `orders` VALUES (728,'RT20251105000728',379,'PAID','2025-11-05 17:28:47','2025-11-05 17:41:47',199.55,'小程序');

INSERT INTO `orders` VALUES (729,'RT20251105000729',183,'PAID','2025-11-05 18:34:14','2025-11-05 19:04:14',198.00,'小程序');

INSERT INTO `orders` VALUES (730,'RT20251105000730',162,'CANCELLED','2025-11-05 19:08:22',NULL,308.95,'官网');

INSERT INTO `orders` VALUES (731,'RT20251105000731',603,'PAID','2025-11-05 19:53:24','2025-11-05 20:50:24',39.90,'线下门店');

INSERT INTO `orders` VALUES (732,'RT20251106000732',573,'PAID','2025-11-06 11:35:17','2025-11-06 12:04:17',49.80,'线下门店');

INSERT INTO `orders` VALUES (733,'RT20251106000733',42,'PAID','2025-11-06 12:16:52','2025-11-06 12:27:52',35.10,'小程序');

INSERT INTO `orders` VALUES (734,'RT20251106000734',121,'PAID','2025-11-06 12:17:14','2025-11-06 13:21:14',104.55,'小程序');

INSERT INTO `orders` VALUES (735,'RT20251106000735',245,'PAID','2025-11-06 13:34:24','2025-11-06 13:46:24',135.75,'官网');

INSERT INTO `orders` VALUES (736,'RT20251106000736',126,'PAID','2025-11-06 13:46:05','2025-11-06 14:23:05',92.90,'官网');

INSERT INTO `orders` VALUES (737,'RT20251106000737',190,'PAID','2025-11-06 18:16:49','2025-11-06 19:31:49',84.55,'小程序');

INSERT INTO `orders` VALUES (738,'RT20251106000738',183,'PAID','2025-11-06 19:03:19','2025-11-06 19:57:19',189.05,'线下门店');

INSERT INTO `orders` VALUES (739,'RT20251106000739',612,'PAID','2025-11-06 19:48:59','2025-11-06 20:53:59',59.00,'线下门店');

INSERT INTO `orders` VALUES (740,'RT20251106000740',613,'PAID','2025-11-06 19:51:28','2025-11-06 19:53:28',160.55,'小程序');

INSERT INTO `orders` VALUES (741,'RT20251107000741',289,'PAID','2025-11-07 12:07:32','2025-11-07 12:27:32',560.55,'小程序');

INSERT INTO `orders` VALUES (742,'RT20251107000742',246,'PAID','2025-11-07 12:21:55','2025-11-07 13:23:55',79.00,'企业采购');

INSERT INTO `orders` VALUES (743,'RT20251107000743',104,'PAID','2025-11-07 12:32:10','2025-11-07 13:41:10',59.00,'小程序');

INSERT INTO `orders` VALUES (744,'RT20251107000744',148,'PAID','2025-11-07 12:46:12','2025-11-07 13:23:12',39.90,'官网');

INSERT INTO `orders` VALUES (745,'RT20251107000745',130,'PAID','2025-11-07 15:18:39','2025-11-07 15:45:39',39.90,'官网');

INSERT INTO `orders` VALUES (746,'RT20251107000746',348,'PAID','2025-11-07 16:27:49','2025-11-07 17:07:49',331.90,'小程序');

INSERT INTO `orders` VALUES (747,'RT20251107000747',402,'CANCELLED','2025-11-07 18:19:41',NULL,118.90,'小程序');

INSERT INTO `orders` VALUES (748,'RT20251107000748',99,'PAID','2025-11-07 20:31:55','2025-11-07 21:25:55',127.22,'线下门店');

INSERT INTO `orders` VALUES (749,'RT20251107000749',184,'PAID','2025-11-07 22:06:14','2025-11-07 23:16:14',124.45,'小程序');

INSERT INTO `orders` VALUES (750,'RT20251108000750',168,'REFUNDED','2025-11-08 10:02:25','2025-11-08 10:41:25',39.00,'官网');

INSERT INTO `orders` VALUES (751,'RT20251108000751',403,'PAID','2025-11-08 13:51:43','2025-11-08 14:01:43',31.26,'线下门店');

INSERT INTO `orders` VALUES (752,'RT20251108000752',511,'PAID','2025-11-08 15:46:52','2025-11-08 16:17:52',98.00,'线下门店');

INSERT INTO `orders` VALUES (753,'RT20251108000753',480,'CANCELLED','2025-11-08 17:59:38',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (754,'RT20251108000754',160,'PAID','2025-11-08 18:01:24','2025-11-08 18:07:24',89.00,'线下门店');

INSERT INTO `orders` VALUES (755,'RT20251108000755',439,'PAID','2025-11-08 18:27:56','2025-11-08 18:36:56',39.00,'线下门店');

INSERT INTO `orders` VALUES (756,'RT20251108000756',158,'PAID','2025-11-08 19:17:36','2025-11-08 20:30:36',328.00,'小程序');

INSERT INTO `orders` VALUES (757,'RT20251108000757',622,'PAID','2025-11-08 20:17:40','2025-11-08 20:35:40',39.90,'线下门店');

INSERT INTO `orders` VALUES (758,'RT20251109000758',291,'PAID','2025-11-09 08:25:41','2025-11-09 08:55:41',78.00,'线下门店');

INSERT INTO `orders` VALUES (759,'RT20251109000759',175,'PAID','2025-11-09 10:13:42','2025-11-09 10:56:42',64.60,'小程序');

INSERT INTO `orders` VALUES (760,'RT20251109000760',44,'PAID','2025-11-09 11:48:14','2025-11-09 11:56:14',147.00,'线下门店');

INSERT INTO `orders` VALUES (761,'RT20251109000761',424,'PAID','2025-11-09 12:40:06','2025-11-09 13:27:06',299.00,'小程序');

INSERT INTO `orders` VALUES (762,'RT20251109000762',591,'PAID','2025-11-09 13:29:52','2025-11-09 14:36:52',37.05,'官网');

INSERT INTO `orders` VALUES (763,'RT20251109000763',7,'PAID','2025-11-09 13:46:12','2025-11-09 14:30:12',32.90,'小程序');

INSERT INTO `orders` VALUES (764,'RT20251109000764',428,'PAID','2025-11-09 14:35:50','2025-11-09 14:56:50',39.00,'线下门店');

INSERT INTO `orders` VALUES (765,'RT20251109000765',56,'PAID','2025-11-09 15:39:22','2025-11-09 15:47:22',37.05,'官网');

INSERT INTO `orders` VALUES (766,'RT20251109000766',357,'PAID','2025-11-09 16:30:35','2025-11-09 16:44:35',32.90,'小程序');

INSERT INTO `orders` VALUES (767,'RT20251109000767',42,'PAID','2025-11-09 21:56:03','2025-11-09 22:09:03',39.90,'线下门店');

INSERT INTO `orders` VALUES (768,'RT20251110000768',173,'PAID','2025-11-10 10:59:52','2025-11-10 11:29:52',118.00,'小程序');

INSERT INTO `orders` VALUES (769,'RT20251110000769',180,'PAID','2025-11-10 11:34:07','2025-11-10 12:03:07',47.31,'官网');

INSERT INTO `orders` VALUES (770,'RT20251110000770',488,'PAID','2025-11-10 12:35:46','2025-11-10 13:25:46',148.00,'企业采购');

INSERT INTO `orders` VALUES (771,'RT20251110000771',110,'PAID','2025-11-10 12:56:35','2025-11-10 13:07:35',39.90,'小程序');

INSERT INTO `orders` VALUES (772,'RT20251110000772',454,'PAID','2025-11-10 14:31:15','2025-11-10 15:27:15',129.00,'小程序');

INSERT INTO `orders` VALUES (773,'RT20251110000773',456,'PAID','2025-11-10 19:18:23','2025-11-10 20:22:23',199.00,'小程序');

INSERT INTO `orders` VALUES (774,'RT20251110000774',174,'PAID','2025-11-10 19:21:52','2025-11-10 20:04:52',317.90,'小程序');

INSERT INTO `orders` VALUES (775,'RT20251111000775',192,'PAID','2025-11-11 09:04:49','2025-11-11 09:22:49',24.90,'官网');

INSERT INTO `orders` VALUES (776,'RT20251111000776',186,'PAID','2025-11-11 14:17:29','2025-11-11 15:02:29',131.10,'线下门店');

INSERT INTO `orders` VALUES (777,'RT20251111000777',163,'PAID','2025-11-11 14:58:16','2025-11-11 16:12:16',208.00,'线下门店');

INSERT INTO `orders` VALUES (778,'RT20251111000778',38,'PAID','2025-11-11 15:22:08','2025-11-11 16:14:08',299.00,'官网');

INSERT INTO `orders` VALUES (779,'RT20251111000779',349,'PAID','2025-11-11 15:22:23','2025-11-11 15:33:23',56.05,'小程序');

INSERT INTO `orders` VALUES (780,'RT20251111000780',127,'PAID','2025-11-11 15:48:12','2025-11-11 16:40:12',68.00,'小程序');

INSERT INTO `orders` VALUES (781,'RT20251111000781',254,'PAID','2025-11-11 18:53:37','2025-11-11 18:59:37',39.00,'官网');

INSERT INTO `orders` VALUES (782,'RT20251111000782',285,'CANCELLED','2025-11-11 19:23:31',NULL,68.00,'线下门店');

INSERT INTO `orders` VALUES (783,'RT20251112000783',9,'PAID','2025-11-12 12:05:24','2025-11-12 12:38:24',39.00,'小程序');

INSERT INTO `orders` VALUES (784,'RT20251112000784',8,'PAID','2025-11-12 12:14:25','2025-11-12 13:29:25',69.00,'小程序');

INSERT INTO `orders` VALUES (785,'RT20251112000785',54,'CANCELLED','2025-11-12 13:27:13',NULL,37.91,'线下门店');

INSERT INTO `orders` VALUES (786,'RT20251112000786',488,'PAID','2025-11-12 13:40:13','2025-11-12 13:46:13',139.20,'小程序');

INSERT INTO `orders` VALUES (787,'RT20251112000787',330,'PAID','2025-11-12 13:58:48','2025-11-12 15:07:48',347.00,'小程序');

INSERT INTO `orders` VALUES (788,'RT20251112000788',167,'PAID','2025-11-12 16:02:21','2025-11-12 16:46:21',79.00,'小程序');

INSERT INTO `orders` VALUES (789,'RT20251112000789',8,'PAID','2025-11-12 18:28:59','2025-11-12 18:31:59',32.90,'小程序');

INSERT INTO `orders` VALUES (790,'RT20251112000790',315,'PAID','2025-11-12 19:44:39','2025-11-12 20:26:39',158.51,'小程序');

INSERT INTO `orders` VALUES (791,'RT20251112000791',206,'PAID','2025-11-12 20:14:21','2025-11-12 21:09:21',59.00,'线下门店');

INSERT INTO `orders` VALUES (792,'RT20251113000792',60,'PAID','2025-11-13 10:47:54','2025-11-13 11:03:54',127.31,'线下门店');

INSERT INTO `orders` VALUES (793,'RT20251113000793',44,'PAID','2025-11-13 13:00:49','2025-11-13 14:14:49',159.00,'小程序');

INSERT INTO `orders` VALUES (794,'RT20251113000794',350,'PAID','2025-11-13 15:52:47','2025-11-13 16:04:47',68.00,'小程序');

INSERT INTO `orders` VALUES (795,'RT20251113000795',183,'PAID','2025-11-13 17:51:34','2025-11-13 18:58:34',37.91,'小程序');

INSERT INTO `orders` VALUES (796,'RT20251113000796',177,'REFUNDED','2025-11-13 18:31:33','2025-11-13 19:14:33',79.00,'线下门店');

INSERT INTO `orders` VALUES (797,'RT20251113000797',431,'PAID','2025-11-13 19:34:05','2025-11-13 20:02:05',69.00,'线下门店');

INSERT INTO `orders` VALUES (798,'RT20251113000798',415,'PAID','2025-11-13 21:24:38','2025-11-13 21:59:38',1956.00,'线下门店');

INSERT INTO `orders` VALUES (799,'RT20251114000799',471,'PAID','2025-11-14 14:35:11','2025-11-14 15:00:11',24.90,'小程序');

INSERT INTO `orders` VALUES (800,'RT20251114000800',475,'PAID','2025-11-14 16:01:17','2025-11-14 17:00:17',107.90,'小程序');

INSERT INTO `orders` VALUES (801,'RT20251114000801',459,'PAID','2025-11-14 17:19:32','2025-11-14 18:26:32',56.05,'小程序');

INSERT INTO `orders` VALUES (802,'RT20251114000802',8,'PAID','2025-11-14 17:39:56','2025-11-14 18:10:56',64.80,'小程序');

INSERT INTO `orders` VALUES (803,'RT20251114000803',97,'PAID','2025-11-14 19:01:15','2025-11-14 19:57:15',155.45,'官网');

INSERT INTO `orders` VALUES (804,'RT20251114000804',352,'PAID','2025-11-14 19:22:25','2025-11-14 20:04:25',29.61,'小程序');

INSERT INTO `orders` VALUES (805,'RT20251114000805',459,'PAID','2025-11-14 21:06:49','2025-11-14 22:11:49',68.00,'小程序');

INSERT INTO `orders` VALUES (806,'RT20251115000806',175,'PAID','2025-11-15 10:10:45','2025-11-15 11:12:45',59.00,'小程序');

INSERT INTO `orders` VALUES (807,'RT20251115000807',130,'PAID','2025-11-15 13:03:17','2025-11-15 13:50:17',129.00,'小程序');

INSERT INTO `orders` VALUES (808,'RT20251115000808',492,'PAID','2025-11-15 15:32:52','2025-11-15 15:50:52',29.61,'小程序');

INSERT INTO `orders` VALUES (809,'RT20251115000809',403,'PAID','2025-11-15 17:59:55','2025-11-15 18:15:55',178.00,'小程序');

INSERT INTO `orders` VALUES (810,'RT20251115000810',404,'REFUNDED','2025-11-15 20:36:09','2025-11-15 21:43:09',79.00,'线下门店');

INSERT INTO `orders` VALUES (811,'RT20251116000811',112,'PAID','2025-11-16 10:53:18','2025-11-16 11:57:18',35.10,'线下门店');

INSERT INTO `orders` VALUES (812,'RT20251116000812',313,'PAID','2025-11-16 11:36:48','2025-11-16 12:37:48',159.00,'小程序');

INSERT INTO `orders` VALUES (813,'RT20251116000813',577,'PAID','2025-11-16 11:53:53','2025-11-16 12:07:53',308.95,'小程序');

INSERT INTO `orders` VALUES (814,'RT20251116000814',397,'PAID','2025-11-16 12:41:01','2025-11-16 13:56:01',32.90,'线下门店');

INSERT INTO `orders` VALUES (815,'RT20251116000815',542,'PAID','2025-11-16 14:24:46','2025-11-16 15:23:46',106.05,'小程序');

INSERT INTO `orders` VALUES (816,'RT20251116000816',138,'REFUNDED','2025-11-16 15:01:04','2025-11-16 15:31:04',62.51,'小程序');

INSERT INTO `orders` VALUES (817,'RT20251116000817',206,'PAID','2025-11-16 15:52:00','2025-11-16 16:23:00',39.00,'小程序');

INSERT INTO `orders` VALUES (818,'RT20251116000818',398,'PAID','2025-11-16 18:03:49','2025-11-16 19:16:49',183.90,'官网');

INSERT INTO `orders` VALUES (819,'RT20251117000819',225,'PAID','2025-11-17 11:10:36','2025-11-17 11:24:36',159.00,'小程序');

INSERT INTO `orders` VALUES (820,'RT20251117000820',162,'PAID','2025-11-17 12:03:38','2025-11-17 12:47:38',62.51,'官网');

INSERT INTO `orders` VALUES (821,'RT20251117000821',209,'PAID','2025-11-17 12:50:26','2025-11-17 13:57:26',118.00,'线下门店');

INSERT INTO `orders` VALUES (822,'RT20251117000822',570,'PAID','2025-11-17 12:52:43','2025-11-17 13:50:43',69.95,'线下门店');

INSERT INTO `orders` VALUES (823,'RT20251117000823',197,'PAID','2025-11-17 15:41:38','2025-11-17 15:54:38',31.26,'线下门店');

INSERT INTO `orders` VALUES (824,'RT20251117000824',100,'PAID','2025-11-17 18:14:40','2025-11-17 18:17:40',399.00,'小程序');

INSERT INTO `orders` VALUES (825,'RT20251117000825',236,'PAID','2025-11-17 20:55:29','2025-11-17 21:26:29',338.00,'线下门店');

INSERT INTO `orders` VALUES (826,'RT20251118000826',300,'PAID','2025-11-18 15:58:58','2025-11-18 16:20:58',399.00,'线下门店');

INSERT INTO `orders` VALUES (827,'RT20251118000827',272,'CANCELLED','2025-11-18 17:32:28',NULL,62.66,'小程序');

INSERT INTO `orders` VALUES (828,'RT20251118000828',484,'PAID','2025-11-18 17:52:42','2025-11-18 18:38:42',65.55,'小程序');

INSERT INTO `orders` VALUES (829,'RT20251118000829',320,'PAID','2025-11-18 19:24:21','2025-11-18 20:26:21',701.96,'小程序');

INSERT INTO `orders` VALUES (830,'RT20251118000830',277,'PAID','2025-11-18 19:40:11','2025-11-18 20:11:11',39.00,'小程序');

INSERT INTO `orders` VALUES (831,'RT20251118000831',279,'PAID','2025-11-18 21:26:38','2025-11-18 22:08:38',84.55,'线下门店');

INSERT INTO `orders` VALUES (832,'RT20251119000832',339,'PAID','2025-11-19 08:54:42','2025-11-19 09:36:42',68.00,'小程序');

INSERT INTO `orders` VALUES (833,'RT20251119000833',440,'PAID','2025-11-19 10:55:37','2025-11-19 11:47:37',64.60,'官网');

INSERT INTO `orders` VALUES (834,'RT20251119000834',228,'PAID','2025-11-19 11:28:28','2025-11-19 11:43:28',37.91,'小程序');

INSERT INTO `orders` VALUES (835,'RT20251119000835',298,'PAID','2025-11-19 11:39:24','2025-11-19 12:34:24',296.00,'小程序');

INSERT INTO `orders` VALUES (836,'RT20251119000836',424,'PAID','2025-11-19 11:45:22','2025-11-19 11:57:22',103.46,'线下门店');

INSERT INTO `orders` VALUES (837,'RT20251119000837',204,'PAID','2025-11-19 13:45:00','2025-11-19 13:58:00',95.00,'小程序');

INSERT INTO `orders` VALUES (838,'RT20251119000838',167,'CANCELLED','2025-11-19 16:04:10',NULL,159.90,'官网');

INSERT INTO `orders` VALUES (839,'RT20251119000839',241,'REFUNDED','2025-11-19 19:16:36','2025-11-19 19:45:36',177.00,'小程序');

INSERT INTO `orders` VALUES (840,'RT20251119000840',254,'PAID','2025-11-19 20:46:58','2025-11-19 21:04:58',115.95,'小程序');

INSERT INTO `orders` VALUES (841,'RT20251120000841',563,'PAID','2025-11-20 09:33:56','2025-11-20 10:41:56',89.50,'小程序');

INSERT INTO `orders` VALUES (842,'RT20251120000842',210,'PAID','2025-11-20 10:07:14','2025-11-20 10:18:14',39.00,'官网');

INSERT INTO `orders` VALUES (843,'RT20251120000843',248,'PAID','2025-11-20 10:26:33','2025-11-20 11:31:33',248.80,'小程序');

INSERT INTO `orders` VALUES (844,'RT20251120000844',26,'PAID','2025-11-20 12:15:28','2025-11-20 12:27:28',62.51,'小程序');

INSERT INTO `orders` VALUES (845,'RT20251120000845',566,'CANCELLED','2025-11-20 14:36:27',NULL,74.10,'小程序');

INSERT INTO `orders` VALUES (846,'RT20251120000846',222,'REFUNDED','2025-11-20 16:54:45','2025-11-20 18:00:45',39.90,'线下门店');

INSERT INTO `orders` VALUES (847,'RT20251120000847',43,'PAID','2025-11-20 18:32:39','2025-11-20 18:58:39',237.00,'官网');

INSERT INTO `orders` VALUES (848,'RT20251120000848',484,'REFUNDED','2025-11-20 19:26:57','2025-11-20 19:48:57',258.20,'小程序');

INSERT INTO `orders` VALUES (849,'RT20251120000849',445,'PAID','2025-11-20 20:44:00','2025-11-20 20:52:00',32.90,'线下门店');

INSERT INTO `orders` VALUES (850,'RT20251121000850',126,'PAID','2025-11-21 12:04:06','2025-11-21 12:46:06',39.00,'官网');

INSERT INTO `orders` VALUES (851,'RT20251121000851',290,'PAID','2025-11-21 12:18:32','2025-11-21 12:25:32',59.46,'线下门店');

INSERT INTO `orders` VALUES (852,'RT20251121000852',548,'PAID','2025-11-21 14:34:49','2025-11-21 15:34:49',74.96,'小程序');

INSERT INTO `orders` VALUES (853,'RT20251121000853',86,'PAID','2025-11-21 14:41:31','2025-11-21 15:21:31',159.00,'小程序');

INSERT INTO `orders` VALUES (854,'RT20251121000854',53,'PAID','2025-11-21 17:01:57','2025-11-21 18:00:57',89.00,'小程序');

INSERT INTO `orders` VALUES (855,'RT20251121000855',127,'PAID','2025-11-21 19:56:36','2025-11-21 20:14:36',798.00,'企业采购');

INSERT INTO `orders` VALUES (856,'RT20251121000856',81,'PAID','2025-11-21 20:13:28','2025-11-21 21:11:28',39.00,'小程序');

INSERT INTO `orders` VALUES (857,'RT20251122000857',6,'PAID','2025-11-22 12:45:52','2025-11-22 12:55:52',24.90,'小程序');

INSERT INTO `orders` VALUES (858,'RT20251122000858',403,'REFUNDED','2025-11-22 13:39:35','2025-11-22 14:28:35',37.91,'小程序');

INSERT INTO `orders` VALUES (859,'RT20251122000859',556,'REFUNDED','2025-11-22 16:08:05','2025-11-22 16:22:05',24.90,'小程序');

INSERT INTO `orders` VALUES (860,'RT20251122000860',175,'PAID','2025-11-22 18:09:43','2025-11-22 18:53:43',831.00,'小程序');

INSERT INTO `orders` VALUES (861,'RT20251122000861',583,'PAID','2025-11-22 19:09:24','2025-11-22 19:47:24',68.61,'线下门店');

INSERT INTO `orders` VALUES (862,'RT20251122000862',240,'PAID','2025-11-22 19:42:15','2025-11-22 20:19:15',535.00,'线下门店');

INSERT INTO `orders` VALUES (863,'RT20251122000863',456,'PAID','2025-11-22 21:10:28','2025-11-22 21:56:28',65.55,'线下门店');

INSERT INTO `orders` VALUES (864,'RT20251122000864',481,'CANCELLED','2025-11-22 21:51:59',NULL,284.05,'线下门店');

INSERT INTO `orders` VALUES (865,'RT20251123000865',224,'PAID','2025-11-23 08:33:44','2025-11-23 09:23:44',114.10,'小程序');

INSERT INTO `orders` VALUES (866,'RT20251123000866',562,'PAID','2025-11-23 14:40:12','2025-11-23 15:13:12',71.82,'官网');

INSERT INTO `orders` VALUES (867,'RT20251123000867',54,'PAID','2025-11-23 16:19:41','2025-11-23 16:26:41',32.90,'小程序');

INSERT INTO `orders` VALUES (868,'RT20251123000868',81,'PAID','2025-11-23 17:08:54','2025-11-23 17:42:54',546.90,'小程序');

INSERT INTO `orders` VALUES (869,'RT20251123000869',544,'PAID','2025-11-23 18:32:20','2025-11-23 19:43:20',897.00,'线下门店');

INSERT INTO `orders` VALUES (870,'RT20251123000870',142,'PAID','2025-11-23 19:11:25','2025-11-23 19:37:25',367.00,'线下门店');

INSERT INTO `orders` VALUES (871,'RT20251123000871',235,'PAID','2025-11-23 19:56:44','2025-11-23 20:33:44',23.66,'小程序');

INSERT INTO `orders` VALUES (872,'RT20251123000872',474,'CANCELLED','2025-11-23 20:05:51',NULL,39.00,'企业采购');

INSERT INTO `orders` VALUES (873,'RT20251123000873',78,'PAID','2025-11-23 21:05:24','2025-11-23 21:08:24',225.00,'小程序');

INSERT INTO `orders` VALUES (874,'RT20251124000874',11,'PAID','2025-11-24 11:07:16','2025-11-24 12:05:16',118.00,'官网');

INSERT INTO `orders` VALUES (875,'RT20251124000875',224,'CANCELLED','2025-11-24 11:53:58',NULL,76.91,'企业采购');

INSERT INTO `orders` VALUES (876,'RT20251124000876',470,'PAID','2025-11-24 13:28:51','2025-11-24 14:08:51',126.86,'线下门店');

INSERT INTO `orders` VALUES (877,'RT20251124000877',625,'PAID','2025-11-24 14:59:42','2025-11-24 15:31:42',122.55,'小程序');

INSERT INTO `orders` VALUES (878,'RT20251124000878',349,'PAID','2025-11-24 18:37:27','2025-11-24 19:29:27',24.90,'官网');

INSERT INTO `orders` VALUES (879,'RT20251124000879',130,'PAID','2025-11-24 18:50:10','2025-11-24 19:25:10',37.91,'小程序');

INSERT INTO `orders` VALUES (880,'RT20251124000880',574,'PAID','2025-11-24 19:04:00','2025-11-24 19:47:00',160.20,'企业采购');

INSERT INTO `orders` VALUES (881,'RT20251125000881',42,'PAID','2025-11-25 10:22:27','2025-11-25 11:06:27',59.00,'小程序');

INSERT INTO `orders` VALUES (882,'RT20251125000882',356,'PAID','2025-11-25 10:38:13','2025-11-25 11:09:13',58.76,'小程序');

INSERT INTO `orders` VALUES (883,'RT20251125000883',89,'PAID','2025-11-25 14:04:07','2025-11-25 15:08:07',128.90,'线下门店');

INSERT INTO `orders` VALUES (884,'RT20251125000884',153,'PAID','2025-11-25 14:29:09','2025-11-25 15:27:09',199.00,'小程序');

INSERT INTO `orders` VALUES (885,'RT20251125000885',590,'PAID','2025-11-25 15:05:32','2025-11-25 15:31:32',102.66,'小程序');

INSERT INTO `orders` VALUES (886,'RT20251125000886',378,'PAID','2025-11-25 18:23:58','2025-11-25 19:29:58',127.57,'官网');

INSERT INTO `orders` VALUES (887,'RT20251125000887',163,'PAID','2025-11-25 18:51:09','2025-11-25 18:59:09',104.50,'小程序');

INSERT INTO `orders` VALUES (888,'RT20251125000888',296,'PAID','2025-11-25 18:52:00','2025-11-25 19:42:00',32.90,'官网');

INSERT INTO `orders` VALUES (889,'RT20251125000889',316,'PAID','2025-11-25 19:23:02','2025-11-25 19:53:02',149.96,'小程序');

INSERT INTO `orders` VALUES (890,'RT20251125000890',171,'PAID','2025-11-25 19:55:51','2025-11-25 20:38:51',31.26,'官网');

INSERT INTO `orders` VALUES (891,'RT20251125000891',419,'PAID','2025-11-25 20:16:05','2025-11-25 21:26:05',664.05,'小程序');

INSERT INTO `orders` VALUES (892,'RT20251125000892',516,'PAID','2025-11-25 20:45:56','2025-11-25 21:37:56',269.10,'线下门店');

INSERT INTO `orders` VALUES (893,'RT20251126000893',137,'CANCELLED','2025-11-26 09:18:54',NULL,68.00,'企业采购');

INSERT INTO `orders` VALUES (894,'RT20251126000894',440,'PAID','2025-11-26 12:52:58','2025-11-26 13:48:58',32.90,'小程序');

INSERT INTO `orders` VALUES (895,'RT20251126000895',277,'PAID','2025-11-26 14:47:49','2025-11-26 15:41:49',79.00,'官网');

INSERT INTO `orders` VALUES (896,'RT20251126000896',596,'PAID','2025-11-26 14:54:52','2025-11-26 15:50:52',69.00,'小程序');

INSERT INTO `orders` VALUES (897,'RT20251126000897',44,'PAID','2025-11-26 15:33:39','2025-11-26 16:14:39',281.10,'官网');

INSERT INTO `orders` VALUES (898,'RT20251126000898',175,'PAID','2025-11-26 18:42:25','2025-11-26 19:45:25',92.90,'官网');

INSERT INTO `orders` VALUES (899,'RT20251126000899',524,'CANCELLED','2025-11-26 19:16:02',NULL,101.90,'线下门店');

INSERT INTO `orders` VALUES (900,'RT20251126000900',364,'CANCELLED','2025-11-26 19:18:19',NULL,59.00,'小程序');

INSERT INTO `orders` VALUES (901,'RT20251126000901',29,'PAID','2025-11-26 19:28:36','2025-11-26 20:19:36',39.90,'线下门店');

INSERT INTO `orders` VALUES (902,'RT20251127000902',92,'PAID','2025-11-27 14:23:19','2025-11-27 15:09:19',316.00,'线下门店');

INSERT INTO `orders` VALUES (903,'RT20251127000903',224,'PAID','2025-11-27 16:55:34','2025-11-27 17:04:34',134.16,'小程序');

INSERT INTO `orders` VALUES (904,'RT20251127000904',327,'REFUNDED','2025-11-27 18:28:52','2025-11-27 19:07:52',53.10,'线下门店');

INSERT INTO `orders` VALUES (905,'RT20251127000905',637,'PAID','2025-11-27 20:18:28','2025-11-27 21:32:28',151.05,'线下门店');

INSERT INTO `orders` VALUES (906,'RT20251128000906',393,'PAID','2025-11-28 12:41:49','2025-11-28 13:32:49',68.00,'小程序');

INSERT INTO `orders` VALUES (907,'RT20251128000907',117,'PAID','2025-11-28 12:59:15','2025-11-28 13:20:15',70.81,'线下门店');

INSERT INTO `orders` VALUES (908,'RT20251128000908',326,'PAID','2025-11-28 13:35:03','2025-11-28 14:50:03',32.90,'企业采购');

INSERT INTO `orders` VALUES (909,'RT20251128000909',53,'PAID','2025-11-28 15:40:14','2025-11-28 16:33:14',56.05,'官网');

INSERT INTO `orders` VALUES (910,'RT20251128000910',459,'PAID','2025-11-28 15:54:05','2025-11-28 16:37:05',39.90,'企业采购');

INSERT INTO `orders` VALUES (911,'RT20251128000911',231,'PAID','2025-11-28 17:57:27','2025-11-28 19:07:27',68.00,'线下门店');

INSERT INTO `orders` VALUES (912,'RT20251128000912',218,'PAID','2025-11-28 20:29:58','2025-11-28 21:28:58',39.90,'线下门店');

INSERT INTO `orders` VALUES (913,'RT20251128000913',395,'PAID','2025-11-28 20:38:22','2025-11-28 21:37:22',74.91,'线下门店');

INSERT INTO `orders` VALUES (914,'RT20251129000914',432,'PAID','2025-11-29 09:22:41','2025-11-29 09:44:41',61.41,'线下门店');

INSERT INTO `orders` VALUES (915,'RT20251129000915',32,'PAID','2025-11-29 10:41:31','2025-11-29 11:00:31',95.05,'线下门店');

INSERT INTO `orders` VALUES (916,'RT20251129000916',15,'PAID','2025-11-29 11:04:11','2025-11-29 12:10:11',121.90,'小程序');

INSERT INTO `orders` VALUES (917,'RT20251129000917',71,'PAID','2025-11-29 12:19:10','2025-11-29 12:55:10',139.10,'线下门店');

INSERT INTO `orders` VALUES (918,'RT20251129000918',246,'PAID','2025-11-29 13:48:18','2025-11-29 14:57:18',142.80,'小程序');

INSERT INTO `orders` VALUES (919,'RT20251129000919',83,'PAID','2025-11-29 17:50:15','2025-11-29 17:54:15',128.90,'小程序');

INSERT INTO `orders` VALUES (920,'RT20251129000920',185,'PAID','2025-11-29 17:56:41','2025-11-29 18:16:41',39.00,'小程序');

INSERT INTO `orders` VALUES (921,'RT20251129000921',35,'PAID','2025-11-29 18:09:24','2025-11-29 18:26:24',199.00,'官网');

INSERT INTO `orders` VALUES (922,'RT20251129000922',71,'PAID','2025-11-29 18:12:14','2025-11-29 18:26:14',59.00,'线下门店');

INSERT INTO `orders` VALUES (923,'RT20251129000923',99,'PAID','2025-11-29 20:57:02','2025-11-29 22:09:02',138.81,'官网');

INSERT INTO `orders` VALUES (924,'RT20251129000924',177,'PAID','2025-11-29 21:54:46','2025-11-29 23:00:46',32.90,'线下门店');

INSERT INTO `orders` VALUES (925,'RT20251130000925',56,'PAID','2025-11-30 09:22:47','2025-11-30 09:42:47',69.00,'官网');

INSERT INTO `orders` VALUES (926,'RT20251130000926',270,'PAID','2025-11-30 12:24:03','2025-11-30 12:28:03',68.00,'小程序');

INSERT INTO `orders` VALUES (927,'RT20251130000927',32,'PAID','2025-11-30 14:10:59','2025-11-30 15:03:59',31.26,'小程序');

INSERT INTO `orders` VALUES (928,'RT20251130000928',166,'PAID','2025-11-30 15:26:23','2025-11-30 16:01:23',98.61,'小程序');

INSERT INTO `orders` VALUES (929,'RT20251130000929',7,'PAID','2025-11-30 16:56:52','2025-11-30 17:28:52',359.10,'小程序');

INSERT INTO `orders` VALUES (930,'RT20251130000930',190,'PAID','2025-11-30 19:07:46','2025-11-30 20:13:46',39.90,'线下门店');

INSERT INTO `orders` VALUES (931,'RT20251130000931',608,'PAID','2025-11-30 20:56:18','2025-11-30 22:03:18',821.55,'线下门店');

INSERT INTO `orders` VALUES (932,'RT20251130000932',558,'PAID','2025-11-30 21:10:55','2025-11-30 21:52:55',71.10,'小程序');

INSERT INTO `orders` VALUES (933,'RT20251130000933',248,'PAID','2025-11-30 21:42:43','2025-11-30 21:46:43',32.90,'企业采购');

INSERT INTO `orders` VALUES (934,'RT20251201000934',24,'PAID','2025-12-01 09:32:53','2025-12-01 10:26:53',68.00,'小程序');

INSERT INTO `orders` VALUES (935,'RT20251201000935',192,'PAID','2025-12-01 11:55:54','2025-12-01 12:25:54',39.00,'线下门店');

INSERT INTO `orders` VALUES (936,'RT20251201000936',237,'PAID','2025-12-01 13:01:00','2025-12-01 13:59:00',59.00,'小程序');

INSERT INTO `orders` VALUES (937,'RT20251201000937',322,'PAID','2025-12-01 18:00:52','2025-12-01 18:45:52',68.00,'官网');

INSERT INTO `orders` VALUES (938,'RT20251202000938',188,'PAID','2025-12-02 12:17:45','2025-12-02 13:01:45',168.90,'小程序');

INSERT INTO `orders` VALUES (939,'RT20251202000939',411,'PAID','2025-12-02 12:22:29','2025-12-02 13:07:29',159.00,'线下门店');

INSERT INTO `orders` VALUES (940,'RT20251202000940',295,'PAID','2025-12-02 12:39:28','2025-12-02 12:58:28',438.00,'小程序');

INSERT INTO `orders` VALUES (941,'RT20251202000941',57,'PAID','2025-12-02 13:51:36','2025-12-02 14:40:36',122.40,'线下门店');

INSERT INTO `orders` VALUES (942,'RT20251202000942',66,'PAID','2025-12-02 16:30:24','2025-12-02 16:50:24',78.00,'线下门店');

INSERT INTO `orders` VALUES (943,'RT20251202000943',167,'CANCELLED','2025-12-02 18:54:37',NULL,136.00,'官网');

INSERT INTO `orders` VALUES (944,'RT20251202000944',15,'PAID','2025-12-02 18:59:50','2025-12-02 19:02:50',322.60,'官网');

INSERT INTO `orders` VALUES (945,'RT20251202000945',100,'PAID','2025-12-02 19:19:28','2025-12-02 19:24:28',59.00,'小程序');

INSERT INTO `orders` VALUES (946,'RT20251202000946',142,'PAID','2025-12-02 19:44:49','2025-12-02 20:21:49',4084.05,'线下门店');

INSERT INTO `orders` VALUES (947,'RT20251202000947',42,'PAID','2025-12-02 19:47:39','2025-12-02 20:39:39',75.05,'线下门店');

INSERT INTO `orders` VALUES (948,'RT20251202000948',315,'PAID','2025-12-02 20:41:48','2025-12-02 21:35:48',106.20,'小程序');

INSERT INTO `orders` VALUES (949,'RT20251202000949',217,'PAID','2025-12-02 21:32:43','2025-12-02 21:52:43',62.51,'官网');

INSERT INTO `orders` VALUES (950,'RT20251203000950',99,'PAID','2025-12-03 10:49:52','2025-12-03 11:23:52',367.00,'小程序');

INSERT INTO `orders` VALUES (951,'RT20251203000951',174,'PAID','2025-12-03 12:59:53','2025-12-03 13:19:53',39.00,'小程序');

INSERT INTO `orders` VALUES (952,'RT20251203000952',524,'CANCELLED','2025-12-03 13:55:59',NULL,136.00,'小程序');

INSERT INTO `orders` VALUES (953,'RT20251203000953',121,'PAID','2025-12-03 15:22:25','2025-12-03 16:09:25',39.00,'小程序');

INSERT INTO `orders` VALUES (954,'RT20251204000954',404,'PAID','2025-12-04 12:31:39','2025-12-04 12:32:39',87.21,'官网');

INSERT INTO `orders` VALUES (955,'RT20251204000955',43,'PAID','2025-12-04 14:35:07','2025-12-04 15:21:07',138.80,'线下门店');

INSERT INTO `orders` VALUES (956,'RT20251204000956',100,'CANCELLED','2025-12-04 15:06:42',NULL,166.95,'官网');

INSERT INTO `orders` VALUES (957,'RT20251204000957',171,'CANCELLED','2025-12-04 16:15:05',NULL,137.40,'线下门店');

INSERT INTO `orders` VALUES (958,'RT20251204000958',585,'PAID','2025-12-04 16:24:47','2025-12-04 17:08:47',89.00,'线下门店');

INSERT INTO `orders` VALUES (959,'RT20251204000959',104,'PAID','2025-12-04 16:29:11','2025-12-04 17:00:11',89.00,'小程序');

INSERT INTO `orders` VALUES (960,'RT20251204000960',257,'PAID','2025-12-04 16:38:00','2025-12-04 17:21:00',39.90,'小程序');

INSERT INTO `orders` VALUES (961,'RT20251204000961',264,'PAID','2025-12-04 18:19:34','2025-12-04 18:23:34',56.05,'线下门店');

INSERT INTO `orders` VALUES (962,'RT20251204000962',65,'REFUNDED','2025-12-04 18:36:18','2025-12-04 18:40:18',39.00,'线下门店');

INSERT INTO `orders` VALUES (963,'RT20251204000963',37,'PAID','2025-12-04 19:02:03','2025-12-04 19:26:03',99.12,'线下门店');

INSERT INTO `orders` VALUES (964,'RT20251204000964',561,'PAID','2025-12-04 19:23:44','2025-12-04 20:37:44',68.00,'小程序');

INSERT INTO `orders` VALUES (965,'RT20251204000965',53,'PAID','2025-12-04 19:27:04','2025-12-04 20:05:04',203.40,'小程序');

INSERT INTO `orders` VALUES (966,'RT20251205000966',88,'PAID','2025-12-05 10:26:11','2025-12-05 11:14:11',193.45,'小程序');

INSERT INTO `orders` VALUES (967,'RT20251205000967',542,'PAID','2025-12-05 11:26:57','2025-12-05 11:58:57',158.00,'小程序');

INSERT INTO `orders` VALUES (968,'RT20251205000968',195,'PAID','2025-12-05 15:32:16','2025-12-05 15:53:16',129.00,'线下门店');

INSERT INTO `orders` VALUES (969,'RT20251205000969',489,'PAID','2025-12-05 16:01:17','2025-12-05 17:04:17',87.21,'官网');

INSERT INTO `orders` VALUES (970,'RT20251205000970',533,'PAID','2025-12-05 18:05:36','2025-12-05 18:45:36',56.05,'线下门店');

INSERT INTO `orders` VALUES (971,'RT20251205000971',81,'PAID','2025-12-05 18:48:14','2025-12-05 19:41:14',160.55,'线下门店');

INSERT INTO `orders` VALUES (972,'RT20251205000972',79,'PAID','2025-12-05 19:52:58','2025-12-05 20:27:58',169.00,'线下门店');

INSERT INTO `orders` VALUES (973,'RT20251206000973',136,'PAID','2025-12-06 11:53:56','2025-12-06 11:57:56',129.00,'线下门店');

INSERT INTO `orders` VALUES (974,'RT20251206000974',450,'PAID','2025-12-06 12:25:24','2025-12-06 12:45:24',56.05,'线下门店');

INSERT INTO `orders` VALUES (975,'RT20251206000975',224,'PAID','2025-12-06 14:04:23','2025-12-06 15:00:23',39.90,'官网');

INSERT INTO `orders` VALUES (976,'RT20251206000976',188,'PAID','2025-12-06 15:14:17','2025-12-06 15:44:17',32.90,'小程序');

INSERT INTO `orders` VALUES (977,'RT20251206000977',270,'PAID','2025-12-06 16:12:10','2025-12-06 17:05:10',37.05,'小程序');

INSERT INTO `orders` VALUES (978,'RT20251206000978',83,'PAID','2025-12-06 18:09:36','2025-12-06 18:16:36',56.05,'官网');

INSERT INTO `orders` VALUES (979,'RT20251206000979',247,'CANCELLED','2025-12-06 19:32:00',NULL,32.90,'线下门店');

INSERT INTO `orders` VALUES (980,'RT20251207000980',1,'PAID','2025-12-07 10:12:45','2025-12-07 10:56:45',32.90,'官网');

INSERT INTO `orders` VALUES (981,'RT20251207000981',136,'PAID','2025-12-07 12:14:57','2025-12-07 12:45:57',80.95,'官网');

INSERT INTO `orders` VALUES (982,'RT20251207000982',170,'PAID','2025-12-07 16:04:51','2025-12-07 16:49:51',583.95,'小程序');

INSERT INTO `orders` VALUES (983,'RT20251207000983',562,'PAID','2025-12-07 16:48:14','2025-12-07 17:38:14',322.66,'小程序');

INSERT INTO `orders` VALUES (984,'RT20251207000984',138,'PAID','2025-12-07 17:46:11','2025-12-07 18:13:11',177.00,'线下门店');

INSERT INTO `orders` VALUES (985,'RT20251207000985',357,'PAID','2025-12-07 18:39:28','2025-12-07 19:09:28',37.05,'线下门店');

INSERT INTO `orders` VALUES (986,'RT20251207000986',507,'PAID','2025-12-07 19:25:31','2025-12-07 19:27:31',59.00,'官网');

INSERT INTO `orders` VALUES (987,'RT20251208000987',532,'PAID','2025-12-08 10:00:21','2025-12-08 11:14:21',31.26,'线下门店');

INSERT INTO `orders` VALUES (988,'RT20251208000988',300,'PAID','2025-12-08 10:40:34','2025-12-08 10:59:34',37.05,'小程序');

INSERT INTO `orders` VALUES (989,'RT20251208000989',237,'PAID','2025-12-08 10:49:24','2025-12-08 11:49:24',62.81,'官网');

INSERT INTO `orders` VALUES (990,'RT20251208000990',480,'PAID','2025-12-08 11:17:31','2025-12-08 11:40:31',117.00,'小程序');

INSERT INTO `orders` VALUES (991,'RT20251208000991',221,'PAID','2025-12-08 11:36:41','2025-12-08 12:08:41',104.55,'线下门店');

INSERT INTO `orders` VALUES (992,'RT20251208000992',104,'PAID','2025-12-08 12:40:46','2025-12-08 13:17:46',147.80,'小程序');

INSERT INTO `orders` VALUES (993,'RT20251208000993',430,'PAID','2025-12-08 12:43:44','2025-12-08 12:54:44',127.00,'小程序');

INSERT INTO `orders` VALUES (994,'RT20251208000994',169,'PAID','2025-12-08 15:43:11','2025-12-08 15:46:11',137.00,'小程序');

INSERT INTO `orders` VALUES (995,'RT20251208000995',321,'CANCELLED','2025-12-08 16:35:24',NULL,49.80,'线下门店');

INSERT INTO `orders` VALUES (996,'RT20251209000996',336,'PAID','2025-12-09 10:45:46','2025-12-09 10:51:46',32.90,'官网');

INSERT INTO `orders` VALUES (997,'RT20251209000997',125,'PAID','2025-12-09 10:58:49','2025-12-09 11:53:49',169.00,'官网');

INSERT INTO `orders` VALUES (998,'RT20251209000998',256,'PAID','2025-12-09 12:44:20','2025-12-09 12:57:20',39.90,'线下门店');

INSERT INTO `orders` VALUES (999,'RT20251209000999',175,'PAID','2025-12-09 12:55:01','2025-12-09 13:43:01',83.90,'小程序');

INSERT INTO `orders` VALUES (1000,'RT20251209001000',182,'PAID','2025-12-09 20:36:13','2025-12-09 21:03:13',238.90,'小程序');

INSERT INTO `orders` VALUES (1001,'RT20251209001001',421,'PAID','2025-12-09 20:40:12','2025-12-09 20:46:12',102.51,'官网');

INSERT INTO `orders` VALUES (1002,'RT20251210001002',13,'PAID','2025-12-10 12:18:19','2025-12-10 12:40:19',299.00,'小程序');

INSERT INTO `orders` VALUES (1003,'RT20251210001003',22,'CANCELLED','2025-12-10 14:28:29',NULL,69.00,'小程序');

INSERT INTO `orders` VALUES (1004,'RT20251210001004',72,'PAID','2025-12-10 17:11:00','2025-12-10 17:51:00',64.60,'小程序');

INSERT INTO `orders` VALUES (1005,'RT20251211001005',52,'PAID','2025-12-11 10:58:08','2025-12-11 11:44:08',32.90,'线下门店');

INSERT INTO `orders` VALUES (1006,'RT20251211001006',318,'PAID','2025-12-11 15:59:20','2025-12-11 16:33:20',24.90,'官网');

INSERT INTO `orders` VALUES (1007,'RT20251211001007',53,'PAID','2025-12-11 18:41:05','2025-12-11 19:23:05',250.80,'线下门店');

INSERT INTO `orders` VALUES (1008,'RT20251211001008',466,'PAID','2025-12-11 20:04:47','2025-12-11 20:48:47',86.10,'线下门店');

INSERT INTO `orders` VALUES (1009,'RT20251211001009',294,'PAID','2025-12-11 21:44:48','2025-12-11 22:00:48',438.00,'官网');

INSERT INTO `orders` VALUES (1010,'RT20251212001010',147,'PAID','2025-12-12 11:00:07','2025-12-12 11:35:07',207.90,'小程序');

INSERT INTO `orders` VALUES (1011,'RT20251212001011',425,'PAID','2025-12-12 12:43:50','2025-12-12 13:45:50',56.05,'小程序');

INSERT INTO `orders` VALUES (1012,'RT20251212001012',64,'PAID','2025-12-12 12:44:16','2025-12-12 13:34:16',118.90,'小程序');

INSERT INTO `orders` VALUES (1013,'RT20251212001013',51,'PAID','2025-12-12 15:02:06','2025-12-12 16:07:06',399.00,'小程序');

INSERT INTO `orders` VALUES (1014,'RT20251212001014',185,'CANCELLED','2025-12-12 16:26:45',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (1015,'RT20251212001015',1,'CANCELLED','2025-12-12 17:24:51',NULL,80.10,'企业采购');

INSERT INTO `orders` VALUES (1016,'RT20251212001016',50,'PAID','2025-12-12 20:03:53','2025-12-12 20:57:53',79.00,'线下门店');

INSERT INTO `orders` VALUES (1017,'RT20251212001017',550,'PAID','2025-12-12 21:52:01','2025-12-12 22:28:01',199.00,'线下门店');

INSERT INTO `orders` VALUES (1018,'RT20251213001018',482,'PAID','2025-12-13 11:42:12','2025-12-13 11:49:12',39.00,'企业采购');

INSERT INTO `orders` VALUES (1019,'RT20251213001019',264,'PAID','2025-12-13 11:53:50','2025-12-13 12:15:50',78.00,'小程序');

INSERT INTO `orders` VALUES (1020,'RT20251213001020',411,'PAID','2025-12-13 12:20:27','2025-12-13 12:42:27',89.00,'线下门店');

INSERT INTO `orders` VALUES (1021,'RT20251213001021',401,'PAID','2025-12-13 13:43:00','2025-12-13 13:52:00',39.00,'官网');

INSERT INTO `orders` VALUES (1022,'RT20251213001022',294,'PAID','2025-12-13 14:33:51','2025-12-13 15:26:51',24.90,'线下门店');

INSERT INTO `orders` VALUES (1023,'RT20251213001023',94,'PAID','2025-12-13 16:43:40','2025-12-13 17:29:40',191.90,'线下门店');

INSERT INTO `orders` VALUES (1024,'RT20251213001024',515,'PAID','2025-12-13 17:18:59','2025-12-13 18:17:59',129.00,'官网');

INSERT INTO `orders` VALUES (1025,'RT20251213001025',315,'PAID','2025-12-13 19:07:28','2025-12-13 19:56:28',89.00,'官网');

INSERT INTO `orders` VALUES (1026,'RT20251213001026',193,'PAID','2025-12-13 19:49:44','2025-12-13 20:40:44',237.00,'小程序');

INSERT INTO `orders` VALUES (1027,'RT20251213001027',268,'CANCELLED','2025-12-13 19:50:38',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1028,'RT20251214001028',601,'PAID','2025-12-14 09:37:07','2025-12-14 09:49:07',39.90,'小程序');

INSERT INTO `orders` VALUES (1029,'RT20251214001029',245,'PAID','2025-12-14 10:53:02','2025-12-14 11:07:02',118.00,'小程序');

INSERT INTO `orders` VALUES (1030,'RT20251214001030',87,'PAID','2025-12-14 14:58:51','2025-12-14 15:58:51',143.55,'小程序');

INSERT INTO `orders` VALUES (1031,'RT20251214001031',351,'PAID','2025-12-14 15:30:15','2025-12-14 16:15:15',343.05,'线下门店');

INSERT INTO `orders` VALUES (1032,'RT20251214001032',435,'PAID','2025-12-14 17:49:46','2025-12-14 18:03:46',39.00,'线下门店');

INSERT INTO `orders` VALUES (1033,'RT20251214001033',322,'PAID','2025-12-14 17:52:51','2025-12-14 18:06:51',22.41,'小程序');

INSERT INTO `orders` VALUES (1034,'RT20251214001034',260,'PAID','2025-12-14 18:21:07','2025-12-14 18:52:07',47.31,'小程序');

INSERT INTO `orders` VALUES (1035,'RT20251214001035',153,'PAID','2025-12-14 22:56:09','2025-12-15 00:07:09',386.00,'线下门店');

INSERT INTO `orders` VALUES (1036,'RT20251215001036',273,'PAID','2025-12-15 09:46:06','2025-12-15 10:18:06',32.90,'小程序');

INSERT INTO `orders` VALUES (1037,'RT20251215001037',138,'PAID','2025-12-15 14:19:55','2025-12-15 14:37:55',281.10,'小程序');

INSERT INTO `orders` VALUES (1038,'RT20251215001038',270,'PAID','2025-12-15 14:35:54','2025-12-15 14:43:54',159.00,'官网');

INSERT INTO `orders` VALUES (1039,'RT20251215001039',412,'PAID','2025-12-15 14:40:11','2025-12-15 15:44:11',250.90,'企业采购');

INSERT INTO `orders` VALUES (1040,'RT20251215001040',156,'REFUNDED','2025-12-15 17:45:29','2025-12-15 18:15:29',24.90,'小程序');

INSERT INTO `orders` VALUES (1041,'RT20251215001041',323,'PAID','2025-12-15 21:30:21','2025-12-15 22:25:21',24.90,'线下门店');

INSERT INTO `orders` VALUES (1042,'RT20251216001042',505,'PAID','2025-12-16 10:56:19','2025-12-16 12:03:19',32.90,'官网');

INSERT INTO `orders` VALUES (1043,'RT20251216001043',238,'CANCELLED','2025-12-16 12:48:33',NULL,37.05,'小程序');

INSERT INTO `orders` VALUES (1044,'RT20251216001044',478,'REFUNDED','2025-12-16 12:52:13','2025-12-16 13:02:13',39.00,'线下门店');

INSERT INTO `orders` VALUES (1045,'RT20251216001045',159,'CANCELLED','2025-12-16 16:40:45',NULL,338.90,'小程序');

INSERT INTO `orders` VALUES (1046,'RT20251216001046',62,'PAID','2025-12-16 17:39:57','2025-12-16 18:49:57',414.00,'小程序');

INSERT INTO `orders` VALUES (1047,'RT20251216001047',125,'PAID','2025-12-16 21:36:56','2025-12-16 21:56:56',68.00,'线下门店');

INSERT INTO `orders` VALUES (1048,'RT20251217001048',192,'PAID','2025-12-17 08:19:56','2025-12-17 09:04:56',31.26,'小程序');

INSERT INTO `orders` VALUES (1049,'RT20251217001049',123,'PAID','2025-12-17 12:11:07','2025-12-17 13:22:07',139.65,'线下门店');

INSERT INTO `orders` VALUES (1050,'RT20251217001050',162,'PAID','2025-12-17 12:31:34','2025-12-17 13:07:34',32.90,'小程序');

INSERT INTO `orders` VALUES (1051,'RT20251217001051',208,'PAID','2025-12-17 16:35:13','2025-12-17 16:53:13',158.00,'小程序');

INSERT INTO `orders` VALUES (1052,'RT20251217001052',78,'REFUNDED','2025-12-17 19:35:59','2025-12-17 20:41:59',23.66,'小程序');

INSERT INTO `orders` VALUES (1053,'RT20251217001053',508,'PAID','2025-12-17 20:00:51','2025-12-17 20:19:51',59.00,'官网');

INSERT INTO `orders` VALUES (1054,'RT20251217001054',381,'PAID','2025-12-17 20:30:17','2025-12-17 20:53:17',39.00,'线下门店');

INSERT INTO `orders` VALUES (1055,'RT20251218001055',321,'PAID','2025-12-18 13:40:59','2025-12-18 14:53:59',68.00,'小程序');

INSERT INTO `orders` VALUES (1056,'RT20251218001056',259,'PAID','2025-12-18 18:56:52','2025-12-18 19:36:52',68.00,'线下门店');

INSERT INTO `orders` VALUES (1057,'RT20251218001057',405,'PAID','2025-12-18 18:57:09','2025-12-18 20:07:09',284.05,'官网');

INSERT INTO `orders` VALUES (1058,'RT20251218001058',383,'PAID','2025-12-18 20:25:53','2025-12-18 20:42:53',128.90,'线下门店');

INSERT INTO `orders` VALUES (1059,'RT20251218001059',487,'PAID','2025-12-18 20:50:29','2025-12-18 21:54:29',243.96,'小程序');

INSERT INTO `orders` VALUES (1060,'RT20251218001060',502,'PAID','2025-12-18 21:41:23','2025-12-18 22:37:23',89.00,'小程序');

INSERT INTO `orders` VALUES (1061,'RT20251219001061',258,'PAID','2025-12-19 10:53:31','2025-12-19 11:40:31',92.90,'官网');

INSERT INTO `orders` VALUES (1062,'RT20251219001062',213,'REFUNDED','2025-12-19 11:50:14','2025-12-19 12:32:14',184.21,'线下门店');

INSERT INTO `orders` VALUES (1063,'RT20251219001063',327,'PAID','2025-12-19 13:33:37','2025-12-19 14:37:37',373.70,'小程序');

INSERT INTO `orders` VALUES (1064,'RT20251219001064',106,'CANCELLED','2025-12-19 13:38:18',NULL,59.00,'线下门店');

INSERT INTO `orders` VALUES (1065,'RT20251219001065',556,'REFUNDED','2025-12-19 17:24:40','2025-12-19 17:28:40',248.00,'官网');

INSERT INTO `orders` VALUES (1066,'RT20251219001066',178,'PAID','2025-12-19 18:08:57','2025-12-19 18:27:57',39.00,'小程序');

INSERT INTO `orders` VALUES (1067,'RT20251219001067',596,'PAID','2025-12-19 22:47:36','2025-12-19 23:42:36',39.90,'官网');

INSERT INTO `orders` VALUES (1068,'RT20251220001068',318,'PAID','2025-12-20 11:47:16','2025-12-20 12:32:16',78.90,'小程序');

INSERT INTO `orders` VALUES (1069,'RT20251220001069',105,'PAID','2025-12-20 11:49:20','2025-12-20 12:15:20',32.90,'官网');

INSERT INTO `orders` VALUES (1070,'RT20251220001070',429,'PAID','2025-12-20 13:28:00','2025-12-20 14:02:00',39.00,'小程序');

INSERT INTO `orders` VALUES (1071,'RT20251220001071',509,'PAID','2025-12-20 13:31:51','2025-12-20 14:20:51',59.00,'线下门店');

INSERT INTO `orders` VALUES (1072,'RT20251220001072',588,'PAID','2025-12-20 14:48:34','2025-12-20 15:46:34',338.90,'线下门店');

INSERT INTO `orders` VALUES (1073,'RT20251220001073',9,'PAID','2025-12-20 15:32:26','2025-12-20 16:23:26',39.90,'官网');

INSERT INTO `orders` VALUES (1074,'RT20251220001074',51,'PAID','2025-12-20 16:46:48','2025-12-20 17:39:48',340.60,'线下门店');

INSERT INTO `orders` VALUES (1075,'RT20251220001075',51,'PAID','2025-12-20 17:44:36','2025-12-20 18:12:36',39.90,'小程序');

INSERT INTO `orders` VALUES (1076,'RT20251220001076',38,'PAID','2025-12-20 20:42:58','2025-12-20 21:44:58',84.55,'小程序');

INSERT INTO `orders` VALUES (1077,'RT20251221001077',149,'PAID','2025-12-21 09:00:41','2025-12-21 09:37:41',39.00,'官网');

INSERT INTO `orders` VALUES (1078,'RT20251221001078',74,'PAID','2025-12-21 12:19:33','2025-12-21 13:06:33',104.55,'小程序');

INSERT INTO `orders` VALUES (1079,'RT20251221001079',195,'PAID','2025-12-21 12:26:51','2025-12-21 12:31:51',157.90,'线下门店');

INSERT INTO `orders` VALUES (1080,'RT20251221001080',32,'PAID','2025-12-21 16:36:29','2025-12-21 17:46:29',39.00,'小程序');

INSERT INTO `orders` VALUES (1081,'RT20251221001081',360,'PAID','2025-12-21 18:04:02','2025-12-21 18:05:02',258.00,'线下门店');

INSERT INTO `orders` VALUES (1082,'RT20251221001082',541,'PAID','2025-12-21 19:30:51','2025-12-21 20:21:51',72.80,'小程序');

INSERT INTO `orders` VALUES (1083,'RT20251221001083',617,'PAID','2025-12-21 19:40:55','2025-12-21 19:56:55',24.90,'小程序');

INSERT INTO `orders` VALUES (1084,'RT20251221001084',250,'PAID','2025-12-21 19:42:52','2025-12-21 20:03:52',94.10,'小程序');

INSERT INTO `orders` VALUES (1085,'RT20251221001085',446,'CANCELLED','2025-12-21 20:35:22',NULL,79.80,'官网');

INSERT INTO `orders` VALUES (1086,'RT20251221001086',17,'PAID','2025-12-21 20:55:04','2025-12-21 21:28:04',189.90,'小程序');

INSERT INTO `orders` VALUES (1087,'RT20251222001087',309,'PAID','2025-12-22 09:09:47','2025-12-22 10:07:47',195.10,'线下门店');

INSERT INTO `orders` VALUES (1088,'RT20251222001088',328,'PAID','2025-12-22 15:53:14','2025-12-22 16:26:14',196.91,'线下门店');

INSERT INTO `orders` VALUES (1089,'RT20251222001089',500,'PAID','2025-12-22 17:12:56','2025-12-22 17:14:56',71.90,'线下门店');

INSERT INTO `orders` VALUES (1090,'RT20251222001090',37,'PAID','2025-12-22 18:45:04','2025-12-22 19:27:04',68.00,'小程序');

INSERT INTO `orders` VALUES (1091,'RT20251222001091',287,'PAID','2025-12-22 19:24:07','2025-12-22 19:27:07',39.90,'小程序');

INSERT INTO `orders` VALUES (1092,'RT20251223001092',535,'PAID','2025-12-23 11:15:29','2025-12-23 11:20:29',39.90,'小程序');

INSERT INTO `orders` VALUES (1093,'RT20251223001093',457,'PAID','2025-12-23 14:10:52','2025-12-23 15:02:52',64.80,'线下门店');

INSERT INTO `orders` VALUES (1094,'RT20251223001094',356,'CANCELLED','2025-12-23 15:19:16',NULL,118.90,'线下门店');

INSERT INTO `orders` VALUES (1095,'RT20251223001095',378,'PAID','2025-12-23 16:06:09','2025-12-23 16:50:09',59.00,'企业采购');

INSERT INTO `orders` VALUES (1096,'RT20251223001096',20,'CANCELLED','2025-12-23 18:00:58',NULL,129.00,'小程序');

INSERT INTO `orders` VALUES (1097,'RT20251223001097',359,'PAID','2025-12-23 18:04:16','2025-12-23 18:09:16',68.00,'官网');

INSERT INTO `orders` VALUES (1098,'RT20251223001098',60,'REFUNDED','2025-12-23 18:42:40','2025-12-23 19:47:40',64.60,'线下门店');

INSERT INTO `orders` VALUES (1099,'RT20251223001099',139,'PAID','2025-12-23 19:12:42','2025-12-23 20:15:42',24.90,'线下门店');

INSERT INTO `orders` VALUES (1100,'RT20251223001100',224,'PAID','2025-12-23 19:18:41','2025-12-23 20:28:41',59.00,'小程序');

INSERT INTO `orders` VALUES (1101,'RT20251223001101',160,'PAID','2025-12-23 20:11:53','2025-12-23 21:21:53',39.90,'线下门店');

INSERT INTO `orders` VALUES (1102,'RT20251224001102',122,'PAID','2025-12-24 11:17:52','2025-12-24 11:45:52',126.91,'线下门店');

INSERT INTO `orders` VALUES (1103,'RT20251224001103',264,'PAID','2025-12-24 11:21:09','2025-12-24 12:28:09',39.00,'小程序');

INSERT INTO `orders` VALUES (1104,'RT20251224001104',219,'PAID','2025-12-24 11:27:14','2025-12-24 12:32:14',267.00,'企业采购');

INSERT INTO `orders` VALUES (1105,'RT20251224001105',264,'PAID','2025-12-24 13:16:59','2025-12-24 13:18:59',286.20,'小程序');

INSERT INTO `orders` VALUES (1106,'RT20251224001106',29,'PAID','2025-12-24 14:24:01','2025-12-24 15:18:01',55.31,'小程序');

INSERT INTO `orders` VALUES (1107,'RT20251224001107',634,'PAID','2025-12-24 16:12:54','2025-12-24 16:59:54',69.00,'小程序');

INSERT INTO `orders` VALUES (1108,'RT20251224001108',553,'PAID','2025-12-24 16:17:53','2025-12-24 17:32:53',113.00,'小程序');

INSERT INTO `orders` VALUES (1109,'RT20251224001109',462,'PAID','2025-12-24 18:09:04','2025-12-24 19:17:04',123.80,'小程序');

INSERT INTO `orders` VALUES (1110,'RT20251224001110',602,'PAID','2025-12-24 19:11:29','2025-12-24 19:17:29',37.05,'小程序');

INSERT INTO `orders` VALUES (1111,'RT20251224001111',337,'PAID','2025-12-24 19:27:04','2025-12-24 20:12:04',118.00,'企业采购');

INSERT INTO `orders` VALUES (1112,'RT20251224001112',72,'PAID','2025-12-24 19:49:05','2025-12-24 20:22:05',37.91,'小程序');

INSERT INTO `orders` VALUES (1113,'RT20251224001113',117,'PAID','2025-12-24 20:06:31','2025-12-24 20:19:31',118.00,'官网');

INSERT INTO `orders` VALUES (1114,'RT20251225001114',24,'PAID','2025-12-25 11:22:52','2025-12-25 11:26:52',37.05,'线下门店');

INSERT INTO `orders` VALUES (1115,'RT20251225001115',225,'PAID','2025-12-25 11:44:59','2025-12-25 12:24:59',39.00,'线下门店');

INSERT INTO `orders` VALUES (1116,'RT20251225001116',552,'PAID','2025-12-25 12:11:12','2025-12-25 13:08:12',899.00,'线下门店');

INSERT INTO `orders` VALUES (1117,'RT20251225001117',183,'PAID','2025-12-25 15:44:52','2025-12-25 15:58:52',78.00,'官网');

INSERT INTO `orders` VALUES (1118,'RT20251225001118',475,'REFUNDED','2025-12-25 16:44:37','2025-12-25 17:33:37',39.90,'小程序');

INSERT INTO `orders` VALUES (1119,'RT20251225001119',264,'PAID','2025-12-25 18:06:48','2025-12-25 18:29:48',338.00,'线下门店');

INSERT INTO `orders` VALUES (1120,'RT20251226001120',64,'PAID','2025-12-26 11:50:13','2025-12-26 12:33:13',78.00,'官网');

INSERT INTO `orders` VALUES (1121,'RT20251226001121',204,'PAID','2025-12-26 13:37:05','2025-12-26 14:27:05',59.00,'线下门店');

INSERT INTO `orders` VALUES (1122,'RT20251226001122',96,'PAID','2025-12-26 15:35:32','2025-12-26 15:36:32',136.00,'线下门店');

INSERT INTO `orders` VALUES (1123,'RT20251226001123',143,'PAID','2025-12-26 17:30:25','2025-12-26 18:13:25',160.55,'小程序');

INSERT INTO `orders` VALUES (1124,'RT20251226001124',262,'PAID','2025-12-26 17:58:11','2025-12-26 18:30:11',669.00,'企业采购');

INSERT INTO `orders` VALUES (1125,'RT20251226001125',7,'PAID','2025-12-26 18:04:37','2025-12-26 18:46:37',160.55,'线下门店');

INSERT INTO `orders` VALUES (1126,'RT20251226001126',174,'PAID','2025-12-26 18:26:54','2025-12-26 19:21:54',169.00,'小程序');

INSERT INTO `orders` VALUES (1127,'RT20251227001127',444,'PAID','2025-12-27 10:01:44','2025-12-27 10:35:44',105.30,'小程序');

INSERT INTO `orders` VALUES (1128,'RT20251227001128',179,'PAID','2025-12-27 10:30:00','2025-12-27 10:44:00',71.90,'小程序');

INSERT INTO `orders` VALUES (1129,'RT20251227001129',42,'PAID','2025-12-27 10:34:20','2025-12-27 11:34:20',135.85,'小程序');

INSERT INTO `orders` VALUES (1130,'RT20251227001130',427,'PAID','2025-12-27 12:25:55','2025-12-27 13:00:55',65.80,'小程序');

INSERT INTO `orders` VALUES (1131,'RT20251227001131',28,'PAID','2025-12-27 14:22:30','2025-12-27 15:10:30',136.00,'线下门店');

INSERT INTO `orders` VALUES (1132,'RT20251227001132',625,'PAID','2025-12-27 15:05:04','2025-12-27 15:37:04',399.00,'小程序');

INSERT INTO `orders` VALUES (1133,'RT20251227001133',192,'PAID','2025-12-27 15:42:00','2025-12-27 16:03:00',78.00,'线下门店');

INSERT INTO `orders` VALUES (1134,'RT20251227001134',357,'PAID','2025-12-27 15:58:25','2025-12-27 16:28:25',169.00,'小程序');

INSERT INTO `orders` VALUES (1135,'RT20251227001135',577,'PAID','2025-12-27 17:24:39','2025-12-27 18:35:39',168.00,'企业采购');

INSERT INTO `orders` VALUES (1136,'RT20251227001136',107,'PAID','2025-12-27 19:43:02','2025-12-27 19:56:02',79.00,'小程序');

INSERT INTO `orders` VALUES (1137,'RT20251227001137',372,'PAID','2025-12-27 20:06:54','2025-12-27 21:17:54',71.82,'线下门店');

INSERT INTO `orders` VALUES (1138,'RT20251227001138',187,'CANCELLED','2025-12-27 21:17:32',NULL,276.90,'小程序');

INSERT INTO `orders` VALUES (1139,'RT20251228001139',318,'PAID','2025-12-28 10:19:45','2025-12-28 11:12:45',68.00,'线下门店');

INSERT INTO `orders` VALUES (1140,'RT20251228001140',294,'PAID','2025-12-28 12:58:43','2025-12-28 14:12:43',35.10,'小程序');

INSERT INTO `orders` VALUES (1141,'RT20251228001141',285,'PAID','2025-12-28 13:25:50','2025-12-28 13:31:50',32.90,'小程序');

INSERT INTO `orders` VALUES (1142,'RT20251228001142',153,'PAID','2025-12-28 13:46:41','2025-12-28 14:37:41',68.00,'小程序');

INSERT INTO `orders` VALUES (1143,'RT20251228001143',393,'CANCELLED','2025-12-28 14:24:26',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (1144,'RT20251228001144',265,'PAID','2025-12-28 14:49:06','2025-12-28 15:25:06',80.10,'官网');

INSERT INTO `orders` VALUES (1145,'RT20251228001145',494,'PAID','2025-12-28 16:53:43','2025-12-28 17:01:43',59.00,'小程序');

INSERT INTO `orders` VALUES (1146,'RT20251228001146',188,'CANCELLED','2025-12-28 18:26:15',NULL,128.80,'小程序');

INSERT INTO `orders` VALUES (1147,'RT20251228001147',111,'PAID','2025-12-28 20:18:55','2025-12-28 20:28:55',39.90,'企业采购');

INSERT INTO `orders` VALUES (1148,'RT20251228001148',505,'PAID','2025-12-28 20:48:48','2025-12-28 21:08:48',37.91,'线下门店');

INSERT INTO `orders` VALUES (1149,'RT20251228001149',241,'PAID','2025-12-28 21:10:04','2025-12-28 21:40:04',39.00,'线下门店');

INSERT INTO `orders` VALUES (1150,'RT20251228001150',213,'PAID','2025-12-28 21:27:02','2025-12-28 22:06:02',103.90,'线下门店');

INSERT INTO `orders` VALUES (1151,'RT20251229001151',27,'PAID','2025-12-29 10:45:58','2025-12-29 11:30:58',119.70,'线下门店');

INSERT INTO `orders` VALUES (1152,'RT20251229001152',239,'PAID','2025-12-29 13:53:49','2025-12-29 13:56:49',138.00,'官网');

INSERT INTO `orders` VALUES (1153,'RT20251229001153',374,'REFUNDED','2025-12-29 18:10:31','2025-12-29 18:54:31',37.91,'小程序');

INSERT INTO `orders` VALUES (1154,'RT20251229001154',418,'PAID','2025-12-29 18:30:15','2025-12-29 19:39:15',64.60,'官网');

INSERT INTO `orders` VALUES (1155,'RT20251229001155',109,'PAID','2025-12-29 18:40:36','2025-12-29 19:24:36',136.00,'小程序');

INSERT INTO `orders` VALUES (1156,'RT20251229001156',371,'PAID','2025-12-29 18:49:07','2025-12-29 19:49:07',78.00,'小程序');

INSERT INTO `orders` VALUES (1157,'RT20251229001157',136,'PAID','2025-12-29 19:49:41','2025-12-29 21:02:41',184.10,'企业采购');

INSERT INTO `orders` VALUES (1158,'RT20251229001158',43,'PAID','2025-12-29 21:05:30','2025-12-29 22:09:30',178.76,'小程序');

INSERT INTO `orders` VALUES (1159,'RT20251230001159',299,'PAID','2025-12-30 11:10:40','2025-12-30 11:59:40',116.10,'小程序');

INSERT INTO `orders` VALUES (1160,'RT20251230001160',121,'PAID','2025-12-30 11:15:31','2025-12-30 11:27:31',447.00,'小程序');

INSERT INTO `orders` VALUES (1161,'RT20251230001161',214,'REFUNDED','2025-12-30 11:31:50','2025-12-30 12:19:50',111.90,'企业采购');

INSERT INTO `orders` VALUES (1162,'RT20251230001162',195,'PAID','2025-12-30 11:47:35','2025-12-30 12:43:35',100.90,'小程序');

INSERT INTO `orders` VALUES (1163,'RT20251230001163',187,'PAID','2025-12-30 14:29:44','2025-12-30 15:17:44',371.80,'线下门店');

INSERT INTO `orders` VALUES (1164,'RT20251230001164',294,'PAID','2025-12-30 16:31:02','2025-12-30 17:28:02',158.00,'官网');

INSERT INTO `orders` VALUES (1165,'RT20251230001165',496,'PAID','2025-12-30 18:13:56','2025-12-30 18:52:56',169.00,'线下门店');

INSERT INTO `orders` VALUES (1166,'RT20251230001166',287,'PAID','2025-12-30 19:39:10','2025-12-30 20:13:10',24.90,'线下门店');

INSERT INTO `orders` VALUES (1167,'RT20251230001167',338,'PAID','2025-12-30 20:57:51','2025-12-30 22:00:51',96.06,'企业采购');

INSERT INTO `orders` VALUES (1168,'RT20251231001168',29,'PAID','2025-12-31 09:25:47','2025-12-31 09:45:47',185.45,'线下门店');

INSERT INTO `orders` VALUES (1169,'RT20251231001169',580,'PAID','2025-12-31 10:43:05','2025-12-31 11:38:05',32.90,'小程序');

INSERT INTO `orders` VALUES (1170,'RT20251231001170',287,'PAID','2025-12-31 12:20:36','2025-12-31 13:29:36',327.46,'官网');

INSERT INTO `orders` VALUES (1171,'RT20251231001171',61,'PAID','2025-12-31 12:48:41','2025-12-31 13:54:41',32.90,'官网');

INSERT INTO `orders` VALUES (1172,'RT20251231001172',512,'CANCELLED','2025-12-31 13:23:44',NULL,32.90,'官网');

INSERT INTO `orders` VALUES (1173,'RT20251231001173',195,'PAID','2025-12-31 17:27:02','2025-12-31 18:31:02',258.00,'官网');

INSERT INTO `orders` VALUES (1174,'RT20251231001174',494,'PAID','2025-12-31 18:44:52','2025-12-31 19:27:52',147.80,'官网');

INSERT INTO `orders` VALUES (1175,'RT20251231001175',544,'PAID','2025-12-31 21:26:26','2025-12-31 22:19:26',39.90,'小程序');

INSERT INTO `orders` VALUES (1176,'RT20260101001176',507,'PAID','2026-01-01 10:10:27','2026-01-01 11:15:27',78.90,'线下门店');

INSERT INTO `orders` VALUES (1177,'RT20260101001177',328,'PAID','2026-01-01 10:20:46','2026-01-01 11:17:46',64.80,'线下门店');

INSERT INTO `orders` VALUES (1178,'RT20260101001178',162,'PAID','2026-01-01 10:34:29','2026-01-01 10:41:29',751.10,'小程序');

INSERT INTO `orders` VALUES (1179,'RT20260101001179',288,'PAID','2026-01-01 15:59:34','2026-01-01 16:04:34',186.46,'小程序');

INSERT INTO `orders` VALUES (1180,'RT20260101001180',112,'PAID','2026-01-01 18:03:52','2026-01-01 19:02:52',94.85,'小程序');

INSERT INTO `orders` VALUES (1181,'RT20260101001181',49,'PAID','2026-01-01 19:19:10','2026-01-01 19:59:10',79.80,'小程序');

INSERT INTO `orders` VALUES (1182,'RT20260101001182',288,'PAID','2026-01-01 19:25:25','2026-01-01 20:06:25',88.80,'小程序');

INSERT INTO `orders` VALUES (1183,'RT20260102001183',403,'CANCELLED','2026-01-02 12:11:27',NULL,68.00,'线下门店');

INSERT INTO `orders` VALUES (1184,'RT20260102001184',185,'PAID','2026-01-02 16:22:11','2026-01-02 16:39:11',23.66,'线下门店');

INSERT INTO `orders` VALUES (1185,'RT20260102001185',218,'PAID','2026-01-02 17:19:33','2026-01-02 17:34:33',39.00,'小程序');

INSERT INTO `orders` VALUES (1186,'RT20260102001186',278,'PAID','2026-01-02 17:39:55','2026-01-02 18:34:55',184.30,'小程序');

INSERT INTO `orders` VALUES (1187,'RT20260102001187',264,'PAID','2026-01-02 18:13:18','2026-01-02 18:38:18',69.00,'小程序');

INSERT INTO `orders` VALUES (1188,'RT20260102001188',99,'PAID','2026-01-02 19:33:03','2026-01-02 20:22:03',31.26,'官网');

INSERT INTO `orders` VALUES (1189,'RT20260103001189',622,'PAID','2026-01-03 11:53:44','2026-01-03 12:11:44',232.45,'企业采购');

INSERT INTO `orders` VALUES (1190,'RT20260103001190',476,'PAID','2026-01-03 13:40:38','2026-01-03 14:14:38',59.00,'小程序');

INSERT INTO `orders` VALUES (1191,'RT20260103001191',205,'PAID','2026-01-03 16:54:11','2026-01-03 17:04:11',39.00,'小程序');

INSERT INTO `orders` VALUES (1192,'RT20260103001192',217,'PAID','2026-01-03 17:13:29','2026-01-03 17:36:29',546.90,'企业采购');

INSERT INTO `orders` VALUES (1193,'RT20260103001193',599,'PAID','2026-01-03 20:10:31','2026-01-03 20:59:31',68.00,'线下门店');

INSERT INTO `orders` VALUES (1194,'RT20260103001194',399,'CANCELLED','2026-01-03 20:22:09',NULL,179.10,'线下门店');

INSERT INTO `orders` VALUES (1195,'RT20260104001195',22,'PAID','2026-01-04 14:36:58','2026-01-04 14:40:58',23.66,'官网');

INSERT INTO `orders` VALUES (1196,'RT20260104001196',437,'PAID','2026-01-04 15:11:41','2026-01-04 15:26:41',59.00,'线下门店');

INSERT INTO `orders` VALUES (1197,'RT20260104001197',88,'PAID','2026-01-04 15:46:56','2026-01-04 15:52:56',212.90,'小程序');

INSERT INTO `orders` VALUES (1198,'RT20260104001198',309,'PAID','2026-01-04 16:24:06','2026-01-04 17:17:06',64.60,'线下门店');

INSERT INTO `orders` VALUES (1199,'RT20260104001199',238,'PAID','2026-01-04 18:00:41','2026-01-04 19:11:41',798.00,'小程序');

INSERT INTO `orders` VALUES (1200,'RT20260105001200',511,'PAID','2026-01-05 11:43:06','2026-01-05 11:52:06',64.60,'小程序');

INSERT INTO `orders` VALUES (1201,'RT20260105001201',395,'PAID','2026-01-05 12:14:15','2026-01-05 12:20:15',32.90,'官网');

INSERT INTO `orders` VALUES (1202,'RT20260105001202',281,'PAID','2026-01-05 12:27:16','2026-01-05 12:57:16',169.00,'线下门店');

INSERT INTO `orders` VALUES (1203,'RT20260105001203',188,'PAID','2026-01-05 18:11:35','2026-01-05 18:15:35',116.80,'小程序');

INSERT INTO `orders` VALUES (1204,'RT20260105001204',505,'PAID','2026-01-05 18:35:14','2026-01-05 19:37:14',328.00,'小程序');

INSERT INTO `orders` VALUES (1205,'RT20260106001205',89,'PAID','2026-01-06 09:51:06','2026-01-06 10:47:06',78.00,'官网');

INSERT INTO `orders` VALUES (1206,'RT20260106001206',219,'PAID','2026-01-06 10:04:26','2026-01-06 10:05:26',71.10,'线下门店');

INSERT INTO `orders` VALUES (1207,'RT20260106001207',552,'PAID','2026-01-06 11:55:15','2026-01-06 12:04:15',140.80,'小程序');

INSERT INTO `orders` VALUES (1208,'RT20260106001208',296,'PAID','2026-01-06 17:11:58','2026-01-06 17:56:58',39.90,'小程序');

INSERT INTO `orders` VALUES (1209,'RT20260106001209',258,'PAID','2026-01-06 18:17:34','2026-01-06 18:26:34',122.55,'小程序');

INSERT INTO `orders` VALUES (1210,'RT20260107001210',100,'PAID','2026-01-07 08:06:57','2026-01-07 08:40:57',32.90,'线下门店');

INSERT INTO `orders` VALUES (1211,'RT20260107001211',111,'REFUNDED','2026-01-07 12:57:16','2026-01-07 13:09:16',166.91,'小程序');

INSERT INTO `orders` VALUES (1212,'RT20260107001212',422,'PAID','2026-01-07 16:12:47','2026-01-07 16:37:47',39.00,'线下门店');

INSERT INTO `orders` VALUES (1213,'RT20260107001213',162,'CANCELLED','2026-01-07 18:19:43',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (1214,'RT20260107001214',109,'PAID','2026-01-07 18:46:10','2026-01-07 18:56:10',65.80,'小程序');

INSERT INTO `orders` VALUES (1215,'RT20260107001215',157,'PAID','2026-01-07 20:33:41','2026-01-07 21:44:41',150.10,'小程序');

INSERT INTO `orders` VALUES (1216,'RT20260108001216',217,'PAID','2026-01-08 12:45:45','2026-01-08 13:00:45',102.21,'小程序');

INSERT INTO `orders` VALUES (1217,'RT20260108001217',18,'PAID','2026-01-08 16:21:44','2026-01-08 16:29:44',39.00,'小程序');

INSERT INTO `orders` VALUES (1218,'RT20260108001218',428,'PAID','2026-01-08 18:06:01','2026-01-08 18:15:01',118.90,'小程序');

INSERT INTO `orders` VALUES (1219,'RT20260108001219',1,'PAID','2026-01-08 18:37:07','2026-01-08 19:29:07',79.80,'线下门店');

INSERT INTO `orders` VALUES (1220,'RT20260109001220',437,'PAID','2026-01-09 10:32:28','2026-01-09 11:14:28',445.00,'小程序');

INSERT INTO `orders` VALUES (1221,'RT20260109001221',169,'PAID','2026-01-09 11:08:41','2026-01-09 11:41:41',105.91,'线下门店');

INSERT INTO `orders` VALUES (1222,'RT20260109001222',31,'PAID','2026-01-09 13:23:04','2026-01-09 13:28:04',68.00,'小程序');

INSERT INTO `orders` VALUES (1223,'RT20260109001223',163,'PAID','2026-01-09 14:30:25','2026-01-09 15:30:25',59.00,'官网');

INSERT INTO `orders` VALUES (1224,'RT20260109001224',303,'PAID','2026-01-09 15:22:55','2026-01-09 16:30:55',196.00,'线下门店');

INSERT INTO `orders` VALUES (1225,'RT20260109001225',204,'PAID','2026-01-09 16:48:01','2026-01-09 17:20:01',170.90,'线下门店');

INSERT INTO `orders` VALUES (1226,'RT20260109001226',312,'PAID','2026-01-09 16:59:29','2026-01-09 17:07:29',68.00,'官网');

INSERT INTO `orders` VALUES (1227,'RT20260109001227',612,'PAID','2026-01-09 17:52:50','2026-01-09 18:18:50',159.00,'官网');

INSERT INTO `orders` VALUES (1228,'RT20260109001228',143,'PAID','2026-01-09 18:30:00','2026-01-09 19:42:00',208.90,'线下门店');

INSERT INTO `orders` VALUES (1229,'RT20260109001229',501,'PAID','2026-01-09 19:34:52','2026-01-09 20:26:52',70.26,'小程序');

INSERT INTO `orders` VALUES (1230,'RT20260110001230',521,'PAID','2026-01-10 12:11:28','2026-01-10 12:47:28',39.90,'小程序');

INSERT INTO `orders` VALUES (1231,'RT20260110001231',103,'PAID','2026-01-10 12:56:33','2026-01-10 14:03:33',79.00,'官网');

INSERT INTO `orders` VALUES (1232,'RT20260110001232',167,'PAID','2026-01-10 17:42:17','2026-01-10 18:48:17',24.90,'官网');

INSERT INTO `orders` VALUES (1233,'RT20260110001233',365,'PAID','2026-01-10 20:47:50','2026-01-10 21:20:50',175.76,'小程序');

INSERT INTO `orders` VALUES (1234,'RT20260110001234',461,'PAID','2026-01-10 21:22:50','2026-01-10 22:28:50',59.00,'小程序');

INSERT INTO `orders` VALUES (1235,'RT20260110001235',380,'PAID','2026-01-10 21:58:12','2026-01-10 22:32:12',68.00,'官网');

INSERT INTO `orders` VALUES (1236,'RT20260111001236',86,'PAID','2026-01-11 13:16:44','2026-01-11 13:20:44',159.00,'线下门店');

INSERT INTO `orders` VALUES (1237,'RT20260111001237',555,'PAID','2026-01-11 14:42:39','2026-01-11 15:23:39',1708.10,'官网');

INSERT INTO `orders` VALUES (1238,'RT20260111001238',2,'PAID','2026-01-11 16:43:32','2026-01-11 17:20:32',158.00,'线下门店');

INSERT INTO `orders` VALUES (1239,'RT20260111001239',429,'PAID','2026-01-11 17:40:47','2026-01-11 18:33:47',68.00,'线下门店');

INSERT INTO `orders` VALUES (1240,'RT20260111001240',248,'PAID','2026-01-11 18:21:09','2026-01-11 19:26:09',190.00,'小程序');

INSERT INTO `orders` VALUES (1241,'RT20260111001241',598,'CANCELLED','2026-01-11 20:29:24',NULL,37.91,'线下门店');

INSERT INTO `orders` VALUES (1242,'RT20260112001242',341,'PAID','2026-01-12 10:12:00','2026-01-12 10:41:00',334.05,'小程序');

INSERT INTO `orders` VALUES (1243,'RT20260112001243',133,'PAID','2026-01-12 13:54:21','2026-01-12 14:48:21',39.00,'小程序');

INSERT INTO `orders` VALUES (1244,'RT20260112001244',10,'PAID','2026-01-12 15:13:13','2026-01-12 15:41:13',39.00,'线下门店');

INSERT INTO `orders` VALUES (1245,'RT20260112001245',296,'PAID','2026-01-12 15:15:34','2026-01-12 16:28:34',79.00,'线下门店');

INSERT INTO `orders` VALUES (1246,'RT20260112001246',9,'PAID','2026-01-12 20:05:06','2026-01-12 20:46:06',31.26,'线下门店');

INSERT INTO `orders` VALUES (1247,'RT20260113001247',256,'PAID','2026-01-13 11:30:47','2026-01-13 12:34:47',399.00,'小程序');

INSERT INTO `orders` VALUES (1248,'RT20260113001248',117,'PAID','2026-01-13 13:08:16','2026-01-13 13:39:16',24.90,'官网');

INSERT INTO `orders` VALUES (1249,'RT20260113001249',158,'PAID','2026-01-13 16:47:02','2026-01-13 18:02:02',24.90,'线下门店');

INSERT INTO `orders` VALUES (1250,'RT20260113001250',509,'PAID','2026-01-13 18:46:46','2026-01-13 19:36:46',103.80,'小程序');

INSERT INTO `orders` VALUES (1251,'RT20260113001251',163,'PAID','2026-01-13 19:18:44','2026-01-13 20:14:44',148.00,'小程序');

INSERT INTO `orders` VALUES (1252,'RT20260113001252',7,'PAID','2026-01-13 20:38:01','2026-01-13 20:40:01',24.90,'小程序');

INSERT INTO `orders` VALUES (1253,'RT20260113001253',386,'PAID','2026-01-13 21:46:24','2026-01-13 22:16:24',218.50,'线下门店');

INSERT INTO `orders` VALUES (1254,'RT20260114001254',39,'PAID','2026-01-14 12:14:21','2026-01-14 13:26:21',449.90,'线下门店');

INSERT INTO `orders` VALUES (1255,'RT20260114001255',627,'PAID','2026-01-14 12:55:27','2026-01-14 13:54:27',177.00,'小程序');

INSERT INTO `orders` VALUES (1256,'RT20260114001256',256,'PAID','2026-01-14 15:57:45','2026-01-14 17:06:45',39.90,'企业采购');

INSERT INTO `orders` VALUES (1257,'RT20260114001257',45,'PAID','2026-01-14 19:25:14','2026-01-14 19:27:14',68.00,'官网');

INSERT INTO `orders` VALUES (1258,'RT20260114001258',245,'PAID','2026-01-14 19:28:53','2026-01-14 20:36:53',24.90,'线下门店');

INSERT INTO `orders` VALUES (1259,'RT20260115001259',161,'PAID','2026-01-15 15:18:11','2026-01-15 15:35:11',495.00,'线下门店');

INSERT INTO `orders` VALUES (1260,'RT20260115001260',111,'PAID','2026-01-15 17:27:03','2026-01-15 18:36:03',230.66,'小程序');

INSERT INTO `orders` VALUES (1261,'RT20260115001261',414,'PAID','2026-01-15 20:06:14','2026-01-15 20:18:14',49.80,'官网');

INSERT INTO `orders` VALUES (1262,'RT20260116001262',376,'PAID','2026-01-16 12:38:04','2026-01-16 13:39:04',79.00,'小程序');

INSERT INTO `orders` VALUES (1263,'RT20260116001263',160,'PAID','2026-01-16 14:17:16','2026-01-16 14:30:16',79.00,'线下门店');

INSERT INTO `orders` VALUES (1264,'RT20260116001264',44,'PAID','2026-01-16 14:29:27','2026-01-16 14:34:27',68.00,'小程序');

INSERT INTO `orders` VALUES (1265,'RT20260116001265',93,'PAID','2026-01-16 15:43:44','2026-01-16 16:15:44',143.60,'线下门店');

INSERT INTO `orders` VALUES (1266,'RT20260116001266',52,'PAID','2026-01-16 16:46:32','2026-01-16 17:26:32',191.15,'官网');

INSERT INTO `orders` VALUES (1267,'RT20260116001267',457,'REFUNDED','2026-01-16 17:09:00','2026-01-16 17:30:00',39.00,'小程序');

INSERT INTO `orders` VALUES (1268,'RT20260116001268',205,'PAID','2026-01-16 17:43:20','2026-01-16 18:44:20',598.00,'小程序');

INSERT INTO `orders` VALUES (1269,'RT20260116001269',127,'PAID','2026-01-16 17:45:16','2026-01-16 18:48:16',413.05,'小程序');

INSERT INTO `orders` VALUES (1270,'RT20260116001270',26,'PAID','2026-01-16 18:04:31','2026-01-16 18:05:31',177.00,'小程序');

INSERT INTO `orders` VALUES (1271,'RT20260116001271',51,'PAID','2026-01-16 18:18:26','2026-01-16 18:53:26',32.90,'线下门店');

INSERT INTO `orders` VALUES (1272,'RT20260116001272',553,'PAID','2026-01-16 18:38:18','2026-01-16 18:57:18',64.60,'官网');

INSERT INTO `orders` VALUES (1273,'RT20260116001273',392,'PAID','2026-01-16 20:50:54','2026-01-16 21:45:54',68.00,'小程序');

INSERT INTO `orders` VALUES (1274,'RT20260117001274',235,'PAID','2026-01-17 12:37:37','2026-01-17 13:39:37',93.90,'官网');

INSERT INTO `orders` VALUES (1275,'RT20260117001275',49,'PAID','2026-01-17 13:07:22','2026-01-17 14:22:22',39.90,'线下门店');

INSERT INTO `orders` VALUES (1276,'RT20260117001276',615,'PAID','2026-01-17 13:27:36','2026-01-17 13:57:36',159.00,'官网');

INSERT INTO `orders` VALUES (1277,'RT20260117001277',69,'PAID','2026-01-17 15:59:39','2026-01-17 17:13:39',74.10,'官网');

INSERT INTO `orders` VALUES (1278,'RT20260117001278',145,'PAID','2026-01-17 16:09:42','2026-01-17 17:14:42',68.00,'官网');

INSERT INTO `orders` VALUES (1279,'RT20260117001279',376,'PAID','2026-01-17 19:58:47','2026-01-17 20:49:47',122.55,'官网');

INSERT INTO `orders` VALUES (1280,'RT20260118001280',218,'PAID','2026-01-18 15:56:08','2026-01-18 16:44:08',142.90,'线下门店');

INSERT INTO `orders` VALUES (1281,'RT20260118001281',574,'PAID','2026-01-18 18:32:18','2026-01-18 19:07:18',196.05,'小程序');

INSERT INTO `orders` VALUES (1282,'RT20260118001282',118,'PAID','2026-01-18 19:11:42','2026-01-18 19:34:42',152.10,'小程序');

INSERT INTO `orders` VALUES (1283,'RT20260119001283',229,'PAID','2026-01-19 12:42:23','2026-01-19 13:23:23',75.05,'小程序');

INSERT INTO `orders` VALUES (1284,'RT20260119001284',551,'PAID','2026-01-19 13:06:28','2026-01-19 13:21:28',177.70,'线下门店');

INSERT INTO `orders` VALUES (1285,'RT20260119001285',67,'PAID','2026-01-19 14:44:20','2026-01-19 14:54:20',136.00,'官网');

INSERT INTO `orders` VALUES (1286,'RT20260119001286',370,'CANCELLED','2026-01-19 16:50:24',NULL,69.95,'线下门店');

INSERT INTO `orders` VALUES (1287,'RT20260119001287',585,'PAID','2026-01-19 17:15:06','2026-01-19 17:41:06',311.20,'线下门店');

INSERT INTO `orders` VALUES (1288,'RT20260119001288',293,'PAID','2026-01-19 21:14:24','2026-01-19 21:56:24',24.90,'线下门店');

INSERT INTO `orders` VALUES (1289,'RT20260120001289',504,'PAID','2026-01-20 09:28:00','2026-01-20 09:43:00',37.91,'小程序');

INSERT INTO `orders` VALUES (1290,'RT20260120001290',99,'PAID','2026-01-20 10:23:10','2026-01-20 11:17:10',78.90,'线下门店');

INSERT INTO `orders` VALUES (1291,'RT20260120001291',124,'PAID','2026-01-20 17:41:11','2026-01-20 18:30:11',68.00,'官网');

INSERT INTO `orders` VALUES (1292,'RT20260120001292',99,'PAID','2026-01-20 17:42:38','2026-01-20 17:55:38',59.00,'小程序');

INSERT INTO `orders` VALUES (1293,'RT20260120001293',296,'PAID','2026-01-20 18:44:43','2026-01-20 19:40:43',68.00,'官网');

INSERT INTO `orders` VALUES (1294,'RT20260122001294',265,'PAID','2026-01-22 11:26:16','2026-01-22 11:31:16',32.90,'官网');

INSERT INTO `orders` VALUES (1295,'RT20260122001295',530,'PAID','2026-01-22 16:27:49','2026-01-22 16:37:49',29.61,'官网');

INSERT INTO `orders` VALUES (1296,'RT20260122001296',348,'PAID','2026-01-22 19:00:24','2026-01-22 19:16:24',39.90,'小程序');

INSERT INTO `orders` VALUES (1297,'RT20260123001297',264,'PAID','2026-01-23 18:53:48','2026-01-23 19:16:48',79.00,'线下门店');

INSERT INTO `orders` VALUES (1298,'RT20260123001298',71,'CANCELLED','2026-01-23 19:07:57',NULL,59.00,'小程序');

INSERT INTO `orders` VALUES (1299,'RT20260123001299',6,'PAID','2026-01-23 21:21:35','2026-01-23 21:38:35',98.70,'官网');

INSERT INTO `orders` VALUES (1300,'RT20260123001300',354,'PAID','2026-01-23 21:44:36','2026-01-23 21:56:36',191.90,'小程序');

INSERT INTO `orders` VALUES (1301,'RT20260123001301',213,'PAID','2026-01-23 21:52:55','2026-01-23 23:03:55',407.00,'线下门店');

INSERT INTO `orders` VALUES (1302,'RT20260124001302',165,'PAID','2026-01-24 09:48:52','2026-01-24 10:18:52',64.60,'小程序');

INSERT INTO `orders` VALUES (1303,'RT20260124001303',598,'PAID','2026-01-24 11:16:21','2026-01-24 11:49:21',169.00,'小程序');

INSERT INTO `orders` VALUES (1304,'RT20260124001304',43,'PAID','2026-01-24 15:10:51','2026-01-24 15:39:51',183.80,'小程序');

INSERT INTO `orders` VALUES (1305,'RT20260124001305',213,'PAID','2026-01-24 17:17:14','2026-01-24 17:29:14',39.00,'线下门店');

INSERT INTO `orders` VALUES (1306,'RT20260124001306',106,'PAID','2026-01-24 18:04:02','2026-01-24 18:37:02',138.00,'线下门店');

INSERT INTO `orders` VALUES (1307,'RT20260124001307',36,'PAID','2026-01-24 18:45:02','2026-01-24 19:55:02',159.00,'线下门店');

INSERT INTO `orders` VALUES (1308,'RT20260125001308',253,'PAID','2026-01-25 10:29:12','2026-01-25 11:39:12',39.00,'小程序');

INSERT INTO `orders` VALUES (1309,'RT20260125001309',166,'PAID','2026-01-25 12:05:20','2026-01-25 12:54:20',136.00,'小程序');

INSERT INTO `orders` VALUES (1310,'RT20260125001310',41,'PAID','2026-01-25 12:32:03','2026-01-25 13:12:03',194.91,'官网');

INSERT INTO `orders` VALUES (1311,'RT20260125001311',101,'PAID','2026-01-25 12:39:57','2026-01-25 12:52:57',32.90,'线下门店');

INSERT INTO `orders` VALUES (1312,'RT20260125001312',480,'PAID','2026-01-25 15:22:34','2026-01-25 15:23:34',237.00,'线下门店');

INSERT INTO `orders` VALUES (1313,'RT20260125001313',245,'CANCELLED','2026-01-25 16:12:03',NULL,78.00,'小程序');

INSERT INTO `orders` VALUES (1314,'RT20260125001314',565,'CANCELLED','2026-01-25 16:39:12',NULL,358.00,'小程序');

INSERT INTO `orders` VALUES (1315,'RT20260125001315',227,'REFUNDED','2026-01-25 17:49:48','2026-01-25 18:00:48',4338.90,'官网');

INSERT INTO `orders` VALUES (1316,'RT20260125001316',226,'PAID','2026-01-25 20:32:34','2026-01-25 20:59:34',88.80,'线下门店');

INSERT INTO `orders` VALUES (1317,'RT20260126001317',351,'PAID','2026-01-26 10:59:42','2026-01-26 11:25:42',269.26,'小程序');

INSERT INTO `orders` VALUES (1318,'RT20260126001318',178,'CANCELLED','2026-01-26 19:03:15',NULL,435.00,'线下门店');

INSERT INTO `orders` VALUES (1319,'RT20260126001319',516,'PAID','2026-01-26 19:35:54','2026-01-26 19:42:54',62.66,'小程序');

INSERT INTO `orders` VALUES (1320,'RT20260127001320',83,'PAID','2026-01-27 15:54:11','2026-01-27 16:06:11',78.00,'线下门店');

INSERT INTO `orders` VALUES (1321,'RT20260127001321',409,'PAID','2026-01-27 16:40:05','2026-01-27 16:43:05',59.00,'小程序');

INSERT INTO `orders` VALUES (1322,'RT20260127001322',217,'PAID','2026-01-27 17:54:45','2026-01-27 18:11:45',365.20,'线下门店');

INSERT INTO `orders` VALUES (1323,'RT20260127001323',275,'PAID','2026-01-27 18:20:30','2026-01-27 19:27:30',90.26,'小程序');

INSERT INTO `orders` VALUES (1324,'RT20260127001324',422,'PAID','2026-01-27 18:21:30','2026-01-27 18:52:30',37.91,'官网');

INSERT INTO `orders` VALUES (1325,'RT20260128001325',357,'PAID','2026-01-28 08:02:06','2026-01-28 08:19:06',79.80,'官网');

INSERT INTO `orders` VALUES (1326,'RT20260128001326',323,'PAID','2026-01-28 10:35:17','2026-01-28 11:04:17',78.00,'线下门店');

INSERT INTO `orders` VALUES (1327,'RT20260128001327',130,'PAID','2026-01-28 11:19:50','2026-01-28 11:32:50',32.90,'小程序');

INSERT INTO `orders` VALUES (1328,'RT20260128001328',85,'PAID','2026-01-28 11:36:04','2026-01-28 12:20:04',59.00,'线下门店');

INSERT INTO `orders` VALUES (1329,'RT20260128001329',278,'PAID','2026-01-28 11:57:52','2026-01-28 12:11:52',23.66,'小程序');

INSERT INTO `orders` VALUES (1330,'RT20260128001330',231,'PAID','2026-01-28 12:40:28','2026-01-28 13:44:28',69.00,'官网');

INSERT INTO `orders` VALUES (1331,'RT20260128001331',31,'PAID','2026-01-28 15:53:57','2026-01-28 17:06:57',39.00,'小程序');

INSERT INTO `orders` VALUES (1332,'RT20260128001332',13,'PAID','2026-01-28 17:15:35','2026-01-28 17:53:35',279.55,'线下门店');

INSERT INTO `orders` VALUES (1333,'RT20260128001333',493,'PAID','2026-01-28 17:50:25','2026-01-28 18:30:25',79.00,'官网');

INSERT INTO `orders` VALUES (1334,'RT20260128001334',331,'PAID','2026-01-28 20:22:40','2026-01-28 20:24:40',32.90,'线下门店');

INSERT INTO `orders` VALUES (1335,'RT20260129001335',399,'CANCELLED','2026-01-29 11:20:44',NULL,147.45,'线下门店');

INSERT INTO `orders` VALUES (1336,'RT20260129001336',311,'PAID','2026-01-29 15:56:05','2026-01-29 16:40:05',169.00,'小程序');

INSERT INTO `orders` VALUES (1337,'RT20260129001337',182,'PAID','2026-01-29 16:56:48','2026-01-29 17:24:48',150.10,'小程序');

INSERT INTO `orders` VALUES (1338,'RT20260129001338',175,'CANCELLED','2026-01-29 18:51:52',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (1339,'RT20260130001339',409,'PAID','2026-01-30 09:06:22','2026-01-30 09:37:22',68.00,'官网');

INSERT INTO `orders` VALUES (1340,'RT20260130001340',349,'PAID','2026-01-30 12:21:00','2026-01-30 13:34:00',69.00,'线下门店');

INSERT INTO `orders` VALUES (1341,'RT20260130001341',446,'PAID','2026-01-30 17:34:47','2026-01-30 18:02:47',62.51,'小程序');

INSERT INTO `orders` VALUES (1342,'RT20260131001342',331,'PAID','2026-01-31 10:40:49','2026-01-31 11:43:49',197.00,'线下门店');

INSERT INTO `orders` VALUES (1343,'RT20260131001343',117,'CANCELLED','2026-01-31 11:28:55',NULL,256.35,'线下门店');

INSERT INTO `orders` VALUES (1344,'RT20260131001344',236,'PAID','2026-01-31 20:01:45','2026-01-31 21:00:45',4598.00,'企业采购');

INSERT INTO `orders` VALUES (1345,'RT20260131001345',10,'PAID','2026-01-31 21:14:39','2026-01-31 22:02:39',39.90,'线下门店');

INSERT INTO `orders` VALUES (1346,'RT20260201001346',177,'PAID','2026-02-01 17:30:31','2026-02-01 17:40:31',121.60,'官网');

INSERT INTO `orders` VALUES (1347,'RT20260201001347',170,'PAID','2026-02-01 18:58:08','2026-02-01 20:02:08',75.05,'线下门店');

INSERT INTO `orders` VALUES (1348,'RT20260201001348',285,'PAID','2026-02-01 19:29:55','2026-02-01 20:07:55',153.90,'官网');

INSERT INTO `orders` VALUES (1349,'RT20260202001349',87,'CANCELLED','2026-02-02 13:01:55',NULL,157.51,'小程序');

INSERT INTO `orders` VALUES (1350,'RT20260202001350',363,'PAID','2026-02-02 13:24:13','2026-02-02 13:53:13',178.00,'线下门店');

INSERT INTO `orders` VALUES (1351,'RT20260202001351',26,'PAID','2026-02-02 16:42:36','2026-02-02 17:33:36',37.91,'小程序');

INSERT INTO `orders` VALUES (1352,'RT20260202001352',346,'CANCELLED','2026-02-02 20:51:01',NULL,118.00,'官网');

INSERT INTO `orders` VALUES (1353,'RT20260202001353',320,'PAID','2026-02-02 21:16:16','2026-02-02 21:45:16',59.00,'官网');

INSERT INTO `orders` VALUES (1354,'RT20260203001354',419,'PAID','2026-02-03 11:06:03','2026-02-03 11:30:03',68.00,'线下门店');

INSERT INTO `orders` VALUES (1355,'RT20260203001355',296,'PAID','2026-02-03 13:03:37','2026-02-03 14:03:37',199.00,'小程序');

INSERT INTO `orders` VALUES (1356,'RT20260203001356',34,'REFUNDED','2026-02-03 19:17:22','2026-02-03 20:24:22',37.91,'小程序');

INSERT INTO `orders` VALUES (1357,'RT20260203001357',533,'PAID','2026-02-03 19:21:27','2026-02-03 20:29:27',127.00,'线下门店');

INSERT INTO `orders` VALUES (1358,'RT20260203001358',51,'PAID','2026-02-03 20:55:16','2026-02-03 21:26:16',29.61,'线下门店');

INSERT INTO `orders` VALUES (1359,'RT20260203001359',438,'PAID','2026-02-03 22:57:40','2026-02-03 23:41:40',159.00,'小程序');

INSERT INTO `orders` VALUES (1360,'RT20260204001360',344,'PAID','2026-02-04 12:13:45','2026-02-04 12:38:45',37.05,'官网');

INSERT INTO `orders` VALUES (1361,'RT20260204001361',43,'PAID','2026-02-04 13:34:38','2026-02-04 14:24:38',201.90,'小程序');

INSERT INTO `orders` VALUES (1362,'RT20260204001362',500,'PAID','2026-02-04 15:53:36','2026-02-04 16:24:36',62.51,'小程序');

INSERT INTO `orders` VALUES (1363,'RT20260204001363',430,'PAID','2026-02-04 17:13:51','2026-02-04 18:03:51',129.00,'小程序');

INSERT INTO `orders` VALUES (1364,'RT20260204001364',296,'PAID','2026-02-04 18:20:43','2026-02-04 19:06:43',331.90,'官网');

INSERT INTO `orders` VALUES (1365,'RT20260204001365',324,'PAID','2026-02-04 20:11:50','2026-02-04 20:53:50',37.91,'小程序');

INSERT INTO `orders` VALUES (1366,'RT20260204001366',399,'PAID','2026-02-04 21:23:17','2026-02-04 22:37:17',68.61,'线下门店');

INSERT INTO `orders` VALUES (1367,'RT20260205001367',447,'PAID','2026-02-05 10:05:11','2026-02-05 10:41:11',76.95,'官网');

INSERT INTO `orders` VALUES (1368,'RT20260205001368',607,'PAID','2026-02-05 10:45:52','2026-02-05 11:48:52',39.00,'线下门店');

INSERT INTO `orders` VALUES (1369,'RT20260205001369',438,'PAID','2026-02-05 11:57:40','2026-02-05 12:30:40',222.90,'线下门店');

INSERT INTO `orders` VALUES (1370,'RT20260205001370',212,'PAID','2026-02-05 11:57:45','2026-02-05 12:43:45',89.00,'官网');

INSERT INTO `orders` VALUES (1371,'RT20260205001371',165,'PAID','2026-02-05 13:04:26','2026-02-05 14:02:26',24.90,'小程序');

INSERT INTO `orders` VALUES (1372,'RT20260205001372',97,'PAID','2026-02-05 17:59:19','2026-02-05 19:08:19',23.66,'官网');

INSERT INTO `orders` VALUES (1373,'RT20260205001373',315,'PAID','2026-02-05 18:49:38','2026-02-05 19:05:38',56.05,'线下门店');

INSERT INTO `orders` VALUES (1374,'RT20260205001374',367,'PAID','2026-02-05 19:08:57','2026-02-05 20:13:57',304.20,'官网');

INSERT INTO `orders` VALUES (1375,'RT20260205001375',373,'PAID','2026-02-05 19:19:09','2026-02-05 19:50:09',39.90,'小程序');

INSERT INTO `orders` VALUES (1376,'RT20260205001376',7,'PAID','2026-02-05 22:19:45','2026-02-05 22:54:45',243.70,'小程序');

INSERT INTO `orders` VALUES (1377,'RT20260206001377',464,'PAID','2026-02-06 09:08:50','2026-02-06 10:23:50',31.26,'小程序');

INSERT INTO `orders` VALUES (1378,'RT20260206001378',409,'PAID','2026-02-06 16:32:15','2026-02-06 17:09:15',59.00,'小程序');

INSERT INTO `orders` VALUES (1379,'RT20260206001379',358,'PAID','2026-02-06 16:52:18','2026-02-06 17:06:18',152.55,'线下门店');

INSERT INTO `orders` VALUES (1380,'RT20260206001380',566,'PAID','2026-02-06 18:10:37','2026-02-06 18:39:37',98.00,'官网');

INSERT INTO `orders` VALUES (1381,'RT20260206001381',338,'PAID','2026-02-06 18:58:19','2026-02-06 19:21:19',39.90,'企业采购');

INSERT INTO `orders` VALUES (1382,'RT20260206001382',518,'PAID','2026-02-06 19:38:10','2026-02-06 19:50:10',84.55,'官网');

INSERT INTO `orders` VALUES (1383,'RT20260207001383',236,'PAID','2026-02-07 12:17:09','2026-02-07 13:17:09',202.00,'官网');

INSERT INTO `orders` VALUES (1384,'RT20260207001384',243,'PAID','2026-02-07 18:26:51','2026-02-07 19:01:51',75.05,'线下门店');

INSERT INTO `orders` VALUES (1385,'RT20260208001385',108,'PAID','2026-02-08 09:53:19','2026-02-08 10:08:19',31.26,'官网');

INSERT INTO `orders` VALUES (1386,'RT20260208001386',265,'PAID','2026-02-08 10:55:37','2026-02-08 12:04:37',116.91,'小程序');

INSERT INTO `orders` VALUES (1387,'RT20260208001387',232,'PAID','2026-02-08 13:01:24','2026-02-08 14:08:24',696.00,'小程序');

INSERT INTO `orders` VALUES (1388,'RT20260208001388',384,'CANCELLED','2026-02-08 21:13:13',NULL,136.00,'小程序');

INSERT INTO `orders` VALUES (1389,'RT20260209001389',153,'PAID','2026-02-09 10:07:00','2026-02-09 11:08:00',108.00,'小程序');

INSERT INTO `orders` VALUES (1390,'RT20260209001390',122,'REFUNDED','2026-02-09 10:30:55','2026-02-09 10:45:55',31.26,'官网');

INSERT INTO `orders` VALUES (1391,'RT20260209001391',475,'PAID','2026-02-09 10:34:33','2026-02-09 11:44:33',39.00,'线下门店');

INSERT INTO `orders` VALUES (1392,'RT20260209001392',631,'PAID','2026-02-09 18:38:46','2026-02-09 18:52:46',159.00,'小程序');

INSERT INTO `orders` VALUES (1393,'RT20260209001393',363,'PAID','2026-02-09 19:53:25','2026-02-09 20:51:25',69.00,'官网');

INSERT INTO `orders` VALUES (1394,'RT20260210001394',41,'PAID','2026-02-10 17:01:16','2026-02-10 18:04:16',74.70,'官网');

INSERT INTO `orders` VALUES (1395,'RT20260210001395',277,'PAID','2026-02-10 18:05:37','2026-02-10 18:31:37',117.90,'线下门店');

INSERT INTO `orders` VALUES (1396,'RT20260210001396',343,'PAID','2026-02-10 18:16:10','2026-02-10 19:27:10',39.00,'官网');

INSERT INTO `orders` VALUES (1397,'RT20260210001397',188,'PAID','2026-02-10 19:57:30','2026-02-10 20:43:30',130.51,'线下门店');

INSERT INTO `orders` VALUES (1398,'RT20260210001398',200,'PAID','2026-02-10 20:34:36','2026-02-10 21:49:36',23.66,'线下门店');

INSERT INTO `orders` VALUES (1399,'RT20260210001399',64,'PAID','2026-02-10 20:52:51','2026-02-10 21:27:51',160.55,'线下门店');

INSERT INTO `orders` VALUES (1400,'RT20260211001400',199,'PAID','2026-02-11 09:35:14','2026-02-11 09:58:14',103.46,'小程序');

INSERT INTO `orders` VALUES (1401,'RT20260211001401',334,'PAID','2026-02-11 10:20:20','2026-02-11 11:07:20',31.26,'官网');

INSERT INTO `orders` VALUES (1402,'RT20260211001402',173,'PAID','2026-02-11 11:27:10','2026-02-11 11:38:10',1887.00,'小程序');

INSERT INTO `orders` VALUES (1403,'RT20260211001403',172,'PAID','2026-02-11 18:32:53','2026-02-11 18:46:53',118.80,'小程序');

INSERT INTO `orders` VALUES (1404,'RT20260211001404',318,'PAID','2026-02-11 18:48:53','2026-02-11 19:18:53',95.95,'小程序');

INSERT INTO `orders` VALUES (1405,'RT20260211001405',148,'CANCELLED','2026-02-11 19:25:46',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (1406,'RT20260212001406',143,'PAID','2026-02-12 16:22:18','2026-02-12 16:40:18',39.00,'小程序');

INSERT INTO `orders` VALUES (1407,'RT20260212001407',152,'PAID','2026-02-12 18:52:05','2026-02-12 19:37:05',39.00,'线下门店');

INSERT INTO `orders` VALUES (1408,'RT20260212001408',152,'PAID','2026-02-12 22:46:57','2026-02-12 23:21:57',151.80,'线下门店');

INSERT INTO `orders` VALUES (1409,'RT20260213001409',329,'PAID','2026-02-13 09:26:14','2026-02-13 10:25:14',798.00,'小程序');

INSERT INTO `orders` VALUES (1410,'RT20260213001410',41,'PAID','2026-02-13 12:10:10','2026-02-13 12:30:10',1089.66,'小程序');

INSERT INTO `orders` VALUES (1411,'RT20260213001411',391,'PAID','2026-02-13 16:35:40','2026-02-13 17:14:40',39.90,'小程序');

INSERT INTO `orders` VALUES (1412,'RT20260213001412',167,'PAID','2026-02-13 18:58:18','2026-02-13 19:08:18',299.00,'小程序');

INSERT INTO `orders` VALUES (1413,'RT20260213001413',44,'PAID','2026-02-13 19:38:23','2026-02-13 20:35:23',118.00,'企业采购');

INSERT INTO `orders` VALUES (1414,'RT20260214001414',118,'PAID','2026-02-14 09:13:02','2026-02-14 09:56:02',68.00,'小程序');

INSERT INTO `orders` VALUES (1415,'RT20260214001415',630,'PAID','2026-02-14 16:41:29','2026-02-14 16:57:29',169.00,'线下门店');

INSERT INTO `orders` VALUES (1416,'RT20260214001416',574,'PAID','2026-02-14 19:26:21','2026-02-14 20:23:21',378.10,'小程序');

INSERT INTO `orders` VALUES (1417,'RT20260215001417',192,'PAID','2026-02-15 16:27:19','2026-02-15 17:28:19',208.90,'官网');

INSERT INTO `orders` VALUES (1418,'RT20260215001418',280,'PAID','2026-02-15 18:08:20','2026-02-15 19:08:20',39.00,'小程序');

INSERT INTO `orders` VALUES (1419,'RT20260215001419',346,'PAID','2026-02-15 18:09:03','2026-02-15 19:15:03',23.66,'小程序');

INSERT INTO `orders` VALUES (1420,'RT20260215001420',504,'PAID','2026-02-15 19:19:34','2026-02-15 19:56:34',32.90,'官网');

INSERT INTO `orders` VALUES (1421,'RT20260216001421',472,'PAID','2026-02-16 12:23:19','2026-02-16 13:17:19',65.80,'小程序');

INSERT INTO `orders` VALUES (1422,'RT20260216001422',446,'PAID','2026-02-16 16:20:24','2026-02-16 17:11:24',32.90,'小程序');

INSERT INTO `orders` VALUES (1423,'RT20260216001423',126,'PAID','2026-02-16 17:13:27','2026-02-16 18:00:27',399.00,'小程序');

INSERT INTO `orders` VALUES (1424,'RT20260216001424',437,'PAID','2026-02-16 21:32:37','2026-02-16 22:04:37',68.00,'线下门店');

INSERT INTO `orders` VALUES (1425,'RT20260217001425',594,'PAID','2026-02-17 18:22:59','2026-02-17 19:17:59',168.90,'官网');

INSERT INTO `orders` VALUES (1426,'RT20260217001426',384,'PAID','2026-02-17 18:51:51','2026-02-17 19:12:51',169.00,'线下门店');

INSERT INTO `orders` VALUES (1427,'RT20260217001427',586,'REFUNDED','2026-02-17 19:04:54','2026-02-17 20:12:54',182.90,'官网');

INSERT INTO `orders` VALUES (1428,'RT20260217001428',314,'PAID','2026-02-17 19:36:02','2026-02-17 20:24:02',78.00,'官网');

INSERT INTO `orders` VALUES (1429,'RT20260217001429',169,'CANCELLED','2026-02-17 20:04:26',NULL,359.10,'小程序');

INSERT INTO `orders` VALUES (1430,'RT20260218001430',22,'PAID','2026-02-18 11:01:45','2026-02-18 12:01:45',68.00,'线下门店');

INSERT INTO `orders` VALUES (1431,'RT20260218001431',243,'PAID','2026-02-18 14:00:59','2026-02-18 14:57:59',37.05,'小程序');

INSERT INTO `orders` VALUES (1432,'RT20260218001432',78,'PAID','2026-02-18 15:19:31','2026-02-18 16:17:31',147.80,'线下门店');

INSERT INTO `orders` VALUES (1433,'RT20260218001433',216,'PAID','2026-02-18 15:37:56','2026-02-18 16:21:56',39.90,'小程序');

INSERT INTO `orders` VALUES (1434,'RT20260218001434',20,'PAID','2026-02-18 17:34:04','2026-02-18 17:51:04',353.55,'官网');

INSERT INTO `orders` VALUES (1435,'RT20260218001435',415,'PAID','2026-02-18 19:20:09','2026-02-18 20:10:09',64.80,'小程序');

INSERT INTO `orders` VALUES (1436,'RT20260219001436',102,'PAID','2026-02-19 10:02:36','2026-02-19 11:02:36',103.46,'企业采购');

INSERT INTO `orders` VALUES (1437,'RT20260219001437',41,'PAID','2026-02-19 12:59:17','2026-02-19 13:54:17',141.51,'小程序');

INSERT INTO `orders` VALUES (1438,'RT20260219001438',149,'PAID','2026-02-19 15:11:39','2026-02-19 15:38:39',23.66,'小程序');

INSERT INTO `orders` VALUES (1439,'RT20260219001439',277,'PAID','2026-02-19 16:46:20','2026-02-19 16:47:20',68.00,'线下门店');

INSERT INTO `orders` VALUES (1440,'RT20260219001440',455,'PAID','2026-02-19 17:01:29','2026-02-19 17:47:29',150.10,'线下门店');

INSERT INTO `orders` VALUES (1441,'RT20260219001441',501,'PAID','2026-02-19 17:02:42','2026-02-19 17:52:42',59.00,'线下门店');

INSERT INTO `orders` VALUES (1442,'RT20260219001442',28,'PAID','2026-02-19 18:21:01','2026-02-19 19:01:01',35.91,'小程序');

INSERT INTO `orders` VALUES (1443,'RT20260219001443',507,'PAID','2026-02-19 20:02:30','2026-02-19 20:03:30',24.90,'企业采购');

INSERT INTO `orders` VALUES (1444,'RT20260219001444',395,'PAID','2026-02-19 20:17:17','2026-02-19 20:21:17',39.90,'企业采购');

INSERT INTO `orders` VALUES (1445,'RT20260220001445',542,'PAID','2026-02-20 10:37:26','2026-02-20 10:40:26',304.50,'线下门店');

INSERT INTO `orders` VALUES (1446,'RT20260220001446',23,'PAID','2026-02-20 11:11:29','2026-02-20 11:48:29',133.80,'线下门店');

INSERT INTO `orders` VALUES (1447,'RT20260220001447',511,'PAID','2026-02-20 12:14:46','2026-02-20 12:39:46',59.00,'小程序');

INSERT INTO `orders` VALUES (1448,'RT20260220001448',198,'CANCELLED','2026-02-20 13:07:24',NULL,299.00,'小程序');

INSERT INTO `orders` VALUES (1449,'RT20260220001449',428,'PAID','2026-02-20 16:49:22','2026-02-20 17:01:22',129.00,'企业采购');

INSERT INTO `orders` VALUES (1450,'RT20260220001450',213,'PAID','2026-02-20 16:50:42','2026-02-20 17:40:42',39.90,'线下门店');

INSERT INTO `orders` VALUES (1451,'RT20260220001451',135,'PAID','2026-02-20 17:17:07','2026-02-20 17:37:07',107.90,'小程序');

INSERT INTO `orders` VALUES (1452,'RT20260220001452',276,'PAID','2026-02-20 17:24:04','2026-02-20 18:18:04',107.86,'线下门店');

INSERT INTO `orders` VALUES (1453,'RT20260220001453',266,'PAID','2026-02-20 18:15:36','2026-02-20 18:46:36',199.00,'小程序');

INSERT INTO `orders` VALUES (1454,'RT20260220001454',619,'PAID','2026-02-20 19:37:49','2026-02-20 20:19:49',32.90,'小程序');

INSERT INTO `orders` VALUES (1455,'RT20260220001455',92,'PAID','2026-02-20 21:14:49','2026-02-20 22:19:49',99.15,'小程序');

INSERT INTO `orders` VALUES (1456,'RT20260221001456',339,'PAID','2026-02-21 12:03:44','2026-02-21 13:08:44',32.90,'小程序');

INSERT INTO `orders` VALUES (1457,'RT20260221001457',591,'PAID','2026-02-21 13:41:29','2026-02-21 14:51:29',229.20,'官网');

INSERT INTO `orders` VALUES (1458,'RT20260221001458',69,'PAID','2026-02-21 15:19:03','2026-02-21 15:24:03',32.90,'官网');

INSERT INTO `orders` VALUES (1459,'RT20260221001459',150,'REFUNDED','2026-02-21 15:58:11','2026-02-21 16:57:11',103.60,'线下门店');

INSERT INTO `orders` VALUES (1460,'RT20260221001460',490,'PAID','2026-02-21 17:23:07','2026-02-21 18:16:07',71.82,'小程序');

INSERT INTO `orders` VALUES (1461,'RT20260221001461',290,'PAID','2026-02-21 17:49:26','2026-02-21 19:04:26',39.90,'小程序');

INSERT INTO `orders` VALUES (1462,'RT20260221001462',135,'PAID','2026-02-21 20:21:04','2026-02-21 20:24:04',65.80,'线下门店');

INSERT INTO `orders` VALUES (1463,'RT20260221001463',211,'PAID','2026-02-21 20:32:23','2026-02-21 21:11:23',68.00,'小程序');

INSERT INTO `orders` VALUES (1464,'RT20260222001464',514,'PAID','2026-02-22 13:11:29','2026-02-22 13:38:29',32.90,'线下门店');

INSERT INTO `orders` VALUES (1465,'RT20260222001465',20,'PAID','2026-02-22 17:02:24','2026-02-22 18:03:24',32.90,'线下门店');

INSERT INTO `orders` VALUES (1466,'RT20260222001466',221,'PAID','2026-02-22 17:33:52','2026-02-22 18:06:52',227.00,'线下门店');

INSERT INTO `orders` VALUES (1467,'RT20260222001467',276,'PAID','2026-02-22 19:35:59','2026-02-22 20:49:59',23.66,'小程序');

INSERT INTO `orders` VALUES (1468,'RT20260223001468',529,'PAID','2026-02-23 11:35:01','2026-02-23 12:29:01',185.45,'小程序');

INSERT INTO `orders` VALUES (1469,'RT20260223001469',295,'PAID','2026-02-23 13:36:23','2026-02-23 14:16:23',798.00,'小程序');

INSERT INTO `orders` VALUES (1470,'RT20260223001470',155,'PAID','2026-02-23 13:36:34','2026-02-23 13:57:34',78.00,'线下门店');

INSERT INTO `orders` VALUES (1471,'RT20260223001471',492,'PAID','2026-02-23 20:38:33','2026-02-23 21:00:33',39.00,'小程序');

INSERT INTO `orders` VALUES (1472,'RT20260224001472',9,'CANCELLED','2026-02-24 10:08:38',NULL,101.81,'小程序');

INSERT INTO `orders` VALUES (1473,'RT20260224001473',202,'PAID','2026-02-24 11:13:16','2026-02-24 12:10:16',568.10,'小程序');

INSERT INTO `orders` VALUES (1474,'RT20260224001474',214,'PAID','2026-02-24 11:49:17','2026-02-24 11:57:17',32.90,'线下门店');

INSERT INTO `orders` VALUES (1475,'RT20260224001475',89,'CANCELLED','2026-02-24 14:53:46',NULL,79.80,'线下门店');

INSERT INTO `orders` VALUES (1476,'RT20260224001476',178,'PAID','2026-02-24 19:49:18','2026-02-24 20:36:18',118.00,'小程序');

INSERT INTO `orders` VALUES (1477,'RT20260225001477',362,'PAID','2026-02-25 12:30:36','2026-02-25 13:24:36',39.90,'官网');

INSERT INTO `orders` VALUES (1478,'RT20260225001478',407,'PAID','2026-02-25 12:50:37','2026-02-25 12:58:37',24.90,'小程序');

INSERT INTO `orders` VALUES (1479,'RT20260225001479',150,'PAID','2026-02-25 13:27:21','2026-02-25 14:00:21',79.80,'线下门店');

INSERT INTO `orders` VALUES (1480,'RT20260225001480',183,'PAID','2026-02-25 15:01:17','2026-02-25 15:04:17',76.05,'小程序');

INSERT INTO `orders` VALUES (1481,'RT20260225001481',143,'PAID','2026-02-25 16:07:18','2026-02-25 16:10:18',238.90,'官网');

INSERT INTO `orders` VALUES (1482,'RT20260225001482',523,'PAID','2026-02-25 16:21:59','2026-02-25 17:01:59',22.41,'线下门店');

INSERT INTO `orders` VALUES (1483,'RT20260225001483',387,'PAID','2026-02-25 17:06:20','2026-02-25 17:39:20',31.26,'小程序');

INSERT INTO `orders` VALUES (1484,'RT20260225001484',469,'PAID','2026-02-25 18:13:26','2026-02-25 18:48:26',151.70,'官网');

INSERT INTO `orders` VALUES (1485,'RT20260225001485',417,'PAID','2026-02-25 20:32:00','2026-02-25 21:23:00',360.10,'企业采购');

INSERT INTO `orders` VALUES (1486,'RT20260226001486',130,'PAID','2026-02-26 13:04:45','2026-02-26 13:24:45',463.60,'线下门店');

INSERT INTO `orders` VALUES (1487,'RT20260226001487',334,'PAID','2026-02-26 15:03:03','2026-02-26 15:29:03',37.05,'线下门店');

INSERT INTO `orders` VALUES (1488,'RT20260226001488',232,'PAID','2026-02-26 15:43:08','2026-02-26 16:24:08',122.55,'线下门店');

INSERT INTO `orders` VALUES (1489,'RT20260226001489',141,'PAID','2026-02-26 17:59:56','2026-02-26 18:50:56',75.05,'小程序');

INSERT INTO `orders` VALUES (1490,'RT20260226001490',117,'PAID','2026-02-26 21:19:46','2026-02-26 21:35:46',24.90,'线下门店');

INSERT INTO `orders` VALUES (1491,'RT20260227001491',65,'CANCELLED','2026-02-27 10:33:26',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1492,'RT20260227001492',26,'CANCELLED','2026-02-27 10:40:35',NULL,79.00,'小程序');

INSERT INTO `orders` VALUES (1493,'RT20260227001493',296,'PAID','2026-02-27 12:06:23','2026-02-27 13:11:23',39.00,'企业采购');

INSERT INTO `orders` VALUES (1494,'RT20260227001494',8,'PAID','2026-02-27 13:45:49','2026-02-27 14:39:49',321.01,'官网');

INSERT INTO `orders` VALUES (1495,'RT20260227001495',122,'PAID','2026-02-27 13:47:09','2026-02-27 14:55:09',129.00,'线下门店');

INSERT INTO `orders` VALUES (1496,'RT20260227001496',101,'PAID','2026-02-27 14:08:09','2026-02-27 15:07:09',158.00,'小程序');

INSERT INTO `orders` VALUES (1497,'RT20260227001497',538,'PAID','2026-02-27 15:29:54','2026-02-27 16:18:54',65.55,'线下门店');

INSERT INTO `orders` VALUES (1498,'RT20260227001498',474,'PAID','2026-02-27 16:54:58','2026-02-27 17:06:58',61.20,'小程序');

INSERT INTO `orders` VALUES (1499,'RT20260227001499',275,'PAID','2026-02-27 18:41:29','2026-02-27 19:06:29',136.00,'官网');

INSERT INTO `orders` VALUES (1500,'RT20260227001500',531,'PAID','2026-02-27 21:51:07','2026-02-27 22:54:07',1798.00,'小程序');

INSERT INTO `orders` VALUES (1501,'RT20260228001501',276,'CANCELLED','2026-02-28 11:57:33',NULL,98.70,'线下门店');

INSERT INTO `orders` VALUES (1502,'RT20260228001502',121,'PAID','2026-02-28 13:50:31','2026-02-28 14:45:31',249.10,'线下门店');

INSERT INTO `orders` VALUES (1503,'RT20260228001503',509,'PAID','2026-02-28 18:17:44','2026-02-28 19:26:44',169.00,'小程序');

INSERT INTO `orders` VALUES (1504,'RT20260228001504',138,'PAID','2026-02-28 19:20:24','2026-02-28 19:36:24',68.00,'小程序');

INSERT INTO `orders` VALUES (1505,'RT20260228001505',391,'PAID','2026-02-28 20:40:35','2026-02-28 20:53:35',98.45,'小程序');

INSERT INTO `orders` VALUES (1506,'RT20260301001506',74,'PAID','2026-03-01 08:36:44','2026-03-01 09:16:44',169.00,'小程序');

INSERT INTO `orders` VALUES (1507,'RT20260301001507',308,'PAID','2026-03-01 11:36:06','2026-03-01 12:07:06',59.00,'线下门店');

INSERT INTO `orders` VALUES (1508,'RT20260301001508',276,'PAID','2026-03-01 18:14:40','2026-03-01 19:14:40',75.05,'官网');

INSERT INTO `orders` VALUES (1509,'RT20260301001509',317,'PAID','2026-03-01 19:06:27','2026-03-01 19:30:27',200.45,'线下门店');

INSERT INTO `orders` VALUES (1510,'RT20260301001510',106,'PAID','2026-03-01 19:49:10','2026-03-01 20:12:10',1398.00,'官网');

INSERT INTO `orders` VALUES (1511,'RT20260301001511',411,'CANCELLED','2026-03-01 21:12:08',NULL,35.10,'线下门店');

INSERT INTO `orders` VALUES (1512,'RT20260302001512',13,'PAID','2026-03-02 08:15:14','2026-03-02 09:10:14',341.66,'小程序');

INSERT INTO `orders` VALUES (1513,'RT20260302001513',629,'PAID','2026-03-02 15:49:15','2026-03-02 17:03:15',32.90,'小程序');

INSERT INTO `orders` VALUES (1514,'RT20260302001514',460,'PAID','2026-03-02 16:31:19','2026-03-02 16:36:19',112.10,'线下门店');

INSERT INTO `orders` VALUES (1515,'RT20260303001515',316,'REFUNDED','2026-03-03 08:02:55','2026-03-03 08:28:55',37.91,'小程序');

INSERT INTO `orders` VALUES (1516,'RT20260303001516',221,'PAID','2026-03-03 09:46:02','2026-03-03 10:38:02',129.00,'线下门店');

INSERT INTO `orders` VALUES (1517,'RT20260303001517',265,'PAID','2026-03-03 10:56:36','2026-03-03 11:56:36',64.60,'线下门店');

INSERT INTO `orders` VALUES (1518,'RT20260303001518',40,'PAID','2026-03-03 15:38:33','2026-03-03 16:36:33',169.00,'官网');

INSERT INTO `orders` VALUES (1519,'RT20260303001519',139,'PAID','2026-03-03 16:06:39','2026-03-03 16:13:39',39.90,'小程序');

INSERT INTO `orders` VALUES (1520,'RT20260303001520',159,'REFUNDED','2026-03-03 17:14:18','2026-03-03 17:55:18',68.81,'企业采购');

INSERT INTO `orders` VALUES (1521,'RT20260303001521',156,'PAID','2026-03-03 20:30:15','2026-03-03 20:37:15',32.90,'小程序');

INSERT INTO `orders` VALUES (1522,'RT20260303001522',90,'PAID','2026-03-03 20:41:38','2026-03-03 21:04:38',258.00,'小程序');

INSERT INTO `orders` VALUES (1523,'RT20260304001523',498,'PAID','2026-03-04 09:08:18','2026-03-04 09:43:18',241.80,'小程序');

INSERT INTO `orders` VALUES (1524,'RT20260304001524',167,'PAID','2026-03-04 11:31:14','2026-03-04 12:09:14',190.05,'线下门店');

INSERT INTO `orders` VALUES (1525,'RT20260304001525',261,'CANCELLED','2026-03-04 12:33:27',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1526,'RT20260304001526',571,'PAID','2026-03-04 14:07:03','2026-03-04 15:22:03',79.00,'线下门店');

INSERT INTO `orders` VALUES (1527,'RT20260304001527',474,'PAID','2026-03-04 14:19:18','2026-03-04 14:56:18',24.90,'线下门店');

INSERT INTO `orders` VALUES (1528,'RT20260304001528',187,'PAID','2026-03-04 17:14:01','2026-03-04 17:49:01',32.90,'小程序');

INSERT INTO `orders` VALUES (1529,'RT20260304001529',490,'PAID','2026-03-04 18:34:09','2026-03-04 19:47:09',39.00,'小程序');

INSERT INTO `orders` VALUES (1530,'RT20260304001530',27,'PAID','2026-03-04 19:24:59','2026-03-04 20:14:59',56.05,'小程序');

INSERT INTO `orders` VALUES (1531,'RT20260304001531',404,'PAID','2026-03-04 20:56:03','2026-03-04 21:15:03',68.00,'小程序');

INSERT INTO `orders` VALUES (1532,'RT20260305001532',245,'PAID','2026-03-05 10:40:57','2026-03-05 11:09:57',160.55,'小程序');

INSERT INTO `orders` VALUES (1533,'RT20260305001533',149,'PAID','2026-03-05 15:58:39','2026-03-05 16:36:39',227.90,'官网');

INSERT INTO `orders` VALUES (1534,'RT20260305001534',26,'CANCELLED','2026-03-05 20:41:25',NULL,65.55,'小程序');

INSERT INTO `orders` VALUES (1535,'RT20260305001535',532,'PAID','2026-03-05 20:47:46','2026-03-05 20:59:46',135.05,'小程序');

INSERT INTO `orders` VALUES (1536,'RT20260305001536',193,'CANCELLED','2026-03-05 22:57:51',NULL,88.61,'小程序');

INSERT INTO `orders` VALUES (1537,'RT20260306001537',539,'PAID','2026-03-06 11:13:53','2026-03-06 11:46:53',59.00,'线下门店');

INSERT INTO `orders` VALUES (1538,'RT20260306001538',165,'PAID','2026-03-06 12:50:54','2026-03-06 13:55:54',39.90,'小程序');

INSERT INTO `orders` VALUES (1539,'RT20260306001539',276,'PAID','2026-03-06 13:21:19','2026-03-06 13:52:19',167.00,'线下门店');

INSERT INTO `orders` VALUES (1540,'RT20260306001540',93,'PAID','2026-03-06 13:27:35','2026-03-06 14:00:35',24.90,'线下门店');

INSERT INTO `orders` VALUES (1541,'RT20260306001541',39,'PAID','2026-03-06 14:04:23','2026-03-06 14:11:23',68.00,'线下门店');

INSERT INTO `orders` VALUES (1542,'RT20260306001542',314,'PAID','2026-03-06 15:08:51','2026-03-06 15:26:51',63.90,'线下门店');

INSERT INTO `orders` VALUES (1543,'RT20260306001543',50,'PAID','2026-03-06 17:21:19','2026-03-06 18:34:19',59.00,'小程序');

INSERT INTO `orders` VALUES (1544,'RT20260306001544',227,'PAID','2026-03-06 17:33:47','2026-03-06 18:26:47',114.81,'官网');

INSERT INTO `orders` VALUES (1545,'RT20260307001545',29,'PAID','2026-03-07 11:12:06','2026-03-07 12:02:06',169.00,'线下门店');

INSERT INTO `orders` VALUES (1546,'RT20260307001546',34,'PAID','2026-03-07 12:49:05','2026-03-07 13:14:05',997.00,'线下门店');

INSERT INTO `orders` VALUES (1547,'RT20260307001547',383,'PAID','2026-03-07 13:55:58','2026-03-07 14:50:58',423.90,'官网');

INSERT INTO `orders` VALUES (1548,'RT20260307001548',188,'PAID','2026-03-07 14:42:11','2026-03-07 15:18:11',35.91,'小程序');

INSERT INTO `orders` VALUES (1549,'RT20260307001549',380,'PAID','2026-03-07 15:41:21','2026-03-07 16:46:21',75.05,'线下门店');

INSERT INTO `orders` VALUES (1550,'RT20260307001550',288,'PAID','2026-03-07 17:33:44','2026-03-07 18:23:44',199.00,'小程序');

INSERT INTO `orders` VALUES (1551,'RT20260307001551',170,'PAID','2026-03-07 20:14:53','2026-03-07 20:17:53',39.00,'小程序');

INSERT INTO `orders` VALUES (1552,'RT20260307001552',161,'PAID','2026-03-07 20:41:02','2026-03-07 21:49:02',39.00,'企业采购');

INSERT INTO `orders` VALUES (1553,'RT20260308001553',259,'CANCELLED','2026-03-08 11:05:58',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (1554,'RT20260308001554',481,'PAID','2026-03-08 11:20:17','2026-03-08 12:00:17',68.00,'线下门店');

INSERT INTO `orders` VALUES (1555,'RT20260308001555',38,'PAID','2026-03-08 13:24:43','2026-03-08 14:17:43',39.90,'官网');

INSERT INTO `orders` VALUES (1556,'RT20260308001556',277,'PAID','2026-03-08 15:31:07','2026-03-08 16:38:07',128.00,'线下门店');

INSERT INTO `orders` VALUES (1557,'RT20260308001557',143,'PAID','2026-03-08 15:44:12','2026-03-08 16:02:12',37.91,'官网');

INSERT INTO `orders` VALUES (1558,'RT20260308001558',380,'PAID','2026-03-08 17:41:33','2026-03-08 18:38:33',63.90,'官网');

INSERT INTO `orders` VALUES (1559,'RT20260308001559',597,'PAID','2026-03-08 18:14:26','2026-03-08 19:08:26',318.00,'小程序');

INSERT INTO `orders` VALUES (1560,'RT20260309001560',60,'PAID','2026-03-09 09:12:28','2026-03-09 09:24:28',308.10,'线下门店');

INSERT INTO `orders` VALUES (1561,'RT20260309001561',84,'CANCELLED','2026-03-09 15:07:20',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (1562,'RT20260309001562',213,'PAID','2026-03-09 17:38:26','2026-03-09 18:28:26',68.00,'小程序');

INSERT INTO `orders` VALUES (1563,'RT20260309001563',377,'PAID','2026-03-09 18:15:52','2026-03-09 18:40:52',39.00,'小程序');

INSERT INTO `orders` VALUES (1564,'RT20260309001564',140,'PAID','2026-03-09 20:06:03','2026-03-09 21:21:03',159.00,'小程序');

INSERT INTO `orders` VALUES (1565,'RT20260309001565',482,'PAID','2026-03-09 20:55:09','2026-03-09 21:21:09',76.95,'官网');

INSERT INTO `orders` VALUES (1566,'RT20260310001566',404,'PAID','2026-03-10 12:31:09','2026-03-10 13:00:09',174.95,'小程序');

INSERT INTO `orders` VALUES (1567,'RT20260310001567',61,'CANCELLED','2026-03-10 17:50:03',NULL,79.00,'企业采购');

INSERT INTO `orders` VALUES (1568,'RT20260310001568',153,'PAID','2026-03-10 18:06:01','2026-03-10 18:37:01',126.91,'小程序');

INSERT INTO `orders` VALUES (1569,'RT20260310001569',24,'PAID','2026-03-10 18:53:02','2026-03-10 19:12:02',117.00,'小程序');

INSERT INTO `orders` VALUES (1570,'RT20260310001570',2,'PAID','2026-03-10 19:15:38','2026-03-10 19:45:38',68.00,'小程序');

INSERT INTO `orders` VALUES (1571,'RT20260310001571',238,'PAID','2026-03-10 19:58:40','2026-03-10 20:06:40',169.00,'线下门店');

INSERT INTO `orders` VALUES (1572,'RT20260311001572',235,'PAID','2026-03-11 09:16:19','2026-03-11 09:48:19',37.91,'小程序');

INSERT INTO `orders` VALUES (1573,'RT20260311001573',276,'CANCELLED','2026-03-11 21:33:33',NULL,299.00,'小程序');

INSERT INTO `orders` VALUES (1574,'RT20260312001574',288,'PAID','2026-03-12 08:52:51','2026-03-12 09:11:51',119.75,'企业采购');

INSERT INTO `orders` VALUES (1575,'RT20260312001575',39,'PAID','2026-03-12 10:53:44','2026-03-12 11:33:44',208.90,'小程序');

INSERT INTO `orders` VALUES (1576,'RT20260312001576',411,'PAID','2026-03-12 11:14:44','2026-03-12 11:38:44',39.90,'小程序');

INSERT INTO `orders` VALUES (1577,'RT20260312001577',605,'PAID','2026-03-12 14:00:35','2026-03-12 14:05:35',24.90,'线下门店');

INSERT INTO `orders` VALUES (1578,'RT20260312001578',134,'PAID','2026-03-12 16:39:03','2026-03-12 17:45:03',39.90,'线下门店');

INSERT INTO `orders` VALUES (1579,'RT20260312001579',340,'PAID','2026-03-12 17:50:31','2026-03-12 17:57:31',118.00,'线下门店');

INSERT INTO `orders` VALUES (1580,'RT20260312001580',80,'CANCELLED','2026-03-12 18:21:57',NULL,39.00,'线下门店');

INSERT INTO `orders` VALUES (1581,'RT20260312001581',135,'PAID','2026-03-12 19:05:30','2026-03-12 19:09:30',153.90,'小程序');

INSERT INTO `orders` VALUES (1582,'RT20260312001582',635,'PAID','2026-03-12 19:28:10','2026-03-12 20:32:10',111.00,'小程序');

INSERT INTO `orders` VALUES (1583,'RT20260313001583',99,'PAID','2026-03-13 08:41:56','2026-03-13 08:59:56',107.60,'官网');

INSERT INTO `orders` VALUES (1584,'RT20260313001584',543,'PAID','2026-03-13 11:01:06','2026-03-13 11:16:06',177.62,'线下门店');

INSERT INTO `orders` VALUES (1585,'RT20260313001585',275,'PAID','2026-03-13 11:08:52','2026-03-13 12:05:52',129.00,'小程序');

INSERT INTO `orders` VALUES (1586,'RT20260313001586',67,'PAID','2026-03-13 11:37:40','2026-03-13 11:48:40',169.00,'小程序');

INSERT INTO `orders` VALUES (1587,'RT20260313001587',351,'PAID','2026-03-13 16:59:10','2026-03-13 18:07:10',39.90,'小程序');

INSERT INTO `orders` VALUES (1588,'RT20260313001588',22,'PAID','2026-03-13 19:03:38','2026-03-13 19:43:38',79.00,'官网');

INSERT INTO `orders` VALUES (1589,'RT20260313001589',317,'PAID','2026-03-13 19:35:16','2026-03-13 20:13:16',477.00,'小程序');

INSERT INTO `orders` VALUES (1590,'RT20260313001590',15,'PAID','2026-03-13 19:36:41','2026-03-13 20:50:41',4123.05,'线下门店');

INSERT INTO `orders` VALUES (1591,'RT20260314001591',258,'PAID','2026-03-14 10:52:43','2026-03-14 11:04:43',281.55,'线下门店');

INSERT INTO `orders` VALUES (1592,'RT20260314001592',529,'PAID','2026-03-14 11:16:02','2026-03-14 12:27:02',61.20,'官网');

INSERT INTO `orders` VALUES (1593,'RT20260314001593',194,'REFUNDED','2026-03-14 19:26:49','2026-03-14 20:38:49',128.00,'小程序');

INSERT INTO `orders` VALUES (1594,'RT20260315001594',237,'PAID','2026-03-15 09:31:38','2026-03-15 09:54:38',189.10,'官网');

INSERT INTO `orders` VALUES (1595,'RT20260315001595',257,'PAID','2026-03-15 09:36:35','2026-03-15 10:36:35',39.00,'小程序');

INSERT INTO `orders` VALUES (1596,'RT20260315001596',103,'PAID','2026-03-15 10:37:52','2026-03-15 11:44:52',69.00,'线下门店');

INSERT INTO `orders` VALUES (1597,'RT20260315001597',603,'PAID','2026-03-15 12:07:33','2026-03-15 12:08:33',59.00,'小程序');

INSERT INTO `orders` VALUES (1598,'RT20260315001598',211,'CANCELLED','2026-03-15 16:15:36',NULL,854.05,'小程序');

INSERT INTO `orders` VALUES (1599,'RT20260315001599',302,'PAID','2026-03-15 17:19:10','2026-03-15 17:42:10',56.05,'小程序');

INSERT INTO `orders` VALUES (1600,'RT20260315001600',3,'PAID','2026-03-15 18:29:19','2026-03-15 19:00:19',159.00,'线下门店');

INSERT INTO `orders` VALUES (1601,'RT20260315001601',419,'PAID','2026-03-15 18:43:00','2026-03-15 19:17:00',98.90,'小程序');

INSERT INTO `orders` VALUES (1602,'RT20260315001602',252,'PAID','2026-03-15 19:30:35','2026-03-15 20:17:35',35.91,'小程序');

INSERT INTO `orders` VALUES (1603,'RT20260315001603',177,'PAID','2026-03-15 20:01:41','2026-03-15 20:14:41',39.00,'线下门店');

INSERT INTO `orders` VALUES (1604,'RT20260315001604',295,'PAID','2026-03-15 20:48:44','2026-03-15 21:11:44',35.10,'小程序');

INSERT INTO `orders` VALUES (1605,'RT20260316001605',421,'PAID','2026-03-16 11:58:47','2026-03-16 12:49:47',189.90,'小程序');

INSERT INTO `orders` VALUES (1606,'RT20260316001606',249,'PAID','2026-03-16 14:27:18','2026-03-16 14:31:18',332.05,'小程序');

INSERT INTO `orders` VALUES (1607,'RT20260316001607',261,'PAID','2026-03-16 18:38:57','2026-03-16 19:07:57',56.05,'企业采购');

INSERT INTO `orders` VALUES (1608,'RT20260316001608',41,'PAID','2026-03-16 19:07:10','2026-03-16 20:08:10',35.91,'小程序');

INSERT INTO `orders` VALUES (1609,'RT20260316001609',599,'PAID','2026-03-16 19:33:41','2026-03-16 20:07:41',59.00,'小程序');

INSERT INTO `orders` VALUES (1610,'RT20260317001610',83,'PAID','2026-03-17 13:55:59','2026-03-17 14:04:59',225.05,'小程序');

INSERT INTO `orders` VALUES (1611,'RT20260317001611',179,'PAID','2026-03-17 16:06:39','2026-03-17 16:12:39',37.91,'小程序');

INSERT INTO `orders` VALUES (1612,'RT20260317001612',470,'PAID','2026-03-17 16:06:49','2026-03-17 17:17:49',129.00,'小程序');

INSERT INTO `orders` VALUES (1613,'RT20260317001613',247,'PAID','2026-03-17 16:59:08','2026-03-17 17:17:08',169.00,'官网');

INSERT INTO `orders` VALUES (1614,'RT20260317001614',31,'PAID','2026-03-17 17:43:32','2026-03-17 17:49:32',59.00,'小程序');

INSERT INTO `orders` VALUES (1615,'RT20260317001615',516,'REFUNDED','2026-03-17 18:13:14','2026-03-17 18:51:14',107.00,'小程序');

INSERT INTO `orders` VALUES (1616,'RT20260317001616',69,'PAID','2026-03-17 19:14:13','2026-03-17 19:42:13',755.25,'小程序');

INSERT INTO `orders` VALUES (1617,'RT20260317001617',606,'CANCELLED','2026-03-17 20:02:14',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (1618,'RT20260317001618',203,'PAID','2026-03-17 21:57:52','2026-03-17 22:25:52',118.00,'官网');

INSERT INTO `orders` VALUES (1619,'RT20260318001619',41,'PAID','2026-03-18 09:58:09','2026-03-18 10:46:09',68.00,'小程序');

INSERT INTO `orders` VALUES (1620,'RT20260318001620',302,'PAID','2026-03-18 11:09:08','2026-03-18 11:13:08',39.90,'线下门店');

INSERT INTO `orders` VALUES (1621,'RT20260318001621',491,'PAID','2026-03-18 11:31:17','2026-03-18 12:31:17',39.00,'线下门店');

INSERT INTO `orders` VALUES (1622,'RT20260318001622',112,'PAID','2026-03-18 11:34:27','2026-03-18 11:37:27',277.00,'小程序');

INSERT INTO `orders` VALUES (1623,'RT20260318001623',391,'PAID','2026-03-18 11:47:08','2026-03-18 12:21:08',79.00,'线下门店');

INSERT INTO `orders` VALUES (1624,'RT20260318001624',110,'PAID','2026-03-18 12:46:43','2026-03-18 13:50:43',37.91,'小程序');

INSERT INTO `orders` VALUES (1625,'RT20260318001625',127,'PAID','2026-03-18 15:31:14','2026-03-18 16:06:14',169.00,'线下门店');

INSERT INTO `orders` VALUES (1626,'RT20260318001626',27,'REFUNDED','2026-03-18 16:38:31','2026-03-18 17:30:31',234.81,'线下门店');

INSERT INTO `orders` VALUES (1627,'RT20260318001627',246,'PAID','2026-03-18 16:42:13','2026-03-18 17:41:13',299.00,'小程序');

INSERT INTO `orders` VALUES (1628,'RT20260318001628',608,'PAID','2026-03-18 16:52:36','2026-03-18 17:01:36',105.05,'小程序');

INSERT INTO `orders` VALUES (1629,'RT20260318001629',329,'PAID','2026-03-18 19:36:58','2026-03-18 20:51:58',143.10,'线下门店');

INSERT INTO `orders` VALUES (1630,'RT20260319001630',142,'PAID','2026-03-19 09:09:54','2026-03-19 10:15:54',119.70,'小程序');

INSERT INTO `orders` VALUES (1631,'RT20260319001631',610,'PAID','2026-03-19 12:03:54','2026-03-19 12:04:54',31.26,'官网');

INSERT INTO `orders` VALUES (1632,'RT20260319001632',218,'PAID','2026-03-19 14:14:40','2026-03-19 14:47:40',102.00,'官网');

INSERT INTO `orders` VALUES (1633,'RT20260319001633',15,'REFUNDED','2026-03-19 15:12:44','2026-03-19 16:01:44',65.55,'官网');

INSERT INTO `orders` VALUES (1634,'RT20260319001634',70,'PAID','2026-03-19 19:10:33','2026-03-19 20:19:33',71.10,'官网');

INSERT INTO `orders` VALUES (1635,'RT20260320001635',206,'PAID','2026-03-20 11:32:37','2026-03-20 12:28:37',108.15,'小程序');

INSERT INTO `orders` VALUES (1636,'RT20260320001636',231,'PAID','2026-03-20 15:05:55','2026-03-20 15:37:55',32.90,'官网');

INSERT INTO `orders` VALUES (1637,'RT20260320001637',357,'PAID','2026-03-20 17:04:21','2026-03-20 17:07:21',258.00,'官网');

INSERT INTO `orders` VALUES (1638,'RT20260320001638',401,'PAID','2026-03-20 19:34:59','2026-03-20 20:05:59',37.91,'企业采购');

INSERT INTO `orders` VALUES (1639,'RT20260320001639',425,'PAID','2026-03-20 19:37:33','2026-03-20 20:10:33',73.01,'线下门店');

INSERT INTO `orders` VALUES (1640,'RT20260320001640',134,'PAID','2026-03-20 20:22:02','2026-03-20 21:21:02',39.90,'线下门店');

INSERT INTO `orders` VALUES (1641,'RT20260321001641',57,'PAID','2026-03-21 11:50:22','2026-03-21 12:29:22',39.90,'小程序');

INSERT INTO `orders` VALUES (1642,'RT20260321001642',187,'PAID','2026-03-21 14:04:47','2026-03-21 14:17:47',168.15,'小程序');

INSERT INTO `orders` VALUES (1643,'RT20260321001643',185,'PAID','2026-03-21 14:31:13','2026-03-21 15:07:13',39.90,'线下门店');

INSERT INTO `orders` VALUES (1644,'RT20260321001644',115,'PAID','2026-03-21 14:51:57','2026-03-21 15:09:57',310.20,'企业采购');

INSERT INTO `orders` VALUES (1645,'RT20260321001645',311,'PAID','2026-03-21 17:16:28','2026-03-21 18:07:28',32.90,'线下门店');

INSERT INTO `orders` VALUES (1646,'RT20260321001646',491,'PAID','2026-03-21 18:04:05','2026-03-21 18:58:05',75.00,'线下门店');

INSERT INTO `orders` VALUES (1647,'RT20260321001647',71,'PAID','2026-03-21 18:41:24','2026-03-21 19:40:24',61.20,'官网');

INSERT INTO `orders` VALUES (1648,'RT20260321001648',66,'PAID','2026-03-21 20:48:59','2026-03-21 20:59:59',39.00,'官网');

INSERT INTO `orders` VALUES (1649,'RT20260322001649',280,'PAID','2026-03-22 11:06:13','2026-03-22 11:19:13',89.00,'小程序');

INSERT INTO `orders` VALUES (1650,'RT20260322001650',3,'PAID','2026-03-22 12:01:56','2026-03-22 12:49:56',835.91,'线下门店');

INSERT INTO `orders` VALUES (1651,'RT20260322001651',32,'REFUNDED','2026-03-22 13:26:42','2026-03-22 14:13:42',84.55,'小程序');

INSERT INTO `orders` VALUES (1652,'RT20260322001652',136,'PAID','2026-03-22 15:43:28','2026-03-22 16:30:28',68.00,'线下门店');

INSERT INTO `orders` VALUES (1653,'RT20260322001653',228,'PAID','2026-03-22 15:52:50','2026-03-22 17:03:50',107.00,'小程序');

INSERT INTO `orders` VALUES (1654,'RT20260322001654',351,'PAID','2026-03-22 16:57:41','2026-03-22 17:30:41',168.90,'官网');

INSERT INTO `orders` VALUES (1655,'RT20260322001655',80,'PAID','2026-03-22 17:20:49','2026-03-22 17:21:49',194.45,'小程序');

INSERT INTO `orders` VALUES (1656,'RT20260322001656',99,'PAID','2026-03-22 17:49:54','2026-03-22 18:42:54',24.90,'线下门店');

INSERT INTO `orders` VALUES (1657,'RT20260322001657',589,'PAID','2026-03-22 18:58:31','2026-03-22 19:04:31',104.70,'线下门店');

INSERT INTO `orders` VALUES (1658,'RT20260322001658',122,'PAID','2026-03-22 19:13:52','2026-03-22 19:42:52',32.90,'官网');

INSERT INTO `orders` VALUES (1659,'RT20260322001659',382,'CANCELLED','2026-03-22 20:22:55',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (1660,'RT20260323001660',297,'PAID','2026-03-23 10:45:08','2026-03-23 11:31:08',39.90,'官网');

INSERT INTO `orders` VALUES (1661,'RT20260323001661',206,'PAID','2026-03-23 11:15:49','2026-03-23 12:21:49',338.00,'小程序');

INSERT INTO `orders` VALUES (1662,'RT20260323001662',58,'PAID','2026-03-23 11:49:27','2026-03-23 12:21:27',32.90,'线下门店');

INSERT INTO `orders` VALUES (1663,'RT20260323001663',139,'PAID','2026-03-23 13:19:31','2026-03-23 14:25:31',399.00,'企业采购');

INSERT INTO `orders` VALUES (1664,'RT20260323001664',39,'PAID','2026-03-23 13:43:47','2026-03-23 14:57:47',104.50,'小程序');

INSERT INTO `orders` VALUES (1665,'RT20260323001665',622,'PAID','2026-03-23 17:18:42','2026-03-23 18:07:42',211.72,'官网');

INSERT INTO `orders` VALUES (1666,'RT20260323001666',39,'PAID','2026-03-23 18:22:29','2026-03-23 19:23:29',68.00,'小程序');

INSERT INTO `orders` VALUES (1667,'RT20260323001667',232,'REFUNDED','2026-03-23 21:35:35','2026-03-23 21:53:35',72.80,'线下门店');

INSERT INTO `orders` VALUES (1668,'RT20260324001668',45,'PAID','2026-03-24 13:07:59','2026-03-24 13:40:59',152.60,'小程序');

INSERT INTO `orders` VALUES (1669,'RT20260324001669',242,'PAID','2026-03-24 13:14:11','2026-03-24 13:41:11',37.91,'小程序');

INSERT INTO `orders` VALUES (1670,'RT20260324001670',232,'PAID','2026-03-24 16:31:29','2026-03-24 16:53:29',296.00,'小程序');

INSERT INTO `orders` VALUES (1671,'RT20260324001671',564,'PAID','2026-03-24 19:06:29','2026-03-24 20:04:29',69.00,'线下门店');

INSERT INTO `orders` VALUES (1672,'RT20260325001672',472,'PAID','2026-03-25 09:54:46','2026-03-25 10:43:46',71.90,'官网');

INSERT INTO `orders` VALUES (1673,'RT20260325001673',214,'PAID','2026-03-25 10:24:45','2026-03-25 10:32:45',212.55,'小程序');

INSERT INTO `orders` VALUES (1674,'RT20260325001674',278,'PAID','2026-03-25 13:48:15','2026-03-25 14:59:15',32.90,'线下门店');

INSERT INTO `orders` VALUES (1675,'RT20260325001675',473,'PAID','2026-03-25 14:22:44','2026-03-25 15:35:44',24.90,'小程序');

INSERT INTO `orders` VALUES (1676,'RT20260325001676',333,'PAID','2026-03-25 15:12:24','2026-03-25 15:27:24',78.90,'小程序');

INSERT INTO `orders` VALUES (1677,'RT20260325001677',3,'PAID','2026-03-25 15:24:38','2026-03-25 15:49:38',24.90,'小程序');

INSERT INTO `orders` VALUES (1678,'RT20260325001678',71,'PAID','2026-03-25 16:30:43','2026-03-25 16:50:43',39.00,'小程序');

INSERT INTO `orders` VALUES (1679,'RT20260325001679',620,'PAID','2026-03-25 16:47:15','2026-03-25 17:11:15',24.90,'线下门店');

INSERT INTO `orders` VALUES (1680,'RT20260325001680',17,'PAID','2026-03-25 17:09:20','2026-03-25 18:20:20',57.80,'线下门店');

INSERT INTO `orders` VALUES (1681,'RT20260325001681',274,'PAID','2026-03-25 17:33:17','2026-03-25 18:15:17',279.90,'线下门店');

INSERT INTO `orders` VALUES (1682,'RT20260325001682',250,'PAID','2026-03-25 17:38:41','2026-03-25 18:00:41',32.90,'官网');

INSERT INTO `orders` VALUES (1683,'RT20260325001683',240,'PAID','2026-03-25 18:02:15','2026-03-25 18:37:15',39.90,'小程序');

INSERT INTO `orders` VALUES (1684,'RT20260325001684',208,'PAID','2026-03-25 18:28:38','2026-03-25 19:04:38',31.26,'线下门店');

INSERT INTO `orders` VALUES (1685,'RT20260325001685',531,'PAID','2026-03-25 18:44:58','2026-03-25 19:45:58',37.05,'线下门店');

INSERT INTO `orders` VALUES (1686,'RT20260325001686',135,'PAID','2026-03-25 20:13:58','2026-03-25 20:39:58',299.00,'线下门店');

INSERT INTO `orders` VALUES (1687,'RT20260326001687',109,'PAID','2026-03-26 12:30:59','2026-03-26 13:44:59',32.90,'小程序');

INSERT INTO `orders` VALUES (1688,'RT20260326001688',147,'REFUNDED','2026-03-26 15:15:33','2026-03-26 16:22:33',57.80,'线下门店');

INSERT INTO `orders` VALUES (1689,'RT20260326001689',561,'PAID','2026-03-26 16:22:19','2026-03-26 17:36:19',259.06,'小程序');

INSERT INTO `orders` VALUES (1690,'RT20260326001690',227,'PAID','2026-03-26 16:37:53','2026-03-26 17:30:53',39.00,'线下门店');

INSERT INTO `orders` VALUES (1691,'RT20260326001691',193,'PAID','2026-03-26 16:57:34','2026-03-26 17:39:34',201.66,'企业采购');

INSERT INTO `orders` VALUES (1692,'RT20260326001692',51,'PAID','2026-03-26 17:06:52','2026-03-26 17:54:52',177.90,'小程序');

INSERT INTO `orders` VALUES (1693,'RT20260326001693',25,'CANCELLED','2026-03-26 19:03:35',NULL,54.92,'官网');

INSERT INTO `orders` VALUES (1694,'RT20260326001694',355,'PAID','2026-03-26 19:58:02','2026-03-26 20:49:02',136.00,'官网');

INSERT INTO `orders` VALUES (1695,'RT20260326001695',302,'PAID','2026-03-26 22:08:25','2026-03-26 23:10:25',341.66,'小程序');

INSERT INTO `orders` VALUES (1696,'RT20260326001696',291,'PAID','2026-03-26 22:39:41','2026-03-26 22:43:41',69.00,'官网');

INSERT INTO `orders` VALUES (1697,'RT20260327001697',115,'PAID','2026-03-27 08:07:44','2026-03-27 08:51:44',32.90,'小程序');

INSERT INTO `orders` VALUES (1698,'RT20260327001698',250,'PAID','2026-03-27 10:45:06','2026-03-27 11:24:06',79.00,'小程序');

INSERT INTO `orders` VALUES (1699,'RT20260327001699',458,'PAID','2026-03-27 18:33:36','2026-03-27 19:33:36',78.90,'线下门店');

INSERT INTO `orders` VALUES (1700,'RT20260327001700',213,'PAID','2026-03-27 20:05:58','2026-03-27 20:48:58',89.00,'官网');

INSERT INTO `orders` VALUES (1701,'RT20260328001701',190,'PAID','2026-03-28 09:23:42','2026-03-28 09:36:42',78.00,'线下门店');

INSERT INTO `orders` VALUES (1702,'RT20260328001702',216,'PAID','2026-03-28 11:30:02','2026-03-28 11:47:02',39.00,'小程序');

INSERT INTO `orders` VALUES (1703,'RT20260328001703',198,'PAID','2026-03-28 11:31:11','2026-03-28 12:32:11',39.00,'官网');

INSERT INTO `orders` VALUES (1704,'RT20260328001704',383,'PAID','2026-03-28 12:08:57','2026-03-28 13:11:57',78.90,'线下门店');

INSERT INTO `orders` VALUES (1705,'RT20260328001705',619,'PAID','2026-03-28 12:26:37','2026-03-28 13:16:37',64.60,'线下门店');

INSERT INTO `orders` VALUES (1706,'RT20260328001706',302,'PAID','2026-03-28 13:50:01','2026-03-28 13:55:01',39.90,'企业采购');

INSERT INTO `orders` VALUES (1707,'RT20260328001707',308,'PAID','2026-03-28 17:18:54','2026-03-28 17:40:54',387.00,'线下门店');

INSERT INTO `orders` VALUES (1708,'RT20260328001708',373,'CANCELLED','2026-03-28 18:37:13',NULL,71.90,'线下门店');

INSERT INTO `orders` VALUES (1709,'RT20260328001709',110,'PAID','2026-03-28 18:52:16','2026-03-28 19:26:16',90.26,'线下门店');

INSERT INTO `orders` VALUES (1710,'RT20260328001710',257,'PAID','2026-03-28 19:33:51','2026-03-28 19:50:51',242.90,'线下门店');

INSERT INTO `orders` VALUES (1711,'RT20260329001711',288,'PAID','2026-03-29 13:00:01','2026-03-29 14:02:01',39.90,'小程序');

INSERT INTO `orders` VALUES (1712,'RT20260329001712',208,'PAID','2026-03-29 14:43:45','2026-03-29 15:38:45',39.00,'线下门店');

INSERT INTO `orders` VALUES (1713,'RT20260329001713',599,'PAID','2026-03-29 14:43:47','2026-03-29 15:25:47',24.90,'官网');

INSERT INTO `orders` VALUES (1714,'RT20260329001714',442,'PAID','2026-03-29 14:55:28','2026-03-29 14:59:28',137.00,'线下门店');

INSERT INTO `orders` VALUES (1715,'RT20260329001715',409,'PAID','2026-03-29 15:39:47','2026-03-29 16:06:47',131.90,'小程序');

INSERT INTO `orders` VALUES (1716,'RT20260329001716',69,'REFUNDED','2026-03-29 15:50:15','2026-03-29 15:54:15',57.80,'线下门店');

INSERT INTO `orders` VALUES (1717,'RT20260329001717',501,'PAID','2026-03-29 16:55:42','2026-03-29 17:20:42',32.90,'线下门店');

INSERT INTO `orders` VALUES (1718,'RT20260329001718',208,'REFUNDED','2026-03-29 18:48:23','2026-03-29 19:32:23',318.00,'小程序');

INSERT INTO `orders` VALUES (1719,'RT20260329001719',593,'PAID','2026-03-29 18:53:24','2026-03-29 19:52:24',32.90,'线下门店');

INSERT INTO `orders` VALUES (1720,'RT20260329001720',183,'PAID','2026-03-29 19:21:12','2026-03-29 20:35:12',39.00,'小程序');

INSERT INTO `orders` VALUES (1721,'RT20260329001721',340,'PAID','2026-03-29 19:23:25','2026-03-29 20:12:25',129.00,'线下门店');

INSERT INTO `orders` VALUES (1722,'RT20260330001722',401,'PAID','2026-03-30 12:36:41','2026-03-30 13:29:41',39.00,'线下门店');

INSERT INTO `orders` VALUES (1723,'RT20260330001723',141,'PAID','2026-03-30 15:44:34','2026-03-30 16:02:34',104.55,'官网');

INSERT INTO `orders` VALUES (1724,'RT20260330001724',118,'PAID','2026-03-30 18:38:00','2026-03-30 18:39:00',453.55,'小程序');

INSERT INTO `orders` VALUES (1725,'RT20260330001725',569,'PAID','2026-03-30 21:31:55','2026-03-30 22:41:55',103.90,'小程序');

INSERT INTO `orders` VALUES (1726,'RT20260331001726',331,'PAID','2026-03-31 08:42:52','2026-03-31 09:35:52',39.00,'小程序');

INSERT INTO `orders` VALUES (1727,'RT20260331001727',357,'PAID','2026-03-31 12:54:08','2026-03-31 13:32:08',68.00,'官网');

INSERT INTO `orders` VALUES (1728,'RT20260331001728',222,'PAID','2026-03-31 14:20:08','2026-03-31 15:10:08',253.55,'线下门店');

INSERT INTO `orders` VALUES (1729,'RT20260331001729',550,'CANCELLED','2026-03-31 15:07:11',NULL,186.80,'线下门店');

INSERT INTO `orders` VALUES (1730,'RT20260331001730',351,'PAID','2026-03-31 15:07:40','2026-03-31 16:00:40',99.70,'小程序');

INSERT INTO `orders` VALUES (1731,'RT20260331001731',430,'PAID','2026-03-31 15:36:00','2026-03-31 15:55:00',37.91,'官网');

INSERT INTO `orders` VALUES (1732,'RT20260331001732',71,'PAID','2026-03-31 16:38:02','2026-03-31 17:38:02',136.00,'小程序');

INSERT INTO `orders` VALUES (1733,'RT20260331001733',429,'PAID','2026-03-31 17:05:10','2026-03-31 17:15:10',29.61,'官网');

INSERT INTO `orders` VALUES (1734,'RT20260331001734',69,'PAID','2026-03-31 18:00:53','2026-03-31 18:33:53',151.05,'官网');

INSERT INTO `orders` VALUES (1735,'RT20260331001735',147,'PAID','2026-03-31 19:42:05','2026-03-31 20:32:05',29.61,'小程序');

INSERT INTO `orders` VALUES (1736,'RT20260331001736',270,'PAID','2026-03-31 19:48:13','2026-03-31 20:34:13',56.05,'官网');

INSERT INTO `orders` VALUES (1737,'RT20260331001737',41,'PAID','2026-03-31 20:59:45','2026-03-31 21:43:45',78.90,'官网');

INSERT INTO `orders` VALUES (1738,'RT20260401001738',355,'PAID','2026-04-01 09:54:15','2026-04-01 09:59:15',32.90,'小程序');

INSERT INTO `orders` VALUES (1739,'RT20260401001739',96,'PAID','2026-04-01 15:05:56','2026-04-01 15:48:56',878.95,'小程序');

INSERT INTO `orders` VALUES (1740,'RT20260401001740',194,'CANCELLED','2026-04-01 17:31:39',NULL,62.81,'小程序');

INSERT INTO `orders` VALUES (1741,'RT20260401001741',63,'PAID','2026-04-01 18:07:42','2026-04-01 18:36:42',158.70,'小程序');

INSERT INTO `orders` VALUES (1742,'RT20260402001742',545,'PAID','2026-04-02 10:03:06','2026-04-02 10:08:06',65.80,'小程序');

INSERT INTO `orders` VALUES (1743,'RT20260402001743',251,'PAID','2026-04-02 10:59:02','2026-04-02 11:38:02',248.00,'官网');

INSERT INTO `orders` VALUES (1744,'RT20260402001744',515,'PAID','2026-04-02 13:33:02','2026-04-02 13:50:02',280.41,'小程序');

INSERT INTO `orders` VALUES (1745,'RT20260402001745',147,'PAID','2026-04-02 19:45:12','2026-04-02 20:40:12',24.90,'小程序');

INSERT INTO `orders` VALUES (1746,'RT20260402001746',426,'REFUNDED','2026-04-02 20:45:27','2026-04-02 20:51:27',80.10,'线下门店');

INSERT INTO `orders` VALUES (1747,'RT20260403001747',224,'REFUNDED','2026-04-03 10:00:34','2026-04-03 10:19:34',39.00,'线下门店');

INSERT INTO `orders` VALUES (1748,'RT20260403001748',133,'PAID','2026-04-03 11:43:59','2026-04-03 12:12:59',244.05,'小程序');

INSERT INTO `orders` VALUES (1749,'RT20260403001749',312,'PAID','2026-04-03 11:57:22','2026-04-03 12:22:22',159.00,'小程序');

INSERT INTO `orders` VALUES (1750,'RT20260403001750',176,'PAID','2026-04-03 12:20:50','2026-04-03 12:37:50',39.90,'线下门店');

INSERT INTO `orders` VALUES (1751,'RT20260403001751',159,'PAID','2026-04-03 13:21:05','2026-04-03 13:39:05',37.91,'官网');

INSERT INTO `orders` VALUES (1752,'RT20260403001752',282,'PAID','2026-04-03 16:53:59','2026-04-03 17:26:59',118.00,'线下门店');

INSERT INTO `orders` VALUES (1753,'RT20260404001753',413,'PAID','2026-04-04 10:06:11','2026-04-04 11:10:11',297.00,'小程序');

INSERT INTO `orders` VALUES (1754,'RT20260404001754',474,'PAID','2026-04-04 12:54:55','2026-04-04 13:48:55',418.95,'线下门店');

INSERT INTO `orders` VALUES (1755,'RT20260404001755',65,'PAID','2026-04-04 16:57:03','2026-04-04 17:05:03',126.91,'官网');

INSERT INTO `orders` VALUES (1756,'RT20260404001756',406,'PAID','2026-04-04 18:07:43','2026-04-04 18:38:43',68.00,'小程序');

INSERT INTO `orders` VALUES (1757,'RT20260404001757',200,'PAID','2026-04-04 18:55:36','2026-04-04 19:35:36',157.00,'小程序');

INSERT INTO `orders` VALUES (1758,'RT20260404001758',90,'PAID','2026-04-04 21:36:01','2026-04-04 22:40:01',72.80,'线下门店');

INSERT INTO `orders` VALUES (1759,'RT20260405001759',45,'PAID','2026-04-05 11:03:35','2026-04-05 11:53:35',80.10,'官网');

INSERT INTO `orders` VALUES (1760,'RT20260405001760',246,'PAID','2026-04-05 11:54:14','2026-04-05 13:00:14',84.55,'官网');

INSERT INTO `orders` VALUES (1761,'RT20260405001761',392,'PAID','2026-04-05 12:59:58','2026-04-05 13:40:58',39.00,'官网');

INSERT INTO `orders` VALUES (1762,'RT20260405001762',458,'PAID','2026-04-05 18:55:05','2026-04-05 19:24:05',367.00,'线下门店');

INSERT INTO `orders` VALUES (1763,'RT20260405001763',317,'REFUNDED','2026-04-05 18:55:45','2026-04-05 20:03:45',22.41,'小程序');

INSERT INTO `orders` VALUES (1764,'RT20260406001764',450,'PAID','2026-04-06 09:50:13','2026-04-06 10:27:13',39.90,'线下门店');

INSERT INTO `orders` VALUES (1765,'RT20260406001765',91,'PAID','2026-04-06 16:20:01','2026-04-06 17:33:01',126.80,'官网');

INSERT INTO `orders` VALUES (1766,'RT20260406001766',42,'PAID','2026-04-06 19:21:22','2026-04-06 20:00:22',68.00,'小程序');

INSERT INTO `orders` VALUES (1767,'RT20260406001767',246,'PAID','2026-04-06 19:35:31','2026-04-06 20:24:31',72.80,'小程序');

INSERT INTO `orders` VALUES (1768,'RT20260406001768',482,'PAID','2026-04-06 20:57:45','2026-04-06 21:14:45',81.41,'线下门店');

INSERT INTO `orders` VALUES (1769,'RT20260406001769',9,'PAID','2026-04-06 21:20:12','2026-04-06 22:12:12',24.90,'官网');

INSERT INTO `orders` VALUES (1770,'RT20260406001770',114,'PAID','2026-04-06 21:20:14','2026-04-06 22:18:14',32.90,'线下门店');

INSERT INTO `orders` VALUES (1771,'RT20260407001771',332,'PAID','2026-04-07 09:49:53','2026-04-07 10:42:53',68.00,'小程序');

INSERT INTO `orders` VALUES (1772,'RT20260407001772',495,'PAID','2026-04-07 12:01:10','2026-04-07 12:48:10',35.91,'线下门店');

INSERT INTO `orders` VALUES (1773,'RT20260407001773',332,'PAID','2026-04-07 13:26:38','2026-04-07 13:56:38',68.00,'官网');

INSERT INTO `orders` VALUES (1774,'RT20260407001774',72,'PAID','2026-04-07 13:56:05','2026-04-07 14:49:05',129.00,'小程序');

INSERT INTO `orders` VALUES (1775,'RT20260407001775',481,'PAID','2026-04-07 22:30:51','2026-04-07 23:03:51',178.00,'官网');

INSERT INTO `orders` VALUES (1776,'RT20260408001776',375,'PAID','2026-04-08 10:28:49','2026-04-08 11:12:49',326.00,'官网');

INSERT INTO `orders` VALUES (1777,'RT20260408001777',568,'PAID','2026-04-08 14:43:52','2026-04-08 14:44:52',32.90,'官网');

INSERT INTO `orders` VALUES (1778,'RT20260408001778',25,'PAID','2026-04-08 14:58:42','2026-04-08 15:11:42',186.30,'企业采购');

INSERT INTO `orders` VALUES (1779,'RT20260408001779',5,'PAID','2026-04-08 17:41:13','2026-04-08 18:23:13',129.00,'小程序');

INSERT INTO `orders` VALUES (1780,'RT20260408001780',254,'PAID','2026-04-08 17:55:44','2026-04-08 18:34:44',39.90,'小程序');

INSERT INTO `orders` VALUES (1781,'RT20260408001781',459,'PAID','2026-04-08 19:08:13','2026-04-08 19:44:13',562.05,'官网');

INSERT INTO `orders` VALUES (1782,'RT20260408001782',325,'CANCELLED','2026-04-08 19:33:45',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (1783,'RT20260409001783',491,'PAID','2026-04-09 10:11:36','2026-04-09 10:39:36',111.90,'小程序');

INSERT INTO `orders` VALUES (1784,'RT20260409001784',126,'PAID','2026-04-09 10:54:42','2026-04-09 12:00:42',177.00,'线下门店');

INSERT INTO `orders` VALUES (1785,'RT20260409001785',199,'PAID','2026-04-09 11:18:29','2026-04-09 12:11:29',157.00,'官网');

INSERT INTO `orders` VALUES (1786,'RT20260409001786',150,'PAID','2026-04-09 12:43:58','2026-04-09 13:19:58',23.66,'线下门店');

INSERT INTO `orders` VALUES (1787,'RT20260409001787',500,'PAID','2026-04-09 13:17:42','2026-04-09 13:35:42',68.00,'小程序');

INSERT INTO `orders` VALUES (1788,'RT20260409001788',2,'PAID','2026-04-09 13:34:39','2026-04-09 14:22:39',438.90,'小程序');

INSERT INTO `orders` VALUES (1789,'RT20260409001789',89,'PAID','2026-04-09 15:40:17','2026-04-09 16:25:17',399.00,'官网');

INSERT INTO `orders` VALUES (1790,'RT20260409001790',249,'PAID','2026-04-09 17:17:53','2026-04-09 18:12:53',39.00,'线下门店');

INSERT INTO `orders` VALUES (1791,'RT20260409001791',298,'PAID','2026-04-09 19:28:22','2026-04-09 20:10:22',269.10,'线下门店');

INSERT INTO `orders` VALUES (1792,'RT20260410001792',14,'PAID','2026-04-10 10:22:45','2026-04-10 11:27:45',39.00,'官网');

INSERT INTO `orders` VALUES (1793,'RT20260410001793',138,'CANCELLED','2026-04-10 12:02:13',NULL,59.00,'线下门店');

INSERT INTO `orders` VALUES (1794,'RT20260410001794',190,'PAID','2026-04-10 12:12:11','2026-04-10 12:22:11',69.00,'企业采购');

INSERT INTO `orders` VALUES (1795,'RT20260410001795',139,'PAID','2026-04-10 12:24:49','2026-04-10 13:30:49',65.80,'小程序');

INSERT INTO `orders` VALUES (1796,'RT20260410001796',152,'PAID','2026-04-10 17:00:15','2026-04-10 17:11:15',171.10,'线下门店');

INSERT INTO `orders` VALUES (1797,'RT20260410001797',180,'PAID','2026-04-10 17:56:10','2026-04-10 18:55:10',39.90,'官网');

INSERT INTO `orders` VALUES (1798,'RT20260410001798',255,'PAID','2026-04-10 19:56:19','2026-04-10 20:47:19',299.00,'官网');

INSERT INTO `orders` VALUES (1799,'RT20260410001799',83,'PAID','2026-04-10 20:48:53','2026-04-10 21:41:53',53.10,'小程序');

INSERT INTO `orders` VALUES (1800,'RT20260410001800',271,'PAID','2026-04-10 21:19:18','2026-04-10 22:27:18',89.00,'小程序');

INSERT INTO `orders` VALUES (1801,'RT20260410001801',265,'PAID','2026-04-10 21:29:24','2026-04-10 22:33:24',80.10,'小程序');

INSERT INTO `orders` VALUES (1802,'RT20260411001802',25,'PAID','2026-04-11 12:58:13','2026-04-11 14:06:13',158.00,'小程序');

INSERT INTO `orders` VALUES (1803,'RT20260411001803',286,'PAID','2026-04-11 16:19:32','2026-04-11 16:44:32',207.90,'官网');

INSERT INTO `orders` VALUES (1804,'RT20260411001804',358,'CANCELLED','2026-04-11 18:16:14',NULL,86.17,'线下门店');

INSERT INTO `orders` VALUES (1805,'RT20260411001805',97,'PAID','2026-04-11 22:09:46','2026-04-11 22:33:46',39.90,'小程序');

INSERT INTO `orders` VALUES (1806,'RT20260412001806',357,'PAID','2026-04-12 10:15:40','2026-04-12 10:20:40',32.90,'小程序');

INSERT INTO `orders` VALUES (1807,'RT20260412001807',140,'PAID','2026-04-12 10:19:21','2026-04-12 10:59:21',79.00,'线下门店');

INSERT INTO `orders` VALUES (1808,'RT20260412001808',136,'PAID','2026-04-12 11:55:37','2026-04-12 13:01:37',392.80,'线下门店');

INSERT INTO `orders` VALUES (1809,'RT20260412001809',168,'CANCELLED','2026-04-12 13:17:44',NULL,49.80,'线下门店');

INSERT INTO `orders` VALUES (1810,'RT20260412001810',195,'PAID','2026-04-12 15:17:03','2026-04-12 15:58:03',32.90,'小程序');

INSERT INTO `orders` VALUES (1811,'RT20260412001811',577,'PAID','2026-04-12 16:46:06','2026-04-12 17:08:06',124.10,'企业采购');

INSERT INTO `orders` VALUES (1812,'RT20260412001812',198,'CANCELLED','2026-04-12 16:50:12',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (1813,'RT20260412001813',156,'PAID','2026-04-12 17:14:48','2026-04-12 17:50:48',23.66,'企业采购');

INSERT INTO `orders` VALUES (1814,'RT20260412001814',10,'PAID','2026-04-12 18:18:52','2026-04-12 19:19:52',71.90,'线下门店');

INSERT INTO `orders` VALUES (1815,'RT20260412001815',207,'PAID','2026-04-12 18:39:59','2026-04-12 19:08:59',39.00,'线下门店');

INSERT INTO `orders` VALUES (1816,'RT20260412001816',84,'PAID','2026-04-12 18:45:16','2026-04-12 19:21:16',1047.00,'小程序');

INSERT INTO `orders` VALUES (1817,'RT20260412001817',606,'PAID','2026-04-12 19:02:17','2026-04-12 19:11:17',24.90,'小程序');

INSERT INTO `orders` VALUES (1818,'RT20260412001818',106,'PAID','2026-04-12 19:27:42','2026-04-12 20:10:42',367.90,'小程序');

INSERT INTO `orders` VALUES (1819,'RT20260412001819',462,'PAID','2026-04-12 22:59:12','2026-04-12 23:02:12',70.81,'线下门店');

INSERT INTO `orders` VALUES (1820,'RT20260413001820',334,'PAID','2026-04-13 12:41:18','2026-04-13 12:43:18',39.90,'小程序');

INSERT INTO `orders` VALUES (1821,'RT20260413001821',447,'PAID','2026-04-13 14:09:23','2026-04-13 15:17:23',189.05,'线下门店');

INSERT INTO `orders` VALUES (1822,'RT20260413001822',436,'PAID','2026-04-13 15:09:07','2026-04-13 16:13:07',169.00,'小程序');

INSERT INTO `orders` VALUES (1823,'RT20260413001823',435,'PAID','2026-04-13 16:55:57','2026-04-13 18:04:57',37.05,'官网');

INSERT INTO `orders` VALUES (1824,'RT20260413001824',308,'PAID','2026-04-13 20:13:17','2026-04-13 20:30:17',198.90,'线下门店');

INSERT INTO `orders` VALUES (1825,'RT20260413001825',600,'CANCELLED','2026-04-13 20:44:22',NULL,32.90,'官网');

INSERT INTO `orders` VALUES (1826,'RT20260413001826',242,'PAID','2026-04-13 21:00:14','2026-04-13 22:09:14',144.76,'线下门店');

INSERT INTO `orders` VALUES (1827,'RT20260414001827',4,'PAID','2026-04-14 12:25:41','2026-04-14 12:31:41',24.90,'官网');

INSERT INTO `orders` VALUES (1828,'RT20260414001828',558,'PAID','2026-04-14 12:27:56','2026-04-14 13:07:56',39.90,'线下门店');

INSERT INTO `orders` VALUES (1829,'RT20260414001829',93,'PAID','2026-04-14 14:32:58','2026-04-14 15:30:58',78.00,'线下门店');

INSERT INTO `orders` VALUES (1830,'RT20260414001830',630,'PAID','2026-04-14 15:52:58','2026-04-14 16:01:58',124.05,'线下门店');

INSERT INTO `orders` VALUES (1831,'RT20260414001831',284,'PAID','2026-04-14 16:15:34','2026-04-14 16:29:34',177.00,'官网');

INSERT INTO `orders` VALUES (1832,'RT20260414001832',404,'PAID','2026-04-14 16:55:23','2026-04-14 17:41:23',68.00,'线下门店');

INSERT INTO `orders` VALUES (1833,'RT20260414001833',298,'PAID','2026-04-14 17:56:17','2026-04-14 18:06:17',179.10,'线下门店');

INSERT INTO `orders` VALUES (1834,'RT20260415001834',167,'CANCELLED','2026-04-15 13:43:52',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1835,'RT20260415001835',387,'PAID','2026-04-15 13:44:30','2026-04-15 14:44:30',221.25,'线下门店');

INSERT INTO `orders` VALUES (1836,'RT20260415001836',198,'PAID','2026-04-15 16:57:18','2026-04-15 17:45:18',698.90,'小程序');

INSERT INTO `orders` VALUES (1837,'RT20260415001837',327,'PAID','2026-04-15 17:09:43','2026-04-15 17:27:43',258.00,'小程序');

INSERT INTO `orders` VALUES (1838,'RT20260415001838',313,'PAID','2026-04-15 18:55:53','2026-04-15 19:23:53',62.81,'小程序');

INSERT INTO `orders` VALUES (1839,'RT20260415001839',261,'PAID','2026-04-15 19:31:37','2026-04-15 20:09:37',24.90,'企业采购');

INSERT INTO `orders` VALUES (1840,'RT20260415001840',249,'PAID','2026-04-15 19:41:35','2026-04-15 20:23:35',79.80,'官网');

INSERT INTO `orders` VALUES (1841,'RT20260415001841',136,'PAID','2026-04-15 19:58:12','2026-04-15 20:44:12',68.00,'线下门店');

INSERT INTO `orders` VALUES (1842,'RT20260415001842',180,'PAID','2026-04-15 20:54:34','2026-04-15 21:35:34',127.00,'线下门店');

INSERT INTO `orders` VALUES (1843,'RT20260416001843',405,'PAID','2026-04-16 15:42:45','2026-04-16 16:37:45',136.00,'线下门店');

INSERT INTO `orders` VALUES (1844,'RT20260416001844',589,'PAID','2026-04-16 17:30:01','2026-04-16 18:36:01',146.90,'线下门店');

INSERT INTO `orders` VALUES (1845,'RT20260417001845',633,'PAID','2026-04-17 11:19:22','2026-04-17 12:23:22',79.00,'官网');

INSERT INTO `orders` VALUES (1846,'RT20260417001846',102,'PAID','2026-04-17 17:40:25','2026-04-17 17:48:25',39.90,'官网');

INSERT INTO `orders` VALUES (1847,'RT20260418001847',176,'PAID','2026-04-18 10:35:27','2026-04-18 11:47:27',59.00,'小程序');

INSERT INTO `orders` VALUES (1848,'RT20260418001848',186,'PAID','2026-04-18 11:27:22','2026-04-18 11:46:22',160.20,'小程序');

INSERT INTO `orders` VALUES (1849,'RT20260418001849',360,'PAID','2026-04-18 12:31:02','2026-04-18 13:38:02',96.81,'官网');

INSERT INTO `orders` VALUES (1850,'RT20260418001850',93,'PAID','2026-04-18 13:04:16','2026-04-18 13:17:16',56.56,'小程序');

INSERT INTO `orders` VALUES (1851,'RT20260418001851',212,'PAID','2026-04-18 15:42:29','2026-04-18 15:58:29',59.00,'官网');

INSERT INTO `orders` VALUES (1852,'RT20260418001852',82,'PAID','2026-04-18 15:54:58','2026-04-18 16:08:58',39.90,'小程序');

INSERT INTO `orders` VALUES (1853,'RT20260418001853',272,'CANCELLED','2026-04-18 17:39:21',NULL,505.05,'小程序');

INSERT INTO `orders` VALUES (1854,'RT20260418001854',251,'PAID','2026-04-18 18:07:48','2026-04-18 18:14:48',84.55,'官网');

INSERT INTO `orders` VALUES (1855,'RT20260418001855',238,'PAID','2026-04-18 18:33:16','2026-04-18 18:39:16',286.20,'官网');

INSERT INTO `orders` VALUES (1856,'RT20260418001856',348,'CANCELLED','2026-04-18 19:09:31',NULL,64.80,'官网');

INSERT INTO `orders` VALUES (1857,'RT20260418001857',623,'PAID','2026-04-18 19:55:18','2026-04-18 20:12:18',69.00,'小程序');

INSERT INTO `orders` VALUES (1858,'RT20260418001858',213,'PAID','2026-04-18 20:46:05','2026-04-18 21:17:05',64.60,'线下门店');

INSERT INTO `orders` VALUES (1859,'RT20260418001859',228,'PAID','2026-04-18 21:06:13','2026-04-18 21:39:13',108.00,'企业采购');

INSERT INTO `orders` VALUES (1860,'RT20260418001860',253,'PAID','2026-04-18 21:43:25','2026-04-18 21:52:25',233.05,'小程序');

INSERT INTO `orders` VALUES (1861,'RT20260419001861',347,'PAID','2026-04-19 08:43:18','2026-04-19 08:59:18',62.51,'线下门店');

INSERT INTO `orders` VALUES (1862,'RT20260419001862',365,'PAID','2026-04-19 10:17:13','2026-04-19 11:12:13',32.90,'线下门店');

INSERT INTO `orders` VALUES (1863,'RT20260419001863',495,'PAID','2026-04-19 10:34:23','2026-04-19 10:44:23',138.00,'小程序');

INSERT INTO `orders` VALUES (1864,'RT20260419001864',142,'PAID','2026-04-19 16:34:46','2026-04-19 17:31:46',798.00,'企业采购');

INSERT INTO `orders` VALUES (1865,'RT20260419001865',227,'PAID','2026-04-19 17:00:09','2026-04-19 17:39:09',108.90,'小程序');

INSERT INTO `orders` VALUES (1866,'RT20260419001866',69,'PAID','2026-04-19 19:21:58','2026-04-19 20:02:58',960.20,'企业采购');

INSERT INTO `orders` VALUES (1867,'RT20260420001867',334,'CANCELLED','2026-04-20 13:36:10',NULL,37.05,'线下门店');

INSERT INTO `orders` VALUES (1868,'RT20260420001868',230,'PAID','2026-04-20 13:42:05','2026-04-20 14:50:05',460.20,'线下门店');

INSERT INTO `orders` VALUES (1869,'RT20260420001869',90,'PAID','2026-04-20 15:20:40','2026-04-20 15:34:40',37.91,'小程序');

INSERT INTO `orders` VALUES (1870,'RT20260420001870',147,'REFUNDED','2026-04-20 16:39:40','2026-04-20 17:46:40',103.46,'线下门店');

INSERT INTO `orders` VALUES (1871,'RT20260420001871',241,'PAID','2026-04-20 16:42:13','2026-04-20 17:25:13',24.90,'小程序');

INSERT INTO `orders` VALUES (1872,'RT20260420001872',282,'PAID','2026-04-20 17:07:00','2026-04-20 17:16:00',39.00,'线下门店');

INSERT INTO `orders` VALUES (1873,'RT20260420001873',394,'CANCELLED','2026-04-20 17:30:38',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (1874,'RT20260420001874',178,'PAID','2026-04-20 19:41:31','2026-04-20 19:50:31',127.00,'小程序');

INSERT INTO `orders` VALUES (1875,'RT20260420001875',65,'PAID','2026-04-20 20:42:25','2026-04-20 21:54:25',65.80,'官网');

INSERT INTO `orders` VALUES (1876,'RT20260421001876',328,'CANCELLED','2026-04-21 12:58:58',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (1877,'RT20260421001877',134,'PAID','2026-04-21 13:46:25','2026-04-21 14:16:25',237.00,'小程序');

INSERT INTO `orders` VALUES (1878,'RT20260421001878',209,'PAID','2026-04-21 13:55:14','2026-04-21 13:57:14',31.26,'小程序');

INSERT INTO `orders` VALUES (1879,'RT20260421001879',82,'PAID','2026-04-21 16:39:56','2026-04-21 17:08:56',90.26,'小程序');

INSERT INTO `orders` VALUES (1880,'RT20260421001880',191,'PAID','2026-04-21 17:38:06','2026-04-21 18:14:06',32.90,'小程序');

INSERT INTO `orders` VALUES (1881,'RT20260421001881',149,'PAID','2026-04-21 17:47:18','2026-04-21 18:56:18',37.05,'小程序');

INSERT INTO `orders` VALUES (1882,'RT20260421001882',102,'PAID','2026-04-21 19:32:16','2026-04-21 20:30:16',75.05,'线下门店');

INSERT INTO `orders` VALUES (1883,'RT20260421001883',148,'PAID','2026-04-21 19:35:26','2026-04-21 19:45:26',68.00,'官网');

INSERT INTO `orders` VALUES (1884,'RT20260421001884',272,'PAID','2026-04-21 19:47:10','2026-04-21 20:10:10',134.35,'官网');

INSERT INTO `orders` VALUES (1885,'RT20260421001885',475,'PAID','2026-04-21 20:44:01','2026-04-21 21:28:01',458.00,'线下门店');

INSERT INTO `orders` VALUES (1886,'RT20260422001886',299,'PAID','2026-04-22 11:00:10','2026-04-22 11:38:10',80.10,'线下门店');

INSERT INTO `orders` VALUES (1887,'RT20260422001887',171,'PAID','2026-04-22 15:46:59','2026-04-22 17:00:59',23.66,'官网');

INSERT INTO `orders` VALUES (1888,'RT20260422001888',84,'REFUNDED','2026-04-22 16:16:13','2026-04-22 16:59:13',32.90,'线下门店');

INSERT INTO `orders` VALUES (1889,'RT20260422001889',386,'PAID','2026-04-22 19:05:19','2026-04-22 19:27:19',24.90,'官网');

INSERT INTO `orders` VALUES (1890,'RT20260422001890',393,'PAID','2026-04-22 19:10:17','2026-04-22 19:22:17',237.00,'官网');

INSERT INTO `orders` VALUES (1891,'RT20260423001891',77,'PAID','2026-04-23 14:32:17','2026-04-23 15:15:17',153.90,'官网');

INSERT INTO `orders` VALUES (1892,'RT20260423001892',74,'PAID','2026-04-23 15:45:09','2026-04-23 16:16:09',507.00,'官网');

INSERT INTO `orders` VALUES (1893,'RT20260423001893',621,'REFUNDED','2026-04-23 17:20:11','2026-04-23 18:00:11',68.00,'线下门店');

INSERT INTO `orders` VALUES (1894,'RT20260423001894',141,'PAID','2026-04-23 19:07:10','2026-04-23 20:17:10',22.41,'小程序');

INSERT INTO `orders` VALUES (1895,'RT20260423001895',111,'PAID','2026-04-23 22:41:04','2026-04-23 23:49:04',68.00,'小程序');

INSERT INTO `orders` VALUES (1896,'RT20260424001896',557,'PAID','2026-04-24 10:59:49','2026-04-24 11:29:49',76.95,'企业采购');

INSERT INTO `orders` VALUES (1897,'RT20260424001897',492,'PAID','2026-04-24 11:01:11','2026-04-24 12:12:11',334.90,'线下门店');

INSERT INTO `orders` VALUES (1898,'RT20260424001898',271,'PAID','2026-04-24 17:03:59','2026-04-24 17:40:59',39.00,'官网');

INSERT INTO `orders` VALUES (1899,'RT20260424001899',609,'PAID','2026-04-24 19:52:32','2026-04-24 20:15:32',208.90,'小程序');

INSERT INTO `orders` VALUES (1900,'RT20260425001900',135,'PAID','2026-04-25 11:20:25','2026-04-25 12:28:25',107.00,'小程序');

INSERT INTO `orders` VALUES (1901,'RT20260425001901',248,'PAID','2026-04-25 11:45:57','2026-04-25 12:44:57',123.60,'官网');

INSERT INTO `orders` VALUES (1902,'RT20260425001902',603,'PAID','2026-04-25 12:44:52','2026-04-25 13:28:52',159.00,'企业采购');

INSERT INTO `orders` VALUES (1903,'RT20260425001903',253,'PAID','2026-04-25 14:15:11','2026-04-25 14:26:11',160.20,'线下门店');

INSERT INTO `orders` VALUES (1904,'RT20260425001904',127,'PAID','2026-04-25 15:06:29','2026-04-25 15:57:29',70.81,'小程序');

INSERT INTO `orders` VALUES (1905,'RT20260425001905',161,'PAID','2026-04-25 16:45:28','2026-04-25 17:51:28',90.41,'线下门店');

INSERT INTO `orders` VALUES (1906,'RT20260425001906',18,'PAID','2026-04-25 16:55:58','2026-04-25 18:02:58',235.61,'官网');

INSERT INTO `orders` VALUES (1907,'RT20260425001907',423,'PAID','2026-04-25 16:56:01','2026-04-25 18:07:01',31.26,'小程序');

INSERT INTO `orders` VALUES (1908,'RT20260425001908',365,'PAID','2026-04-25 16:59:59','2026-04-25 17:15:59',99.12,'官网');

INSERT INTO `orders` VALUES (1909,'RT20260425001909',155,'PAID','2026-04-25 17:58:36','2026-04-25 18:50:36',701.60,'小程序');

INSERT INTO `orders` VALUES (1910,'RT20260425001910',282,'PAID','2026-04-25 18:26:01','2026-04-25 19:28:01',39.90,'小程序');

INSERT INTO `orders` VALUES (1911,'RT20260425001911',158,'PAID','2026-04-25 18:41:57','2026-04-25 19:27:57',121.90,'官网');

INSERT INTO `orders` VALUES (1912,'RT20260425001912',626,'PAID','2026-04-25 19:48:42','2026-04-25 20:26:42',160.55,'线下门店');

INSERT INTO `orders` VALUES (1913,'RT20260425001913',49,'PAID','2026-04-25 20:18:18','2026-04-25 20:46:18',358.20,'官网');

INSERT INTO `orders` VALUES (1914,'RT20260425001914',131,'PAID','2026-04-25 21:17:06','2026-04-25 22:07:06',39.90,'官网');

INSERT INTO `orders` VALUES (1915,'RT20260426001915',453,'PAID','2026-04-26 10:44:49','2026-04-26 11:04:49',111.90,'线下门店');

INSERT INTO `orders` VALUES (1916,'RT20260426001916',459,'PAID','2026-04-26 11:11:39','2026-04-26 11:13:39',168.90,'小程序');

INSERT INTO `orders` VALUES (1917,'RT20260426001917',543,'PAID','2026-04-26 13:17:28','2026-04-26 13:27:28',31.26,'小程序');

INSERT INTO `orders` VALUES (1918,'RT20260426001918',132,'PAID','2026-04-26 15:29:11','2026-04-26 16:11:11',111.06,'线下门店');

INSERT INTO `orders` VALUES (1919,'RT20260426001919',111,'PAID','2026-04-26 16:52:41','2026-04-26 17:53:41',32.90,'线下门店');

INSERT INTO `orders` VALUES (1920,'RT20260426001920',48,'PAID','2026-04-26 17:55:01','2026-04-26 18:30:01',32.90,'小程序');

INSERT INTO `orders` VALUES (1921,'RT20260426001921',293,'PAID','2026-04-26 18:02:01','2026-04-26 19:11:01',78.90,'小程序');

INSERT INTO `orders` VALUES (1922,'RT20260426001922',136,'PAID','2026-04-26 20:31:29','2026-04-26 21:36:29',168.00,'小程序');

INSERT INTO `orders` VALUES (1923,'RT20260426001923',231,'PAID','2026-04-26 20:54:46','2026-04-26 21:56:46',63.56,'小程序');

INSERT INTO `orders` VALUES (1924,'RT20260427001924',157,'PAID','2026-04-27 14:29:53','2026-04-27 15:25:53',39.00,'小程序');

INSERT INTO `orders` VALUES (1925,'RT20260427001925',28,'PAID','2026-04-27 16:43:59','2026-04-27 17:11:59',37.05,'小程序');

INSERT INTO `orders` VALUES (1926,'RT20260427001926',354,'PAID','2026-04-27 17:02:17','2026-04-27 17:19:17',35.10,'小程序');

INSERT INTO `orders` VALUES (1927,'RT20260427001927',214,'PAID','2026-04-27 19:24:52','2026-04-27 19:38:52',75.05,'企业采购');

INSERT INTO `orders` VALUES (1928,'RT20260427001928',565,'PAID','2026-04-27 19:31:54','2026-04-27 19:36:54',68.00,'小程序');

INSERT INTO `orders` VALUES (1929,'RT20260428001929',59,'CANCELLED','2026-04-28 10:07:26',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1930,'RT20260428001930',186,'PAID','2026-04-28 12:41:59','2026-04-28 13:44:59',89.00,'小程序');

INSERT INTO `orders` VALUES (1931,'RT20260428001931',593,'PAID','2026-04-28 15:10:47','2026-04-28 15:22:47',24.90,'小程序');

INSERT INTO `orders` VALUES (1932,'RT20260428001932',481,'PAID','2026-04-28 16:47:00','2026-04-28 17:44:00',39.90,'小程序');

INSERT INTO `orders` VALUES (1933,'RT20260428001933',455,'PAID','2026-04-28 17:18:45','2026-04-28 17:39:45',29.61,'线下门店');

INSERT INTO `orders` VALUES (1934,'RT20260428001934',169,'PAID','2026-04-28 18:29:00','2026-04-28 19:20:00',29.61,'线下门店');

INSERT INTO `orders` VALUES (1935,'RT20260428001935',158,'PAID','2026-04-28 20:14:55','2026-04-28 21:18:55',164.30,'线下门店');

INSERT INTO `orders` VALUES (1936,'RT20260429001936',6,'PAID','2026-04-29 10:41:10','2026-04-29 11:53:10',169.00,'小程序');

INSERT INTO `orders` VALUES (1937,'RT20260429001937',12,'PAID','2026-04-29 14:23:47','2026-04-29 15:22:47',198.51,'线下门店');

INSERT INTO `orders` VALUES (1938,'RT20260429001938',34,'CANCELLED','2026-04-29 16:48:16',NULL,121.51,'小程序');

INSERT INTO `orders` VALUES (1939,'RT20260429001939',166,'REFUNDED','2026-04-29 17:28:50','2026-04-29 17:59:50',37.05,'小程序');

INSERT INTO `orders` VALUES (1940,'RT20260429001940',317,'PAID','2026-04-29 18:04:55','2026-04-29 18:30:55',234.96,'官网');

INSERT INTO `orders` VALUES (1941,'RT20260429001941',324,'PAID','2026-04-29 19:45:13','2026-04-29 20:41:13',79.00,'小程序');

INSERT INTO `orders` VALUES (1942,'RT20260430001942',170,'PAID','2026-04-30 10:05:43','2026-04-30 11:18:43',75.81,'官网');

INSERT INTO `orders` VALUES (1943,'RT20260430001943',621,'PAID','2026-04-30 11:19:09','2026-04-30 12:22:09',169.00,'线下门店');

INSERT INTO `orders` VALUES (1944,'RT20260430001944',329,'CANCELLED','2026-04-30 13:32:31',NULL,79.00,'官网');

INSERT INTO `orders` VALUES (1945,'RT20260430001945',443,'PAID','2026-04-30 14:00:35','2026-04-30 14:29:35',664.05,'小程序');

INSERT INTO `orders` VALUES (1946,'RT20260430001946',34,'PAID','2026-04-30 15:26:08','2026-04-30 16:37:08',143.60,'小程序');

INSERT INTO `orders` VALUES (1947,'RT20260430001947',139,'PAID','2026-04-30 19:35:44','2026-04-30 20:44:44',230.55,'小程序');

INSERT INTO `orders` VALUES (1948,'RT20260501001948',552,'PAID','2026-05-01 12:44:33','2026-05-01 13:17:33',218.00,'官网');

INSERT INTO `orders` VALUES (1949,'RT20260501001949',322,'PAID','2026-05-01 17:44:10','2026-05-01 18:48:10',24.90,'官网');

INSERT INTO `orders` VALUES (1950,'RT20260501001950',566,'PAID','2026-05-01 18:03:22','2026-05-01 19:04:22',89.00,'小程序');

INSERT INTO `orders` VALUES (1951,'RT20260501001951',30,'PAID','2026-05-01 18:31:55','2026-05-01 19:37:55',110.26,'小程序');

INSERT INTO `orders` VALUES (1952,'RT20260502001952',162,'PAID','2026-05-02 09:04:34','2026-05-02 09:33:34',65.55,'官网');

INSERT INTO `orders` VALUES (1953,'RT20260502001953',249,'PAID','2026-05-02 10:18:04','2026-05-02 11:05:04',129.41,'小程序');

INSERT INTO `orders` VALUES (1954,'RT20260502001954',626,'PAID','2026-05-02 15:08:54','2026-05-02 15:12:54',294.00,'官网');

INSERT INTO `orders` VALUES (1955,'RT20260502001955',200,'CANCELLED','2026-05-02 17:50:18',NULL,79.00,'小程序');

INSERT INTO `orders` VALUES (1956,'RT20260502001956',48,'PAID','2026-05-02 18:48:16','2026-05-02 19:22:16',39.00,'小程序');

INSERT INTO `orders` VALUES (1957,'RT20260503001957',302,'PAID','2026-05-03 10:20:38','2026-05-03 11:11:38',758.10,'小程序');

INSERT INTO `orders` VALUES (1958,'RT20260503001958',195,'PAID','2026-05-03 10:32:21','2026-05-03 11:25:21',71.90,'线下门店');

INSERT INTO `orders` VALUES (1959,'RT20260503001959',443,'PAID','2026-05-03 13:32:30','2026-05-03 13:34:30',145.05,'企业采购');

INSERT INTO `orders` VALUES (1960,'RT20260503001960',585,'PAID','2026-05-03 13:51:11','2026-05-03 14:28:11',365.90,'线下门店');

INSERT INTO `orders` VALUES (1961,'RT20260503001961',578,'PAID','2026-05-03 14:47:51','2026-05-03 15:39:51',59.00,'企业采购');

INSERT INTO `orders` VALUES (1962,'RT20260503001962',280,'PAID','2026-05-03 15:54:23','2026-05-03 16:02:23',74.10,'小程序');

INSERT INTO `orders` VALUES (1963,'RT20260503001963',387,'CANCELLED','2026-05-03 20:22:04',NULL,144.70,'小程序');

INSERT INTO `orders` VALUES (1964,'RT20260504001964',66,'PAID','2026-05-04 08:43:33','2026-05-04 09:13:33',111.00,'小程序');

INSERT INTO `orders` VALUES (1965,'RT20260504001965',491,'PAID','2026-05-04 10:11:22','2026-05-04 10:57:22',79.00,'小程序');

INSERT INTO `orders` VALUES (1966,'RT20260504001966',63,'PAID','2026-05-04 16:04:22','2026-05-04 16:31:22',116.91,'小程序');

INSERT INTO `orders` VALUES (1967,'RT20260504001967',425,'PAID','2026-05-04 16:16:03','2026-05-04 17:07:03',169.00,'线下门店');

INSERT INTO `orders` VALUES (1968,'RT20260504001968',181,'PAID','2026-05-04 18:02:34','2026-05-04 18:12:34',69.00,'官网');

INSERT INTO `orders` VALUES (1969,'RT20260504001969',109,'PAID','2026-05-04 18:53:45','2026-05-04 19:35:45',64.60,'线下门店');

INSERT INTO `orders` VALUES (1970,'RT20260505001970',171,'PAID','2026-05-05 11:16:36','2026-05-05 11:34:36',399.00,'官网');

INSERT INTO `orders` VALUES (1971,'RT20260505001971',223,'CANCELLED','2026-05-05 12:23:31',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (1972,'RT20260505001972',71,'PAID','2026-05-05 12:47:55','2026-05-05 12:59:55',118.90,'官网');

INSERT INTO `orders` VALUES (1973,'RT20260505001973',116,'PAID','2026-05-05 15:28:41','2026-05-05 15:54:41',78.90,'官网');

INSERT INTO `orders` VALUES (1974,'RT20260505001974',58,'PAID','2026-05-05 18:32:58','2026-05-05 19:40:58',39.00,'小程序');

INSERT INTO `orders` VALUES (1975,'RT20260505001975',64,'PAID','2026-05-05 18:45:36','2026-05-05 19:33:36',68.00,'小程序');

INSERT INTO `orders` VALUES (1976,'RT20260505001976',85,'PAID','2026-05-05 20:35:31','2026-05-05 20:43:31',56.05,'小程序');

INSERT INTO `orders` VALUES (1977,'RT20260506001977',58,'PAID','2026-05-06 09:21:29','2026-05-06 09:44:29',22.41,'小程序');

INSERT INTO `orders` VALUES (1978,'RT20260506001978',41,'PAID','2026-05-06 10:09:45','2026-05-06 11:05:45',299.00,'官网');

INSERT INTO `orders` VALUES (1979,'RT20260506001979',607,'PAID','2026-05-06 11:06:47','2026-05-06 11:43:47',72.80,'小程序');

INSERT INTO `orders` VALUES (1980,'RT20260506001980',335,'PAID','2026-05-06 12:08:32','2026-05-06 12:29:32',138.80,'小程序');

INSERT INTO `orders` VALUES (1981,'RT20260506001981',534,'PAID','2026-05-06 12:21:29','2026-05-06 13:06:29',32.90,'官网');

INSERT INTO `orders` VALUES (1982,'RT20260506001982',150,'PAID','2026-05-06 13:00:27','2026-05-06 14:04:27',338.00,'企业采购');

INSERT INTO `orders` VALUES (1983,'RT20260506001983',223,'PAID','2026-05-06 13:01:37','2026-05-06 13:55:37',65.80,'线下门店');

INSERT INTO `orders` VALUES (1984,'RT20260506001984',236,'PAID','2026-05-06 15:37:28','2026-05-06 16:05:28',32.90,'小程序');

INSERT INTO `orders` VALUES (1985,'RT20260506001985',86,'PAID','2026-05-06 16:23:52','2026-05-06 16:56:52',68.00,'官网');

INSERT INTO `orders` VALUES (1986,'RT20260506001986',220,'PAID','2026-05-06 17:28:02','2026-05-06 18:10:02',247.90,'小程序');

INSERT INTO `orders` VALUES (1987,'RT20260506001987',499,'PAID','2026-05-06 17:57:27','2026-05-06 18:29:27',89.00,'线下门店');

INSERT INTO `orders` VALUES (1988,'RT20260506001988',100,'PAID','2026-05-06 17:58:56','2026-05-06 18:28:56',49.80,'企业采购');

INSERT INTO `orders` VALUES (1989,'RT20260506001989',632,'PAID','2026-05-06 18:10:19','2026-05-06 18:21:19',136.00,'线下门店');

INSERT INTO `orders` VALUES (1990,'RT20260506001990',126,'CANCELLED','2026-05-06 18:42:22',NULL,136.00,'官网');

INSERT INTO `orders` VALUES (1991,'RT20260506001991',3,'PAID','2026-05-06 21:19:12','2026-05-06 21:53:12',39.90,'企业采购');

INSERT INTO `orders` VALUES (1992,'RT20260507001992',304,'PAID','2026-05-07 11:19:13','2026-05-07 11:22:13',89.00,'官网');

INSERT INTO `orders` VALUES (1993,'RT20260507001993',33,'PAID','2026-05-07 12:13:54','2026-05-07 12:52:54',39.90,'线下门店');

INSERT INTO `orders` VALUES (1994,'RT20260507001994',492,'PAID','2026-05-07 14:50:03','2026-05-07 15:21:03',68.00,'小程序');

INSERT INTO `orders` VALUES (1995,'RT20260507001995',181,'PAID','2026-05-07 17:32:53','2026-05-07 18:15:53',24.90,'线下门店');

INSERT INTO `orders` VALUES (1996,'RT20260507001996',126,'PAID','2026-05-07 17:43:03','2026-05-07 18:13:03',136.80,'线下门店');

INSERT INTO `orders` VALUES (1997,'RT20260507001997',206,'PAID','2026-05-07 21:04:41','2026-05-07 22:15:41',258.00,'企业采购');

INSERT INTO `orders` VALUES (1998,'RT20260507001998',599,'PAID','2026-05-07 22:07:44','2026-05-07 23:01:44',79.00,'小程序');

INSERT INTO `orders` VALUES (1999,'RT20260508001999',480,'PAID','2026-05-08 12:31:43','2026-05-08 12:43:43',188.00,'官网');

INSERT INTO `orders` VALUES (2000,'RT20260508002000',244,'PAID','2026-05-08 17:56:19','2026-05-08 18:12:19',129.00,'小程序');

INSERT INTO `orders` VALUES (2001,'RT20260508002001',36,'REFUNDED','2026-05-08 18:18:45','2026-05-08 19:28:45',397.00,'官网');

INSERT INTO `orders` VALUES (2002,'RT20260508002002',270,'PAID','2026-05-08 19:34:25','2026-05-08 20:32:25',159.00,'官网');

INSERT INTO `orders` VALUES (2003,'RT20260508002003',249,'PAID','2026-05-08 19:59:47','2026-05-08 21:06:47',39.00,'线下门店');

INSERT INTO `orders` VALUES (2004,'RT20260508002004',15,'PAID','2026-05-08 20:54:56','2026-05-08 22:09:56',59.00,'线下门店');

INSERT INTO `orders` VALUES (2005,'RT20260508002005',295,'CANCELLED','2026-05-08 20:57:07',NULL,138.70,'官网');

INSERT INTO `orders` VALUES (2006,'RT20260508002006',22,'PAID','2026-05-08 22:20:31','2026-05-08 23:04:31',206.91,'线下门店');

INSERT INTO `orders` VALUES (2007,'RT20260509002007',31,'PAID','2026-05-09 11:56:57','2026-05-09 12:41:57',169.00,'线下门店');

INSERT INTO `orders` VALUES (2008,'RT20260509002008',4,'PAID','2026-05-09 14:10:13','2026-05-09 15:08:13',39.00,'线下门店');

INSERT INTO `orders` VALUES (2009,'RT20260509002009',348,'PAID','2026-05-09 15:34:13','2026-05-09 16:45:13',59.00,'小程序');

INSERT INTO `orders` VALUES (2010,'RT20260509002010',134,'PAID','2026-05-09 16:27:08','2026-05-09 17:41:08',126.05,'小程序');

INSERT INTO `orders` VALUES (2011,'RT20260509002011',102,'PAID','2026-05-09 16:36:37','2026-05-09 17:01:37',39.90,'线下门店');

INSERT INTO `orders` VALUES (2012,'RT20260509002012',282,'PAID','2026-05-09 16:51:14','2026-05-09 17:16:14',29.61,'小程序');

INSERT INTO `orders` VALUES (2013,'RT20260509002013',406,'CANCELLED','2026-05-09 17:42:41',NULL,118.90,'线下门店');

INSERT INTO `orders` VALUES (2014,'RT20260509002014',328,'PAID','2026-05-09 18:35:28','2026-05-09 19:02:28',152.00,'小程序');

INSERT INTO `orders` VALUES (2015,'RT20260509002015',23,'PAID','2026-05-09 19:24:18','2026-05-09 19:33:18',59.00,'线下门店');

INSERT INTO `orders` VALUES (2016,'RT20260510002016',369,'PAID','2026-05-10 11:09:15','2026-05-10 12:10:15',246.80,'小程序');

INSERT INTO `orders` VALUES (2017,'RT20260510002017',251,'PAID','2026-05-10 11:26:45','2026-05-10 11:42:45',49.80,'官网');

INSERT INTO `orders` VALUES (2018,'RT20260510002018',128,'CANCELLED','2026-05-10 13:27:29',NULL,49.80,'小程序');

INSERT INTO `orders` VALUES (2019,'RT20260510002019',70,'PAID','2026-05-10 17:43:04','2026-05-10 18:39:04',39.90,'线下门店');

INSERT INTO `orders` VALUES (2020,'RT20260510002020',407,'CANCELLED','2026-05-10 19:22:09',NULL,247.00,'小程序');

INSERT INTO `orders` VALUES (2021,'RT20260510002021',191,'PAID','2026-05-10 19:29:20','2026-05-10 19:38:20',35.91,'线下门店');

INSERT INTO `orders` VALUES (2022,'RT20260510002022',268,'CANCELLED','2026-05-10 20:27:57',NULL,699.00,'官网');

INSERT INTO `orders` VALUES (2023,'RT20260511002023',459,'PAID','2026-05-11 12:57:43','2026-05-11 13:06:43',121.91,'线下门店');

INSERT INTO `orders` VALUES (2024,'RT20260511002024',463,'PAID','2026-05-11 13:32:44','2026-05-11 14:31:44',158.10,'官网');

INSERT INTO `orders` VALUES (2025,'RT20260511002025',38,'PAID','2026-05-11 13:52:30','2026-05-11 14:13:30',159.00,'企业采购');

INSERT INTO `orders` VALUES (2026,'RT20260511002026',359,'PAID','2026-05-11 15:55:53','2026-05-11 16:57:53',129.00,'线下门店');

INSERT INTO `orders` VALUES (2027,'RT20260511002027',487,'PAID','2026-05-11 15:58:58','2026-05-11 16:32:58',89.00,'线下门店');

INSERT INTO `orders` VALUES (2028,'RT20260511002028',495,'CANCELLED','2026-05-11 17:04:31',NULL,664.05,'小程序');

INSERT INTO `orders` VALUES (2029,'RT20260511002029',618,'PAID','2026-05-11 18:54:15','2026-05-11 20:02:15',39.00,'小程序');

INSERT INTO `orders` VALUES (2030,'RT20260511002030',409,'PAID','2026-05-11 21:33:56','2026-05-11 22:43:56',467.00,'小程序');

INSERT INTO `orders` VALUES (2031,'RT20260512002031',6,'PAID','2026-05-12 11:01:57','2026-05-12 11:51:57',75.05,'小程序');

INSERT INTO `orders` VALUES (2032,'RT20260512002032',119,'PAID','2026-05-12 11:33:53','2026-05-12 12:06:53',68.00,'线下门店');

INSERT INTO `orders` VALUES (2033,'RT20260512002033',452,'PAID','2026-05-12 13:14:56','2026-05-12 13:33:56',118.80,'官网');

INSERT INTO `orders` VALUES (2034,'RT20260512002034',582,'PAID','2026-05-12 16:34:21','2026-05-12 17:46:21',70.20,'线下门店');

INSERT INTO `orders` VALUES (2035,'RT20260512002035',413,'PAID','2026-05-12 17:39:54','2026-05-12 18:45:54',336.00,'企业采购');

INSERT INTO `orders` VALUES (2036,'RT20260512002036',248,'PAID','2026-05-12 19:28:48','2026-05-12 20:18:48',71.10,'小程序');

INSERT INTO `orders` VALUES (2037,'RT20260512002037',594,'REFUNDED','2026-05-12 19:29:35','2026-05-12 20:02:35',858.00,'小程序');

INSERT INTO `orders` VALUES (2038,'RT20260512002038',445,'PAID','2026-05-12 19:41:16','2026-05-12 19:56:16',59.00,'小程序');

INSERT INTO `orders` VALUES (2039,'RT20260513002039',65,'PAID','2026-05-13 10:27:13','2026-05-13 10:36:13',348.30,'小程序');

INSERT INTO `orders` VALUES (2040,'RT20260513002040',96,'PAID','2026-05-13 10:39:19','2026-05-13 10:50:19',68.00,'小程序');

INSERT INTO `orders` VALUES (2041,'RT20260513002041',445,'PAID','2026-05-13 14:17:39','2026-05-13 14:48:39',59.00,'线下门店');

INSERT INTO `orders` VALUES (2042,'RT20260513002042',240,'PAID','2026-05-13 18:09:36','2026-05-13 19:23:36',151.05,'线下门店');

INSERT INTO `orders` VALUES (2043,'RT20260513002043',201,'PAID','2026-05-13 18:26:26','2026-05-13 19:09:26',59.00,'小程序');

INSERT INTO `orders` VALUES (2044,'RT20260513002044',379,'PAID','2026-05-13 18:56:36','2026-05-13 20:01:36',173.05,'小程序');

INSERT INTO `orders` VALUES (2045,'RT20260513002045',132,'CANCELLED','2026-05-13 18:59:12',NULL,64.60,'小程序');

INSERT INTO `orders` VALUES (2046,'RT20260513002046',24,'REFUNDED','2026-05-13 21:20:54','2026-05-13 21:34:54',497.90,'线下门店');

INSERT INTO `orders` VALUES (2047,'RT20260513002047',49,'PAID','2026-05-13 21:27:55','2026-05-13 22:11:55',203.05,'小程序');

INSERT INTO `orders` VALUES (2048,'RT20260514002048',500,'PAID','2026-05-14 13:55:41','2026-05-14 14:01:41',37.91,'小程序');

INSERT INTO `orders` VALUES (2049,'RT20260514002049',216,'REFUNDED','2026-05-14 15:56:55','2026-05-14 16:38:55',738.75,'小程序');

INSERT INTO `orders` VALUES (2050,'RT20260514002050',558,'PAID','2026-05-14 17:14:09','2026-05-14 18:21:09',24.90,'官网');

INSERT INTO `orders` VALUES (2051,'RT20260514002051',158,'PAID','2026-05-14 17:24:42','2026-05-14 18:15:42',24.90,'线下门店');

INSERT INTO `orders` VALUES (2052,'RT20260514002052',200,'PAID','2026-05-14 19:52:46','2026-05-14 20:26:46',135.05,'官网');

INSERT INTO `orders` VALUES (2053,'RT20260514002053',89,'PAID','2026-05-14 20:03:05','2026-05-14 20:29:05',39.90,'小程序');

INSERT INTO `orders` VALUES (2054,'RT20260514002054',134,'PAID','2026-05-14 21:02:07','2026-05-14 21:55:07',298.00,'小程序');

INSERT INTO `orders` VALUES (2055,'RT20260514002055',160,'PAID','2026-05-14 22:31:38','2026-05-14 23:12:38',393.86,'官网');

INSERT INTO `orders` VALUES (2056,'RT20260514002056',43,'PAID','2026-05-14 22:35:33','2026-05-14 23:06:33',104.70,'线下门店');

INSERT INTO `orders` VALUES (2057,'RT20260515002057',252,'PAID','2026-05-15 11:17:45','2026-05-15 11:44:45',122.55,'线下门店');

INSERT INTO `orders` VALUES (2058,'RT20260515002058',553,'PAID','2026-05-15 12:41:51','2026-05-15 13:35:51',184.30,'小程序');

INSERT INTO `orders` VALUES (2059,'RT20260515002059',77,'PAID','2026-05-15 13:57:12','2026-05-15 14:32:12',299.00,'小程序');

INSERT INTO `orders` VALUES (2060,'RT20260515002060',369,'PAID','2026-05-15 14:23:39','2026-05-15 14:45:39',185.56,'小程序');

INSERT INTO `orders` VALUES (2061,'RT20260515002061',117,'PAID','2026-05-15 16:03:15','2026-05-15 17:08:15',122.55,'小程序');

INSERT INTO `orders` VALUES (2062,'RT20260515002062',202,'PAID','2026-05-15 16:50:52','2026-05-15 17:13:52',32.90,'官网');

INSERT INTO `orders` VALUES (2063,'RT20260515002063',119,'PAID','2026-05-15 17:35:55','2026-05-15 18:26:55',39.90,'官网');

INSERT INTO `orders` VALUES (2064,'RT20260515002064',435,'CANCELLED','2026-05-15 18:00:18',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (2065,'RT20260515002065',144,'PAID','2026-05-15 18:02:31','2026-05-15 19:10:31',403.95,'企业采购');

INSERT INTO `orders` VALUES (2066,'RT20260515002066',406,'PAID','2026-05-15 18:17:10','2026-05-15 19:21:10',64.60,'小程序');

INSERT INTO `orders` VALUES (2067,'RT20260515002067',182,'PAID','2026-05-15 19:55:49','2026-05-15 21:05:49',144.95,'官网');

INSERT INTO `orders` VALUES (2068,'RT20260515002068',37,'PAID','2026-05-15 20:34:45','2026-05-15 21:02:45',32.90,'企业采购');

INSERT INTO `orders` VALUES (2069,'RT20260515002069',304,'PAID','2026-05-15 20:44:30','2026-05-15 21:16:30',277.00,'线下门店');

INSERT INTO `orders` VALUES (2070,'RT20260515002070',206,'PAID','2026-05-15 21:18:04','2026-05-15 22:33:04',129.00,'小程序');

INSERT INTO `orders` VALUES (2071,'RT20260515002071',12,'PAID','2026-05-15 21:24:39','2026-05-15 21:34:39',268.10,'官网');

INSERT INTO `orders` VALUES (2072,'RT20260516002072',157,'PAID','2026-05-16 08:43:55','2026-05-16 09:17:55',62.66,'线下门店');

INSERT INTO `orders` VALUES (2073,'RT20260516002073',51,'CANCELLED','2026-05-16 10:05:56',NULL,59.00,'官网');

INSERT INTO `orders` VALUES (2074,'RT20260516002074',375,'PAID','2026-05-16 13:15:31','2026-05-16 13:35:31',237.00,'官网');

INSERT INTO `orders` VALUES (2075,'RT20260516002075',77,'CANCELLED','2026-05-16 13:28:45',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (2076,'RT20260516002076',289,'CANCELLED','2026-05-16 15:21:11',NULL,56.56,'小程序');

INSERT INTO `orders` VALUES (2077,'RT20260516002077',630,'PAID','2026-05-16 18:01:51','2026-05-16 18:38:51',186.90,'小程序');

INSERT INTO `orders` VALUES (2078,'RT20260517002078',484,'PAID','2026-05-17 08:10:09','2026-05-17 08:23:09',399.00,'线下门店');

INSERT INTO `orders` VALUES (2079,'RT20260517002079',223,'PAID','2026-05-17 09:37:51','2026-05-17 10:47:51',379.05,'小程序');

INSERT INTO `orders` VALUES (2080,'RT20260517002080',279,'CANCELLED','2026-05-17 12:17:59',NULL,68.00,'线下门店');

INSERT INTO `orders` VALUES (2081,'RT20260517002081',347,'PAID','2026-05-17 16:37:56','2026-05-17 16:38:56',39.00,'线下门店');

INSERT INTO `orders` VALUES (2082,'RT20260517002082',74,'PAID','2026-05-17 18:07:00','2026-05-17 19:14:00',39.00,'小程序');

INSERT INTO `orders` VALUES (2083,'RT20260517002083',73,'PAID','2026-05-17 19:19:35','2026-05-17 20:17:35',299.00,'小程序');

INSERT INTO `orders` VALUES (2084,'RT20260517002084',421,'PAID','2026-05-17 19:36:50','2026-05-17 20:19:50',92.90,'线下门店');

INSERT INTO `orders` VALUES (2085,'RT20260518002085',163,'PAID','2026-05-18 09:16:22','2026-05-18 09:56:22',79.80,'官网');

INSERT INTO `orders` VALUES (2086,'RT20260518002086',28,'PAID','2026-05-18 12:04:26','2026-05-18 12:19:26',71.10,'官网');

INSERT INTO `orders` VALUES (2087,'RT20260518002087',217,'PAID','2026-05-18 12:18:58','2026-05-18 13:20:58',56.05,'线下门店');

INSERT INTO `orders` VALUES (2088,'RT20260518002088',232,'CANCELLED','2026-05-18 15:12:58',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (2089,'RT20260518002089',373,'REFUNDED','2026-05-18 17:18:27','2026-05-18 18:32:27',528.00,'小程序');

INSERT INTO `orders` VALUES (2090,'RT20260518002090',362,'PAID','2026-05-18 18:01:37','2026-05-18 18:13:37',209.77,'小程序');

INSERT INTO `orders` VALUES (2091,'RT20260518002091',347,'PAID','2026-05-18 19:04:20','2026-05-18 19:36:20',89.50,'官网');

INSERT INTO `orders` VALUES (2092,'RT20260518002092',129,'PAID','2026-05-18 20:11:59','2026-05-18 21:12:59',79.00,'官网');

INSERT INTO `orders` VALUES (2093,'RT20260518002093',71,'PAID','2026-05-18 21:27:20','2026-05-18 21:46:20',39.90,'线下门店');

INSERT INTO `orders` VALUES (2094,'RT20260519002094',292,'PAID','2026-05-19 11:37:29','2026-05-19 11:57:29',70.20,'官网');

INSERT INTO `orders` VALUES (2095,'RT20260519002095',254,'PAID','2026-05-19 12:05:53','2026-05-19 13:02:53',93.90,'官网');

INSERT INTO `orders` VALUES (2096,'RT20260519002096',406,'PAID','2026-05-19 13:47:03','2026-05-19 14:36:03',423.90,'线下门店');

INSERT INTO `orders` VALUES (2097,'RT20260519002097',98,'PAID','2026-05-19 15:16:58','2026-05-19 16:01:58',39.90,'小程序');

INSERT INTO `orders` VALUES (2098,'RT20260519002098',64,'REFUNDED','2026-05-19 16:00:10','2026-05-19 16:15:10',69.17,'官网');

INSERT INTO `orders` VALUES (2099,'RT20260519002099',142,'PAID','2026-05-19 17:56:12','2026-05-19 19:06:12',32.90,'企业采购');

INSERT INTO `orders` VALUES (2100,'RT20260520002100',348,'CANCELLED','2026-05-20 11:47:48',NULL,61.20,'官网');

INSERT INTO `orders` VALUES (2101,'RT20260520002101',482,'PAID','2026-05-20 12:57:13','2026-05-20 13:04:13',66.66,'线下门店');

INSERT INTO `orders` VALUES (2102,'RT20260520002102',62,'PAID','2026-05-20 15:28:55','2026-05-20 15:32:55',68.00,'官网');

INSERT INTO `orders` VALUES (2103,'RT20260520002103',149,'PAID','2026-05-20 16:30:08','2026-05-20 17:19:08',79.00,'小程序');

INSERT INTO `orders` VALUES (2104,'RT20260520002104',509,'PAID','2026-05-20 16:47:55','2026-05-20 17:30:55',35.10,'线下门店');

INSERT INTO `orders` VALUES (2105,'RT20260520002105',162,'PAID','2026-05-20 18:36:29','2026-05-20 19:28:29',89.00,'小程序');

INSERT INTO `orders` VALUES (2106,'RT20260520002106',279,'PAID','2026-05-20 19:12:56','2026-05-20 19:52:56',24.90,'小程序');

INSERT INTO `orders` VALUES (2107,'RT20260520002107',316,'CANCELLED','2026-05-20 20:12:54',NULL,59.00,'小程序');

INSERT INTO `orders` VALUES (2108,'RT20260520002108',356,'CANCELLED','2026-05-20 21:35:21',NULL,431.90,'线下门店');

INSERT INTO `orders` VALUES (2109,'RT20260521002109',10,'PAID','2026-05-21 10:10:43','2026-05-21 10:32:43',158.00,'线下门店');

INSERT INTO `orders` VALUES (2110,'RT20260521002110',13,'PAID','2026-05-21 11:45:40','2026-05-21 12:08:40',71.10,'小程序');

INSERT INTO `orders` VALUES (2111,'RT20260521002111',220,'PAID','2026-05-21 13:50:46','2026-05-21 14:14:46',121.51,'小程序');

INSERT INTO `orders` VALUES (2112,'RT20260521002112',231,'PAID','2026-05-21 14:35:42','2026-05-21 15:04:42',269.10,'线下门店');

INSERT INTO `orders` VALUES (2113,'RT20260521002113',52,'CANCELLED','2026-05-21 17:01:06',NULL,143.55,'线下门店');

INSERT INTO `orders` VALUES (2114,'RT20260521002114',263,'PAID','2026-05-21 18:58:22','2026-05-21 19:16:22',68.00,'小程序');

INSERT INTO `orders` VALUES (2115,'RT20260521002115',99,'PAID','2026-05-21 19:03:33','2026-05-21 19:26:33',129.00,'官网');

INSERT INTO `orders` VALUES (2116,'RT20260521002116',48,'PAID','2026-05-21 19:25:34','2026-05-21 20:10:34',123.55,'线下门店');

INSERT INTO `orders` VALUES (2117,'RT20260521002117',68,'PAID','2026-05-21 19:26:36','2026-05-21 20:32:36',56.05,'小程序');

INSERT INTO `orders` VALUES (2118,'RT20260521002118',93,'PAID','2026-05-21 19:53:43','2026-05-21 21:06:43',37.05,'线下门店');

INSERT INTO `orders` VALUES (2119,'RT20260522002119',73,'PAID','2026-05-22 13:26:49','2026-05-22 14:18:49',24.90,'官网');

INSERT INTO `orders` VALUES (2120,'RT20260522002120',104,'PAID','2026-05-22 14:15:00','2026-05-22 15:09:00',39.00,'官网');

INSERT INTO `orders` VALUES (2121,'RT20260522002121',188,'PAID','2026-05-22 15:39:00','2026-05-22 16:46:00',78.00,'线下门店');

INSERT INTO `orders` VALUES (2122,'RT20260522002122',171,'PAID','2026-05-22 15:57:40','2026-05-22 16:03:40',37.91,'官网');

INSERT INTO `orders` VALUES (2123,'RT20260522002123',157,'PAID','2026-05-22 16:28:52','2026-05-22 16:53:52',79.80,'线下门店');

INSERT INTO `orders` VALUES (2124,'RT20260522002124',164,'PAID','2026-05-22 19:36:47','2026-05-22 20:31:47',64.60,'线下门店');

INSERT INTO `orders` VALUES (2125,'RT20260522002125',279,'PAID','2026-05-22 19:51:16','2026-05-22 20:09:16',98.70,'小程序');

INSERT INTO `orders` VALUES (2126,'RT20260522002126',140,'PAID','2026-05-22 20:53:34','2026-05-22 20:56:34',338.00,'企业采购');

INSERT INTO `orders` VALUES (2127,'RT20260522002127',441,'PAID','2026-05-22 21:02:15','2026-05-22 21:31:15',59.00,'线下门店');

INSERT INTO `orders` VALUES (2128,'RT20260523002128',108,'PAID','2026-05-23 08:43:52','2026-05-23 09:36:52',24.90,'小程序');

INSERT INTO `orders` VALUES (2129,'RT20260523002129',74,'PAID','2026-05-23 13:21:38','2026-05-23 14:08:38',79.00,'小程序');

INSERT INTO `orders` VALUES (2130,'RT20260523002130',13,'PAID','2026-05-23 14:02:18','2026-05-23 14:08:18',160.55,'小程序');

INSERT INTO `orders` VALUES (2131,'RT20260523002131',252,'PAID','2026-05-23 15:02:26','2026-05-23 15:44:26',1151.05,'小程序');

INSERT INTO `orders` VALUES (2132,'RT20260523002132',92,'PAID','2026-05-23 18:25:34','2026-05-23 18:44:34',117.00,'企业采购');

INSERT INTO `orders` VALUES (2133,'RT20260524002133',554,'PAID','2026-05-24 10:06:35','2026-05-24 10:31:35',32.90,'线下门店');

INSERT INTO `orders` VALUES (2134,'RT20260524002134',122,'PAID','2026-05-24 12:13:33','2026-05-24 12:56:33',129.00,'小程序');

INSERT INTO `orders` VALUES (2135,'RT20260524002135',125,'PAID','2026-05-24 13:04:31','2026-05-24 13:37:31',39.00,'小程序');

INSERT INTO `orders` VALUES (2136,'RT20260524002136',46,'PAID','2026-05-24 13:05:30','2026-05-24 13:09:30',71.10,'小程序');

INSERT INTO `orders` VALUES (2137,'RT20260524002137',318,'PAID','2026-05-24 13:15:44','2026-05-24 14:07:44',68.00,'官网');

INSERT INTO `orders` VALUES (2138,'RT20260524002138',413,'PAID','2026-05-24 14:30:56','2026-05-24 14:59:56',98.90,'线下门店');

INSERT INTO `orders` VALUES (2139,'RT20260524002139',249,'PAID','2026-05-24 15:24:20','2026-05-24 15:51:20',169.00,'线下门店');

INSERT INTO `orders` VALUES (2140,'RT20260525002140',84,'REFUNDED','2026-05-25 11:05:26','2026-05-25 11:39:26',798.00,'小程序');

INSERT INTO `orders` VALUES (2141,'RT20260525002141',27,'PAID','2026-05-25 12:02:23','2026-05-25 12:43:23',208.00,'线下门店');

INSERT INTO `orders` VALUES (2142,'RT20260525002142',545,'PAID','2026-05-25 18:33:27','2026-05-25 18:37:27',24.90,'官网');

INSERT INTO `orders` VALUES (2143,'RT20260525002143',43,'PAID','2026-05-25 18:53:58','2026-05-25 19:51:58',39.00,'线下门店');

INSERT INTO `orders` VALUES (2144,'RT20260525002144',286,'PAID','2026-05-25 19:23:33','2026-05-25 19:59:33',56.05,'线下门店');

INSERT INTO `orders` VALUES (2145,'RT20260526002145',517,'CANCELLED','2026-05-26 09:14:54',NULL,75.05,'小程序');

INSERT INTO `orders` VALUES (2146,'RT20260526002146',19,'PAID','2026-05-26 09:28:32','2026-05-26 10:24:32',64.60,'小程序');

INSERT INTO `orders` VALUES (2147,'RT20260526002147',461,'PAID','2026-05-26 10:18:50','2026-05-26 11:09:50',79.00,'小程序');

INSERT INTO `orders` VALUES (2148,'RT20260526002148',77,'PAID','2026-05-26 11:27:10','2026-05-26 12:21:10',158.00,'小程序');

INSERT INTO `orders` VALUES (2149,'RT20260526002149',190,'CANCELLED','2026-05-26 11:39:27',NULL,54.92,'线下门店');

INSERT INTO `orders` VALUES (2150,'RT20260526002150',224,'PAID','2026-05-26 12:18:27','2026-05-26 12:55:27',39.90,'小程序');

INSERT INTO `orders` VALUES (2151,'RT20260526002151',161,'PAID','2026-05-26 13:20:55','2026-05-26 13:59:55',64.60,'企业采购');

INSERT INTO `orders` VALUES (2152,'RT20260526002152',222,'PAID','2026-05-26 13:35:11','2026-05-26 13:52:11',39.00,'小程序');

INSERT INTO `orders` VALUES (2153,'RT20260526002153',627,'PAID','2026-05-26 14:46:12','2026-05-26 15:58:12',111.90,'小程序');

INSERT INTO `orders` VALUES (2154,'RT20260526002154',284,'CANCELLED','2026-05-26 14:55:46',NULL,32.90,'线下门店');

INSERT INTO `orders` VALUES (2155,'RT20260526002155',185,'CANCELLED','2026-05-26 15:13:36',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (2156,'RT20260526002156',256,'PAID','2026-05-26 17:20:12','2026-05-26 18:30:12',39.00,'小程序');

INSERT INTO `orders` VALUES (2157,'RT20260526002157',165,'PAID','2026-05-26 19:32:21','2026-05-26 20:27:21',68.00,'小程序');

INSERT INTO `orders` VALUES (2158,'RT20260526002158',410,'PAID','2026-05-26 20:09:13','2026-05-26 20:16:13',57.80,'线下门店');

INSERT INTO `orders` VALUES (2159,'RT20260526002159',77,'PAID','2026-05-26 22:30:05','2026-05-26 23:05:05',100.90,'小程序');

INSERT INTO `orders` VALUES (2160,'RT20260527002160',222,'PAID','2026-05-27 09:51:28','2026-05-27 10:28:28',64.60,'企业采购');

INSERT INTO `orders` VALUES (2161,'RT20260527002161',304,'PAID','2026-05-27 10:10:07','2026-05-27 10:12:07',129.00,'小程序');

INSERT INTO `orders` VALUES (2162,'RT20260527002162',80,'PAID','2026-05-27 14:35:19','2026-05-27 15:03:19',69.00,'小程序');

INSERT INTO `orders` VALUES (2163,'RT20260527002163',465,'PAID','2026-05-27 15:14:23','2026-05-27 15:41:23',152.66,'小程序');

INSERT INTO `orders` VALUES (2164,'RT20260527002164',149,'PAID','2026-05-27 19:09:15','2026-05-27 19:13:15',68.00,'官网');

INSERT INTO `orders` VALUES (2165,'RT20260527002165',314,'CANCELLED','2026-05-27 19:18:03',NULL,169.00,'官网');

INSERT INTO `orders` VALUES (2166,'RT20260527002166',423,'PAID','2026-05-27 21:38:59','2026-05-27 22:02:59',37.91,'官网');

INSERT INTO `orders` VALUES (2167,'RT20260528002167',342,'CANCELLED','2026-05-28 10:49:22',NULL,196.00,'官网');

INSERT INTO `orders` VALUES (2168,'RT20260528002168',465,'PAID','2026-05-28 12:25:13','2026-05-28 13:13:13',110.82,'线下门店');

INSERT INTO `orders` VALUES (2169,'RT20260528002169',12,'PAID','2026-05-28 12:49:10','2026-05-28 13:32:10',103.60,'小程序');

INSERT INTO `orders` VALUES (2170,'RT20260528002170',276,'PAID','2026-05-28 13:25:15','2026-05-28 13:35:15',107.00,'官网');

INSERT INTO `orders` VALUES (2171,'RT20260528002171',13,'PAID','2026-05-28 15:05:59','2026-05-28 15:39:59',39.00,'小程序');

INSERT INTO `orders` VALUES (2172,'RT20260528002172',312,'PAID','2026-05-28 15:19:31','2026-05-28 16:31:31',299.00,'小程序');

INSERT INTO `orders` VALUES (2173,'RT20260529002173',414,'CANCELLED','2026-05-29 11:58:20',NULL,159.00,'小程序');

INSERT INTO `orders` VALUES (2174,'RT20260529002174',439,'PAID','2026-05-29 12:35:11','2026-05-29 13:45:11',64.60,'企业采购');

INSERT INTO `orders` VALUES (2175,'RT20260529002175',145,'PAID','2026-05-29 12:35:39','2026-05-29 13:22:39',137.00,'小程序');

INSERT INTO `orders` VALUES (2176,'RT20260529002176',31,'PAID','2026-05-29 15:23:39','2026-05-29 16:05:39',64.60,'小程序');

INSERT INTO `orders` VALUES (2177,'RT20260529002177',25,'PAID','2026-05-29 15:44:52','2026-05-29 16:55:52',767.00,'小程序');

INSERT INTO `orders` VALUES (2178,'RT20260529002178',70,'CANCELLED','2026-05-29 16:35:22',NULL,104.50,'官网');

INSERT INTO `orders` VALUES (2179,'RT20260529002179',118,'PAID','2026-05-29 17:36:37','2026-05-29 18:46:37',68.00,'小程序');

INSERT INTO `orders` VALUES (2180,'RT20260529002180',205,'PAID','2026-05-29 18:30:04','2026-05-29 19:08:04',35.10,'官网');

INSERT INTO `orders` VALUES (2181,'RT20260529002181',391,'PAID','2026-05-29 18:37:35','2026-05-29 19:51:35',39.90,'线下门店');

INSERT INTO `orders` VALUES (2182,'RT20260529002182',290,'CANCELLED','2026-05-29 19:47:21',NULL,138.20,'线下门店');

INSERT INTO `orders` VALUES (2183,'RT20260529002183',545,'PAID','2026-05-29 20:33:02','2026-05-29 21:22:02',1006.90,'官网');

INSERT INTO `orders` VALUES (2184,'RT20260530002184',171,'PAID','2026-05-30 10:21:12','2026-05-30 11:32:12',4299.00,'官网');

INSERT INTO `orders` VALUES (2185,'RT20260530002185',391,'PAID','2026-05-30 11:04:16','2026-05-30 11:38:16',118.80,'线下门店');

INSERT INTO `orders` VALUES (2186,'RT20260530002186',333,'PAID','2026-05-30 11:16:39','2026-05-30 12:12:39',69.00,'官网');

INSERT INTO `orders` VALUES (2187,'RT20260530002187',215,'PAID','2026-05-30 11:38:51','2026-05-30 12:40:51',75.05,'小程序');

INSERT INTO `orders` VALUES (2188,'RT20260530002188',3,'PAID','2026-05-30 11:39:12','2026-05-30 12:27:12',69.00,'线下门店');

INSERT INTO `orders` VALUES (2189,'RT20260530002189',530,'PAID','2026-05-30 12:47:18','2026-05-30 12:52:18',39.90,'线下门店');

INSERT INTO `orders` VALUES (2190,'RT20260530002190',327,'PAID','2026-05-30 13:58:00','2026-05-30 14:15:00',59.00,'线下门店');

INSERT INTO `orders` VALUES (2191,'RT20260530002191',41,'PAID','2026-05-30 15:08:47','2026-05-30 15:21:47',32.90,'线下门店');

INSERT INTO `orders` VALUES (2192,'RT20260530002192',161,'PAID','2026-05-30 15:53:22','2026-05-30 16:25:22',22.41,'线下门店');

INSERT INTO `orders` VALUES (2193,'RT20260530002193',119,'PAID','2026-05-30 18:51:38','2026-05-30 20:04:38',100.90,'线下门店');

INSERT INTO `orders` VALUES (2194,'RT20260530002194',58,'PAID','2026-05-30 20:01:51','2026-05-30 20:11:51',207.90,'官网');

INSERT INTO `orders` VALUES (2195,'RT20260530002195',69,'PAID','2026-05-30 21:43:40','2026-05-30 22:55:40',37.05,'线下门店');

INSERT INTO `orders` VALUES (2196,'RT20260531002196',58,'PAID','2026-05-31 11:28:02','2026-05-31 12:27:02',39.90,'线下门店');

INSERT INTO `orders` VALUES (2197,'RT20260531002197',437,'REFUNDED','2026-05-31 12:04:20','2026-05-31 12:39:20',59.00,'线下门店');

INSERT INTO `orders` VALUES (2198,'RT20260531002198',213,'PAID','2026-05-31 12:15:47','2026-05-31 13:14:47',131.10,'企业采购');

INSERT INTO `orders` VALUES (2199,'RT20260531002199',276,'PAID','2026-05-31 14:42:34','2026-05-31 14:52:34',68.00,'小程序');

INSERT INTO `orders` VALUES (2200,'RT20260531002200',6,'PAID','2026-05-31 15:05:22','2026-05-31 15:10:22',127.00,'小程序');

INSERT INTO `orders` VALUES (2201,'RT20260531002201',569,'PAID','2026-05-31 17:39:50','2026-05-31 17:42:50',190.55,'小程序');

INSERT INTO `orders` VALUES (2202,'RT20260531002202',350,'PAID','2026-05-31 19:32:46','2026-05-31 20:35:46',65.55,'官网');

INSERT INTO `orders` VALUES (2203,'RT20260531002203',12,'PAID','2026-05-31 20:00:27','2026-05-31 21:07:27',118.00,'小程序');

INSERT INTO `orders` VALUES (2204,'RT20260531002204',79,'PAID','2026-05-31 21:42:10','2026-05-31 21:43:10',39.90,'小程序');

INSERT INTO `orders` VALUES (2205,'RT20260531002205',348,'PAID','2026-05-31 21:42:32','2026-05-31 21:58:32',84.55,'小程序');

INSERT INTO `orders` VALUES (2206,'RT20260601002206',333,'PAID','2026-06-01 13:58:50','2026-06-01 14:42:50',39.90,'线下门店');

INSERT INTO `orders` VALUES (2207,'RT20260601002207',501,'PAID','2026-06-01 14:01:55','2026-06-01 15:11:55',78.00,'线下门店');

INSERT INTO `orders` VALUES (2208,'RT20260601002208',287,'PAID','2026-06-01 14:17:49','2026-06-01 14:53:49',35.91,'官网');

INSERT INTO `orders` VALUES (2209,'RT20260601002209',287,'REFUNDED','2026-06-01 15:14:38','2026-06-01 16:26:38',79.00,'小程序');

INSERT INTO `orders` VALUES (2210,'RT20260601002210',236,'PAID','2026-06-01 15:56:30','2026-06-01 17:10:30',198.46,'线下门店');

INSERT INTO `orders` VALUES (2211,'RT20260601002211',317,'PAID','2026-06-01 18:04:01','2026-06-01 19:00:01',39.90,'小程序');

INSERT INTO `orders` VALUES (2212,'RT20260601002212',390,'PAID','2026-06-01 18:17:18','2026-06-01 19:02:18',59.00,'线下门店');

INSERT INTO `orders` VALUES (2213,'RT20260601002213',76,'PAID','2026-06-01 18:18:09','2026-06-01 18:21:09',399.00,'小程序');

INSERT INTO `orders` VALUES (2214,'RT20260601002214',514,'REFUNDED','2026-06-01 18:18:27','2026-06-01 18:20:27',83.90,'小程序');

INSERT INTO `orders` VALUES (2215,'RT20260601002215',538,'PAID','2026-06-01 19:41:30','2026-06-01 19:58:30',65.80,'小程序');

INSERT INTO `orders` VALUES (2216,'RT20260601002216',112,'PAID','2026-06-01 19:54:08','2026-06-01 20:15:08',936.05,'线下门店');

INSERT INTO `orders` VALUES (2217,'RT20260601002217',92,'CANCELLED','2026-06-01 21:56:43',NULL,59.00,'小程序');

INSERT INTO `orders` VALUES (2218,'RT20260602002218',60,'PAID','2026-06-02 09:39:32','2026-06-02 10:25:32',35.10,'官网');

INSERT INTO `orders` VALUES (2219,'RT20260602002219',128,'PAID','2026-06-02 10:20:21','2026-06-02 10:45:21',23.66,'线下门店');

INSERT INTO `orders` VALUES (2220,'RT20260602002220',5,'PAID','2026-06-02 10:44:22','2026-06-02 11:44:22',169.00,'小程序');

INSERT INTO `orders` VALUES (2221,'RT20260602002221',75,'PAID','2026-06-02 11:54:04','2026-06-02 12:34:04',32.90,'小程序');

INSERT INTO `orders` VALUES (2222,'RT20260602002222',463,'PAID','2026-06-02 12:45:08','2026-06-02 13:59:08',90.41,'小程序');

INSERT INTO `orders` VALUES (2223,'RT20260602002223',528,'PAID','2026-06-02 13:36:57','2026-06-02 14:22:57',233.10,'官网');

INSERT INTO `orders` VALUES (2224,'RT20260602002224',294,'PAID','2026-06-02 13:57:44','2026-06-02 15:03:44',126.91,'官网');

INSERT INTO `orders` VALUES (2225,'RT20260602002225',197,'PAID','2026-06-02 15:42:56','2026-06-02 15:46:56',39.90,'小程序');

INSERT INTO `orders` VALUES (2226,'RT20260602002226',311,'PAID','2026-06-02 15:49:06','2026-06-02 16:58:06',72.80,'小程序');

INSERT INTO `orders` VALUES (2227,'RT20260602002227',12,'PAID','2026-06-02 16:14:42','2026-06-02 16:20:42',68.00,'小程序');

INSERT INTO `orders` VALUES (2228,'RT20260602002228',530,'PAID','2026-06-02 16:44:23','2026-06-02 17:00:23',114.95,'小程序');

INSERT INTO `orders` VALUES (2229,'RT20260602002229',431,'PAID','2026-06-02 17:09:32','2026-06-02 17:15:32',169.00,'小程序');

INSERT INTO `orders` VALUES (2230,'RT20260602002230',76,'PAID','2026-06-02 17:18:38','2026-06-02 18:23:38',39.00,'官网');

INSERT INTO `orders` VALUES (2231,'RT20260602002231',496,'PAID','2026-06-02 17:29:09','2026-06-02 18:33:09',39.90,'小程序');

INSERT INTO `orders` VALUES (2232,'RT20260602002232',385,'CANCELLED','2026-06-02 17:30:00',NULL,75.05,'线下门店');

INSERT INTO `orders` VALUES (2233,'RT20260602002233',136,'PAID','2026-06-02 18:49:36','2026-06-02 19:52:36',68.00,'官网');

INSERT INTO `orders` VALUES (2234,'RT20260602002234',13,'CANCELLED','2026-06-02 19:02:10',NULL,39.00,'线下门店');

INSERT INTO `orders` VALUES (2235,'RT20260602002235',63,'PAID','2026-06-02 19:43:45','2026-06-02 20:18:45',24.90,'线下门店');

INSERT INTO `orders` VALUES (2236,'RT20260602002236',76,'PAID','2026-06-02 20:10:45','2026-06-02 20:37:45',39.00,'线下门店');

INSERT INTO `orders` VALUES (2237,'RT20260602002237',361,'PAID','2026-06-02 20:27:32','2026-06-02 21:28:32',378.00,'线下门店');

INSERT INTO `orders` VALUES (2238,'RT20260602002238',101,'PAID','2026-06-02 20:29:23','2026-06-02 21:10:23',153.90,'官网');

INSERT INTO `orders` VALUES (2239,'RT20260602002239',30,'PAID','2026-06-02 20:33:06','2026-06-02 21:48:06',89.00,'线下门店');

INSERT INTO `orders` VALUES (2240,'RT20260602002240',130,'PAID','2026-06-02 21:57:02','2026-06-02 22:58:02',159.00,'小程序');

INSERT INTO `orders` VALUES (2241,'RT20260603002241',543,'REFUNDED','2026-06-03 10:24:24','2026-06-03 10:50:24',199.00,'线下门店');

INSERT INTO `orders` VALUES (2242,'RT20260603002242',412,'PAID','2026-06-03 10:41:08','2026-06-03 11:16:08',205.00,'小程序');

INSERT INTO `orders` VALUES (2243,'RT20260603002243',538,'PAID','2026-06-03 11:24:08','2026-06-03 11:52:08',39.90,'企业采购');

INSERT INTO `orders` VALUES (2244,'RT20260603002244',46,'PAID','2026-06-03 11:31:14','2026-06-03 11:38:14',39.90,'线下门店');

INSERT INTO `orders` VALUES (2245,'RT20260603002245',386,'PAID','2026-06-03 14:34:26','2026-06-03 15:12:26',39.90,'官网');

INSERT INTO `orders` VALUES (2246,'RT20260603002246',121,'CANCELLED','2026-06-03 17:22:53',NULL,39.90,'线下门店');

INSERT INTO `orders` VALUES (2247,'RT20260603002247',236,'PAID','2026-06-03 17:42:06','2026-06-03 18:34:06',231.90,'小程序');

INSERT INTO `orders` VALUES (2248,'RT20260603002248',118,'PAID','2026-06-03 17:52:04','2026-06-03 18:10:04',129.00,'官网');

INSERT INTO `orders` VALUES (2249,'RT20260603002249',237,'CANCELLED','2026-06-03 17:54:24',NULL,93.96,'线下门店');

INSERT INTO `orders` VALUES (2250,'RT20260603002250',536,'REFUNDED','2026-06-03 18:15:13','2026-06-03 19:30:13',39.90,'线下门店');

INSERT INTO `orders` VALUES (2251,'RT20260603002251',105,'PAID','2026-06-03 18:20:33','2026-06-03 18:23:33',122.55,'小程序');

INSERT INTO `orders` VALUES (2252,'RT20260603002252',202,'PAID','2026-06-03 19:08:15','2026-06-03 20:01:15',258.00,'线下门店');

INSERT INTO `orders` VALUES (2253,'RT20260603002253',315,'PAID','2026-06-03 19:16:10','2026-06-03 19:36:10',355.05,'小程序');

INSERT INTO `orders` VALUES (2254,'RT20260603002254',465,'PAID','2026-06-03 20:36:28','2026-06-03 20:55:28',39.00,'线下门店');

INSERT INTO `orders` VALUES (2255,'RT20260603002255',230,'PAID','2026-06-03 21:26:32','2026-06-03 21:31:32',39.90,'线下门店');

INSERT INTO `orders` VALUES (2256,'RT20260604002256',19,'PAID','2026-06-04 10:32:59','2026-06-04 11:01:59',68.00,'小程序');

INSERT INTO `orders` VALUES (2257,'RT20260604002257',566,'REFUNDED','2026-06-04 10:38:00','2026-06-04 11:26:00',89.00,'线下门店');

INSERT INTO `orders` VALUES (2258,'RT20260604002258',477,'PAID','2026-06-04 10:45:09','2026-06-04 11:15:09',144.40,'小程序');

INSERT INTO `orders` VALUES (2259,'RT20260604002259',119,'PAID','2026-06-04 12:33:58','2026-06-04 13:12:58',68.00,'线下门店');

INSERT INTO `orders` VALUES (2260,'RT20260604002260',73,'PAID','2026-06-04 13:54:30','2026-06-04 14:09:30',237.80,'线下门店');

INSERT INTO `orders` VALUES (2261,'RT20260604002261',161,'PAID','2026-06-04 15:24:26','2026-06-04 16:17:26',23.66,'线下门店');

INSERT INTO `orders` VALUES (2262,'RT20260604002262',48,'PAID','2026-06-04 18:05:26','2026-06-04 18:30:26',32.90,'小程序');

INSERT INTO `orders` VALUES (2263,'RT20260604002263',142,'PAID','2026-06-04 18:24:24','2026-06-04 18:56:24',59.00,'官网');

INSERT INTO `orders` VALUES (2264,'RT20260604002264',612,'PAID','2026-06-04 19:02:38','2026-06-04 19:36:38',68.00,'小程序');

INSERT INTO `orders` VALUES (2265,'RT20260604002265',356,'PAID','2026-06-04 21:55:56','2026-06-04 22:01:56',32.90,'小程序');

INSERT INTO `orders` VALUES (2266,'RT20260605002266',209,'PAID','2026-06-05 09:17:18','2026-06-05 10:05:18',49.80,'小程序');

INSERT INTO `orders` VALUES (2267,'RT20260605002267',156,'PAID','2026-06-05 12:11:02','2026-06-05 13:25:02',136.00,'小程序');

INSERT INTO `orders` VALUES (2268,'RT20260605002268',419,'PAID','2026-06-05 12:36:50','2026-06-05 13:51:50',192.56,'线下门店');

INSERT INTO `orders` VALUES (2269,'RT20260605002269',86,'PAID','2026-06-05 14:09:33','2026-06-05 15:06:33',23.66,'官网');

INSERT INTO `orders` VALUES (2270,'RT20260605002270',121,'PAID','2026-06-05 16:30:08','2026-06-05 17:06:08',24.90,'小程序');

INSERT INTO `orders` VALUES (2271,'RT20260605002271',491,'PAID','2026-06-05 16:38:02','2026-06-05 17:21:02',220.05,'小程序');

INSERT INTO `orders` VALUES (2272,'RT20260605002272',144,'PAID','2026-06-05 16:57:16','2026-06-05 17:27:16',63.90,'小程序');

INSERT INTO `orders` VALUES (2273,'RT20260605002273',110,'PAID','2026-06-05 17:50:33','2026-06-05 19:05:33',31.26,'线下门店');

INSERT INTO `orders` VALUES (2274,'RT20260605002274',340,'REFUNDED','2026-06-05 17:55:32','2026-06-05 18:30:32',68.00,'官网');

INSERT INTO `orders` VALUES (2275,'RT20260605002275',526,'CANCELLED','2026-06-05 18:01:56',NULL,138.00,'线下门店');

INSERT INTO `orders` VALUES (2276,'RT20260605002276',374,'PAID','2026-06-05 18:04:50','2026-06-05 18:17:50',39.00,'线下门店');

INSERT INTO `orders` VALUES (2277,'RT20260605002277',172,'PAID','2026-06-05 18:12:03','2026-06-05 18:17:03',23.66,'小程序');

INSERT INTO `orders` VALUES (2278,'RT20260605002278',247,'PAID','2026-06-05 18:48:46','2026-06-05 19:36:46',39.90,'线下门店');

INSERT INTO `orders` VALUES (2279,'RT20260605002279',248,'PAID','2026-06-05 19:00:16','2026-06-05 19:48:16',32.90,'线下门店');

INSERT INTO `orders` VALUES (2280,'RT20260605002280',469,'PAID','2026-06-05 19:28:56','2026-06-05 20:13:56',24.90,'官网');

INSERT INTO `orders` VALUES (2281,'RT20260606002281',102,'PAID','2026-06-06 08:08:31','2026-06-06 08:15:31',68.00,'线下门店');

INSERT INTO `orders` VALUES (2282,'RT20260606002282',23,'CANCELLED','2026-06-06 09:17:18',NULL,486.05,'线下门店');

INSERT INTO `orders` VALUES (2283,'RT20260606002283',261,'PAID','2026-06-06 10:59:12','2026-06-06 12:07:12',185.05,'线下门店');

INSERT INTO `orders` VALUES (2284,'RT20260606002284',16,'PAID','2026-06-06 11:08:00','2026-06-06 11:33:00',305.00,'官网');

INSERT INTO `orders` VALUES (2285,'RT20260606002285',248,'PAID','2026-06-06 11:16:12','2026-06-06 12:12:12',102.85,'小程序');

INSERT INTO `orders` VALUES (2286,'RT20260606002286',306,'PAID','2026-06-06 12:01:24','2026-06-06 12:21:24',169.00,'小程序');

INSERT INTO `orders` VALUES (2287,'RT20260606002287',201,'PAID','2026-06-06 12:06:00','2026-06-06 12:19:00',133.10,'官网');

INSERT INTO `orders` VALUES (2288,'RT20260606002288',202,'PAID','2026-06-06 12:33:13','2026-06-06 13:40:13',386.00,'线下门店');

INSERT INTO `orders` VALUES (2289,'RT20260606002289',217,'PAID','2026-06-06 14:32:22','2026-06-06 15:02:22',24.90,'官网');

INSERT INTO `orders` VALUES (2290,'RT20260606002290',197,'PAID','2026-06-06 14:59:58','2026-06-06 15:58:58',118.00,'小程序');

INSERT INTO `orders` VALUES (2291,'RT20260606002291',47,'PAID','2026-06-06 15:14:33','2026-06-06 16:18:33',75.05,'线下门店');

INSERT INTO `orders` VALUES (2292,'RT20260606002292',77,'PAID','2026-06-06 15:37:07','2026-06-06 15:54:07',258.00,'线下门店');

INSERT INTO `orders` VALUES (2293,'RT20260606002293',147,'PAID','2026-06-06 16:20:37','2026-06-06 17:35:37',70.81,'小程序');

INSERT INTO `orders` VALUES (2294,'RT20260606002294',30,'PAID','2026-06-06 16:31:36','2026-06-06 17:21:36',188.00,'线下门店');

INSERT INTO `orders` VALUES (2295,'RT20260606002295',43,'PAID','2026-06-06 16:34:31','2026-06-06 17:30:31',37.91,'线下门店');

INSERT INTO `orders` VALUES (2296,'RT20260606002296',203,'CANCELLED','2026-06-06 16:40:06',NULL,89.00,'小程序');

INSERT INTO `orders` VALUES (2297,'RT20260606002297',230,'CANCELLED','2026-06-06 16:51:08',NULL,119.81,'小程序');

INSERT INTO `orders` VALUES (2298,'RT20260606002298',150,'PAID','2026-06-06 17:39:29','2026-06-06 18:01:29',32.90,'线下门店');

INSERT INTO `orders` VALUES (2299,'RT20260606002299',428,'PAID','2026-06-06 18:04:01','2026-06-06 18:37:01',414.15,'小程序');

INSERT INTO `orders` VALUES (2300,'RT20260606002300',215,'PAID','2026-06-06 18:20:17','2026-06-06 18:52:17',89.00,'线下门店');

INSERT INTO `orders` VALUES (2301,'RT20260606002301',189,'PAID','2026-06-06 19:23:19','2026-06-06 19:51:19',32.90,'小程序');

INSERT INTO `orders` VALUES (2302,'RT20260606002302',539,'PAID','2026-06-06 19:36:13','2026-06-06 20:35:13',188.00,'小程序');

INSERT INTO `orders` VALUES (2303,'RT20260606002303',391,'PAID','2026-06-06 20:21:10','2026-06-06 21:16:10',199.00,'小程序');

INSERT INTO `orders` VALUES (2304,'RT20260607002304',119,'PAID','2026-06-07 09:47:09','2026-06-07 10:56:09',35.91,'线下门店');

INSERT INTO `orders` VALUES (2305,'RT20260607002305',534,'PAID','2026-06-07 11:47:32','2026-06-07 12:41:32',274.91,'小程序');

INSERT INTO `orders` VALUES (2306,'RT20260607002306',160,'PAID','2026-06-07 12:14:16','2026-06-07 12:39:16',68.00,'小程序');

INSERT INTO `orders` VALUES (2307,'RT20260607002307',383,'CANCELLED','2026-06-07 13:24:52',NULL,98.00,'小程序');

INSERT INTO `orders` VALUES (2308,'RT20260607002308',311,'PAID','2026-06-07 15:03:23','2026-06-07 16:00:23',187.00,'线下门店');

INSERT INTO `orders` VALUES (2309,'RT20260607002309',337,'PAID','2026-06-07 15:42:36','2026-06-07 16:44:36',225.91,'官网');

INSERT INTO `orders` VALUES (2310,'RT20260607002310',220,'PAID','2026-06-07 17:29:39','2026-06-07 17:41:39',68.00,'小程序');

INSERT INTO `orders` VALUES (2311,'RT20260607002311',525,'CANCELLED','2026-06-07 18:19:49',NULL,68.00,'线下门店');

INSERT INTO `orders` VALUES (2312,'RT20260607002312',306,'PAID','2026-06-07 18:41:26','2026-06-07 19:44:26',39.00,'企业采购');

INSERT INTO `orders` VALUES (2313,'RT20260607002313',181,'PAID','2026-06-07 18:54:58','2026-06-07 19:22:58',275.10,'官网');

INSERT INTO `orders` VALUES (2314,'RT20260607002314',476,'PAID','2026-06-07 18:56:54','2026-06-07 19:13:54',76.91,'线下门店');

INSERT INTO `orders` VALUES (2315,'RT20260607002315',28,'PAID','2026-06-07 20:10:16','2026-06-07 21:04:16',86.85,'小程序');

INSERT INTO `orders` VALUES (2316,'RT20260607002316',183,'PAID','2026-06-07 21:00:40','2026-06-07 22:05:40',37.05,'企业采购');

INSERT INTO `orders` VALUES (2317,'RT20260608002317',212,'PAID','2026-06-08 11:21:39','2026-06-08 12:24:39',122.55,'官网');

INSERT INTO `orders` VALUES (2318,'RT20260608002318',213,'PAID','2026-06-08 12:23:47','2026-06-08 13:11:47',92.90,'小程序');

INSERT INTO `orders` VALUES (2319,'RT20260608002319',477,'PAID','2026-06-08 15:31:41','2026-06-08 15:52:41',113.96,'小程序');

INSERT INTO `orders` VALUES (2320,'RT20260608002320',92,'PAID','2026-06-08 15:37:11','2026-06-08 16:15:11',160.55,'小程序');

INSERT INTO `orders` VALUES (2321,'RT20260608002321',8,'PAID','2026-06-08 15:54:38','2026-06-08 16:43:38',568.00,'小程序');

INSERT INTO `orders` VALUES (2322,'RT20260608002322',380,'PAID','2026-06-08 16:07:23','2026-06-08 17:20:23',59.00,'线下门店');

INSERT INTO `orders` VALUES (2323,'RT20260608002323',424,'PAID','2026-06-08 16:22:31','2026-06-08 16:41:31',179.00,'小程序');

INSERT INTO `orders` VALUES (2324,'RT20260608002324',554,'REFUNDED','2026-06-08 18:40:53','2026-06-08 19:49:53',57.80,'线下门店');

INSERT INTO `orders` VALUES (2325,'RT20260608002325',31,'PAID','2026-06-08 18:56:25','2026-06-08 19:35:25',159.30,'线下门店');

INSERT INTO `orders` VALUES (2326,'RT20260608002326',314,'PAID','2026-06-08 20:17:41','2026-06-08 20:33:41',37.91,'线下门店');

INSERT INTO `orders` VALUES (2327,'RT20260608002327',56,'PAID','2026-06-08 20:31:04','2026-06-08 20:34:04',78.90,'小程序');

INSERT INTO `orders` VALUES (2328,'RT20260609002328',373,'PAID','2026-06-09 11:53:19','2026-06-09 12:45:19',736.91,'官网');

INSERT INTO `orders` VALUES (2329,'RT20260609002329',367,'PAID','2026-06-09 12:19:29','2026-06-09 13:29:29',37.91,'线下门店');

INSERT INTO `orders` VALUES (2330,'RT20260609002330',88,'PAID','2026-06-09 13:01:18','2026-06-09 13:50:18',107.00,'线下门店');

INSERT INTO `orders` VALUES (2331,'RT20260609002331',416,'PAID','2026-06-09 16:08:34','2026-06-09 16:17:34',32.90,'官网');

INSERT INTO `orders` VALUES (2332,'RT20260609002332',212,'PAID','2026-06-09 17:19:19','2026-06-09 17:54:19',39.00,'小程序');

INSERT INTO `orders` VALUES (2333,'RT20260609002333',269,'CANCELLED','2026-06-09 17:27:32',NULL,118.90,'线下门店');

INSERT INTO `orders` VALUES (2334,'RT20260609002334',372,'PAID','2026-06-09 18:29:31','2026-06-09 19:27:31',118.90,'小程序');

INSERT INTO `orders` VALUES (2335,'RT20260609002335',588,'REFUNDED','2026-06-09 19:28:54','2026-06-09 19:49:54',123.82,'官网');

INSERT INTO `orders` VALUES (2336,'RT20260609002336',269,'PAID','2026-06-09 19:31:57','2026-06-09 20:10:57',39.00,'小程序');

INSERT INTO `orders` VALUES (2337,'RT20260609002337',237,'PAID','2026-06-09 20:35:45','2026-06-09 21:38:45',68.00,'官网');

INSERT INTO `orders` VALUES (2338,'RT20260609002338',464,'PAID','2026-06-09 20:51:27','2026-06-09 21:39:27',59.22,'线下门店');

INSERT INTO `orders` VALUES (2339,'RT20260610002339',538,'PAID','2026-06-10 09:10:10','2026-06-10 10:24:10',270.16,'线下门店');

INSERT INTO `orders` VALUES (2340,'RT20260610002340',36,'PAID','2026-06-10 11:00:28','2026-06-10 11:37:28',89.00,'线下门店');

INSERT INTO `orders` VALUES (2341,'RT20260610002341',280,'PAID','2026-06-10 11:12:30','2026-06-10 11:45:30',100.90,'小程序');

INSERT INTO `orders` VALUES (2342,'RT20260610002342',581,'PAID','2026-06-10 13:33:28','2026-06-10 14:01:28',118.00,'企业采购');

INSERT INTO `orders` VALUES (2343,'RT20260610002343',606,'PAID','2026-06-10 15:11:09','2026-06-10 15:39:09',56.05,'线下门店');

INSERT INTO `orders` VALUES (2344,'RT20260610002344',329,'REFUNDED','2026-06-10 15:40:51','2026-06-10 15:57:51',143.36,'官网');

INSERT INTO `orders` VALUES (2345,'RT20260610002345',24,'PAID','2026-06-10 18:02:38','2026-06-10 18:42:38',49.80,'线下门店');

INSERT INTO `orders` VALUES (2346,'RT20260610002346',229,'PAID','2026-06-10 18:03:51','2026-06-10 19:09:51',124.91,'小程序');

INSERT INTO `orders` VALUES (2347,'RT20260610002347',215,'PAID','2026-06-10 18:07:36','2026-06-10 18:42:36',136.00,'小程序');

INSERT INTO `orders` VALUES (2348,'RT20260610002348',634,'PAID','2026-06-10 18:39:19','2026-06-10 18:59:19',350.71,'企业采购');

INSERT INTO `orders` VALUES (2349,'RT20260610002349',115,'PAID','2026-06-10 19:41:06','2026-06-10 20:09:06',63.90,'官网');

INSERT INTO `orders` VALUES (2350,'RT20260610002350',4,'CANCELLED','2026-06-10 19:48:58',NULL,258.00,'官网');

INSERT INTO `orders` VALUES (2351,'RT20260610002351',197,'PAID','2026-06-10 20:52:26','2026-06-10 21:48:26',198.90,'小程序');

INSERT INTO `orders` VALUES (2352,'RT20260611002352',172,'PAID','2026-06-11 11:31:06','2026-06-11 11:55:06',61.20,'官网');

INSERT INTO `orders` VALUES (2353,'RT20260611002353',342,'PAID','2026-06-11 11:39:01','2026-06-11 12:31:01',104.91,'官网');

INSERT INTO `orders` VALUES (2354,'RT20260611002354',191,'PAID','2026-06-11 12:01:29','2026-06-11 12:15:29',159.00,'企业采购');

INSERT INTO `orders` VALUES (2355,'RT20260611002355',53,'PAID','2026-06-11 12:03:07','2026-06-11 12:50:07',39.00,'企业采购');

INSERT INTO `orders` VALUES (2356,'RT20260611002356',16,'CANCELLED','2026-06-11 13:23:55',NULL,31.26,'小程序');

INSERT INTO `orders` VALUES (2357,'RT20260611002357',312,'PAID','2026-06-11 13:48:24','2026-06-11 14:21:24',79.80,'官网');

INSERT INTO `orders` VALUES (2358,'RT20260611002358',270,'PAID','2026-06-11 15:07:30','2026-06-11 15:16:30',108.90,'小程序');

INSERT INTO `orders` VALUES (2359,'RT20260611002359',281,'PAID','2026-06-11 17:25:31','2026-06-11 18:22:31',137.70,'官网');

INSERT INTO `orders` VALUES (2360,'RT20260611002360',310,'PAID','2026-06-11 18:31:12','2026-06-11 18:58:12',31.26,'小程序');

INSERT INTO `orders` VALUES (2361,'RT20260611002361',274,'PAID','2026-06-11 18:57:47','2026-06-11 20:00:47',100.90,'小程序');

INSERT INTO `orders` VALUES (2362,'RT20260611002362',161,'CANCELLED','2026-06-11 19:24:18',NULL,37.05,'线下门店');

INSERT INTO `orders` VALUES (2363,'RT20260611002363',488,'CANCELLED','2026-06-11 19:45:45',NULL,39.90,'小程序');

INSERT INTO `orders` VALUES (2364,'RT20260611002364',438,'PAID','2026-06-11 19:49:27','2026-06-11 20:22:27',78.00,'小程序');

INSERT INTO `orders` VALUES (2365,'RT20260611002365',44,'REFUNDED','2026-06-11 20:56:16','2026-06-11 22:08:16',39.90,'小程序');

INSERT INTO `orders` VALUES (2366,'RT20260611002366',387,'REFUNDED','2026-06-11 20:56:59','2026-06-11 21:39:59',24.90,'线下门店');

INSERT INTO `orders` VALUES (2367,'RT20260611002367',73,'PAID','2026-06-11 21:59:44','2026-06-11 23:11:44',74.10,'小程序');

INSERT INTO `orders` VALUES (2368,'RT20260612002368',585,'PAID','2026-06-12 11:16:23','2026-06-12 12:21:23',68.00,'线下门店');

INSERT INTO `orders` VALUES (2369,'RT20260612002369',307,'PAID','2026-06-12 11:20:34','2026-06-12 12:23:34',267.00,'小程序');

INSERT INTO `orders` VALUES (2370,'RT20260612002370',169,'PAID','2026-06-12 12:55:23','2026-06-12 14:02:23',60.32,'小程序');

INSERT INTO `orders` VALUES (2371,'RT20260612002371',406,'PAID','2026-06-12 13:18:46','2026-06-12 13:19:46',152.10,'小程序');

INSERT INTO `orders` VALUES (2372,'RT20260612002372',426,'PAID','2026-06-12 14:47:52','2026-06-12 14:54:52',103.60,'官网');

INSERT INTO `orders` VALUES (2373,'RT20260612002373',220,'PAID','2026-06-12 14:54:19','2026-06-12 15:43:19',68.00,'小程序');

INSERT INTO `orders` VALUES (2374,'RT20260612002374',302,'PAID','2026-06-12 15:20:07','2026-06-12 16:02:07',159.00,'官网');

INSERT INTO `orders` VALUES (2375,'RT20260612002375',150,'PAID','2026-06-12 15:27:31','2026-06-12 15:30:31',175.95,'小程序');

INSERT INTO `orders` VALUES (2376,'RT20260612002376',96,'PAID','2026-06-12 16:26:17','2026-06-12 17:28:17',68.00,'线下门店');

INSERT INTO `orders` VALUES (2377,'RT20260612002377',61,'PAID','2026-06-12 17:48:07','2026-06-12 18:23:07',200.65,'线下门店');

INSERT INTO `orders` VALUES (2378,'RT20260612002378',436,'PAID','2026-06-12 18:04:15','2026-06-12 18:27:15',59.00,'线下门店');

INSERT INTO `orders` VALUES (2379,'RT20260612002379',132,'PAID','2026-06-12 18:11:04','2026-06-12 19:13:04',720.55,'线下门店');

INSERT INTO `orders` VALUES (2380,'RT20260612002380',335,'PAID','2026-06-12 18:13:23','2026-06-12 19:00:23',75.05,'小程序');

INSERT INTO `orders` VALUES (2381,'RT20260612002381',189,'PAID','2026-06-12 18:18:34','2026-06-12 18:21:34',68.00,'线下门店');

INSERT INTO `orders` VALUES (2382,'RT20260612002382',330,'PAID','2026-06-12 18:23:21','2026-06-12 19:08:21',84.55,'小程序');

INSERT INTO `orders` VALUES (2383,'RT20260612002383',276,'PAID','2026-06-12 18:37:13','2026-06-12 18:42:13',32.90,'官网');

INSERT INTO `orders` VALUES (2384,'RT20260612002384',47,'PAID','2026-06-12 18:46:53','2026-06-12 19:08:53',620.90,'小程序');

INSERT INTO `orders` VALUES (2385,'RT20260612002385',477,'PAID','2026-06-12 18:58:52','2026-06-12 20:09:52',39.00,'线下门店');

INSERT INTO `orders` VALUES (2386,'RT20260612002386',559,'PAID','2026-06-12 19:59:21','2026-06-12 20:42:21',64.60,'线下门店');

INSERT INTO `orders` VALUES (2387,'RT20260612002387',29,'CANCELLED','2026-06-12 20:47:26',NULL,106.31,'官网');

INSERT INTO `orders` VALUES (2388,'RT20260613002388',526,'PAID','2026-06-13 10:37:35','2026-06-13 10:53:35',61.20,'线下门店');

INSERT INTO `orders` VALUES (2389,'RT20260613002389',450,'PAID','2026-06-13 11:44:12','2026-06-13 12:20:12',68.00,'小程序');

INSERT INTO `orders` VALUES (2390,'RT20260613002390',198,'PAID','2026-06-13 11:56:43','2026-06-13 12:55:43',157.90,'官网');

INSERT INTO `orders` VALUES (2391,'RT20260613002391',373,'PAID','2026-06-13 13:22:04','2026-06-13 13:39:04',121.90,'小程序');

INSERT INTO `orders` VALUES (2392,'RT20260613002392',229,'PAID','2026-06-13 13:41:19','2026-06-13 14:51:19',140.41,'小程序');

INSERT INTO `orders` VALUES (2393,'RT20260613002393',520,'PAID','2026-06-13 14:11:51','2026-06-13 14:41:51',169.00,'官网');

INSERT INTO `orders` VALUES (2394,'RT20260613002394',31,'PAID','2026-06-13 15:41:18','2026-06-13 16:16:18',122.55,'小程序');

INSERT INTO `orders` VALUES (2395,'RT20260613002395',290,'PAID','2026-06-13 15:50:33','2026-06-13 16:11:33',118.00,'小程序');

INSERT INTO `orders` VALUES (2396,'RT20260613002396',34,'PAID','2026-06-13 16:12:58','2026-06-13 17:03:58',22.41,'官网');

INSERT INTO `orders` VALUES (2397,'RT20260613002397',113,'PAID','2026-06-13 16:20:47','2026-06-13 17:24:47',62.10,'线下门店');

INSERT INTO `orders` VALUES (2398,'RT20260613002398',403,'PAID','2026-06-13 17:10:17','2026-06-13 18:14:17',79.00,'线下门店');

INSERT INTO `orders` VALUES (2399,'RT20260613002399',603,'PAID','2026-06-13 17:28:28','2026-06-13 17:45:28',62.10,'线下门店');

INSERT INTO `orders` VALUES (2400,'RT20260613002400',39,'PAID','2026-06-13 18:09:52','2026-06-13 18:14:52',193.90,'小程序');

INSERT INTO `orders` VALUES (2401,'RT20260613002401',147,'PAID','2026-06-13 18:33:28','2026-06-13 18:37:28',99.95,'线下门店');

INSERT INTO `orders` VALUES (2402,'RT20260613002402',346,'PAID','2026-06-13 19:36:30','2026-06-13 19:45:30',24.90,'企业采购');

INSERT INTO `orders` VALUES (2403,'RT20260613002403',387,'PAID','2026-06-13 21:14:23','2026-06-13 21:25:23',49.80,'线下门店');

INSERT INTO `orders` VALUES (2404,'RT20260613002404',230,'PAID','2026-06-13 21:16:03','2026-06-13 22:25:03',24.90,'小程序');

INSERT INTO `orders` VALUES (2405,'RT20260614002405',150,'PAID','2026-06-14 09:29:44','2026-06-14 09:52:44',59.00,'官网');

INSERT INTO `orders` VALUES (2406,'RT20260614002406',101,'PAID','2026-06-14 10:25:46','2026-06-14 11:00:46',31.26,'线下门店');

INSERT INTO `orders` VALUES (2407,'RT20260614002407',159,'PAID','2026-06-14 11:03:46','2026-06-14 12:00:46',75.05,'线下门店');

INSERT INTO `orders` VALUES (2408,'RT20260614002408',271,'PAID','2026-06-14 11:40:31','2026-06-14 11:45:31',37.91,'小程序');

INSERT INTO `orders` VALUES (2409,'RT20260614002409',410,'PAID','2026-06-14 12:45:32','2026-06-14 13:27:32',68.00,'小程序');

INSERT INTO `orders` VALUES (2410,'RT20260614002410',415,'PAID','2026-06-14 13:14:44','2026-06-14 14:20:44',89.00,'线下门店');

INSERT INTO `orders` VALUES (2411,'RT20260614002411',122,'PAID','2026-06-14 13:28:51','2026-06-14 13:38:51',798.00,'企业采购');

INSERT INTO `orders` VALUES (2412,'RT20260614002412',491,'PAID','2026-06-14 15:09:49','2026-06-14 16:15:49',37.05,'官网');

INSERT INTO `orders` VALUES (2413,'RT20260614002413',155,'CANCELLED','2026-06-14 16:03:07',NULL,101.81,'线下门店');

INSERT INTO `orders` VALUES (2414,'RT20260614002414',240,'PAID','2026-06-14 16:52:19','2026-06-14 17:58:19',79.00,'线下门店');

INSERT INTO `orders` VALUES (2415,'RT20260614002415',418,'PAID','2026-06-14 17:27:33','2026-06-14 18:33:33',32.90,'官网');

INSERT INTO `orders` VALUES (2416,'RT20260614002416',11,'PAID','2026-06-14 18:43:48','2026-06-14 18:44:48',98.00,'线下门店');

INSERT INTO `orders` VALUES (2417,'RT20260614002417',114,'PAID','2026-06-14 18:51:42','2026-06-14 20:05:42',39.90,'小程序');

INSERT INTO `orders` VALUES (2418,'RT20260614002418',202,'PAID','2026-06-14 18:57:06','2026-06-14 19:11:06',258.00,'小程序');

INSERT INTO `orders` VALUES (2419,'RT20260614002419',28,'PAID','2026-06-14 19:23:46','2026-06-14 19:32:46',183.90,'线下门店');

INSERT INTO `orders` VALUES (2420,'RT20260614002420',165,'PAID','2026-06-14 19:36:13','2026-06-14 20:28:13',103.90,'官网');

INSERT INTO `orders` VALUES (2421,'RT20260614002421',101,'PAID','2026-06-14 21:39:49','2026-06-14 22:27:49',24.90,'官网');

INSERT INTO `orders` VALUES (2422,'RT20260615002422',209,'PAID','2026-06-15 11:32:31','2026-06-15 12:13:31',151.81,'小程序');

INSERT INTO `orders` VALUES (2423,'RT20260615002423',289,'PAID','2026-06-15 12:31:23','2026-06-15 13:19:23',188.00,'小程序');

INSERT INTO `orders` VALUES (2424,'RT20260615002424',331,'PAID','2026-06-15 14:56:32','2026-06-15 15:20:32',245.10,'企业采购');

INSERT INTO `orders` VALUES (2425,'RT20260615002425',513,'PAID','2026-06-15 15:41:08','2026-06-15 16:45:08',59.00,'线下门店');

INSERT INTO `orders` VALUES (2426,'RT20260615002426',440,'PAID','2026-06-15 16:30:08','2026-06-15 17:43:08',123.55,'小程序');

INSERT INTO `orders` VALUES (2427,'RT20260615002427',334,'PAID','2026-06-15 17:59:53','2026-06-15 18:09:53',88.95,'官网');

INSERT INTO `orders` VALUES (2428,'RT20260615002428',435,'PAID','2026-06-15 18:18:41','2026-06-15 19:31:41',90.81,'官网');

INSERT INTO `orders` VALUES (2429,'RT20260615002429',201,'CANCELLED','2026-06-15 18:48:54',NULL,35.91,'线下门店');

INSERT INTO `orders` VALUES (2430,'RT20260615002430',389,'PAID','2026-06-15 19:15:46','2026-06-15 20:10:46',199.00,'小程序');

INSERT INTO `orders` VALUES (2431,'RT20260615002431',32,'PAID','2026-06-15 19:42:10','2026-06-15 20:22:10',136.00,'小程序');

INSERT INTO `orders` VALUES (2432,'RT20260615002432',505,'PAID','2026-06-15 20:06:53','2026-06-15 20:11:53',78.00,'官网');

INSERT INTO `orders` VALUES (2433,'RT20260615002433',259,'PAID','2026-06-15 20:46:32','2026-06-15 21:21:32',160.20,'小程序');

INSERT INTO `orders` VALUES (2434,'RT20260615002434',148,'CANCELLED','2026-06-15 21:33:18',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (2435,'RT20260615002435',448,'PAID','2026-06-15 22:40:47','2026-06-15 23:39:47',59.00,'小程序');

INSERT INTO `orders` VALUES (2436,'RT20260616002436',97,'PAID','2026-06-16 11:08:19','2026-06-16 12:12:19',212.80,'官网');

INSERT INTO `orders` VALUES (2437,'RT20260616002437',587,'PAID','2026-06-16 11:18:18','2026-06-16 11:26:18',68.00,'官网');

INSERT INTO `orders` VALUES (2438,'RT20260616002438',500,'CANCELLED','2026-06-16 12:15:10',NULL,129.20,'线下门店');

INSERT INTO `orders` VALUES (2439,'RT20260616002439',248,'PAID','2026-06-16 12:31:00','2026-06-16 12:36:00',181.55,'线下门店');

INSERT INTO `orders` VALUES (2440,'RT20260616002440',204,'PAID','2026-06-16 13:20:42','2026-06-16 14:31:42',39.90,'小程序');

INSERT INTO `orders` VALUES (2441,'RT20260616002441',352,'CANCELLED','2026-06-16 13:32:49',NULL,24.90,'官网');

INSERT INTO `orders` VALUES (2442,'RT20260616002442',268,'PAID','2026-06-16 13:54:59','2026-06-16 14:07:59',24.90,'线下门店');

INSERT INTO `orders` VALUES (2443,'RT20260616002443',105,'PAID','2026-06-16 14:27:21','2026-06-16 15:05:21',37.91,'小程序');

INSERT INTO `orders` VALUES (2444,'RT20260616002444',342,'PAID','2026-06-16 15:38:59','2026-06-16 16:08:59',129.00,'官网');

INSERT INTO `orders` VALUES (2445,'RT20260616002445',294,'PAID','2026-06-16 15:49:20','2026-06-16 16:36:20',32.90,'线下门店');

INSERT INTO `orders` VALUES (2446,'RT20260616002446',38,'PAID','2026-06-16 16:17:14','2026-06-16 16:19:14',44.82,'线下门店');

INSERT INTO `orders` VALUES (2447,'RT20260616002447',90,'PAID','2026-06-16 17:10:25','2026-06-16 18:18:25',32.90,'小程序');

INSERT INTO `orders` VALUES (2448,'RT20260616002448',348,'PAID','2026-06-16 17:18:03','2026-06-16 18:13:03',79.00,'小程序');

INSERT INTO `orders` VALUES (2449,'RT20260616002449',19,'PAID','2026-06-16 18:18:39','2026-06-16 19:12:39',59.00,'线下门店');

INSERT INTO `orders` VALUES (2450,'RT20260616002450',463,'PAID','2026-06-16 18:26:02','2026-06-16 19:19:02',69.00,'小程序');

INSERT INTO `orders` VALUES (2451,'RT20260616002451',6,'PAID','2026-06-16 18:50:35','2026-06-16 19:05:35',39.90,'线下门店');

INSERT INTO `orders` VALUES (2452,'RT20260616002452',30,'PAID','2026-06-16 19:07:46','2026-06-16 19:36:46',24.90,'小程序');

INSERT INTO `orders` VALUES (2453,'RT20260616002453',449,'REFUNDED','2026-06-16 19:59:13','2026-06-16 21:10:13',418.95,'线下门店');

INSERT INTO `orders` VALUES (2454,'RT20260616002454',217,'PAID','2026-06-16 22:04:05','2026-06-16 23:12:05',129.00,'小程序');

INSERT INTO `orders` VALUES (2455,'RT20260617002455',461,'PAID','2026-06-17 09:02:32','2026-06-17 09:12:32',68.00,'小程序');

INSERT INTO `orders` VALUES (2456,'RT20260617002456',371,'PAID','2026-06-17 09:58:18','2026-06-17 10:18:18',84.55,'小程序');

INSERT INTO `orders` VALUES (2457,'RT20260617002457',37,'PAID','2026-06-17 10:45:18','2026-06-17 11:06:18',96.05,'官网');

INSERT INTO `orders` VALUES (2458,'RT20260617002458',416,'CANCELLED','2026-06-17 11:02:25',NULL,37.91,'企业采购');

INSERT INTO `orders` VALUES (2459,'RT20260617002459',595,'PAID','2026-06-17 11:03:55','2026-06-17 12:01:55',215.00,'小程序');

INSERT INTO `orders` VALUES (2460,'RT20260617002460',550,'PAID','2026-06-17 11:10:09','2026-06-17 12:01:09',68.00,'线下门店');

INSERT INTO `orders` VALUES (2461,'RT20260617002461',34,'PAID','2026-06-17 11:17:38','2026-06-17 11:48:38',227.00,'小程序');

INSERT INTO `orders` VALUES (2462,'RT20260617002462',202,'PAID','2026-06-17 11:59:04','2026-06-17 12:08:04',37.91,'官网');

INSERT INTO `orders` VALUES (2463,'RT20260617002463',283,'PAID','2026-06-17 12:44:48','2026-06-17 12:56:48',68.00,'线下门店');

INSERT INTO `orders` VALUES (2464,'RT20260617002464',56,'PAID','2026-06-17 17:50:34','2026-06-17 18:47:34',56.05,'线下门店');

INSERT INTO `orders` VALUES (2465,'RT20260617002465',580,'PAID','2026-06-17 18:19:55','2026-06-17 18:34:55',39.00,'小程序');

INSERT INTO `orders` VALUES (2466,'RT20260617002466',290,'PAID','2026-06-17 19:03:13','2026-06-17 19:33:13',160.55,'官网');

INSERT INTO `orders` VALUES (2467,'RT20260617002467',154,'CANCELLED','2026-06-17 19:14:03',NULL,68.00,'官网');

INSERT INTO `orders` VALUES (2468,'RT20260617002468',506,'PAID','2026-06-17 19:32:12','2026-06-17 20:01:12',179.10,'小程序');

INSERT INTO `orders` VALUES (2469,'RT20260617002469',287,'PAID','2026-06-17 20:46:21','2026-06-17 21:05:21',318.00,'官网');

INSERT INTO `orders` VALUES (2470,'RT20260617002470',408,'PAID','2026-06-17 21:15:43','2026-06-17 21:47:43',62.81,'线下门店');

INSERT INTO `orders` VALUES (2471,'RT20260617002471',70,'PAID','2026-06-17 21:18:41','2026-06-17 22:25:41',39.00,'线下门店');

INSERT INTO `orders` VALUES (2472,'RT20260618002472',96,'PAID','2026-06-18 10:42:25','2026-06-18 11:14:25',64.60,'小程序');

INSERT INTO `orders` VALUES (2473,'RT20260618002473',158,'PAID','2026-06-18 10:48:46','2026-06-18 11:24:46',191.31,'官网');

INSERT INTO `orders` VALUES (2474,'RT20260618002474',227,'PAID','2026-06-18 11:54:27','2026-06-18 12:03:27',68.00,'线下门店');

INSERT INTO `orders` VALUES (2475,'RT20260618002475',402,'PAID','2026-06-18 12:00:37','2026-06-18 12:33:37',59.00,'线下门店');

INSERT INTO `orders` VALUES (2476,'RT20260618002476',152,'PAID','2026-06-18 12:03:36','2026-06-18 13:17:36',39.90,'小程序');

INSERT INTO `orders` VALUES (2477,'RT20260618002477',216,'PAID','2026-06-18 13:26:34','2026-06-18 14:05:34',89.00,'官网');

INSERT INTO `orders` VALUES (2478,'RT20260618002478',14,'CANCELLED','2026-06-18 13:53:19',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (2479,'RT20260618002479',73,'PAID','2026-06-18 13:55:54','2026-06-18 15:10:54',56.05,'官网');

INSERT INTO `orders` VALUES (2480,'RT20260618002480',512,'PAID','2026-06-18 17:27:23','2026-06-18 18:09:23',148.80,'线下门店');

INSERT INTO `orders` VALUES (2481,'RT20260618002481',628,'PAID','2026-06-18 17:43:05','2026-06-18 18:23:05',68.00,'企业采购');

INSERT INTO `orders` VALUES (2482,'RT20260618002482',365,'CANCELLED','2026-06-18 17:47:57',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (2483,'RT20260618002483',88,'PAID','2026-06-18 18:29:32','2026-06-18 18:45:32',248.80,'官网');

INSERT INTO `orders` VALUES (2484,'RT20260618002484',94,'PAID','2026-06-18 20:26:34','2026-06-18 20:31:34',37.91,'线下门店');

INSERT INTO `orders` VALUES (2485,'RT20260619002485',237,'PAID','2026-06-19 08:52:00','2026-06-19 10:07:00',100.90,'线下门店');

INSERT INTO `orders` VALUES (2486,'RT20260619002486',274,'PAID','2026-06-19 09:56:23','2026-06-19 10:25:23',39.90,'线下门店');

INSERT INTO `orders` VALUES (2487,'RT20260619002487',366,'PAID','2026-06-19 11:31:18','2026-06-19 12:28:18',39.00,'线下门店');

INSERT INTO `orders` VALUES (2488,'RT20260619002488',489,'PAID','2026-06-19 11:38:10','2026-06-19 12:47:10',2097.00,'官网');

INSERT INTO `orders` VALUES (2489,'RT20260619002489',304,'CANCELLED','2026-06-19 14:06:19',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (2490,'RT20260619002490',136,'PAID','2026-06-19 14:55:56','2026-06-19 15:32:56',75.05,'官网');

INSERT INTO `orders` VALUES (2491,'RT20260619002491',538,'PAID','2026-06-19 15:23:51','2026-06-19 15:32:51',37.91,'企业采购');

INSERT INTO `orders` VALUES (2492,'RT20260619002492',58,'PAID','2026-06-19 15:52:55','2026-06-19 15:58:55',64.60,'线下门店');

INSERT INTO `orders` VALUES (2493,'RT20260619002493',254,'PAID','2026-06-19 15:58:16','2026-06-19 16:49:16',35.10,'线下门店');

INSERT INTO `orders` VALUES (2494,'RT20260619002494',379,'PAID','2026-06-19 16:15:01','2026-06-19 17:23:01',49.80,'官网');

INSERT INTO `orders` VALUES (2495,'RT20260619002495',26,'PAID','2026-06-19 17:31:16','2026-06-19 18:35:16',207.00,'小程序');

INSERT INTO `orders` VALUES (2496,'RT20260619002496',607,'PAID','2026-06-19 18:59:05','2026-06-19 19:55:05',65.80,'官网');

INSERT INTO `orders` VALUES (2497,'RT20260619002497',63,'PAID','2026-06-19 19:18:27','2026-06-19 20:03:27',284.05,'官网');

INSERT INTO `orders` VALUES (2498,'RT20260619002498',159,'PAID','2026-06-19 21:21:53','2026-06-19 22:36:53',93.77,'线下门店');

INSERT INTO `orders` VALUES (2499,'RT20260619002499',317,'PAID','2026-06-19 22:05:04','2026-06-19 22:32:04',32.90,'小程序');

INSERT INTO `orders` VALUES (2500,'RT20260619002500',89,'PAID','2026-06-19 22:05:25','2026-06-19 22:08:25',39.90,'小程序');

INSERT INTO `orders` VALUES (2501,'RT20260620002501',616,'PAID','2026-06-20 13:17:25','2026-06-20 13:25:25',32.90,'线下门店');

INSERT INTO `orders` VALUES (2502,'RT20260620002502',443,'CANCELLED','2026-06-20 13:19:24',NULL,699.00,'线下门店');

INSERT INTO `orders` VALUES (2503,'RT20260620002503',299,'PAID','2026-06-20 15:39:51','2026-06-20 16:19:51',79.80,'线下门店');

INSERT INTO `orders` VALUES (2504,'RT20260620002504',220,'PAID','2026-06-20 16:10:33','2026-06-20 16:20:33',31.26,'线下门店');

INSERT INTO `orders` VALUES (2505,'RT20260620002505',145,'PAID','2026-06-20 17:02:24','2026-06-20 18:02:24',201.90,'小程序');

INSERT INTO `orders` VALUES (2506,'RT20260620002506',212,'PAID','2026-06-20 18:36:29','2026-06-20 19:36:29',35.10,'小程序');

INSERT INTO `orders` VALUES (2507,'RT20260620002507',438,'PAID','2026-06-20 19:03:18','2026-06-20 19:45:18',290.90,'线下门店');

INSERT INTO `orders` VALUES (2508,'RT20260620002508',273,'PAID','2026-06-20 19:06:05','2026-06-20 19:48:05',24.90,'官网');

INSERT INTO `orders` VALUES (2509,'RT20260620002509',319,'PAID','2026-06-20 19:08:03','2026-06-20 19:42:03',75.05,'官网');

INSERT INTO `orders` VALUES (2510,'RT20260620002510',585,'PAID','2026-06-20 19:19:40','2026-06-20 19:31:40',159.00,'小程序');

INSERT INTO `orders` VALUES (2511,'RT20260620002511',249,'PAID','2026-06-20 20:18:24','2026-06-20 20:48:24',39.00,'小程序');

INSERT INTO `orders` VALUES (2512,'RT20260620002512',92,'PAID','2026-06-20 20:19:32','2026-06-20 21:23:32',39.90,'官网');

INSERT INTO `orders` VALUES (2513,'RT20260620002513',500,'PAID','2026-06-20 21:58:00','2026-06-20 22:52:00',150.10,'官网');

INSERT INTO `orders` VALUES (2514,'RT20260621002514',5,'PAID','2026-06-21 09:24:09','2026-06-21 10:18:09',75.05,'小程序');

INSERT INTO `orders` VALUES (2515,'RT20260621002515',317,'PAID','2026-06-21 11:01:46','2026-06-21 12:03:46',177.90,'线下门店');

INSERT INTO `orders` VALUES (2516,'RT20260621002516',126,'PAID','2026-06-21 11:46:33','2026-06-21 11:51:33',24.90,'小程序');

INSERT INTO `orders` VALUES (2517,'RT20260621002517',325,'PAID','2026-06-21 12:05:07','2026-06-21 13:09:07',79.00,'小程序');

INSERT INTO `orders` VALUES (2518,'RT20260621002518',489,'PAID','2026-06-21 12:11:44','2026-06-21 12:44:44',23.66,'官网');

INSERT INTO `orders` VALUES (2519,'RT20260621002519',59,'PAID','2026-06-21 13:31:32','2026-06-21 14:16:32',39.90,'小程序');

INSERT INTO `orders` VALUES (2520,'RT20260621002520',412,'PAID','2026-06-21 14:34:51','2026-06-21 14:52:51',190.01,'线下门店');

INSERT INTO `orders` VALUES (2521,'RT20260621002521',612,'PAID','2026-06-21 15:30:58','2026-06-21 15:31:58',114.95,'小程序');

INSERT INTO `orders` VALUES (2522,'RT20260621002522',410,'PAID','2026-06-21 16:24:59','2026-06-21 17:24:59',39.90,'小程序');

INSERT INTO `orders` VALUES (2523,'RT20260621002523',243,'PAID','2026-06-21 17:03:36','2026-06-21 18:11:36',37.91,'线下门店');

INSERT INTO `orders` VALUES (2524,'RT20260621002524',433,'PAID','2026-06-21 18:38:33','2026-06-21 19:11:33',208.26,'线下门店');

INSERT INTO `orders` VALUES (2525,'RT20260621002525',73,'REFUNDED','2026-06-21 18:44:56','2026-06-21 19:10:56',37.05,'小程序');

INSERT INTO `orders` VALUES (2526,'RT20260621002526',99,'PAID','2026-06-21 20:02:04','2026-06-21 20:12:04',177.00,'线下门店');

INSERT INTO `orders` VALUES (2527,'RT20260622002527',225,'PAID','2026-06-22 10:04:59','2026-06-22 10:20:59',169.00,'官网');

INSERT INTO `orders` VALUES (2528,'RT20260622002528',370,'PAID','2026-06-22 11:48:12','2026-06-22 12:37:12',59.00,'线下门店');

INSERT INTO `orders` VALUES (2529,'RT20260622002529',442,'PAID','2026-06-22 12:38:54','2026-06-22 13:17:54',226.35,'线下门店');

INSERT INTO `orders` VALUES (2530,'RT20260622002530',283,'PAID','2026-06-22 13:24:08','2026-06-22 13:46:08',53.10,'小程序');

INSERT INTO `orders` VALUES (2531,'RT20260622002531',319,'PAID','2026-06-22 13:45:06','2026-06-22 14:47:06',32.90,'线下门店');

INSERT INTO `orders` VALUES (2532,'RT20260622002532',636,'PAID','2026-06-22 14:43:00','2026-06-22 14:55:00',103.90,'线下门店');

INSERT INTO `orders` VALUES (2533,'RT20260622002533',407,'PAID','2026-06-22 15:26:24','2026-06-22 15:43:24',24.90,'小程序');

INSERT INTO `orders` VALUES (2534,'RT20260622002534',223,'PAID','2026-06-22 16:18:30','2026-06-22 16:47:30',56.16,'小程序');

INSERT INTO `orders` VALUES (2535,'RT20260622002535',377,'PAID','2026-06-22 17:06:07','2026-06-22 17:53:07',230.85,'小程序');

INSERT INTO `orders` VALUES (2536,'RT20260622002536',38,'PAID','2026-06-22 17:48:55','2026-06-22 18:51:55',107.00,'线下门店');

INSERT INTO `orders` VALUES (2537,'RT20260622002537',112,'PAID','2026-06-22 17:55:15','2026-06-22 18:25:15',59.00,'小程序');

INSERT INTO `orders` VALUES (2538,'RT20260622002538',67,'PAID','2026-06-22 18:41:35','2026-06-22 19:08:35',32.90,'企业采购');

INSERT INTO `orders` VALUES (2539,'RT20260622002539',300,'PAID','2026-06-22 20:06:28','2026-06-22 21:19:28',32.90,'小程序');

INSERT INTO `orders` VALUES (2540,'RT20260622002540',4,'CANCELLED','2026-06-22 20:32:02',NULL,191.55,'小程序');

INSERT INTO `orders` VALUES (2541,'RT20260622002541',45,'PAID','2026-06-22 22:36:27','2026-06-22 22:55:27',128.00,'线下门店');

INSERT INTO `orders` VALUES (2542,'RT20260623002542',55,'CANCELLED','2026-06-23 11:13:51',NULL,59.00,'线下门店');

INSERT INTO `orders` VALUES (2543,'RT20260623002543',59,'PAID','2026-06-23 12:18:01','2026-06-23 13:11:01',62.10,'线下门店');

INSERT INTO `orders` VALUES (2544,'RT20260623002544',622,'PAID','2026-06-23 15:47:15','2026-06-23 16:08:15',37.91,'小程序');

INSERT INTO `orders` VALUES (2545,'RT20260623002545',139,'PAID','2026-06-23 16:32:15','2026-06-23 17:36:15',53.10,'企业采购');

INSERT INTO `orders` VALUES (2546,'RT20260623002546',232,'PAID','2026-06-23 17:40:57','2026-06-23 17:54:57',208.00,'线下门店');

INSERT INTO `orders` VALUES (2547,'RT20260623002547',381,'PAID','2026-06-23 18:20:23','2026-06-23 18:35:23',133.80,'官网');

INSERT INTO `orders` VALUES (2548,'RT20260623002548',308,'PAID','2026-06-23 18:34:08','2026-06-23 19:46:08',29.61,'线下门店');

INSERT INTO `orders` VALUES (2549,'RT20260623002549',377,'PAID','2026-06-23 18:34:27','2026-06-23 18:42:27',185.45,'小程序');

INSERT INTO `orders` VALUES (2550,'RT20260623002550',344,'PAID','2026-06-23 19:46:47','2026-06-23 20:53:47',39.90,'小程序');

INSERT INTO `orders` VALUES (2551,'RT20260624002551',404,'PAID','2026-06-24 10:03:09','2026-06-24 10:39:09',198.90,'小程序');

INSERT INTO `orders` VALUES (2552,'RT20260624002552',348,'PAID','2026-06-24 10:57:32','2026-06-24 11:07:32',37.91,'小程序');

INSERT INTO `orders` VALUES (2553,'RT20260624002553',485,'PAID','2026-06-24 11:31:36','2026-06-24 12:32:36',68.00,'官网');

INSERT INTO `orders` VALUES (2554,'RT20260624002554',132,'PAID','2026-06-24 12:22:19','2026-06-24 12:58:19',74.10,'线下门店');

INSERT INTO `orders` VALUES (2555,'RT20260624002555',602,'PAID','2026-06-24 13:57:09','2026-06-24 14:45:09',129.00,'小程序');

INSERT INTO `orders` VALUES (2556,'RT20260624002556',266,'PAID','2026-06-24 17:19:36','2026-06-24 18:17:36',166.91,'企业采购');

INSERT INTO `orders` VALUES (2557,'RT20260624002557',191,'CANCELLED','2026-06-24 17:36:52',NULL,200.45,'线下门店');

INSERT INTO `orders` VALUES (2558,'RT20260624002558',40,'PAID','2026-06-24 17:39:10','2026-06-24 18:35:10',418.25,'官网');

INSERT INTO `orders` VALUES (2559,'RT20260624002559',151,'PAID','2026-06-24 17:44:08','2026-06-24 18:54:08',110.26,'线下门店');

INSERT INTO `orders` VALUES (2560,'RT20260624002560',78,'PAID','2026-06-24 17:58:44','2026-06-24 19:04:44',32.90,'企业采购');

INSERT INTO `orders` VALUES (2561,'RT20260624002561',5,'PAID','2026-06-24 19:01:51','2026-06-24 20:16:51',64.60,'线下门店');

INSERT INTO `orders` VALUES (2562,'RT20260624002562',499,'PAID','2026-06-24 19:41:12','2026-06-24 20:44:12',175.05,'线下门店');

INSERT INTO `orders` VALUES (2563,'RT20260624002563',546,'PAID','2026-06-24 20:08:16','2026-06-24 20:58:16',59.00,'官网');

INSERT INTO `orders` VALUES (2564,'RT20260624002564',102,'PAID','2026-06-24 20:25:30','2026-06-24 20:57:30',24.90,'小程序');

INSERT INTO `orders` VALUES (2565,'RT20260624002565',384,'PAID','2026-06-24 20:44:38','2026-06-24 20:48:38',64.80,'线下门店');

INSERT INTO `orders` VALUES (2566,'RT20260624002566',4,'PAID','2026-06-24 21:02:24','2026-06-24 22:05:24',107.95,'小程序');

INSERT INTO `orders` VALUES (2567,'RT20260624002567',451,'CANCELLED','2026-06-24 21:52:09',NULL,142.60,'小程序');

INSERT INTO `orders` VALUES (2568,'RT20260625002568',19,'PAID','2026-06-25 09:20:45','2026-06-25 10:07:45',463.60,'官网');

INSERT INTO `orders` VALUES (2569,'RT20260625002569',78,'PAID','2026-06-25 10:39:14','2026-06-25 11:07:14',39.90,'线下门店');

INSERT INTO `orders` VALUES (2570,'RT20260625002570',256,'PAID','2026-06-25 11:15:36','2026-06-25 11:22:36',61.41,'线下门店');

INSERT INTO `orders` VALUES (2571,'RT20260625002571',290,'PAID','2026-06-25 12:47:24','2026-06-25 13:02:24',57.80,'线下门店');

INSERT INTO `orders` VALUES (2572,'RT20260625002572',454,'PAID','2026-06-25 12:54:05','2026-06-25 13:27:05',39.90,'线下门店');

INSERT INTO `orders` VALUES (2573,'RT20260625002573',344,'REFUNDED','2026-06-25 14:20:48','2026-06-25 14:28:48',159.00,'小程序');

INSERT INTO `orders` VALUES (2574,'RT20260625002574',35,'PAID','2026-06-25 15:55:53','2026-06-25 16:16:53',83.90,'小程序');

INSERT INTO `orders` VALUES (2575,'RT20260625002575',108,'PAID','2026-06-25 15:57:48','2026-06-25 16:19:48',68.00,'小程序');

INSERT INTO `orders` VALUES (2576,'RT20260625002576',293,'PAID','2026-06-25 16:52:52','2026-06-25 17:31:52',79.00,'小程序');

INSERT INTO `orders` VALUES (2577,'RT20260625002577',128,'PAID','2026-06-25 16:56:08','2026-06-25 17:11:08',39.90,'官网');

INSERT INTO `orders` VALUES (2578,'RT20260625002578',594,'PAID','2026-06-25 17:02:53','2026-06-25 17:35:53',129.00,'线下门店');

INSERT INTO `orders` VALUES (2579,'RT20260625002579',290,'PAID','2026-06-25 18:17:08','2026-06-25 19:03:08',39.00,'小程序');

INSERT INTO `orders` VALUES (2580,'RT20260625002580',170,'PAID','2026-06-25 18:20:51','2026-06-25 18:58:51',59.00,'小程序');

INSERT INTO `orders` VALUES (2581,'RT20260625002581',266,'PAID','2026-06-25 18:30:11','2026-06-25 19:09:11',39.90,'官网');

INSERT INTO `orders` VALUES (2582,'RT20260625002582',371,'PAID','2026-06-25 18:55:54','2026-06-25 19:39:54',39.90,'企业采购');

INSERT INTO `orders` VALUES (2583,'RT20260625002583',237,'PAID','2026-06-25 19:05:08','2026-06-25 19:48:08',59.00,'小程序');

INSERT INTO `orders` VALUES (2584,'RT20260626002584',198,'PAID','2026-06-26 10:49:27','2026-06-26 12:04:27',37.91,'小程序');

INSERT INTO `orders` VALUES (2585,'RT20260626002585',213,'REFUNDED','2026-06-26 11:38:38','2026-06-26 11:50:38',79.00,'小程序');

INSERT INTO `orders` VALUES (2586,'RT20260626002586',444,'PAID','2026-06-26 11:52:14','2026-06-26 12:07:14',154.55,'小程序');

INSERT INTO `orders` VALUES (2587,'RT20260626002587',263,'PAID','2026-06-26 11:55:50','2026-06-26 11:57:50',39.00,'企业采购');

INSERT INTO `orders` VALUES (2588,'RT20260626002588',180,'PAID','2026-06-26 12:50:59','2026-06-26 13:51:59',58.76,'小程序');

INSERT INTO `orders` VALUES (2589,'RT20260626002589',335,'PAID','2026-06-26 12:55:30','2026-06-26 14:09:30',158.00,'小程序');

INSERT INTO `orders` VALUES (2590,'RT20260626002590',518,'PAID','2026-06-26 13:18:43','2026-06-26 13:36:43',159.00,'线下门店');

INSERT INTO `orders` VALUES (2591,'RT20260626002591',137,'PAID','2026-06-26 15:31:39','2026-06-26 15:45:39',59.00,'线下门店');

INSERT INTO `orders` VALUES (2592,'RT20260626002592',129,'PAID','2026-06-26 16:23:48','2026-06-26 17:26:48',258.00,'小程序');

INSERT INTO `orders` VALUES (2593,'RT20260626002593',292,'PAID','2026-06-26 17:55:31','2026-06-26 18:04:31',117.80,'小程序');

INSERT INTO `orders` VALUES (2594,'RT20260626002594',205,'PAID','2026-06-26 18:00:06','2026-06-26 18:49:06',798.00,'官网');

INSERT INTO `orders` VALUES (2595,'RT20260626002595',629,'PAID','2026-06-26 18:29:22','2026-06-26 19:03:22',39.90,'小程序');

INSERT INTO `orders` VALUES (2596,'RT20260626002596',422,'PAID','2026-06-26 18:30:55','2026-06-26 19:42:55',137.90,'官网');

INSERT INTO `orders` VALUES (2597,'RT20260626002597',25,'REFUNDED','2026-06-26 19:16:01','2026-06-26 19:58:01',39.90,'线下门店');

INSERT INTO `orders` VALUES (2598,'RT20260626002598',477,'PAID','2026-06-26 19:46:06','2026-06-26 20:32:06',37.05,'线下门店');

INSERT INTO `orders` VALUES (2599,'RT20260626002599',268,'PAID','2026-06-26 19:48:05','2026-06-26 20:15:05',110.90,'线下门店');

INSERT INTO `orders` VALUES (2600,'RT20260626002600',262,'PAID','2026-06-26 19:54:16','2026-06-26 20:55:16',176.00,'线下门店');

INSERT INTO `orders` VALUES (2601,'RT20260626002601',339,'PAID','2026-06-26 20:01:16','2026-06-26 20:41:16',37.91,'线下门店');

INSERT INTO `orders` VALUES (2602,'RT20260626002602',56,'CANCELLED','2026-06-26 20:25:42',NULL,74.10,'小程序');

INSERT INTO `orders` VALUES (2603,'RT20260627002603',84,'PAID','2026-06-27 10:54:48','2026-06-27 11:12:48',68.00,'小程序');

INSERT INTO `orders` VALUES (2604,'RT20260627002604',120,'PAID','2026-06-27 11:36:52','2026-06-27 12:44:52',89.00,'线下门店');

INSERT INTO `orders` VALUES (2605,'RT20260627002605',449,'PAID','2026-06-27 12:04:39','2026-06-27 13:05:39',190.26,'线下门店');

INSERT INTO `orders` VALUES (2606,'RT20260627002606',138,'PAID','2026-06-27 12:40:00','2026-06-27 13:52:00',100.90,'小程序');

INSERT INTO `orders` VALUES (2607,'RT20260627002607',433,'PAID','2026-06-27 16:42:26','2026-06-27 17:00:26',31.26,'线下门店');

INSERT INTO `orders` VALUES (2608,'RT20260627002608',61,'PAID','2026-06-27 16:44:04','2026-06-27 17:46:04',39.00,'官网');

INSERT INTO `orders` VALUES (2609,'RT20260627002609',254,'PAID','2026-06-27 17:17:17','2026-06-27 17:28:17',185.05,'线下门店');

INSERT INTO `orders` VALUES (2610,'RT20260627002610',477,'PAID','2026-06-27 18:05:13','2026-06-27 19:18:13',100.90,'线下门店');

INSERT INTO `orders` VALUES (2611,'RT20260627002611',4,'PAID','2026-06-27 18:31:35','2026-06-27 19:44:35',136.00,'线下门店');

INSERT INTO `orders` VALUES (2612,'RT20260627002612',169,'PAID','2026-06-27 18:41:04','2026-06-27 18:57:04',379.05,'线下门店');

INSERT INTO `orders` VALUES (2613,'RT20260627002613',352,'PAID','2026-06-27 18:56:53','2026-06-27 19:25:53',105.36,'小程序');

INSERT INTO `orders` VALUES (2614,'RT20260627002614',51,'PAID','2026-06-27 19:29:30','2026-06-27 19:47:30',117.90,'小程序');

INSERT INTO `orders` VALUES (2615,'RT20260627002615',465,'PAID','2026-06-27 20:27:30','2026-06-27 21:30:30',489.95,'小程序');

INSERT INTO `orders` VALUES (2616,'RT20260627002616',259,'PAID','2026-06-27 20:32:51','2026-06-27 21:03:51',699.00,'小程序');

INSERT INTO `orders` VALUES (2617,'RT20260627002617',584,'PAID','2026-06-27 20:41:28','2026-06-27 21:02:28',250.55,'线下门店');

INSERT INTO `orders` VALUES (2618,'RT20260628002618',433,'PAID','2026-06-28 08:05:31','2026-06-28 08:41:31',326.55,'官网');

INSERT INTO `orders` VALUES (2619,'RT20260628002619',486,'PAID','2026-06-28 10:10:35','2026-06-28 11:11:35',150.20,'小程序');

INSERT INTO `orders` VALUES (2620,'RT20260628002620',35,'PAID','2026-06-28 12:04:54','2026-06-28 12:16:54',116.05,'线下门店');

INSERT INTO `orders` VALUES (2621,'RT20260628002621',272,'PAID','2026-06-28 12:07:36','2026-06-28 12:58:36',80.10,'企业采购');

INSERT INTO `orders` VALUES (2622,'RT20260628002622',392,'PAID','2026-06-28 12:26:00','2026-06-28 12:45:00',118.00,'小程序');

INSERT INTO `orders` VALUES (2623,'RT20260628002623',574,'PAID','2026-06-28 12:27:15','2026-06-28 12:57:15',102.90,'小程序');

INSERT INTO `orders` VALUES (2624,'RT20260628002624',250,'PAID','2026-06-28 13:19:52','2026-06-28 14:13:52',89.00,'官网');

INSERT INTO `orders` VALUES (2625,'RT20260628002625',322,'PAID','2026-06-28 13:26:36','2026-06-28 13:29:36',39.90,'小程序');

INSERT INTO `orders` VALUES (2626,'RT20260628002626',49,'PAID','2026-06-28 14:30:05','2026-06-28 14:48:05',316.95,'线下门店');

INSERT INTO `orders` VALUES (2627,'RT20260628002627',487,'PAID','2026-06-28 15:32:57','2026-06-28 16:43:57',181.41,'线下门店');

INSERT INTO `orders` VALUES (2628,'RT20260628002628',375,'PAID','2026-06-28 16:28:19','2026-06-28 17:18:19',175.90,'小程序');

INSERT INTO `orders` VALUES (2629,'RT20260628002629',12,'PAID','2026-06-28 16:57:49','2026-06-28 17:39:49',39.00,'线下门店');

INSERT INTO `orders` VALUES (2630,'RT20260628002630',496,'PAID','2026-06-28 17:25:07','2026-06-28 17:38:07',23.66,'小程序');

INSERT INTO `orders` VALUES (2631,'RT20260628002631',81,'PAID','2026-06-28 17:52:47','2026-06-28 18:07:47',248.10,'小程序');

INSERT INTO `orders` VALUES (2632,'RT20260628002632',131,'PAID','2026-06-28 17:59:32','2026-06-28 18:07:32',37.91,'小程序');

INSERT INTO `orders` VALUES (2633,'RT20260628002633',122,'PAID','2026-06-28 19:17:34','2026-06-28 20:29:34',31.26,'企业采购');

INSERT INTO `orders` VALUES (2634,'RT20260628002634',146,'PAID','2026-06-28 20:29:55','2026-06-28 21:26:55',35.10,'线下门店');

INSERT INTO `orders` VALUES (2635,'RT20260629002635',359,'REFUNDED','2026-06-29 08:26:41','2026-06-29 09:37:41',153.10,'线下门店');

INSERT INTO `orders` VALUES (2636,'RT20260629002636',119,'PAID','2026-06-29 12:35:35','2026-06-29 13:09:35',398.10,'小程序');

INSERT INTO `orders` VALUES (2637,'RT20260629002637',510,'PAID','2026-06-29 12:43:45','2026-06-29 12:51:45',167.90,'官网');

INSERT INTO `orders` VALUES (2638,'RT20260629002638',387,'PAID','2026-06-29 14:39:33','2026-06-29 15:54:33',200.10,'线下门店');

INSERT INTO `orders` VALUES (2639,'RT20260629002639',118,'PAID','2026-06-29 14:40:44','2026-06-29 15:45:44',61.95,'小程序');

INSERT INTO `orders` VALUES (2640,'RT20260629002640',342,'PAID','2026-06-29 15:42:05','2026-06-29 16:38:05',224.70,'小程序');

INSERT INTO `orders` VALUES (2641,'RT20260629002641',362,'PAID','2026-06-29 15:52:26','2026-06-29 16:41:26',1077.30,'小程序');

INSERT INTO `orders` VALUES (2642,'RT20260629002642',332,'PAID','2026-06-29 16:54:04','2026-06-29 17:06:04',32.90,'小程序');

INSERT INTO `orders` VALUES (2643,'RT20260629002643',494,'PAID','2026-06-29 17:41:18','2026-06-29 18:20:18',31.26,'线下门店');

INSERT INTO `orders` VALUES (2644,'RT20260629002644',102,'PAID','2026-06-29 18:01:06','2026-06-29 18:16:06',65.55,'小程序');

INSERT INTO `orders` VALUES (2645,'RT20260629002645',122,'PAID','2026-06-29 18:22:31','2026-06-29 19:26:31',69.00,'线下门店');

INSERT INTO `orders` VALUES (2646,'RT20260629002646',252,'PAID','2026-06-29 18:29:16','2026-06-29 18:42:16',39.90,'小程序');

INSERT INTO `orders` VALUES (2647,'RT20260629002647',338,'PAID','2026-06-29 18:49:46','2026-06-29 19:50:46',74.91,'官网');

INSERT INTO `orders` VALUES (2648,'RT20260629002648',124,'PAID','2026-06-29 20:13:42','2026-06-29 20:25:42',213.56,'官网');

INSERT INTO `orders` VALUES (2649,'RT20260629002649',24,'PAID','2026-06-29 20:14:55','2026-06-29 20:45:55',190.55,'小程序');

INSERT INTO `orders` VALUES (2650,'RT20260629002650',40,'PAID','2026-06-29 21:53:34','2026-06-29 23:01:34',39.00,'小程序');

INSERT INTO `orders` VALUES (2651,'RT20260630002651',317,'PAID','2026-06-30 09:28:02','2026-06-30 10:00:02',192.60,'官网');

INSERT INTO `orders` VALUES (2652,'RT20260630002652',66,'PAID','2026-06-30 09:53:48','2026-06-30 10:16:48',144.05,'线下门店');

INSERT INTO `orders` VALUES (2653,'RT20260630002653',4,'PAID','2026-06-30 10:31:08','2026-06-30 10:51:08',39.90,'线下门店');

INSERT INTO `orders` VALUES (2654,'RT20260630002654',378,'PAID','2026-06-30 10:49:07','2026-06-30 11:52:07',179.10,'小程序');

INSERT INTO `orders` VALUES (2655,'RT20260630002655',280,'PAID','2026-06-30 11:14:42','2026-06-30 12:22:42',129.00,'小程序');

INSERT INTO `orders` VALUES (2656,'RT20260630002656',309,'PAID','2026-06-30 11:44:54','2026-06-30 12:51:54',74.91,'线下门店');

INSERT INTO `orders` VALUES (2657,'RT20260630002657',102,'PAID','2026-06-30 12:03:00','2026-06-30 13:16:00',32.90,'小程序');

INSERT INTO `orders` VALUES (2658,'RT20260630002658',320,'PAID','2026-06-30 12:25:07','2026-06-30 12:56:07',71.90,'线下门店');

INSERT INTO `orders` VALUES (2659,'RT20260630002659',144,'PAID','2026-06-30 18:10:59','2026-06-30 18:51:59',74.70,'线下门店');

INSERT INTO `orders` VALUES (2660,'RT20260630002660',529,'CANCELLED','2026-06-30 18:37:10',NULL,75.81,'小程序');

INSERT INTO `orders` VALUES (2661,'RT20260630002661',210,'PAID','2026-06-30 19:36:29','2026-06-30 20:25:29',64.60,'线下门店');

INSERT INTO `orders` VALUES (2662,'RT20260630002662',58,'PAID','2026-06-30 21:16:55','2026-06-30 21:50:55',56.16,'小程序');

INSERT INTO `orders` VALUES (2663,'RT20260630002663',343,'PAID','2026-06-30 22:38:51','2026-06-30 23:19:51',239.55,'小程序');

INSERT INTO `orders` VALUES (2664,'RT20260701002664',87,'PAID','2026-07-01 13:57:08','2026-07-01 15:02:08',317.00,'官网');

INSERT INTO `orders` VALUES (2665,'RT20260701002665',9,'PAID','2026-07-01 15:23:46','2026-07-01 15:41:46',178.00,'线下门店');

INSERT INTO `orders` VALUES (2666,'RT20260701002666',44,'PAID','2026-07-01 17:38:50','2026-07-01 18:09:50',76.95,'小程序');

INSERT INTO `orders` VALUES (2667,'RT20260701002667',585,'PAID','2026-07-01 18:06:56','2026-07-01 19:06:56',146.61,'官网');

INSERT INTO `orders` VALUES (2668,'RT20260701002668',282,'PAID','2026-07-01 18:18:48','2026-07-01 19:01:48',71.90,'线下门店');

INSERT INTO `orders` VALUES (2669,'RT20260701002669',611,'PAID','2026-07-01 19:13:29','2026-07-01 20:18:29',169.00,'企业采购');

INSERT INTO `orders` VALUES (2670,'RT20260701002670',302,'PAID','2026-07-01 19:17:08','2026-07-01 20:13:08',56.05,'线下门店');

INSERT INTO `orders` VALUES (2671,'RT20260702002671',528,'PAID','2026-07-02 10:49:42','2026-07-02 11:03:42',152.55,'小程序');

INSERT INTO `orders` VALUES (2672,'RT20260702002672',203,'REFUNDED','2026-07-02 11:39:53','2026-07-02 12:42:53',122.55,'官网');

INSERT INTO `orders` VALUES (2673,'RT20260702002673',67,'PAID','2026-07-02 12:37:47','2026-07-02 13:49:47',201.10,'小程序');

INSERT INTO `orders` VALUES (2674,'RT20260702002674',420,'PAID','2026-07-02 12:38:12','2026-07-02 13:05:12',23.66,'线下门店');

INSERT INTO `orders` VALUES (2675,'RT20260702002675',84,'PAID','2026-07-02 12:41:51','2026-07-02 13:31:51',4406.00,'官网');

INSERT INTO `orders` VALUES (2676,'RT20260702002676',245,'CANCELLED','2026-07-02 14:24:10',NULL,159.00,'官网');

INSERT INTO `orders` VALUES (2677,'RT20260702002677',259,'CANCELLED','2026-07-02 16:16:58',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (2678,'RT20260702002678',369,'PAID','2026-07-02 16:35:58','2026-07-02 16:57:58',133.10,'官网');

INSERT INTO `orders` VALUES (2679,'RT20260702002679',38,'PAID','2026-07-02 16:37:05','2026-07-02 17:00:05',59.00,'小程序');

INSERT INTO `orders` VALUES (2680,'RT20260702002680',209,'PAID','2026-07-02 18:33:13','2026-07-02 19:04:13',192.60,'官网');

INSERT INTO `orders` VALUES (2681,'RT20260702002681',221,'PAID','2026-07-02 18:48:42','2026-07-02 19:28:42',39.00,'小程序');

INSERT INTO `orders` VALUES (2682,'RT20260703002682',215,'PAID','2026-07-03 09:14:58','2026-07-03 09:41:58',68.00,'线下门店');

INSERT INTO `orders` VALUES (2683,'RT20260703002683',48,'PAID','2026-07-03 16:03:23','2026-07-03 17:05:23',158.00,'线下门店');

INSERT INTO `orders` VALUES (2684,'RT20260703002684',236,'PAID','2026-07-03 18:05:06','2026-07-03 18:29:06',39.00,'官网');

INSERT INTO `orders` VALUES (2685,'RT20260703002685',448,'PAID','2026-07-03 18:54:04','2026-07-03 19:07:04',129.00,'线下门店');

INSERT INTO `orders` VALUES (2686,'RT20260703002686',25,'PAID','2026-07-03 19:39:31','2026-07-03 20:30:31',69.00,'官网');

INSERT INTO `orders` VALUES (2687,'RT20260703002687',420,'PAID','2026-07-03 20:22:23','2026-07-03 21:01:23',102.51,'官网');

INSERT INTO `orders` VALUES (2688,'RT20260703002688',333,'CANCELLED','2026-07-03 20:57:25',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (2689,'RT20260704002689',47,'PAID','2026-07-04 10:21:15','2026-07-04 11:29:15',137.51,'小程序');

INSERT INTO `orders` VALUES (2690,'RT20260704002690',96,'PAID','2026-07-04 13:21:10','2026-07-04 14:06:10',111.00,'小程序');

INSERT INTO `orders` VALUES (2691,'RT20260704002691',101,'PAID','2026-07-04 13:32:58','2026-07-04 13:43:58',29.61,'小程序');

INSERT INTO `orders` VALUES (2692,'RT20260704002692',513,'PAID','2026-07-04 14:57:48','2026-07-04 15:01:48',104.50,'线下门店');

INSERT INTO `orders` VALUES (2693,'RT20260704002693',101,'PAID','2026-07-04 15:11:37','2026-07-04 15:17:37',516.00,'企业采购');

INSERT INTO `orders` VALUES (2694,'RT20260704002694',204,'PAID','2026-07-04 16:57:56','2026-07-04 17:41:56',74.10,'小程序');

INSERT INTO `orders` VALUES (2695,'RT20260704002695',488,'PAID','2026-07-04 17:35:56','2026-07-04 18:11:56',98.90,'线下门店');

INSERT INTO `orders` VALUES (2696,'RT20260704002696',219,'PAID','2026-07-04 17:38:52','2026-07-04 18:29:52',81.06,'企业采购');

INSERT INTO `orders` VALUES (2697,'RT20260704002697',52,'CANCELLED','2026-07-04 17:41:13',NULL,24.90,'官网');

INSERT INTO `orders` VALUES (2698,'RT20260704002698',346,'CANCELLED','2026-07-04 17:45:19',NULL,31.26,'企业采购');

INSERT INTO `orders` VALUES (2699,'RT20260704002699',506,'PAID','2026-07-04 19:30:11','2026-07-04 20:24:11',24.90,'线下门店');

INSERT INTO `orders` VALUES (2700,'RT20260705002700',499,'CANCELLED','2026-07-05 11:56:23',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (2701,'RT20260705002701',350,'PAID','2026-07-05 13:19:47','2026-07-05 14:34:47',337.10,'线下门店');

INSERT INTO `orders` VALUES (2702,'RT20260705002702',63,'PAID','2026-07-05 13:37:15','2026-07-05 13:57:15',37.91,'官网');

INSERT INTO `orders` VALUES (2703,'RT20260705002703',46,'PAID','2026-07-05 14:20:30','2026-07-05 15:08:30',83.90,'小程序');

INSERT INTO `orders` VALUES (2704,'RT20260705002704',415,'PAID','2026-07-05 15:14:00','2026-07-05 16:12:00',78.90,'企业采购');

INSERT INTO `orders` VALUES (2705,'RT20260705002705',243,'PAID','2026-07-05 17:17:03','2026-07-05 17:26:03',118.00,'小程序');

INSERT INTO `orders` VALUES (2706,'RT20260705002706',21,'PAID','2026-07-05 17:53:40','2026-07-05 18:23:40',24.90,'线下门店');

INSERT INTO `orders` VALUES (2707,'RT20260705002707',392,'PAID','2026-07-05 18:15:26','2026-07-05 19:19:26',64.60,'小程序');

INSERT INTO `orders` VALUES (2708,'RT20260705002708',166,'PAID','2026-07-05 18:26:52','2026-07-05 18:48:52',32.90,'小程序');

INSERT INTO `orders` VALUES (2709,'RT20260705002709',293,'PAID','2026-07-05 18:51:23','2026-07-05 18:54:23',69.00,'线下门店');

INSERT INTO `orders` VALUES (2710,'RT20260705002710',170,'PAID','2026-07-05 18:57:32','2026-07-05 19:57:32',65.80,'线下门店');

INSERT INTO `orders` VALUES (2711,'RT20260705002711',594,'PAID','2026-07-05 19:14:29','2026-07-05 19:27:29',79.00,'官网');

INSERT INTO `orders` VALUES (2712,'RT20260705002712',474,'PAID','2026-07-05 21:17:47','2026-07-05 22:24:47',207.00,'小程序');

INSERT INTO `orders` VALUES (2713,'RT20260706002713',117,'PAID','2026-07-06 11:41:18','2026-07-06 11:59:18',265.60,'小程序');

INSERT INTO `orders` VALUES (2714,'RT20260706002714',509,'PAID','2026-07-06 14:02:08','2026-07-06 14:10:08',89.00,'小程序');

INSERT INTO `orders` VALUES (2715,'RT20260706002715',329,'PAID','2026-07-06 14:35:32','2026-07-06 14:55:32',151.05,'官网');

INSERT INTO `orders` VALUES (2716,'RT20260706002716',232,'PAID','2026-07-06 15:10:21','2026-07-06 16:09:21',74.70,'官网');

INSERT INTO `orders` VALUES (2717,'RT20260706002717',304,'PAID','2026-07-06 15:22:28','2026-07-06 15:29:28',59.00,'小程序');

INSERT INTO `orders` VALUES (2718,'RT20260706002718',187,'PAID','2026-07-06 15:41:12','2026-07-06 16:30:12',232.90,'线下门店');

INSERT INTO `orders` VALUES (2719,'RT20260706002719',556,'PAID','2026-07-06 16:53:55','2026-07-06 17:50:55',129.00,'小程序');

INSERT INTO `orders` VALUES (2720,'RT20260706002720',43,'PAID','2026-07-06 18:07:41','2026-07-06 18:20:41',237.90,'小程序');

INSERT INTO `orders` VALUES (2721,'RT20260706002721',303,'PAID','2026-07-06 18:09:02','2026-07-06 18:28:02',79.00,'小程序');

INSERT INTO `orders` VALUES (2722,'RT20260706002722',230,'PAID','2026-07-06 18:33:14','2026-07-06 18:53:14',62.10,'小程序');

INSERT INTO `orders` VALUES (2723,'RT20260706002723',11,'PAID','2026-07-06 18:52:58','2026-07-06 19:30:58',22.41,'线下门店');

INSERT INTO `orders` VALUES (2724,'RT20260706002724',301,'PAID','2026-07-06 21:28:31','2026-07-06 21:32:31',79.00,'官网');

INSERT INTO `orders` VALUES (2725,'RT20260706002725',340,'PAID','2026-07-06 21:33:49','2026-07-06 21:50:49',89.00,'线下门店');

INSERT INTO `orders` VALUES (2726,'RT20260707002726',63,'PAID','2026-07-07 10:14:05','2026-07-07 10:19:05',24.90,'小程序');

INSERT INTO `orders` VALUES (2727,'RT20260707002727',619,'PAID','2026-07-07 12:10:52','2026-07-07 12:31:52',59.00,'线下门店');

INSERT INTO `orders` VALUES (2728,'RT20260707002728',501,'REFUNDED','2026-07-07 14:28:30','2026-07-07 15:24:30',39.90,'线下门店');

INSERT INTO `orders` VALUES (2729,'RT20260707002729',73,'PAID','2026-07-07 15:47:26','2026-07-07 15:58:26',227.00,'官网');

INSERT INTO `orders` VALUES (2730,'RT20260707002730',521,'PAID','2026-07-07 16:01:14','2026-07-07 16:55:14',2026.00,'小程序');

INSERT INTO `orders` VALUES (2731,'RT20260707002731',628,'PAID','2026-07-07 16:43:15','2026-07-07 17:43:15',234.55,'小程序');

INSERT INTO `orders` VALUES (2732,'RT20260707002732',147,'PAID','2026-07-07 18:21:14','2026-07-07 18:37:14',387.00,'线下门店');

INSERT INTO `orders` VALUES (2733,'RT20260707002733',18,'PAID','2026-07-07 19:12:07','2026-07-07 19:14:07',56.16,'官网');

INSERT INTO `orders` VALUES (2734,'RT20260707002734',590,'PAID','2026-07-07 22:45:24','2026-07-07 23:08:24',89.00,'小程序');

INSERT INTO `orders` VALUES (2735,'RT20260708002735',259,'PAID','2026-07-08 10:35:40','2026-07-08 11:44:40',193.90,'官网');

INSERT INTO `orders` VALUES (2736,'RT20260708002736',510,'PAID','2026-07-08 11:40:15','2026-07-08 12:40:15',56.05,'小程序');

INSERT INTO `orders` VALUES (2737,'RT20260708002737',527,'PAID','2026-07-08 13:13:07','2026-07-08 13:59:07',545.00,'小程序');

INSERT INTO `orders` VALUES (2738,'RT20260708002738',476,'PAID','2026-07-08 13:37:24','2026-07-08 13:52:24',250.90,'线下门店');

INSERT INTO `orders` VALUES (2739,'RT20260708002739',183,'PAID','2026-07-08 14:07:58','2026-07-08 15:17:58',208.82,'官网');

INSERT INTO `orders` VALUES (2740,'RT20260708002740',218,'PAID','2026-07-08 15:37:03','2026-07-08 16:51:03',114.05,'小程序');

INSERT INTO `orders` VALUES (2741,'RT20260708002741',583,'PAID','2026-07-08 18:12:15','2026-07-08 18:21:15',151.90,'线下门店');

INSERT INTO `orders` VALUES (2742,'RT20260708002742',133,'PAID','2026-07-08 19:59:41','2026-07-08 20:59:41',136.00,'线下门店');

INSERT INTO `orders` VALUES (2743,'RT20260708002743',359,'PAID','2026-07-08 20:27:06','2026-07-08 20:29:06',29.61,'线下门店');

INSERT INTO `orders` VALUES (2744,'RT20260709002744',212,'PAID','2026-07-09 08:24:56','2026-07-09 08:53:56',169.10,'小程序');

INSERT INTO `orders` VALUES (2745,'RT20260709002745',237,'PAID','2026-07-09 11:00:08','2026-07-09 11:16:08',192.90,'线下门店');

INSERT INTO `orders` VALUES (2746,'RT20260709002746',175,'PAID','2026-07-09 11:54:18','2026-07-09 12:18:18',264.91,'官网');

INSERT INTO `orders` VALUES (2747,'RT20260709002747',103,'REFUNDED','2026-07-09 12:15:39','2026-07-09 12:26:39',75.05,'线下门店');

INSERT INTO `orders` VALUES (2748,'RT20260709002748',181,'CANCELLED','2026-07-09 12:56:41',NULL,60.81,'小程序');

INSERT INTO `orders` VALUES (2749,'RT20260709002749',382,'PAID','2026-07-09 13:07:33','2026-07-09 14:04:33',151.05,'小程序');

INSERT INTO `orders` VALUES (2750,'RT20260709002750',388,'PAID','2026-07-09 16:38:01','2026-07-09 17:25:01',199.00,'小程序');

INSERT INTO `orders` VALUES (2751,'RT20260709002751',45,'PAID','2026-07-09 18:45:26','2026-07-09 19:32:26',32.90,'小程序');

INSERT INTO `orders` VALUES (2752,'RT20260709002752',4,'PAID','2026-07-09 19:09:50','2026-07-09 19:30:50',59.57,'线下门店');

INSERT INTO `orders` VALUES (2753,'RT20260710002753',166,'PAID','2026-07-10 10:26:03','2026-07-10 11:20:03',68.00,'线下门店');

INSERT INTO `orders` VALUES (2754,'RT20260710002754',3,'PAID','2026-07-10 10:33:00','2026-07-10 11:35:00',359.10,'官网');

INSERT INTO `orders` VALUES (2755,'RT20260710002755',82,'PAID','2026-07-10 11:28:05','2026-07-10 12:10:05',23.66,'线下门店');

INSERT INTO `orders` VALUES (2756,'RT20260710002756',11,'PAID','2026-07-10 12:33:12','2026-07-10 13:15:12',32.90,'小程序');

INSERT INTO `orders` VALUES (2757,'RT20260710002757',21,'PAID','2026-07-10 13:01:13','2026-07-10 13:46:13',179.71,'官网');

INSERT INTO `orders` VALUES (2758,'RT20260710002758',3,'PAID','2026-07-10 14:52:59','2026-07-10 14:54:59',774.95,'官网');

INSERT INTO `orders` VALUES (2759,'RT20260710002759',175,'PAID','2026-07-10 15:09:04','2026-07-10 15:26:04',89.00,'小程序');

INSERT INTO `orders` VALUES (2760,'RT20260710002760',304,'PAID','2026-07-10 16:24:15','2026-07-10 17:31:15',136.00,'小程序');

INSERT INTO `orders` VALUES (2761,'RT20260710002761',461,'PAID','2026-07-10 16:36:22','2026-07-10 17:48:22',79.00,'小程序');

INSERT INTO `orders` VALUES (2762,'RT20260710002762',141,'PAID','2026-07-10 16:36:38','2026-07-10 16:56:38',92.10,'小程序');

INSERT INTO `orders` VALUES (2763,'RT20260710002763',126,'PAID','2026-07-10 18:26:39','2026-07-10 18:53:39',68.00,'小程序');

INSERT INTO `orders` VALUES (2764,'RT20260710002764',286,'PAID','2026-07-10 18:57:21','2026-07-10 19:23:21',211.10,'小程序');

INSERT INTO `orders` VALUES (2765,'RT20260710002765',242,'CANCELLED','2026-07-10 19:10:17',NULL,159.00,'官网');

INSERT INTO `orders` VALUES (2766,'RT20260710002766',205,'CANCELLED','2026-07-10 21:04:21',NULL,199.00,'官网');

INSERT INTO `orders` VALUES (2767,'RT20260710002767',120,'PAID','2026-07-10 21:39:16','2026-07-10 22:27:16',168.00,'小程序');

INSERT INTO `orders` VALUES (2768,'RT20260711002768',586,'PAID','2026-07-11 09:12:30','2026-07-11 10:14:30',32.90,'企业采购');

INSERT INTO `orders` VALUES (2769,'RT20260711002769',221,'PAID','2026-07-11 11:42:09','2026-07-11 11:50:09',68.00,'小程序');

INSERT INTO `orders` VALUES (2770,'RT20260711002770',197,'PAID','2026-07-11 12:20:29','2026-07-11 12:50:29',169.00,'小程序');

INSERT INTO `orders` VALUES (2771,'RT20260711002771',316,'PAID','2026-07-11 14:01:33','2026-07-11 14:50:33',56.05,'小程序');

INSERT INTO `orders` VALUES (2772,'RT20260711002772',266,'PAID','2026-07-11 14:10:19','2026-07-11 14:44:19',63.90,'小程序');

INSERT INTO `orders` VALUES (2773,'RT20260711002773',71,'PAID','2026-07-11 14:46:38','2026-07-11 15:30:38',114.95,'线下门店');

INSERT INTO `orders` VALUES (2774,'RT20260711002774',222,'CANCELLED','2026-07-11 15:01:45',NULL,92.36,'小程序');

INSERT INTO `orders` VALUES (2775,'RT20260711002775',249,'PAID','2026-07-11 16:06:25','2026-07-11 16:26:25',108.90,'小程序');

INSERT INTO `orders` VALUES (2776,'RT20260711002776',353,'PAID','2026-07-11 17:25:44','2026-07-11 18:35:44',39.00,'小程序');

INSERT INTO `orders` VALUES (2777,'RT20260711002777',50,'PAID','2026-07-11 20:11:46','2026-07-11 21:16:46',56.05,'小程序');

INSERT INTO `orders` VALUES (2778,'RT20260711002778',77,'PAID','2026-07-11 20:53:12','2026-07-11 21:07:12',39.90,'官网');

INSERT INTO `orders` VALUES (2779,'RT20260711002779',175,'PAID','2026-07-11 21:48:55','2026-07-11 22:42:55',74.70,'官网');

INSERT INTO `orders` VALUES (2780,'RT20260712002780',154,'PAID','2026-07-12 12:34:28','2026-07-12 12:45:28',79.00,'线下门店');

INSERT INTO `orders` VALUES (2781,'RT20260712002781',267,'CANCELLED','2026-07-12 12:44:19',NULL,80.10,'线下门店');

INSERT INTO `orders` VALUES (2782,'RT20260712002782',298,'CANCELLED','2026-07-12 13:12:40',NULL,24.90,'官网');

INSERT INTO `orders` VALUES (2783,'RT20260712002783',284,'PAID','2026-07-12 14:25:31','2026-07-12 15:23:31',78.00,'线下门店');

INSERT INTO `orders` VALUES (2784,'RT20260712002784',5,'PAID','2026-07-12 15:03:51','2026-07-12 15:57:51',35.10,'线下门店');

INSERT INTO `orders` VALUES (2785,'RT20260712002785',55,'PAID','2026-07-12 15:24:00','2026-07-12 16:14:00',169.00,'小程序');

INSERT INTO `orders` VALUES (2786,'RT20260712002786',75,'PAID','2026-07-12 17:26:37','2026-07-12 17:34:37',32.90,'小程序');

INSERT INTO `orders` VALUES (2787,'RT20260712002787',468,'PAID','2026-07-12 18:28:41','2026-07-12 19:02:41',150.10,'小程序');

INSERT INTO `orders` VALUES (2788,'RT20260712002788',217,'PAID','2026-07-12 19:03:08','2026-07-12 20:00:08',287.56,'官网');

INSERT INTO `orders` VALUES (2789,'RT20260712002789',307,'PAID','2026-07-12 19:52:58','2026-07-12 19:56:58',747.30,'官网');

INSERT INTO `orders` VALUES (2790,'RT20260713002790',404,'PAID','2026-07-13 10:36:48','2026-07-13 11:11:48',227.00,'官网');

INSERT INTO `orders` VALUES (2791,'RT20260713002791',4,'PAID','2026-07-13 11:25:16','2026-07-13 12:24:16',238.00,'线下门店');

INSERT INTO `orders` VALUES (2792,'RT20260713002792',440,'PAID','2026-07-13 15:42:27','2026-07-13 16:28:27',39.90,'线下门店');

INSERT INTO `orders` VALUES (2793,'RT20260713002793',143,'PAID','2026-07-13 17:39:22','2026-07-13 18:17:22',159.00,'线下门店');

INSERT INTO `orders` VALUES (2794,'RT20260713002794',150,'PAID','2026-07-13 19:01:04','2026-07-13 20:14:04',56.05,'小程序');

INSERT INTO `orders` VALUES (2795,'RT20260713002795',261,'PAID','2026-07-13 19:56:38','2026-07-13 21:03:38',171.10,'小程序');

INSERT INTO `orders` VALUES (2796,'RT20260713002796',206,'PAID','2026-07-13 21:05:23','2026-07-13 22:10:23',32.90,'小程序');

INSERT INTO `orders` VALUES (2797,'RT20260714002797',52,'CANCELLED','2026-07-14 13:08:40',NULL,78.90,'线下门店');

INSERT INTO `orders` VALUES (2798,'RT20260714002798',119,'PAID','2026-07-14 13:43:36','2026-07-14 14:48:36',24.90,'官网');

INSERT INTO `orders` VALUES (2799,'RT20260714002799',127,'PAID','2026-07-14 18:37:35','2026-07-14 19:38:35',39.90,'小程序');

INSERT INTO `orders` VALUES (2800,'RT20260714002800',57,'PAID','2026-07-14 19:24:57','2026-07-14 19:26:57',39.90,'企业采购');

INSERT INTO `orders` VALUES (2801,'RT20260714002801',355,'PAID','2026-07-14 19:57:59','2026-07-14 20:57:59',59.00,'官网');

INSERT INTO `orders` VALUES (2802,'RT20260714002802',100,'PAID','2026-07-14 21:59:39','2026-07-14 22:42:39',4338.00,'官网');

INSERT INTO `orders` VALUES (2803,'RT20260715002803',466,'PAID','2026-07-15 10:27:31','2026-07-15 10:37:31',306.00,'小程序');

INSERT INTO `orders` VALUES (2804,'RT20260715002804',63,'PAID','2026-07-15 13:48:48','2026-07-15 14:36:48',122.55,'小程序');

INSERT INTO `orders` VALUES (2805,'RT20260715002805',233,'PAID','2026-07-15 13:57:15','2026-07-15 14:37:15',159.00,'线下门店');

INSERT INTO `orders` VALUES (2806,'RT20260715002806',480,'PAID','2026-07-15 14:06:13','2026-07-15 15:20:13',24.90,'小程序');

INSERT INTO `orders` VALUES (2807,'RT20260715002807',231,'PAID','2026-07-15 14:13:32','2026-07-15 15:22:32',37.05,'官网');

INSERT INTO `orders` VALUES (2808,'RT20260715002808',361,'PAID','2026-07-15 15:58:58','2026-07-15 16:31:58',79.00,'线下门店');

INSERT INTO `orders` VALUES (2809,'RT20260715002809',261,'PAID','2026-07-15 17:58:31','2026-07-15 18:35:31',32.90,'小程序');

INSERT INTO `orders` VALUES (2810,'RT20260715002810',518,'PAID','2026-07-15 18:54:29','2026-07-15 19:41:29',24.90,'小程序');

INSERT INTO `orders` VALUES (2811,'RT20260716002811',4,'PAID','2026-07-16 12:53:00','2026-07-16 13:48:00',686.00,'小程序');

INSERT INTO `orders` VALUES (2812,'RT20260716002812',242,'PAID','2026-07-16 14:27:15','2026-07-16 15:40:15',568.00,'官网');

INSERT INTO `orders` VALUES (2813,'RT20260716002813',219,'PAID','2026-07-16 18:11:15','2026-07-16 19:05:15',59.00,'小程序');

INSERT INTO `orders` VALUES (2814,'RT20260716002814',25,'PAID','2026-07-16 19:28:51','2026-07-16 20:32:51',399.00,'小程序');

INSERT INTO `orders` VALUES (2815,'RT20260717002815',177,'CANCELLED','2026-07-17 09:26:10',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (2816,'RT20260717002816',563,'PAID','2026-07-17 10:08:51','2026-07-17 10:34:51',74.10,'线下门店');

INSERT INTO `orders` VALUES (2817,'RT20260717002817',245,'PAID','2026-07-17 10:39:39','2026-07-17 11:33:39',252.90,'官网');

INSERT INTO `orders` VALUES (2818,'RT20260717002818',361,'PAID','2026-07-17 11:47:40','2026-07-17 12:25:40',68.00,'线下门店');

INSERT INTO `orders` VALUES (2819,'RT20260717002819',495,'PAID','2026-07-17 12:01:32','2026-07-17 12:54:32',251.40,'小程序');

INSERT INTO `orders` VALUES (2820,'RT20260717002820',233,'PAID','2026-07-17 15:28:21','2026-07-17 16:35:21',24.90,'小程序');

INSERT INTO `orders` VALUES (2821,'RT20260717002821',187,'PAID','2026-07-17 15:37:10','2026-07-17 15:46:10',80.10,'线下门店');

INSERT INTO `orders` VALUES (2822,'RT20260717002822',113,'PAID','2026-07-17 17:04:54','2026-07-17 17:42:54',39.90,'线下门店');

INSERT INTO `orders` VALUES (2823,'RT20260717002823',234,'PAID','2026-07-17 17:13:55','2026-07-17 17:15:55',214.10,'官网');

INSERT INTO `orders` VALUES (2824,'RT20260717002824',129,'PAID','2026-07-17 19:47:12','2026-07-17 20:41:12',664.05,'小程序');

INSERT INTO `orders` VALUES (2825,'RT20260717002825',195,'PAID','2026-07-17 20:15:54','2026-07-17 20:24:54',227.00,'线下门店');

INSERT INTO `orders` VALUES (2826,'RT20260717002826',16,'PAID','2026-07-17 20:39:25','2026-07-17 21:32:25',379.05,'小程序');

INSERT INTO `orders` VALUES (2827,'RT20260717002827',84,'PAID','2026-07-17 20:41:44','2026-07-17 20:50:44',39.90,'线下门店');

INSERT INTO `orders` VALUES (2828,'RT20260717002828',75,'PAID','2026-07-17 20:58:31','2026-07-17 21:27:31',39.00,'企业采购');

INSERT INTO `orders` VALUES (2829,'RT20260718002829',228,'PAID','2026-07-18 09:05:59','2026-07-18 10:01:59',205.10,'企业采购');

INSERT INTO `orders` VALUES (2830,'RT20260718002830',30,'PAID','2026-07-18 12:41:09','2026-07-18 13:06:09',199.00,'小程序');

INSERT INTO `orders` VALUES (2831,'RT20260718002831',129,'PAID','2026-07-18 13:46:31','2026-07-18 14:29:31',47.31,'线下门店');

INSERT INTO `orders` VALUES (2832,'RT20260718002832',202,'PAID','2026-07-18 14:16:13','2026-07-18 14:40:13',798.00,'官网');

INSERT INTO `orders` VALUES (2833,'RT20260718002833',203,'CANCELLED','2026-07-18 16:37:23',NULL,129.00,'小程序');

INSERT INTO `orders` VALUES (2834,'RT20260718002834',230,'PAID','2026-07-18 17:23:03','2026-07-18 17:37:03',110.01,'小程序');

INSERT INTO `orders` VALUES (2835,'RT20260718002835',486,'PAID','2026-07-18 18:14:17','2026-07-18 19:29:17',276.90,'小程序');

INSERT INTO `orders` VALUES (2836,'RT20260718002836',61,'CANCELLED','2026-07-18 18:37:06',NULL,148.00,'官网');

INSERT INTO `orders` VALUES (2837,'RT20260718002837',169,'PAID','2026-07-18 18:37:11','2026-07-18 19:14:11',119.70,'官网');

INSERT INTO `orders` VALUES (2838,'RT20260718002838',139,'PAID','2026-07-18 19:38:12','2026-07-18 20:31:12',159.00,'线下门店');

INSERT INTO `orders` VALUES (2839,'RT20260719002839',49,'PAID','2026-07-19 10:12:36','2026-07-19 11:20:36',24.90,'线下门店');

INSERT INTO `orders` VALUES (2840,'RT20260719002840',478,'REFUNDED','2026-07-19 10:17:12','2026-07-19 10:56:12',183.00,'小程序');

INSERT INTO `orders` VALUES (2841,'RT20260719002841',496,'PAID','2026-07-19 11:39:01','2026-07-19 12:00:01',143.05,'线下门店');

INSERT INTO `orders` VALUES (2842,'RT20260719002842',39,'PAID','2026-07-19 13:17:03','2026-07-19 14:30:03',53.10,'小程序');

INSERT INTO `orders` VALUES (2843,'RT20260719002843',633,'PAID','2026-07-19 13:37:18','2026-07-19 14:05:18',1338.00,'小程序');

INSERT INTO `orders` VALUES (2844,'RT20260719002844',170,'PAID','2026-07-19 14:23:57','2026-07-19 14:34:57',37.91,'线下门店');

INSERT INTO `orders` VALUES (2845,'RT20260719002845',334,'PAID','2026-07-19 14:39:43','2026-07-19 15:03:43',32.90,'小程序');

INSERT INTO `orders` VALUES (2846,'RT20260719002846',152,'PAID','2026-07-19 15:49:55','2026-07-19 16:20:55',108.00,'线下门店');

INSERT INTO `orders` VALUES (2847,'RT20260719002847',230,'PAID','2026-07-19 17:25:37','2026-07-19 17:59:37',65.80,'官网');

INSERT INTO `orders` VALUES (2848,'RT20260719002848',85,'PAID','2026-07-19 19:35:46','2026-07-19 20:13:46',151.05,'小程序');

INSERT INTO `orders` VALUES (2849,'RT20260719002849',522,'PAID','2026-07-19 19:57:20','2026-07-19 20:42:20',37.91,'小程序');

INSERT INTO `orders` VALUES (2850,'RT20260719002850',155,'PAID','2026-07-19 20:49:12','2026-07-19 21:19:12',23.66,'线下门店');

INSERT INTO `orders` VALUES (2851,'RT20260719002851',62,'PAID','2026-07-19 21:48:28','2026-07-19 21:54:28',159.00,'线下门店');

INSERT INTO `orders` VALUES (2852,'RT20260720002852',233,'PAID','2026-07-20 08:40:11','2026-07-20 09:22:11',69.00,'小程序');

INSERT INTO `orders` VALUES (2853,'RT20260720002853',325,'PAID','2026-07-20 09:09:30','2026-07-20 09:10:30',39.90,'线下门店');

INSERT INTO `orders` VALUES (2854,'RT20260720002854',438,'PAID','2026-07-20 11:31:27','2026-07-20 12:16:27',326.00,'官网');

INSERT INTO `orders` VALUES (2855,'RT20260720002855',124,'PAID','2026-07-20 11:38:19','2026-07-20 12:17:19',230.10,'小程序');

INSERT INTO `orders` VALUES (2856,'RT20260720002856',252,'PAID','2026-07-20 12:04:56','2026-07-20 12:12:56',199.00,'官网');

INSERT INTO `orders` VALUES (2857,'RT20260720002857',577,'REFUNDED','2026-07-20 13:01:12','2026-07-20 14:15:12',177.00,'小程序');

INSERT INTO `orders` VALUES (2858,'RT20260720002858',321,'PAID','2026-07-20 13:11:51','2026-07-20 13:53:51',201.15,'官网');

INSERT INTO `orders` VALUES (2859,'RT20260720002859',502,'PAID','2026-07-20 18:14:44','2026-07-20 18:20:44',59.00,'小程序');

INSERT INTO `orders` VALUES (2860,'RT20260720002860',24,'PAID','2026-07-20 18:20:44','2026-07-20 19:11:44',745.00,'官网');

INSERT INTO `orders` VALUES (2861,'RT20260720002861',407,'CANCELLED','2026-07-20 19:40:26',NULL,142.31,'官网');

INSERT INTO `orders` VALUES (2862,'RT20260720002862',133,'PAID','2026-07-20 20:21:11','2026-07-20 20:37:11',24.90,'小程序');

INSERT INTO `orders` VALUES (2863,'RT20260720002863',249,'PAID','2026-07-20 20:28:57','2026-07-20 21:35:57',240.30,'官网');

INSERT INTO `orders` VALUES (2864,'RT20260720002864',132,'CANCELLED','2026-07-20 20:45:32',NULL,159.00,'线下门店');

INSERT INTO `orders` VALUES (2865,'RT20260721002865',40,'PAID','2026-07-21 12:08:26','2026-07-21 12:11:26',148.00,'官网');

INSERT INTO `orders` VALUES (2866,'RT20260721002866',14,'PAID','2026-07-21 14:35:59','2026-07-21 14:54:59',32.90,'官网');

INSERT INTO `orders` VALUES (2867,'RT20260721002867',301,'PAID','2026-07-21 17:30:17','2026-07-21 18:05:17',129.00,'线下门店');

INSERT INTO `orders` VALUES (2868,'RT20260721002868',194,'PAID','2026-07-21 17:41:23','2026-07-21 17:56:23',4299.00,'线下门店');

INSERT INTO `orders` VALUES (2869,'RT20260721002869',46,'PAID','2026-07-21 18:47:07','2026-07-21 19:03:07',44.82,'线下门店');

INSERT INTO `orders` VALUES (2870,'RT20260721002870',140,'PAID','2026-07-21 18:52:44','2026-07-21 19:15:44',193.90,'小程序');

INSERT INTO `orders` VALUES (2871,'RT20260721002871',242,'PAID','2026-07-21 18:57:04','2026-07-21 19:33:04',159.00,'小程序');

INSERT INTO `orders` VALUES (2872,'RT20260721002872',227,'PAID','2026-07-21 21:25:05','2026-07-21 21:26:05',65.55,'小程序');

INSERT INTO `orders` VALUES (2873,'RT20260722002873',30,'PAID','2026-07-22 10:29:18','2026-07-22 11:00:18',65.55,'小程序');

INSERT INTO `orders` VALUES (2874,'RT20260722002874',383,'PAID','2026-07-22 10:45:17','2026-07-22 11:58:17',49.80,'线下门店');

INSERT INTO `orders` VALUES (2875,'RT20260722002875',433,'PAID','2026-07-22 14:08:42','2026-07-22 14:41:42',29.61,'线下门店');

INSERT INTO `orders` VALUES (2876,'RT20260722002876',205,'PAID','2026-07-22 17:51:18','2026-07-22 17:55:18',138.00,'小程序');

INSERT INTO `orders` VALUES (2877,'RT20260722002877',116,'PAID','2026-07-22 18:18:27','2026-07-22 18:30:27',68.00,'线下门店');

INSERT INTO `orders` VALUES (2878,'RT20260722002878',300,'PAID','2026-07-22 18:44:13','2026-07-22 18:46:13',119.70,'小程序');

INSERT INTO `orders` VALUES (2879,'RT20260722002879',171,'REFUNDED','2026-07-22 18:46:25','2026-07-22 19:39:25',79.00,'官网');

INSERT INTO `orders` VALUES (2880,'RT20260722002880',24,'PAID','2026-07-22 19:31:06','2026-07-22 19:36:06',78.00,'小程序');

INSERT INTO `orders` VALUES (2881,'RT20260722002881',19,'PAID','2026-07-22 20:09:11','2026-07-22 20:34:11',233.35,'小程序');

INSERT INTO `orders` VALUES (2882,'RT20260722002882',344,'PAID','2026-07-22 20:41:09','2026-07-22 21:24:09',286.00,'小程序');

INSERT INTO `orders` VALUES (2883,'RT20260722002883',304,'PAID','2026-07-22 20:54:51','2026-07-22 21:56:51',78.90,'线下门店');

INSERT INTO `orders` VALUES (2884,'RT20260723002884',343,'PAID','2026-07-23 11:12:50','2026-07-23 12:25:50',31.26,'小程序');

INSERT INTO `orders` VALUES (2885,'RT20260723002885',100,'PAID','2026-07-23 11:14:58','2026-07-23 11:44:58',59.00,'小程序');

INSERT INTO `orders` VALUES (2886,'RT20260723002886',144,'PAID','2026-07-23 13:14:41','2026-07-23 13:31:41',129.00,'小程序');

INSERT INTO `orders` VALUES (2887,'RT20260723002887',18,'PAID','2026-07-23 13:35:33','2026-07-23 14:46:33',169.00,'小程序');

INSERT INTO `orders` VALUES (2888,'RT20260723002888',342,'PAID','2026-07-23 16:35:10','2026-07-23 16:49:10',457.00,'小程序');

INSERT INTO `orders` VALUES (2889,'RT20260723002889',56,'PAID','2026-07-23 18:11:26','2026-07-23 19:05:26',160.55,'线下门店');

INSERT INTO `orders` VALUES (2890,'RT20260723002890',127,'PAID','2026-07-23 21:56:19','2026-07-23 23:09:19',83.90,'小程序');

INSERT INTO `orders` VALUES (2891,'RT20260724002891',294,'PAID','2026-07-24 08:46:00','2026-07-24 09:16:00',39.90,'线下门店');

INSERT INTO `orders` VALUES (2892,'RT20260724002892',502,'PAID','2026-07-24 09:27:10','2026-07-24 09:40:10',32.90,'线下门店');

INSERT INTO `orders` VALUES (2893,'RT20260724002893',354,'PAID','2026-07-24 12:55:42','2026-07-24 14:09:42',76.91,'官网');

INSERT INTO `orders` VALUES (2894,'RT20260724002894',285,'REFUNDED','2026-07-24 14:07:38','2026-07-24 15:00:38',53.10,'官网');

INSERT INTO `orders` VALUES (2895,'RT20260724002895',437,'PAID','2026-07-24 14:55:30','2026-07-24 15:46:30',247.00,'小程序');

INSERT INTO `orders` VALUES (2896,'RT20260724002896',389,'PAID','2026-07-24 16:08:15','2026-07-24 16:31:15',89.00,'线下门店');

INSERT INTO `orders` VALUES (2897,'RT20260724002897',301,'PAID','2026-07-24 16:18:06','2026-07-24 16:34:06',215.05,'线下门店');

INSERT INTO `orders` VALUES (2898,'RT20260724002898',18,'PAID','2026-07-24 18:25:28','2026-07-24 18:36:28',179.01,'企业采购');

INSERT INTO `orders` VALUES (2899,'RT20260725002899',53,'PAID','2026-07-25 11:12:34','2026-07-25 11:27:34',178.00,'线下门店');

INSERT INTO `orders` VALUES (2900,'RT20260725002900',631,'PAID','2026-07-25 14:17:14','2026-07-25 15:27:14',89.00,'小程序');

INSERT INTO `orders` VALUES (2901,'RT20260725002901',603,'CANCELLED','2026-07-25 15:28:48',NULL,357.90,'企业采购');

INSERT INTO `orders` VALUES (2902,'RT20260725002902',567,'PAID','2026-07-25 15:30:54','2026-07-25 15:41:54',59.00,'小程序');

INSERT INTO `orders` VALUES (2903,'RT20260725002903',194,'PAID','2026-07-25 15:50:51','2026-07-25 16:57:51',39.90,'线下门店');

INSERT INTO `orders` VALUES (2904,'RT20260725002904',161,'CANCELLED','2026-07-25 16:09:01',NULL,159.00,'线下门店');

INSERT INTO `orders` VALUES (2905,'RT20260725002905',86,'PAID','2026-07-25 16:22:10','2026-07-25 17:33:10',39.00,'小程序');

INSERT INTO `orders` VALUES (2906,'RT20260725002906',427,'CANCELLED','2026-07-25 16:35:51',NULL,121.90,'小程序');

INSERT INTO `orders` VALUES (2907,'RT20260725002907',514,'PAID','2026-07-25 16:52:42','2026-07-25 17:14:42',422.66,'企业采购');

INSERT INTO `orders` VALUES (2908,'RT20260725002908',228,'CANCELLED','2026-07-25 17:29:41',NULL,37.91,'线下门店');

INSERT INTO `orders` VALUES (2909,'RT20260725002909',306,'PAID','2026-07-25 17:54:19','2026-07-25 18:16:19',273.90,'官网');

INSERT INTO `orders` VALUES (2910,'RT20260725002910',514,'PAID','2026-07-25 18:05:39','2026-07-25 18:06:39',69.00,'小程序');

INSERT INTO `orders` VALUES (2911,'RT20260725002911',147,'PAID','2026-07-25 20:30:20','2026-07-25 20:46:20',299.00,'官网');

INSERT INTO `orders` VALUES (2912,'RT20260726002912',467,'PAID','2026-07-26 11:00:28','2026-07-26 12:09:28',39.90,'官网');

INSERT INTO `orders` VALUES (2913,'RT20260726002913',306,'PAID','2026-07-26 15:06:55','2026-07-26 15:07:55',117.00,'官网');

INSERT INTO `orders` VALUES (2914,'RT20260726002914',369,'CANCELLED','2026-07-26 15:43:29',NULL,111.90,'官网');

INSERT INTO `orders` VALUES (2915,'RT20260726002915',546,'PAID','2026-07-26 16:28:29','2026-07-26 16:51:29',118.00,'线下门店');

INSERT INTO `orders` VALUES (2916,'RT20260726002916',213,'PAID','2026-07-26 16:33:40','2026-07-26 17:11:40',199.00,'小程序');

INSERT INTO `orders` VALUES (2917,'RT20260726002917',241,'PAID','2026-07-26 17:13:43','2026-07-26 18:02:43',136.00,'线下门店');

INSERT INTO `orders` VALUES (2918,'RT20260726002918',19,'CANCELLED','2026-07-26 18:15:18',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (2919,'RT20260727002919',53,'PAID','2026-07-27 10:26:51','2026-07-27 11:11:51',363.00,'小程序');

INSERT INTO `orders` VALUES (2920,'RT20260727002920',15,'PAID','2026-07-27 11:21:35','2026-07-27 12:00:35',35.91,'小程序');

INSERT INTO `orders` VALUES (2921,'RT20260727002921',603,'PAID','2026-07-27 13:14:05','2026-07-27 13:41:05',267.00,'官网');

INSERT INTO `orders` VALUES (2922,'RT20260727002922',206,'PAID','2026-07-27 15:18:49','2026-07-27 15:20:49',178.00,'企业采购');

INSERT INTO `orders` VALUES (2923,'RT20260727002923',556,'PAID','2026-07-27 16:40:54','2026-07-27 17:37:54',165.05,'小程序');

INSERT INTO `orders` VALUES (2924,'RT20260727002924',16,'REFUNDED','2026-07-27 20:43:58','2026-07-27 21:49:58',260.20,'小程序');

INSERT INTO `orders` VALUES (2925,'RT20260728002925',213,'PAID','2026-07-28 08:29:30','2026-07-28 08:37:30',809.10,'小程序');

INSERT INTO `orders` VALUES (2926,'RT20260728002926',157,'PAID','2026-07-28 09:06:23','2026-07-28 10:09:23',39.00,'小程序');

INSERT INTO `orders` VALUES (2927,'RT20260728002927',215,'PAID','2026-07-28 10:10:15','2026-07-28 10:24:15',75.05,'线下门店');

INSERT INTO `orders` VALUES (2928,'RT20260728002928',374,'REFUNDED','2026-07-28 11:05:27','2026-07-28 12:09:27',83.90,'官网');

INSERT INTO `orders` VALUES (2929,'RT20260728002929',33,'PAID','2026-07-28 11:34:52','2026-07-28 11:39:52',699.00,'小程序');

INSERT INTO `orders` VALUES (2930,'RT20260728002930',212,'PAID','2026-07-28 15:02:19','2026-07-28 15:54:19',477.00,'官网');

INSERT INTO `orders` VALUES (2931,'RT20260728002931',389,'PAID','2026-07-28 16:23:30','2026-07-28 16:36:30',112.70,'小程序');

INSERT INTO `orders` VALUES (2932,'RT20260728002932',152,'PAID','2026-07-28 17:57:38','2026-07-28 18:43:38',84.55,'官网');

INSERT INTO `orders` VALUES (2933,'RT20260728002933',135,'PAID','2026-07-28 20:19:12','2026-07-28 21:26:12',362.90,'线下门店');

INSERT INTO `orders` VALUES (2934,'RT20260728002934',189,'PAID','2026-07-28 21:05:36','2026-07-28 22:03:36',603.91,'小程序');

INSERT INTO `orders` VALUES (2935,'RT20260729002935',94,'PAID','2026-07-29 12:10:27','2026-07-29 13:07:27',129.00,'小程序');

INSERT INTO `orders` VALUES (2936,'RT20260729002936',270,'PAID','2026-07-29 12:51:46','2026-07-29 13:15:46',56.05,'小程序');

INSERT INTO `orders` VALUES (2937,'RT20260729002937',394,'PAID','2026-07-29 15:08:40','2026-07-29 15:22:40',169.00,'小程序');

INSERT INTO `orders` VALUES (2938,'RT20260729002938',353,'CANCELLED','2026-07-29 15:26:51',NULL,153.10,'小程序');

INSERT INTO `orders` VALUES (2939,'RT20260729002939',472,'PAID','2026-07-29 15:47:08','2026-07-29 16:00:08',257.10,'官网');

INSERT INTO `orders` VALUES (2940,'RT20260729002940',350,'PAID','2026-07-29 17:46:00','2026-07-29 17:50:00',22.41,'小程序');

INSERT INTO `orders` VALUES (2941,'RT20260729002941',182,'PAID','2026-07-29 17:52:36','2026-07-29 18:32:36',71.10,'线下门店');

INSERT INTO `orders` VALUES (2942,'RT20260729002942',138,'PAID','2026-07-29 18:49:21','2026-07-29 18:53:21',196.65,'官网');

INSERT INTO `orders` VALUES (2943,'RT20260729002943',95,'PAID','2026-07-29 20:29:06','2026-07-29 20:40:06',1467.00,'小程序');

INSERT INTO `orders` VALUES (2944,'RT20260729002944',27,'CANCELLED','2026-07-29 21:22:49',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (2945,'RT20260730002945',342,'PAID','2026-07-30 10:22:06','2026-07-30 11:07:06',65.80,'线下门店');

INSERT INTO `orders` VALUES (2946,'RT20260730002946',3,'PAID','2026-07-30 12:16:33','2026-07-30 12:34:33',258.00,'小程序');

INSERT INTO `orders` VALUES (2947,'RT20260730002947',160,'PAID','2026-07-30 12:47:14','2026-07-30 13:20:14',201.90,'官网');

INSERT INTO `orders` VALUES (2948,'RT20260730002948',511,'PAID','2026-07-30 13:18:59','2026-07-30 13:30:59',39.00,'小程序');

INSERT INTO `orders` VALUES (2949,'RT20260730002949',273,'PAID','2026-07-30 16:08:55','2026-07-30 17:09:55',70.20,'小程序');

INSERT INTO `orders` VALUES (2950,'RT20260730002950',21,'PAID','2026-07-30 16:09:10','2026-07-30 16:29:10',159.00,'小程序');

INSERT INTO `orders` VALUES (2951,'RT20260730002951',4,'PAID','2026-07-30 16:34:38','2026-07-30 17:44:38',79.00,'小程序');

INSERT INTO `orders` VALUES (2952,'RT20260730002952',511,'PAID','2026-07-30 20:03:30','2026-07-30 20:04:30',68.00,'企业采购');

INSERT INTO `orders` VALUES (2953,'RT20260730002953',181,'PAID','2026-07-30 20:06:14','2026-07-30 20:28:14',39.90,'线下门店');

INSERT INTO `orders` VALUES (2954,'RT20260731002954',25,'PAID','2026-07-31 19:54:29','2026-07-31 20:51:29',136.00,'小程序');

INSERT INTO `orders` VALUES (2955,'RT20260731002955',527,'PAID','2026-07-31 20:28:45','2026-07-31 21:23:45',89.00,'官网');

INSERT INTO `orders` VALUES (2956,'RT20260801002956',160,'CANCELLED','2026-08-01 10:42:25',NULL,256.90,'线下门店');

INSERT INTO `orders` VALUES (2957,'RT20260801002957',434,'PAID','2026-08-01 13:40:53','2026-08-01 14:24:53',218.00,'小程序');

INSERT INTO `orders` VALUES (2958,'RT20260801002958',484,'PAID','2026-08-01 17:15:52','2026-08-01 18:29:52',37.91,'小程序');

INSERT INTO `orders` VALUES (2959,'RT20260801002959',65,'PAID','2026-08-01 18:13:03','2026-08-01 19:18:03',75.05,'线下门店');

INSERT INTO `orders` VALUES (2960,'RT20260801002960',477,'PAID','2026-08-01 18:46:38','2026-08-01 19:42:38',149.35,'线下门店');

INSERT INTO `orders` VALUES (2961,'RT20260801002961',21,'PAID','2026-08-01 19:37:13','2026-08-01 20:23:13',59.00,'线下门店');

INSERT INTO `orders` VALUES (2962,'RT20260802002962',362,'PAID','2026-08-02 10:15:22','2026-08-02 10:40:22',267.70,'官网');

INSERT INTO `orders` VALUES (2963,'RT20260802002963',128,'PAID','2026-08-02 11:21:58','2026-08-02 11:48:58',70.26,'线下门店');

INSERT INTO `orders` VALUES (2964,'RT20260802002964',433,'PAID','2026-08-02 17:15:12','2026-08-02 17:54:12',118.90,'线下门店');

INSERT INTO `orders` VALUES (2965,'RT20260802002965',475,'PAID','2026-08-02 18:11:16','2026-08-02 18:15:16',68.00,'线下门店');

INSERT INTO `orders` VALUES (2966,'RT20260802002966',338,'PAID','2026-08-02 19:21:42','2026-08-02 19:33:42',258.00,'线下门店');

INSERT INTO `orders` VALUES (2967,'RT20260802002967',372,'PAID','2026-08-02 19:50:24','2026-08-02 20:16:24',39.90,'线下门店');

INSERT INTO `orders` VALUES (2968,'RT20260803002968',331,'PAID','2026-08-03 11:28:53','2026-08-03 11:55:53',699.00,'小程序');

INSERT INTO `orders` VALUES (2969,'RT20260803002969',522,'PAID','2026-08-03 16:28:34','2026-08-03 16:29:34',37.91,'官网');

INSERT INTO `orders` VALUES (2970,'RT20260803002970',508,'PAID','2026-08-03 16:30:16','2026-08-03 16:53:16',101.46,'小程序');

INSERT INTO `orders` VALUES (2971,'RT20260803002971',242,'PAID','2026-08-03 16:39:37','2026-08-03 16:52:37',169.00,'线下门店');

INSERT INTO `orders` VALUES (2972,'RT20260803002972',119,'PAID','2026-08-03 17:23:21','2026-08-03 18:18:21',69.00,'小程序');

INSERT INTO `orders` VALUES (2973,'RT20260803002973',302,'PAID','2026-08-03 19:00:16','2026-08-03 19:16:16',68.00,'线下门店');

INSERT INTO `orders` VALUES (2974,'RT20260803002974',62,'PAID','2026-08-03 19:03:01','2026-08-03 19:56:01',24.90,'小程序');

INSERT INTO `orders` VALUES (2975,'RT20260803002975',230,'PAID','2026-08-03 20:49:59','2026-08-03 20:54:59',32.90,'线下门店');

INSERT INTO `orders` VALUES (2976,'RT20260804002976',254,'PAID','2026-08-04 09:00:06','2026-08-04 09:31:06',31.26,'线下门店');

INSERT INTO `orders` VALUES (2977,'RT20260804002977',30,'CANCELLED','2026-08-04 10:16:27',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (2978,'RT20260804002978',408,'PAID','2026-08-04 11:57:43','2026-08-04 12:31:43',164.91,'小程序');

INSERT INTO `orders` VALUES (2979,'RT20260804002979',476,'PAID','2026-08-04 16:39:15','2026-08-04 17:01:15',37.91,'小程序');

INSERT INTO `orders` VALUES (2980,'RT20260804002980',54,'PAID','2026-08-04 17:08:05','2026-08-04 18:01:05',68.00,'官网');

INSERT INTO `orders` VALUES (2981,'RT20260804002981',224,'PAID','2026-08-04 17:35:44','2026-08-04 18:29:44',122.55,'线下门店');

INSERT INTO `orders` VALUES (2982,'RT20260804002982',549,'PAID','2026-08-04 17:52:43','2026-08-04 19:00:43',24.90,'小程序');

INSERT INTO `orders` VALUES (2983,'RT20260804002983',222,'CANCELLED','2026-08-04 20:13:01',NULL,79.00,'官网');

INSERT INTO `orders` VALUES (2984,'RT20260805002984',280,'PAID','2026-08-05 08:08:15','2026-08-05 08:33:15',68.00,'线下门店');

INSERT INTO `orders` VALUES (2985,'RT20260805002985',275,'PAID','2026-08-05 15:49:44','2026-08-05 16:34:44',39.90,'小程序');

INSERT INTO `orders` VALUES (2986,'RT20260805002986',363,'PAID','2026-08-05 16:34:59','2026-08-05 17:37:59',756.11,'小程序');

INSERT INTO `orders` VALUES (2987,'RT20260805002987',475,'PAID','2026-08-05 16:45:59','2026-08-05 17:34:59',56.05,'线下门店');

INSERT INTO `orders` VALUES (2988,'RT20260805002988',448,'REFUNDED','2026-08-05 17:35:27','2026-08-05 18:34:27',159.00,'小程序');

INSERT INTO `orders` VALUES (2989,'RT20260805002989',386,'PAID','2026-08-05 17:58:51','2026-08-05 18:33:51',218.00,'线下门店');

INSERT INTO `orders` VALUES (2990,'RT20260805002990',93,'PAID','2026-08-05 21:24:59','2026-08-05 22:15:59',68.00,'线下门店');

INSERT INTO `orders` VALUES (2991,'RT20260805002991',330,'PAID','2026-08-05 22:45:16','2026-08-05 23:00:16',458.00,'小程序');

INSERT INTO `orders` VALUES (2992,'RT20260806002992',248,'PAID','2026-08-06 09:02:55','2026-08-06 10:01:55',399.00,'线下门店');

INSERT INTO `orders` VALUES (2993,'RT20260806002993',64,'PAID','2026-08-06 10:00:51','2026-08-06 11:12:51',107.00,'小程序');

INSERT INTO `orders` VALUES (2994,'RT20260806002994',327,'PAID','2026-08-06 11:20:24','2026-08-06 11:22:24',62.51,'线下门店');

INSERT INTO `orders` VALUES (2995,'RT20260806002995',605,'PAID','2026-08-06 14:39:27','2026-08-06 15:49:27',39.90,'线下门店');

INSERT INTO `orders` VALUES (2996,'RT20260806002996',189,'PAID','2026-08-06 17:11:34','2026-08-06 17:14:34',137.40,'小程序');

INSERT INTO `orders` VALUES (2997,'RT20260806002997',19,'PAID','2026-08-06 17:12:04','2026-08-06 18:14:04',76.05,'企业采购');

INSERT INTO `orders` VALUES (2998,'RT20260806002998',391,'PAID','2026-08-06 17:49:50','2026-08-06 18:49:50',477.00,'小程序');

INSERT INTO `orders` VALUES (2999,'RT20260806002999',211,'PAID','2026-08-06 21:25:00','2026-08-06 21:30:00',24.90,'官网');

INSERT INTO `orders` VALUES (3000,'RT20260806003000',245,'PAID','2026-08-06 21:53:01','2026-08-06 22:28:01',160.55,'小程序');

INSERT INTO `orders` VALUES (3001,'RT20260807003001',266,'PAID','2026-08-07 12:30:52','2026-08-07 12:57:52',24.90,'官网');

INSERT INTO `orders` VALUES (3002,'RT20260807003002',476,'PAID','2026-08-07 12:32:52','2026-08-07 12:41:52',59.00,'线下门店');

INSERT INTO `orders` VALUES (3003,'RT20260807003003',128,'PAID','2026-08-07 12:48:16','2026-08-07 13:19:16',37.91,'线下门店');

INSERT INTO `orders` VALUES (3004,'RT20260807003004',482,'PAID','2026-08-07 13:22:04','2026-08-07 13:38:04',69.00,'官网');

INSERT INTO `orders` VALUES (3005,'RT20260807003005',265,'PAID','2026-08-07 13:51:12','2026-08-07 14:05:12',39.00,'线下门店');

INSERT INTO `orders` VALUES (3006,'RT20260807003006',191,'PAID','2026-08-07 15:20:13','2026-08-07 16:10:13',129.00,'小程序');

INSERT INTO `orders` VALUES (3007,'RT20260807003007',433,'PAID','2026-08-07 15:20:29','2026-08-07 15:52:29',89.00,'小程序');

INSERT INTO `orders` VALUES (3008,'RT20260807003008',390,'PAID','2026-08-07 17:55:52','2026-08-07 18:57:52',277.90,'线下门店');

INSERT INTO `orders` VALUES (3009,'RT20260807003009',78,'PAID','2026-08-07 18:08:50','2026-08-07 18:43:50',47.31,'线下门店');

INSERT INTO `orders` VALUES (3010,'RT20260807003010',174,'PAID','2026-08-07 18:11:03','2026-08-07 18:31:03',261.05,'线下门店');

INSERT INTO `orders` VALUES (3011,'RT20260807003011',199,'PAID','2026-08-07 18:25:14','2026-08-07 19:02:14',78.00,'小程序');

INSERT INTO `orders` VALUES (3012,'RT20260807003012',371,'PAID','2026-08-07 18:39:39','2026-08-07 19:12:39',39.90,'小程序');

INSERT INTO `orders` VALUES (3013,'RT20260807003013',374,'PAID','2026-08-07 18:49:55','2026-08-07 19:42:55',157.00,'小程序');

INSERT INTO `orders` VALUES (3014,'RT20260807003014',39,'PAID','2026-08-07 19:13:28','2026-08-07 20:17:28',107.90,'线下门店');

INSERT INTO `orders` VALUES (3015,'RT20260807003015',606,'PAID','2026-08-07 20:15:18','2026-08-07 20:21:18',196.05,'官网');

INSERT INTO `orders` VALUES (3016,'RT20260807003016',150,'PAID','2026-08-07 20:46:16','2026-08-07 21:49:16',103.10,'线下门店');

INSERT INTO `orders` VALUES (3017,'RT20260808003017',63,'PAID','2026-08-08 12:59:10','2026-08-08 14:13:10',116.10,'小程序');

INSERT INTO `orders` VALUES (3018,'RT20260808003018',485,'PAID','2026-08-08 13:53:02','2026-08-08 14:40:02',32.90,'小程序');

INSERT INTO `orders` VALUES (3019,'RT20260808003019',352,'PAID','2026-08-08 14:26:53','2026-08-08 14:49:53',47.31,'小程序');

INSERT INTO `orders` VALUES (3020,'RT20260808003020',6,'PAID','2026-08-08 15:23:48','2026-08-08 15:35:48',312.55,'小程序');

INSERT INTO `orders` VALUES (3021,'RT20260808003021',30,'PAID','2026-08-08 15:47:20','2026-08-08 15:48:20',69.00,'小程序');

INSERT INTO `orders` VALUES (3022,'RT20260808003022',196,'REFUNDED','2026-08-08 16:54:40','2026-08-08 17:59:40',99.95,'线下门店');

INSERT INTO `orders` VALUES (3023,'RT20260808003023',263,'PAID','2026-08-08 17:00:22','2026-08-08 17:56:22',120.20,'官网');

INSERT INTO `orders` VALUES (3024,'RT20260808003024',209,'PAID','2026-08-08 17:02:13','2026-08-08 17:17:13',24.90,'官网');

INSERT INTO `orders` VALUES (3025,'RT20260808003025',84,'PAID','2026-08-08 17:05:10','2026-08-08 17:57:10',2697.00,'小程序');

INSERT INTO `orders` VALUES (3026,'RT20260808003026',133,'PAID','2026-08-08 18:27:07','2026-08-08 18:39:07',160.55,'小程序');

INSERT INTO `orders` VALUES (3027,'RT20260808003027',371,'PAID','2026-08-08 18:36:32','2026-08-08 18:51:32',215.00,'线下门店');

INSERT INTO `orders` VALUES (3028,'RT20260808003028',83,'PAID','2026-08-08 19:08:11','2026-08-08 20:18:11',63.90,'小程序');

INSERT INTO `orders` VALUES (3029,'RT20260808003029',276,'PAID','2026-08-08 19:10:41','2026-08-08 19:28:41',112.61,'小程序');

INSERT INTO `orders` VALUES (3030,'RT20260808003030',578,'PAID','2026-08-08 19:11:13','2026-08-08 19:18:13',169.00,'线下门店');

INSERT INTO `orders` VALUES (3031,'RT20260808003031',4,'PAID','2026-08-08 19:32:26','2026-08-08 19:49:26',120.26,'线下门店');

INSERT INTO `orders` VALUES (3032,'RT20260808003032',51,'PAID','2026-08-08 20:38:48','2026-08-08 21:12:48',89.00,'线下门店');

INSERT INTO `orders` VALUES (3033,'RT20260808003033',499,'PAID','2026-08-08 20:50:50','2026-08-08 21:18:50',416.96,'小程序');

INSERT INTO `orders` VALUES (3034,'RT20260808003034',116,'PAID','2026-08-08 22:16:06','2026-08-08 23:26:06',144.40,'小程序');

INSERT INTO `orders` VALUES (3035,'RT20260808003035',128,'CANCELLED','2026-08-08 22:19:39',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (3036,'RT20260809003036',59,'PAID','2026-08-09 09:18:00','2026-08-09 10:21:00',231.51,'小程序');

INSERT INTO `orders` VALUES (3037,'RT20260809003037',4,'PAID','2026-08-09 12:16:21','2026-08-09 12:18:21',68.00,'小程序');

INSERT INTO `orders` VALUES (3038,'RT20260809003038',424,'PAID','2026-08-09 12:23:41','2026-08-09 13:02:41',56.56,'小程序');

INSERT INTO `orders` VALUES (3039,'RT20260809003039',95,'PAID','2026-08-09 13:02:44','2026-08-09 13:13:44',56.05,'小程序');

INSERT INTO `orders` VALUES (3040,'RT20260809003040',15,'PAID','2026-08-09 17:04:53','2026-08-09 18:03:53',61.57,'线下门店');

INSERT INTO `orders` VALUES (3041,'RT20260809003041',18,'PAID','2026-08-09 17:26:42','2026-08-09 18:31:42',137.61,'企业采购');

INSERT INTO `orders` VALUES (3042,'RT20260809003042',181,'PAID','2026-08-09 18:26:11','2026-08-09 18:51:11',49.80,'小程序');

INSERT INTO `orders` VALUES (3043,'RT20260809003043',9,'PAID','2026-08-09 18:41:38','2026-08-09 18:46:38',71.16,'线下门店');

INSERT INTO `orders` VALUES (3044,'RT20260809003044',21,'PAID','2026-08-09 18:43:32','2026-08-09 19:41:32',39.00,'小程序');

INSERT INTO `orders` VALUES (3045,'RT20260809003045',188,'PAID','2026-08-09 20:50:38','2026-08-09 21:44:38',59.00,'小程序');

INSERT INTO `orders` VALUES (3046,'RT20260810003046',212,'CANCELLED','2026-08-10 09:10:29',NULL,274.05,'小程序');

INSERT INTO `orders` VALUES (3047,'RT20260810003047',85,'PAID','2026-08-10 13:15:08','2026-08-10 13:39:08',156.17,'线下门店');

INSERT INTO `orders` VALUES (3048,'RT20260810003048',375,'PAID','2026-08-10 13:38:42','2026-08-10 14:20:42',79.00,'小程序');

INSERT INTO `orders` VALUES (3049,'RT20260810003049',617,'PAID','2026-08-10 14:29:08','2026-08-10 15:18:08',169.00,'小程序');

INSERT INTO `orders` VALUES (3050,'RT20260810003050',81,'PAID','2026-08-10 15:39:06','2026-08-10 15:49:06',434.05,'官网');

INSERT INTO `orders` VALUES (3051,'RT20260810003051',53,'PAID','2026-08-10 16:18:11','2026-08-10 17:07:11',103.80,'线下门店');

INSERT INTO `orders` VALUES (3052,'RT20260810003052',267,'REFUNDED','2026-08-10 17:39:15','2026-08-10 18:48:15',23.66,'线下门店');

INSERT INTO `orders` VALUES (3053,'RT20260810003053',337,'PAID','2026-08-10 17:55:37','2026-08-10 18:36:37',101.10,'小程序');

INSERT INTO `orders` VALUES (3054,'RT20260810003054',107,'PAID','2026-08-10 19:09:42','2026-08-10 19:25:42',72.80,'小程序');

INSERT INTO `orders` VALUES (3055,'RT20260810003055',415,'PAID','2026-08-10 19:48:54','2026-08-10 20:00:54',49.80,'线下门店');

INSERT INTO `orders` VALUES (3056,'RT20260811003056',517,'PAID','2026-08-11 10:19:06','2026-08-11 10:44:06',32.90,'官网');

INSERT INTO `orders` VALUES (3057,'RT20260811003057',269,'PAID','2026-08-11 11:08:16','2026-08-11 11:49:16',139.10,'小程序');

INSERT INTO `orders` VALUES (3058,'RT20260811003058',46,'PAID','2026-08-11 15:14:00','2026-08-11 15:49:00',323.45,'官网');

INSERT INTO `orders` VALUES (3059,'RT20260811003059',328,'PAID','2026-08-11 17:34:48','2026-08-11 18:29:48',136.00,'企业采购');

INSERT INTO `orders` VALUES (3060,'RT20260811003060',173,'PAID','2026-08-11 17:52:12','2026-08-11 18:44:12',37.91,'线下门店');

INSERT INTO `orders` VALUES (3061,'RT20260811003061',259,'PAID','2026-08-11 21:10:13','2026-08-11 21:24:13',136.65,'小程序');

INSERT INTO `orders` VALUES (3062,'RT20260812003062',375,'PAID','2026-08-12 10:18:39','2026-08-12 11:09:39',290.90,'线下门店');

INSERT INTO `orders` VALUES (3063,'RT20260812003063',69,'PAID','2026-08-12 10:23:20','2026-08-12 11:07:20',416.96,'官网');

INSERT INTO `orders` VALUES (3064,'RT20260812003064',53,'PAID','2026-08-12 14:05:07','2026-08-12 14:48:07',39.00,'线下门店');

INSERT INTO `orders` VALUES (3065,'RT20260812003065',398,'PAID','2026-08-12 16:18:50','2026-08-12 16:20:50',138.00,'线下门店');

INSERT INTO `orders` VALUES (3066,'RT20260812003066',142,'PAID','2026-08-12 17:05:30','2026-08-12 17:31:30',31.26,'官网');

INSERT INTO `orders` VALUES (3067,'RT20260812003067',324,'REFUNDED','2026-08-12 17:35:30','2026-08-12 17:38:30',64.60,'小程序');

INSERT INTO `orders` VALUES (3068,'RT20260812003068',612,'PAID','2026-08-12 17:45:15','2026-08-12 18:42:15',89.00,'小程序');

INSERT INTO `orders` VALUES (3069,'RT20260812003069',605,'PAID','2026-08-12 18:37:49','2026-08-12 19:16:49',39.90,'小程序');

INSERT INTO `orders` VALUES (3070,'RT20260812003070',632,'PAID','2026-08-12 21:18:17','2026-08-12 22:29:17',24.90,'小程序');

INSERT INTO `orders` VALUES (3071,'RT20260812003071',285,'PAID','2026-08-12 21:21:05','2026-08-12 22:13:05',32.90,'小程序');

INSERT INTO `orders` VALUES (3072,'RT20260812003072',28,'PAID','2026-08-12 21:43:05','2026-08-12 22:11:05',239.10,'线下门店');

INSERT INTO `orders` VALUES (3073,'RT20260813003073',103,'CANCELLED','2026-08-13 09:13:05',NULL,122.55,'官网');

INSERT INTO `orders` VALUES (3074,'RT20260813003074',348,'PAID','2026-08-13 12:05:03','2026-08-13 13:20:03',39.90,'小程序');

INSERT INTO `orders` VALUES (3075,'RT20260813003075',46,'PAID','2026-08-13 13:25:58','2026-08-13 13:53:58',298.00,'线下门店');

INSERT INTO `orders` VALUES (3076,'RT20260813003076',174,'REFUNDED','2026-08-13 17:43:22','2026-08-13 18:13:22',68.00,'官网');

INSERT INTO `orders` VALUES (3077,'RT20260813003077',527,'PAID','2026-08-13 18:12:05','2026-08-13 19:05:05',222.60,'线下门店');

INSERT INTO `orders` VALUES (3078,'RT20260813003078',464,'PAID','2026-08-13 18:38:52','2026-08-13 18:54:52',129.00,'小程序');

INSERT INTO `orders` VALUES (3079,'RT20260813003079',18,'CANCELLED','2026-08-13 20:32:00',NULL,188.00,'小程序');

INSERT INTO `orders` VALUES (3080,'RT20260813003080',19,'PAID','2026-08-13 21:13:17','2026-08-13 21:36:17',29.61,'小程序');

INSERT INTO `orders` VALUES (3081,'RT20260814003081',1,'PAID','2026-08-14 11:06:35','2026-08-14 11:34:35',108.90,'线下门店');

INSERT INTO `orders` VALUES (3082,'RT20260814003082',299,'PAID','2026-08-14 14:16:06','2026-08-14 15:31:06',89.00,'小程序');

INSERT INTO `orders` VALUES (3083,'RT20260814003083',491,'PAID','2026-08-14 15:03:31','2026-08-14 16:04:31',140.71,'官网');

INSERT INTO `orders` VALUES (3084,'RT20260814003084',556,'PAID','2026-08-14 15:46:57','2026-08-14 16:35:57',39.00,'小程序');

INSERT INTO `orders` VALUES (3085,'RT20260814003085',280,'CANCELLED','2026-08-14 16:11:18',NULL,29.61,'官网');

INSERT INTO `orders` VALUES (3086,'RT20260814003086',425,'CANCELLED','2026-08-14 16:28:34',NULL,284.05,'小程序');

INSERT INTO `orders` VALUES (3087,'RT20260814003087',557,'PAID','2026-08-14 16:55:57','2026-08-14 17:48:57',68.00,'线下门店');

INSERT INTO `orders` VALUES (3088,'RT20260814003088',354,'PAID','2026-08-14 17:30:49','2026-08-14 18:32:49',169.00,'线下门店');

INSERT INTO `orders` VALUES (3089,'RT20260814003089',410,'PAID','2026-08-14 18:22:14','2026-08-14 18:42:14',183.20,'线下门店');

INSERT INTO `orders` VALUES (3090,'RT20260814003090',400,'PAID','2026-08-14 19:29:29','2026-08-14 19:37:29',74.70,'线下门店');

INSERT INTO `orders` VALUES (3091,'RT20260814003091',276,'PAID','2026-08-14 19:55:18','2026-08-14 20:14:18',133.55,'企业采购');

INSERT INTO `orders` VALUES (3092,'RT20260815003092',361,'PAID','2026-08-15 09:43:27','2026-08-15 10:44:27',79.00,'官网');

INSERT INTO `orders` VALUES (3093,'RT20260815003093',605,'PAID','2026-08-15 10:40:44','2026-08-15 10:49:44',56.05,'官网');

INSERT INTO `orders` VALUES (3094,'RT20260815003094',530,'PAID','2026-08-15 13:31:02','2026-08-15 14:22:02',37.05,'小程序');

INSERT INTO `orders` VALUES (3095,'RT20260815003095',597,'PAID','2026-08-15 14:05:03','2026-08-15 15:16:03',318.00,'官网');

INSERT INTO `orders` VALUES (3096,'RT20260815003096',242,'PAID','2026-08-15 14:34:20','2026-08-15 15:17:20',89.00,'线下门店');

INSERT INTO `orders` VALUES (3097,'RT20260815003097',208,'PAID','2026-08-15 15:14:52','2026-08-15 15:45:52',64.60,'线下门店');

INSERT INTO `orders` VALUES (3098,'RT20260815003098',233,'PAID','2026-08-15 15:29:47','2026-08-15 16:15:47',134.00,'官网');

INSERT INTO `orders` VALUES (3099,'RT20260815003099',76,'PAID','2026-08-15 17:04:30','2026-08-15 17:10:30',35.91,'线下门店');

INSERT INTO `orders` VALUES (3100,'RT20260815003100',113,'PAID','2026-08-15 17:35:31','2026-08-15 18:40:31',39.90,'小程序');

INSERT INTO `orders` VALUES (3101,'RT20260815003101',440,'PAID','2026-08-15 18:13:15','2026-08-15 18:31:15',79.00,'官网');

INSERT INTO `orders` VALUES (3102,'RT20260815003102',198,'PAID','2026-08-15 20:19:04','2026-08-15 21:03:04',280.90,'线下门店');

INSERT INTO `orders` VALUES (3103,'RT20260816003103',108,'CANCELLED','2026-08-16 11:21:58',NULL,197.90,'小程序');

INSERT INTO `orders` VALUES (3104,'RT20260816003104',624,'PAID','2026-08-16 12:14:49','2026-08-16 12:37:49',37.05,'线下门店');

INSERT INTO `orders` VALUES (3105,'RT20260816003105',258,'PAID','2026-08-16 13:10:22','2026-08-16 13:32:22',32.90,'官网');

INSERT INTO `orders` VALUES (3106,'RT20260816003106',370,'PAID','2026-08-16 14:00:21','2026-08-16 14:37:21',79.00,'小程序');

INSERT INTO `orders` VALUES (3107,'RT20260816003107',115,'PAID','2026-08-16 14:25:17','2026-08-16 15:06:17',88.80,'线下门店');

INSERT INTO `orders` VALUES (3108,'RT20260816003108',457,'CANCELLED','2026-08-16 17:03:36',NULL,89.50,'线下门店');

INSERT INTO `orders` VALUES (3109,'RT20260816003109',440,'PAID','2026-08-16 17:09:30','2026-08-16 17:42:30',89.00,'小程序');

INSERT INTO `orders` VALUES (3110,'RT20260816003110',311,'PAID','2026-08-16 19:09:35','2026-08-16 19:36:35',37.91,'小程序');

INSERT INTO `orders` VALUES (3111,'RT20260816003111',292,'PAID','2026-08-16 19:17:34','2026-08-16 19:42:34',114.91,'官网');

INSERT INTO `orders` VALUES (3112,'RT20260816003112',407,'PAID','2026-08-16 19:48:42','2026-08-16 20:51:42',299.00,'线下门店');

INSERT INTO `orders` VALUES (3113,'RT20260816003113',209,'PAID','2026-08-16 21:12:05','2026-08-16 22:06:05',159.00,'线下门店');

INSERT INTO `orders` VALUES (3114,'RT20260817003114',360,'PAID','2026-08-17 08:23:17','2026-08-17 09:01:17',39.90,'小程序');

INSERT INTO `orders` VALUES (3115,'RT20260817003115',89,'PAID','2026-08-17 12:55:18','2026-08-17 14:06:18',37.05,'小程序');

INSERT INTO `orders` VALUES (3116,'RT20260817003116',284,'PAID','2026-08-17 14:24:38','2026-08-17 15:05:38',195.05,'小程序');

INSERT INTO `orders` VALUES (3117,'RT20260817003117',119,'CANCELLED','2026-08-17 16:06:36',NULL,299.00,'小程序');

INSERT INTO `orders` VALUES (3118,'RT20260817003118',627,'PAID','2026-08-17 16:28:49','2026-08-17 17:32:49',106.20,'小程序');

INSERT INTO `orders` VALUES (3119,'RT20260817003119',403,'PAID','2026-08-17 17:03:18','2026-08-17 17:24:18',64.60,'线下门店');

INSERT INTO `orders` VALUES (3120,'RT20260817003120',518,'PAID','2026-08-17 17:33:15','2026-08-17 18:07:15',39.00,'官网');

INSERT INTO `orders` VALUES (3121,'RT20260817003121',609,'PAID','2026-08-17 18:42:53','2026-08-17 18:49:53',128.00,'官网');

INSERT INTO `orders` VALUES (3122,'RT20260817003122',333,'PAID','2026-08-17 18:59:58','2026-08-17 19:40:58',35.91,'线下门店');

INSERT INTO `orders` VALUES (3123,'RT20260817003123',175,'PAID','2026-08-17 20:45:53','2026-08-17 21:40:53',399.00,'线下门店');

INSERT INTO `orders` VALUES (3124,'RT20260817003124',518,'PAID','2026-08-17 21:11:37','2026-08-17 21:17:37',24.90,'线下门店');

INSERT INTO `orders` VALUES (3125,'RT20260818003125',284,'CANCELLED','2026-08-18 10:53:22',NULL,39.90,'小程序');

INSERT INTO `orders` VALUES (3126,'RT20260818003126',301,'PAID','2026-08-18 13:33:48','2026-08-18 14:16:48',738.00,'小程序');

INSERT INTO `orders` VALUES (3127,'RT20260818003127',161,'PAID','2026-08-18 13:36:27','2026-08-18 14:38:27',129.20,'线下门店');

INSERT INTO `orders` VALUES (3128,'RT20260818003128',329,'PAID','2026-08-18 13:48:05','2026-08-18 14:21:05',476.10,'企业采购');

INSERT INTO `orders` VALUES (3129,'RT20260818003129',379,'CANCELLED','2026-08-18 14:47:37',NULL,39.00,'线下门店');

INSERT INTO `orders` VALUES (3130,'RT20260818003130',182,'PAID','2026-08-18 16:01:39','2026-08-18 17:12:39',349.10,'线下门店');

INSERT INTO `orders` VALUES (3131,'RT20260818003131',345,'PAID','2026-08-18 17:23:21','2026-08-18 17:48:21',74.70,'企业采购');

INSERT INTO `orders` VALUES (3132,'RT20260818003132',358,'PAID','2026-08-18 18:01:49','2026-08-18 18:45:49',32.90,'线下门店');

INSERT INTO `orders` VALUES (3133,'RT20260819003133',75,'PAID','2026-08-19 10:35:04','2026-08-19 10:55:04',168.00,'官网');

INSERT INTO `orders` VALUES (3134,'RT20260819003134',76,'PAID','2026-08-19 14:56:18','2026-08-19 15:40:18',379.05,'官网');

INSERT INTO `orders` VALUES (3135,'RT20260819003135',428,'PAID','2026-08-19 19:41:15','2026-08-19 20:00:15',151.05,'线下门店');

INSERT INTO `orders` VALUES (3136,'RT20260819003136',174,'PAID','2026-08-19 20:20:12','2026-08-19 20:52:12',95.95,'官网');

INSERT INTO `orders` VALUES (3137,'RT20260819003137',496,'PAID','2026-08-19 21:21:14','2026-08-19 22:23:14',159.00,'官网');

INSERT INTO `orders` VALUES (3138,'RT20260820003138',345,'PAID','2026-08-20 08:31:21','2026-08-20 08:45:21',152.10,'官网');

INSERT INTO `orders` VALUES (3139,'RT20260820003139',536,'PAID','2026-08-20 10:59:45','2026-08-20 11:25:45',89.00,'线下门店');

INSERT INTO `orders` VALUES (3140,'RT20260820003140',298,'PAID','2026-08-20 11:37:55','2026-08-20 12:15:55',69.00,'小程序');

INSERT INTO `orders` VALUES (3141,'RT20260820003141',243,'PAID','2026-08-20 11:39:48','2026-08-20 11:55:48',75.05,'官网');

INSERT INTO `orders` VALUES (3142,'RT20260820003142',230,'PAID','2026-08-20 14:36:03','2026-08-20 15:28:03',63.90,'小程序');

INSERT INTO `orders` VALUES (3143,'RT20260820003143',270,'PAID','2026-08-20 16:37:17','2026-08-20 17:28:17',159.00,'线下门店');

INSERT INTO `orders` VALUES (3144,'RT20260820003144',9,'PAID','2026-08-20 19:50:00','2026-08-20 20:07:00',62.51,'企业采购');

INSERT INTO `orders` VALUES (3145,'RT20260821003145',520,'REFUNDED','2026-08-21 09:10:49','2026-08-21 10:10:49',39.90,'官网');

INSERT INTO `orders` VALUES (3146,'RT20260821003146',382,'PAID','2026-08-21 10:18:31','2026-08-21 10:51:31',159.00,'线下门店');

INSERT INTO `orders` VALUES (3147,'RT20260821003147',174,'PAID','2026-08-21 10:46:38','2026-08-21 12:01:38',129.00,'小程序');

INSERT INTO `orders` VALUES (3148,'RT20260821003148',181,'PAID','2026-08-21 13:29:13','2026-08-21 14:21:13',151.05,'官网');

INSERT INTO `orders` VALUES (3149,'RT20260821003149',216,'PAID','2026-08-21 15:03:24','2026-08-21 16:11:24',227.00,'线下门店');

INSERT INTO `orders` VALUES (3150,'RT20260821003150',6,'PAID','2026-08-21 15:55:54','2026-08-21 16:56:54',79.00,'线下门店');

INSERT INTO `orders` VALUES (3151,'RT20260821003151',448,'PAID','2026-08-21 16:44:44','2026-08-21 16:57:44',79.00,'小程序');

INSERT INTO `orders` VALUES (3152,'RT20260821003152',605,'CANCELLED','2026-08-21 18:31:58',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (3153,'RT20260821003153',434,'PAID','2026-08-21 19:19:07','2026-08-21 19:58:07',79.00,'小程序');

INSERT INTO `orders` VALUES (3154,'RT20260821003154',386,'CANCELLED','2026-08-21 19:24:24',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (3155,'RT20260821003155',79,'PAID','2026-08-21 20:49:21','2026-08-21 20:51:21',89.00,'官网');

INSERT INTO `orders` VALUES (3156,'RT20260822003156',467,'CANCELLED','2026-08-22 11:05:18',NULL,32.90,'线下门店');

INSERT INTO `orders` VALUES (3157,'RT20260822003157',215,'PAID','2026-08-22 12:07:38','2026-08-22 12:42:38',22.41,'小程序');

INSERT INTO `orders` VALUES (3158,'RT20260822003158',134,'PAID','2026-08-22 12:21:11','2026-08-22 12:46:11',108.00,'官网');

INSERT INTO `orders` VALUES (3159,'RT20260822003159',375,'PAID','2026-08-22 12:45:18','2026-08-22 13:27:18',68.00,'企业采购');

INSERT INTO `orders` VALUES (3160,'RT20260822003160',351,'PAID','2026-08-22 13:12:59','2026-08-22 13:59:59',75.05,'小程序');

INSERT INTO `orders` VALUES (3161,'RT20260822003161',331,'PAID','2026-08-22 13:17:47','2026-08-22 13:54:47',79.00,'官网');

INSERT INTO `orders` VALUES (3162,'RT20260822003162',116,'CANCELLED','2026-08-22 13:28:34',NULL,118.90,'企业采购');

INSERT INTO `orders` VALUES (3163,'RT20260822003163',97,'PAID','2026-08-22 16:25:31','2026-08-22 17:38:31',184.85,'线下门店');

INSERT INTO `orders` VALUES (3164,'RT20260822003164',365,'PAID','2026-08-22 16:28:53','2026-08-22 17:04:53',32.90,'官网');

INSERT INTO `orders` VALUES (3165,'RT20260822003165',334,'REFUNDED','2026-08-22 16:33:46','2026-08-22 17:44:46',79.00,'线下门店');

INSERT INTO `orders` VALUES (3166,'RT20260822003166',22,'CANCELLED','2026-08-22 18:32:28',NULL,79.00,'官网');

INSERT INTO `orders` VALUES (3167,'RT20260822003167',535,'PAID','2026-08-22 19:09:38','2026-08-22 19:43:38',74.10,'官网');

INSERT INTO `orders` VALUES (3168,'RT20260822003168',18,'PAID','2026-08-22 19:43:40','2026-08-22 20:30:40',377.00,'小程序');

INSERT INTO `orders` VALUES (3169,'RT20260822003169',16,'CANCELLED','2026-08-22 20:35:04',NULL,119.70,'小程序');

INSERT INTO `orders` VALUES (3170,'RT20260823003170',229,'PAID','2026-08-23 10:29:45','2026-08-23 11:20:45',95.16,'小程序');

INSERT INTO `orders` VALUES (3171,'RT20260823003171',36,'PAID','2026-08-23 13:41:45','2026-08-23 14:27:45',142.60,'小程序');

INSERT INTO `orders` VALUES (3172,'RT20260823003172',208,'PAID','2026-08-23 17:10:40','2026-08-23 17:21:40',39.00,'官网');

INSERT INTO `orders` VALUES (3173,'RT20260823003173',6,'PAID','2026-08-23 17:27:08','2026-08-23 17:32:08',105.91,'官网');

INSERT INTO `orders` VALUES (3174,'RT20260823003174',2,'PAID','2026-08-23 17:55:34','2026-08-23 17:56:34',399.00,'线下门店');

INSERT INTO `orders` VALUES (3175,'RT20260823003175',97,'CANCELLED','2026-08-23 18:08:15',NULL,32.90,'线下门店');

INSERT INTO `orders` VALUES (3176,'RT20260823003176',442,'PAID','2026-08-23 19:51:03','2026-08-23 20:15:03',219.05,'小程序');

INSERT INTO `orders` VALUES (3177,'RT20260823003177',166,'PAID','2026-08-23 19:58:57','2026-08-23 20:17:57',138.80,'小程序');

INSERT INTO `orders` VALUES (3178,'RT20260824003178',91,'PAID','2026-08-24 10:51:53','2026-08-24 11:50:53',39.00,'小程序');

INSERT INTO `orders` VALUES (3179,'RT20260824003179',128,'PAID','2026-08-24 11:45:45','2026-08-24 12:53:45',184.10,'小程序');

INSERT INTO `orders` VALUES (3180,'RT20260824003180',373,'PAID','2026-08-24 12:15:21','2026-08-24 12:57:21',60.81,'小程序');

INSERT INTO `orders` VALUES (3181,'RT20260824003181',273,'PAID','2026-08-24 12:32:32','2026-08-24 12:35:32',479.10,'小程序');

INSERT INTO `orders` VALUES (3182,'RT20260824003182',98,'PAID','2026-08-24 13:19:36','2026-08-24 13:30:36',82.66,'小程序');

INSERT INTO `orders` VALUES (3183,'RT20260824003183',436,'PAID','2026-08-24 17:57:41','2026-08-24 18:54:41',49.80,'小程序');

INSERT INTO `orders` VALUES (3184,'RT20260824003184',104,'CANCELLED','2026-08-24 21:34:41',NULL,218.00,'线下门店');

INSERT INTO `orders` VALUES (3185,'RT20260825003185',314,'CANCELLED','2026-08-25 08:38:46',NULL,65.55,'官网');

INSERT INTO `orders` VALUES (3186,'RT20260825003186',38,'PAID','2026-08-25 10:21:48','2026-08-25 11:32:48',39.90,'小程序');

INSERT INTO `orders` VALUES (3187,'RT20260825003187',375,'PAID','2026-08-25 10:34:43','2026-08-25 11:05:43',29.61,'小程序');

INSERT INTO `orders` VALUES (3188,'RT20260825003188',154,'PAID','2026-08-25 12:28:35','2026-08-25 13:23:35',114.05,'官网');

INSERT INTO `orders` VALUES (3189,'RT20260825003189',274,'PAID','2026-08-25 16:11:36','2026-08-25 16:14:36',89.00,'官网');

INSERT INTO `orders` VALUES (3190,'RT20260825003190',582,'PAID','2026-08-25 17:09:15','2026-08-25 17:23:15',39.00,'线下门店');

INSERT INTO `orders` VALUES (3191,'RT20260825003191',315,'PAID','2026-08-25 18:24:36','2026-08-25 19:17:36',56.05,'线下门店');

INSERT INTO `orders` VALUES (3192,'RT20260825003192',527,'PAID','2026-08-25 18:35:37','2026-08-25 18:40:37',37.91,'线下门店');

INSERT INTO `orders` VALUES (3193,'RT20260825003193',157,'CANCELLED','2026-08-25 18:38:19',NULL,79.00,'官网');

INSERT INTO `orders` VALUES (3194,'RT20260825003194',468,'PAID','2026-08-25 21:03:11','2026-08-25 21:13:11',173.91,'小程序');

INSERT INTO `orders` VALUES (3195,'RT20260825003195',68,'PAID','2026-08-25 21:07:19','2026-08-25 21:47:19',39.90,'官网');

INSERT INTO `orders` VALUES (3196,'RT20260826003196',18,'PAID','2026-08-26 11:09:15','2026-08-26 11:59:15',83.90,'线下门店');

INSERT INTO `orders` VALUES (3197,'RT20260826003197',158,'PAID','2026-08-26 11:14:22','2026-08-26 12:23:22',24.90,'官网');

INSERT INTO `orders` VALUES (3198,'RT20260826003198',263,'PAID','2026-08-26 11:36:20','2026-08-26 11:44:20',24.90,'官网');

INSERT INTO `orders` VALUES (3199,'RT20260826003199',581,'PAID','2026-08-26 15:14:27','2026-08-26 15:18:27',84.55,'官网');

INSERT INTO `orders` VALUES (3200,'RT20260826003200',80,'PAID','2026-08-26 15:15:41','2026-08-26 16:16:41',143.10,'小程序');

INSERT INTO `orders` VALUES (3201,'RT20260826003201',480,'PAID','2026-08-26 15:40:01','2026-08-26 16:52:01',37.05,'小程序');

INSERT INTO `orders` VALUES (3202,'RT20260826003202',581,'PAID','2026-08-26 15:46:43','2026-08-26 16:20:43',64.60,'小程序');

INSERT INTO `orders` VALUES (3203,'RT20260826003203',496,'PAID','2026-08-26 18:09:06','2026-08-26 18:48:06',103.60,'官网');

INSERT INTO `orders` VALUES (3204,'RT20260826003204',537,'CANCELLED','2026-08-26 18:22:46',NULL,79.80,'官网');

INSERT INTO `orders` VALUES (3205,'RT20260826003205',155,'PAID','2026-08-26 18:31:43','2026-08-26 19:15:43',24.90,'官网');

INSERT INTO `orders` VALUES (3206,'RT20260826003206',258,'PAID','2026-08-26 19:00:38','2026-08-26 20:04:38',39.90,'线下门店');

INSERT INTO `orders` VALUES (3207,'RT20260826003207',113,'PAID','2026-08-26 19:10:41','2026-08-26 19:46:41',108.90,'小程序');

INSERT INTO `orders` VALUES (3208,'RT20260826003208',14,'PAID','2026-08-26 19:22:40','2026-08-26 19:43:40',39.90,'小程序');

INSERT INTO `orders` VALUES (3209,'RT20260826003209',134,'CANCELLED','2026-08-26 20:23:00',NULL,319.90,'官网');

INSERT INTO `orders` VALUES (3210,'RT20260826003210',56,'PAID','2026-08-26 20:39:58','2026-08-26 21:30:58',98.90,'官网');

INSERT INTO `orders` VALUES (3211,'RT20260827003211',554,'PAID','2026-08-27 12:14:41','2026-08-27 13:14:41',32.90,'企业采购');

INSERT INTO `orders` VALUES (3212,'RT20260827003212',63,'PAID','2026-08-27 12:41:29','2026-08-27 12:57:29',147.80,'小程序');

INSERT INTO `orders` VALUES (3213,'RT20260827003213',3,'PAID','2026-08-27 14:33:26','2026-08-27 14:41:26',39.90,'官网');

INSERT INTO `orders` VALUES (3214,'RT20260827003214',20,'CANCELLED','2026-08-27 16:48:44',NULL,418.05,'官网');

INSERT INTO `orders` VALUES (3215,'RT20260827003215',87,'PAID','2026-08-27 17:18:09','2026-08-27 17:52:09',169.00,'线下门店');

INSERT INTO `orders` VALUES (3216,'RT20260827003216',302,'PAID','2026-08-27 19:41:12','2026-08-27 20:48:12',153.10,'线下门店');

INSERT INTO `orders` VALUES (3217,'RT20260827003217',21,'PAID','2026-08-27 19:53:22','2026-08-27 20:45:22',159.00,'线下门店');

INSERT INTO `orders` VALUES (3218,'RT20260827003218',181,'PAID','2026-08-27 20:13:26','2026-08-27 21:24:26',138.00,'官网');

INSERT INTO `orders` VALUES (3219,'RT20260828003219',141,'PAID','2026-08-28 10:06:37','2026-08-28 10:17:37',129.00,'企业采购');

INSERT INTO `orders` VALUES (3220,'RT20260828003220',467,'PAID','2026-08-28 12:10:30','2026-08-28 13:00:30',107.90,'线下门店');

INSERT INTO `orders` VALUES (3221,'RT20260828003221',110,'PAID','2026-08-28 12:19:09','2026-08-28 13:29:09',61.20,'小程序');

INSERT INTO `orders` VALUES (3222,'RT20260828003222',103,'PAID','2026-08-28 14:19:54','2026-08-28 14:50:54',245.10,'官网');

INSERT INTO `orders` VALUES (3223,'RT20260828003223',62,'PAID','2026-08-28 16:24:29','2026-08-28 17:38:29',139.10,'官网');

INSERT INTO `orders` VALUES (3224,'RT20260828003224',309,'PAID','2026-08-28 16:30:37','2026-08-28 16:34:37',39.00,'小程序');

INSERT INTO `orders` VALUES (3225,'RT20260828003225',292,'PAID','2026-08-28 17:07:55','2026-08-28 18:00:55',32.90,'小程序');

INSERT INTO `orders` VALUES (3226,'RT20260828003226',164,'CANCELLED','2026-08-28 17:32:23',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (3227,'RT20260828003227',282,'PAID','2026-08-28 18:09:44','2026-08-28 19:18:44',699.00,'小程序');

INSERT INTO `orders` VALUES (3228,'RT20260828003228',263,'PAID','2026-08-28 20:37:50','2026-08-28 21:17:50',107.90,'线下门店');

INSERT INTO `orders` VALUES (3229,'RT20260829003229',325,'PAID','2026-08-29 08:29:39','2026-08-29 09:25:39',35.91,'小程序');

INSERT INTO `orders` VALUES (3230,'RT20260829003230',96,'PAID','2026-08-29 12:43:35','2026-08-29 12:47:35',90.41,'线下门店');

INSERT INTO `orders` VALUES (3231,'RT20260829003231',48,'PAID','2026-08-29 16:11:34','2026-08-29 16:14:34',117.00,'线下门店');

INSERT INTO `orders` VALUES (3232,'RT20260829003232',20,'PAID','2026-08-29 16:27:18','2026-08-29 17:39:18',39.90,'官网');

INSERT INTO `orders` VALUES (3233,'RT20260829003233',3,'PAID','2026-08-29 20:17:35','2026-08-29 21:19:35',123.60,'小程序');

INSERT INTO `orders` VALUES (3234,'RT20260829003234',160,'PAID','2026-08-29 20:48:11','2026-08-29 21:58:11',59.00,'官网');

INSERT INTO `orders` VALUES (3235,'RT20260829003235',604,'PAID','2026-08-29 20:49:35','2026-08-29 21:05:35',230.10,'官网');

INSERT INTO `orders` VALUES (3236,'RT20260829003236',598,'PAID','2026-08-29 21:59:58','2026-08-29 22:53:58',39.00,'企业采购');

INSERT INTO `orders` VALUES (3237,'RT20260830003237',119,'REFUNDED','2026-08-30 10:06:09','2026-08-30 11:19:09',76.95,'小程序');

INSERT INTO `orders` VALUES (3238,'RT20260830003238',420,'CANCELLED','2026-08-30 11:50:11',NULL,39.90,'小程序');

INSERT INTO `orders` VALUES (3239,'RT20260830003239',128,'PAID','2026-08-30 12:01:21','2026-08-30 13:10:21',79.80,'小程序');

INSERT INTO `orders` VALUES (3240,'RT20260830003240',147,'PAID','2026-08-30 13:34:35','2026-08-30 14:18:35',159.00,'小程序');

INSERT INTO `orders` VALUES (3241,'RT20260830003241',313,'PAID','2026-08-30 16:33:00','2026-08-30 17:10:00',118.00,'线下门店');

INSERT INTO `orders` VALUES (3242,'RT20260830003242',221,'PAID','2026-08-30 18:12:13','2026-08-30 18:50:13',71.16,'小程序');

INSERT INTO `orders` VALUES (3243,'RT20260830003243',358,'PAID','2026-08-30 19:59:28','2026-08-30 20:21:28',114.81,'线下门店');

INSERT INTO `orders` VALUES (3244,'RT20260831003244',135,'PAID','2026-08-31 12:12:04','2026-08-31 13:22:04',152.66,'线下门店');

INSERT INTO `orders` VALUES (3245,'RT20260831003245',6,'PAID','2026-08-31 12:15:10','2026-08-31 13:23:10',4299.00,'小程序');

INSERT INTO `orders` VALUES (3246,'RT20260831003246',4,'PAID','2026-08-31 12:28:32','2026-08-31 13:14:32',635.10,'官网');

INSERT INTO `orders` VALUES (3247,'RT20260831003247',526,'PAID','2026-08-31 13:20:44','2026-08-31 14:26:44',168.00,'小程序');

INSERT INTO `orders` VALUES (3248,'RT20260831003248',42,'PAID','2026-08-31 13:33:31','2026-08-31 13:53:31',198.90,'小程序');

INSERT INTO `orders` VALUES (3249,'RT20260831003249',369,'PAID','2026-08-31 17:35:38','2026-08-31 18:24:38',294.15,'官网');

INSERT INTO `orders` VALUES (3250,'RT20260831003250',144,'PAID','2026-08-31 18:41:56','2026-08-31 18:52:56',84.55,'小程序');

INSERT INTO `orders` VALUES (3251,'RT20260831003251',471,'PAID','2026-08-31 19:49:43','2026-08-31 20:02:43',68.00,'线下门店');

INSERT INTO `orders` VALUES (3252,'RT20260831003252',264,'PAID','2026-08-31 22:06:41','2026-08-31 22:40:41',180.50,'小程序');

INSERT INTO `orders` VALUES (3253,'RT20260831003253',319,'PAID','2026-08-31 22:54:37','2026-08-31 23:05:37',32.90,'小程序');

INSERT INTO `orders` VALUES (3254,'RT20260901003254',457,'PAID','2026-09-01 08:50:49','2026-09-01 09:04:49',65.55,'官网');

INSERT INTO `orders` VALUES (3255,'RT20260901003255',303,'PAID','2026-09-01 10:55:25','2026-09-01 11:15:25',68.00,'小程序');

INSERT INTO `orders` VALUES (3256,'RT20260901003256',305,'PAID','2026-09-01 12:56:47','2026-09-01 13:21:47',39.90,'线下门店');

INSERT INTO `orders` VALUES (3257,'RT20260901003257',49,'PAID','2026-09-01 14:02:02','2026-09-01 14:09:02',71.90,'线下门店');

INSERT INTO `orders` VALUES (3258,'RT20260901003258',283,'PAID','2026-09-01 14:36:25','2026-09-01 14:48:25',59.00,'线下门店');

INSERT INTO `orders` VALUES (3259,'RT20260901003259',379,'CANCELLED','2026-09-01 15:15:45',NULL,410.06,'线下门店');

INSERT INTO `orders` VALUES (3260,'RT20260901003260',282,'PAID','2026-09-01 16:04:11','2026-09-01 17:17:11',142.01,'线下门店');

INSERT INTO `orders` VALUES (3261,'RT20260901003261',46,'PAID','2026-09-01 17:34:06','2026-09-01 18:10:06',118.90,'小程序');

INSERT INTO `orders` VALUES (3262,'RT20260901003262',317,'PAID','2026-09-01 17:34:29','2026-09-01 17:39:29',175.90,'小程序');

INSERT INTO `orders` VALUES (3263,'RT20260901003263',152,'PAID','2026-09-01 17:36:31','2026-09-01 18:41:31',24.90,'官网');

INSERT INTO `orders` VALUES (3264,'RT20260901003264',389,'PAID','2026-09-01 20:47:35','2026-09-01 21:42:35',138.00,'小程序');

INSERT INTO `orders` VALUES (3265,'RT20260902003265',636,'PAID','2026-09-02 12:14:57','2026-09-02 12:34:57',387.00,'小程序');

INSERT INTO `orders` VALUES (3266,'RT20260902003266',595,'PAID','2026-09-02 12:29:57','2026-09-02 12:38:57',133.10,'线下门店');

INSERT INTO `orders` VALUES (3267,'RT20260902003267',212,'PAID','2026-09-02 15:50:26','2026-09-02 16:52:26',68.00,'小程序');

INSERT INTO `orders` VALUES (3268,'RT20260902003268',367,'PAID','2026-09-02 19:39:51','2026-09-02 20:17:51',24.90,'小程序');

INSERT INTO `orders` VALUES (3269,'RT20260902003269',122,'PAID','2026-09-02 19:40:55','2026-09-02 19:56:55',84.55,'线下门店');

INSERT INTO `orders` VALUES (3270,'RT20260903003270',263,'PAID','2026-09-03 10:02:02','2026-09-03 10:15:02',24.90,'小程序');

INSERT INTO `orders` VALUES (3271,'RT20260903003271',206,'PAID','2026-09-03 10:46:13','2026-09-03 10:55:13',398.00,'线下门店');

INSERT INTO `orders` VALUES (3272,'RT20260903003272',2,'PAID','2026-09-03 11:33:35','2026-09-03 12:39:35',35.10,'企业采购');

INSERT INTO `orders` VALUES (3273,'RT20260903003273',88,'PAID','2026-09-03 12:30:01','2026-09-03 13:08:01',53.10,'小程序');

INSERT INTO `orders` VALUES (3274,'RT20260903003274',305,'PAID','2026-09-03 13:32:41','2026-09-03 14:16:41',89.00,'线下门店');

INSERT INTO `orders` VALUES (3275,'RT20260903003275',309,'PAID','2026-09-03 15:14:57','2026-09-03 16:03:57',79.00,'小程序');

INSERT INTO `orders` VALUES (3276,'RT20260903003276',584,'PAID','2026-09-03 15:33:09','2026-09-03 15:37:09',59.00,'小程序');

INSERT INTO `orders` VALUES (3277,'RT20260903003277',84,'PAID','2026-09-03 16:45:35','2026-09-03 17:28:35',159.00,'官网');

INSERT INTO `orders` VALUES (3278,'RT20260903003278',279,'PAID','2026-09-03 17:33:03','2026-09-03 18:41:03',147.00,'小程序');

INSERT INTO `orders` VALUES (3279,'RT20260903003279',405,'PAID','2026-09-03 17:48:55','2026-09-03 18:35:55',195.80,'小程序');

INSERT INTO `orders` VALUES (3280,'RT20260904003280',92,'PAID','2026-09-04 15:44:56','2026-09-04 16:50:56',151.05,'线下门店');

INSERT INTO `orders` VALUES (3281,'RT20260904003281',30,'PAID','2026-09-04 15:59:03','2026-09-04 16:06:03',3495.00,'线下门店');

INSERT INTO `orders` VALUES (3282,'RT20260904003282',127,'CANCELLED','2026-09-04 17:20:50',NULL,158.26,'线下门店');

INSERT INTO `orders` VALUES (3283,'RT20260904003283',377,'PAID','2026-09-04 18:24:18','2026-09-04 18:42:18',59.00,'线下门店');

INSERT INTO `orders` VALUES (3284,'RT20260904003284',539,'PAID','2026-09-04 21:54:25','2026-09-04 22:06:25',29.61,'小程序');

INSERT INTO `orders` VALUES (3285,'RT20260905003285',102,'PAID','2026-09-05 10:31:23','2026-09-05 11:36:23',23.66,'小程序');

INSERT INTO `orders` VALUES (3286,'RT20260905003286',296,'REFUNDED','2026-09-05 11:58:06','2026-09-05 12:41:06',159.00,'线下门店');

INSERT INTO `orders` VALUES (3287,'RT20260905003287',79,'PAID','2026-09-05 12:50:15','2026-09-05 13:59:15',201.90,'线下门店');

INSERT INTO `orders` VALUES (3288,'RT20260905003288',231,'CANCELLED','2026-09-05 13:31:06',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (3289,'RT20260905003289',537,'PAID','2026-09-05 13:49:47','2026-09-05 14:35:47',59.00,'小程序');

INSERT INTO `orders` VALUES (3290,'RT20260905003290',317,'REFUNDED','2026-09-05 19:05:56','2026-09-05 20:00:56',68.00,'线下门店');

INSERT INTO `orders` VALUES (3291,'RT20260905003291',13,'PAID','2026-09-05 19:52:45','2026-09-05 20:56:45',79.00,'小程序');

INSERT INTO `orders` VALUES (3292,'RT20260905003292',100,'PAID','2026-09-05 20:06:06','2026-09-05 20:58:06',24.90,'小程序');

INSERT INTO `orders` VALUES (3293,'RT20260906003293',93,'PAID','2026-09-06 08:38:26','2026-09-06 09:31:26',59.57,'小程序');

INSERT INTO `orders` VALUES (3294,'RT20260906003294',498,'PAID','2026-09-06 09:19:21','2026-09-06 09:28:21',70.26,'小程序');

INSERT INTO `orders` VALUES (3295,'RT20260906003295',511,'PAID','2026-09-06 13:04:48','2026-09-06 13:09:48',72.80,'小程序');

INSERT INTO `orders` VALUES (3296,'RT20260906003296',59,'REFUNDED','2026-09-06 14:19:07','2026-09-06 15:33:07',378.10,'小程序');

INSERT INTO `orders` VALUES (3297,'RT20260906003297',200,'PAID','2026-09-06 15:00:10','2026-09-06 15:13:10',24.90,'小程序');

INSERT INTO `orders` VALUES (3298,'RT20260906003298',157,'PAID','2026-09-06 15:12:22','2026-09-06 16:15:22',175.00,'小程序');

INSERT INTO `orders` VALUES (3299,'RT20260906003299',286,'PAID','2026-09-06 15:35:51','2026-09-06 15:41:51',37.05,'小程序');

INSERT INTO `orders` VALUES (3300,'RT20260906003300',293,'PAID','2026-09-06 16:15:04','2026-09-06 16:30:04',115.05,'线下门店');

INSERT INTO `orders` VALUES (3301,'RT20260906003301',120,'CANCELLED','2026-09-06 16:55:34',NULL,107.90,'线下门店');

INSERT INTO `orders` VALUES (3302,'RT20260906003302',301,'PAID','2026-09-06 18:39:45','2026-09-06 19:20:45',68.00,'官网');

INSERT INTO `orders` VALUES (3303,'RT20260906003303',442,'CANCELLED','2026-09-06 18:48:51',NULL,239.20,'官网');

INSERT INTO `orders` VALUES (3304,'RT20260906003304',268,'PAID','2026-09-06 19:15:37','2026-09-06 19:33:37',299.00,'官网');

INSERT INTO `orders` VALUES (3305,'RT20260906003305',339,'PAID','2026-09-06 20:33:07','2026-09-06 21:19:07',299.00,'线下门店');

INSERT INTO `orders` VALUES (3306,'RT20260907003306',605,'PAID','2026-09-07 10:16:29','2026-09-07 10:17:29',78.00,'官网');

INSERT INTO `orders` VALUES (3307,'RT20260907003307',160,'PAID','2026-09-07 10:21:13','2026-09-07 11:28:13',117.90,'线下门店');

INSERT INTO `orders` VALUES (3308,'RT20260907003308',88,'PAID','2026-09-07 12:20:11','2026-09-07 12:24:11',117.90,'小程序');

INSERT INTO `orders` VALUES (3309,'RT20260907003309',194,'PAID','2026-09-07 14:56:36','2026-09-07 15:28:36',159.00,'企业采购');

INSERT INTO `orders` VALUES (3310,'RT20260907003310',106,'PAID','2026-09-07 15:02:17','2026-09-07 15:35:17',39.90,'小程序');

INSERT INTO `orders` VALUES (3311,'RT20260907003311',421,'PAID','2026-09-07 15:40:48','2026-09-07 16:46:48',309.00,'小程序');

INSERT INTO `orders` VALUES (3312,'RT20260907003312',305,'PAID','2026-09-07 18:20:49','2026-09-07 18:50:49',68.00,'小程序');

INSERT INTO `orders` VALUES (3313,'RT20260907003313',468,'PAID','2026-09-07 18:51:15','2026-09-07 19:10:15',107.90,'线下门店');

INSERT INTO `orders` VALUES (3314,'RT20260907003314',365,'PAID','2026-09-07 19:18:26','2026-09-07 19:39:26',208.00,'小程序');

INSERT INTO `orders` VALUES (3315,'RT20260907003315',114,'PAID','2026-09-07 19:27:07','2026-09-07 20:23:07',32.90,'小程序');

INSERT INTO `orders` VALUES (3316,'RT20260907003316',98,'CANCELLED','2026-09-07 20:32:53',NULL,39.90,'官网');

INSERT INTO `orders` VALUES (3317,'RT20260908003317',286,'PAID','2026-09-08 12:55:09','2026-09-08 13:05:09',206.05,'线下门店');

INSERT INTO `orders` VALUES (3318,'RT20260908003318',626,'CANCELLED','2026-09-08 16:23:59',NULL,69.00,'线下门店');

INSERT INTO `orders` VALUES (3319,'RT20260908003319',164,'CANCELLED','2026-09-08 20:44:16',NULL,248.00,'小程序');

INSERT INTO `orders` VALUES (3320,'RT20260908003320',135,'PAID','2026-09-08 21:29:30','2026-09-08 22:38:30',24.90,'小程序');

INSERT INTO `orders` VALUES (3321,'RT20260909003321',534,'PAID','2026-09-09 11:18:35','2026-09-09 11:29:35',39.00,'小程序');

INSERT INTO `orders` VALUES (3322,'RT20260909003322',301,'PAID','2026-09-09 13:01:45','2026-09-09 13:18:45',39.90,'线下门店');

INSERT INTO `orders` VALUES (3323,'RT20260909003323',302,'PAID','2026-09-09 14:42:44','2026-09-09 15:00:44',68.00,'小程序');

INSERT INTO `orders` VALUES (3324,'RT20260909003324',345,'PAID','2026-09-09 15:57:59','2026-09-09 16:30:59',32.90,'线下门店');

INSERT INTO `orders` VALUES (3325,'RT20260909003325',11,'REFUNDED','2026-09-09 16:29:22','2026-09-09 16:37:22',125.05,'小程序');

INSERT INTO `orders` VALUES (3326,'RT20260909003326',74,'PAID','2026-09-09 16:44:46','2026-09-09 17:17:46',129.00,'企业采购');

INSERT INTO `orders` VALUES (3327,'RT20260909003327',555,'REFUNDED','2026-09-09 17:51:51','2026-09-09 18:03:51',368.00,'官网');

INSERT INTO `orders` VALUES (3328,'RT20260909003328',362,'PAID','2026-09-09 20:08:59','2026-09-09 20:31:59',98.25,'小程序');

INSERT INTO `orders` VALUES (3329,'RT20260909003329',363,'PAID','2026-09-09 20:58:30','2026-09-09 21:07:30',258.00,'线下门店');

INSERT INTO `orders` VALUES (3330,'RT20260909003330',292,'PAID','2026-09-09 21:29:10','2026-09-09 21:58:10',60.00,'小程序');

INSERT INTO `orders` VALUES (3331,'RT20260910003331',243,'PAID','2026-09-10 11:21:33','2026-09-10 11:54:33',53.10,'小程序');

INSERT INTO `orders` VALUES (3332,'RT20260910003332',289,'CANCELLED','2026-09-10 13:37:56',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (3333,'RT20260910003333',186,'PAID','2026-09-10 16:12:46','2026-09-10 17:08:46',69.00,'小程序');

INSERT INTO `orders` VALUES (3334,'RT20260910003334',164,'PAID','2026-09-10 16:34:53','2026-09-10 16:37:53',69.00,'官网');

INSERT INTO `orders` VALUES (3335,'RT20260910003335',589,'PAID','2026-09-10 18:08:31','2026-09-10 19:06:31',32.90,'小程序');

INSERT INTO `orders` VALUES (3336,'RT20260910003336',45,'PAID','2026-09-10 18:33:42','2026-09-10 19:30:42',64.60,'官网');

INSERT INTO `orders` VALUES (3337,'RT20260911003337',48,'PAID','2026-09-11 11:13:07','2026-09-11 11:33:07',699.00,'小程序');

INSERT INTO `orders` VALUES (3338,'RT20260911003338',523,'CANCELLED','2026-09-11 11:34:22',NULL,223.90,'线下门店');

INSERT INTO `orders` VALUES (3339,'RT20260911003339',67,'PAID','2026-09-11 13:52:06','2026-09-11 14:31:06',110.90,'线下门店');

INSERT INTO `orders` VALUES (3340,'RT20260911003340',105,'PAID','2026-09-11 15:20:39','2026-09-11 15:37:39',24.90,'官网');

INSERT INTO `orders` VALUES (3341,'RT20260911003341',577,'PAID','2026-09-11 16:01:05','2026-09-11 16:37:05',37.91,'官网');

INSERT INTO `orders` VALUES (3342,'RT20260911003342',296,'PAID','2026-09-11 16:44:25','2026-09-11 16:55:25',39.00,'企业采购');

INSERT INTO `orders` VALUES (3343,'RT20260911003343',21,'PAID','2026-09-11 17:46:25','2026-09-11 19:00:25',39.00,'线下门店');

INSERT INTO `orders` VALUES (3344,'RT20260911003344',207,'PAID','2026-09-11 18:15:06','2026-09-11 18:28:06',160.55,'小程序');

INSERT INTO `orders` VALUES (3345,'RT20260911003345',465,'PAID','2026-09-11 18:44:19','2026-09-11 19:53:19',89.00,'小程序');

INSERT INTO `orders` VALUES (3346,'RT20260911003346',528,'PAID','2026-09-11 19:00:17','2026-09-11 19:44:17',32.90,'小程序');

INSERT INTO `orders` VALUES (3347,'RT20260911003347',304,'PAID','2026-09-11 21:20:58','2026-09-11 22:20:58',32.90,'线下门店');

INSERT INTO `orders` VALUES (3348,'RT20260912003348',383,'CANCELLED','2026-09-12 11:43:15',NULL,39.00,'小程序');

INSERT INTO `orders` VALUES (3349,'RT20260912003349',52,'PAID','2026-09-12 12:32:35','2026-09-12 13:45:35',32.90,'线下门店');

INSERT INTO `orders` VALUES (3350,'RT20260912003350',7,'PAID','2026-09-12 12:58:46','2026-09-12 13:25:46',24.90,'小程序');

INSERT INTO `orders` VALUES (3351,'RT20260912003351',230,'PAID','2026-09-12 14:48:22','2026-09-12 15:19:22',100.90,'小程序');

INSERT INTO `orders` VALUES (3352,'RT20260912003352',610,'PAID','2026-09-12 15:28:06','2026-09-12 16:41:06',108.90,'官网');

INSERT INTO `orders` VALUES (3353,'RT20260912003353',521,'PAID','2026-09-12 17:16:27','2026-09-12 18:17:27',68.00,'小程序');

INSERT INTO `orders` VALUES (3354,'RT20260912003354',73,'PAID','2026-09-12 18:04:43','2026-09-12 18:46:43',78.00,'官网');

INSERT INTO `orders` VALUES (3355,'RT20260912003355',406,'PAID','2026-09-12 19:23:06','2026-09-12 19:47:06',138.70,'小程序');

INSERT INTO `orders` VALUES (3356,'RT20260912003356',519,'PAID','2026-09-12 20:12:08','2026-09-12 20:13:08',169.00,'线下门店');

INSERT INTO `orders` VALUES (3357,'RT20260912003357',150,'PAID','2026-09-12 20:16:40','2026-09-12 20:17:40',106.11,'小程序');

INSERT INTO `orders` VALUES (3358,'RT20260912003358',141,'PAID','2026-09-12 20:56:34','2026-09-12 21:46:34',39.00,'官网');

INSERT INTO `orders` VALUES (3359,'RT20260913003359',306,'PAID','2026-09-13 09:00:30','2026-09-13 09:21:30',160.55,'小程序');

INSERT INTO `orders` VALUES (3360,'RT20260913003360',297,'PAID','2026-09-13 09:02:26','2026-09-13 09:13:26',71.16,'线下门店');

INSERT INTO `orders` VALUES (3361,'RT20260913003361',621,'PAID','2026-09-13 10:27:57','2026-09-13 11:27:57',161.90,'小程序');

INSERT INTO `orders` VALUES (3362,'RT20260913003362',264,'PAID','2026-09-13 11:15:49','2026-09-13 11:22:49',129.00,'线下门店');

INSERT INTO `orders` VALUES (3363,'RT20260913003363',437,'PAID','2026-09-13 13:29:41','2026-09-13 14:43:41',56.16,'小程序');

INSERT INTO `orders` VALUES (3364,'RT20260913003364',263,'PAID','2026-09-13 14:47:50','2026-09-13 15:24:50',129.00,'小程序');

INSERT INTO `orders` VALUES (3365,'RT20260913003365',23,'PAID','2026-09-13 15:00:13','2026-09-13 15:23:13',110.90,'官网');

INSERT INTO `orders` VALUES (3366,'RT20260913003366',406,'PAID','2026-09-13 17:21:27','2026-09-13 17:25:27',285.00,'官网');

INSERT INTO `orders` VALUES (3367,'RT20260913003367',16,'PAID','2026-09-13 17:45:06','2026-09-13 18:07:06',78.00,'企业采购');

INSERT INTO `orders` VALUES (3368,'RT20260913003368',112,'PAID','2026-09-13 18:09:49','2026-09-13 19:11:49',143.60,'小程序');

INSERT INTO `orders` VALUES (3369,'RT20260913003369',98,'PAID','2026-09-13 21:01:06','2026-09-13 21:22:06',31.26,'线下门店');

INSERT INTO `orders` VALUES (3370,'RT20260914003370',457,'PAID','2026-09-14 09:33:29','2026-09-14 10:33:29',56.16,'线下门店');

INSERT INTO `orders` VALUES (3371,'RT20260914003371',57,'CANCELLED','2026-09-14 10:33:22',NULL,79.00,'小程序');

INSERT INTO `orders` VALUES (3372,'RT20260914003372',604,'PAID','2026-09-14 12:38:46','2026-09-14 13:18:46',142.91,'线下门店');

INSERT INTO `orders` VALUES (3373,'RT20260914003373',237,'PAID','2026-09-14 13:23:54','2026-09-14 14:06:54',35.91,'小程序');

INSERT INTO `orders` VALUES (3374,'RT20260914003374',329,'PAID','2026-09-14 16:01:48','2026-09-14 16:54:48',44.82,'线下门店');

INSERT INTO `orders` VALUES (3375,'RT20260914003375',280,'PAID','2026-09-14 16:14:37','2026-09-14 16:44:37',122.46,'线下门店');

INSERT INTO `orders` VALUES (3376,'RT20260914003376',347,'PAID','2026-09-14 16:46:03','2026-09-14 16:49:03',190.05,'线下门店');

INSERT INTO `orders` VALUES (3377,'RT20260914003377',403,'PAID','2026-09-14 17:01:38','2026-09-14 17:22:38',24.90,'小程序');

INSERT INTO `orders` VALUES (3378,'RT20260914003378',269,'PAID','2026-09-14 17:22:10','2026-09-14 17:29:10',39.90,'小程序');

INSERT INTO `orders` VALUES (3379,'RT20260914003379',456,'PAID','2026-09-14 19:09:30','2026-09-14 20:02:30',158.00,'小程序');

INSERT INTO `orders` VALUES (3380,'RT20260915003380',299,'PAID','2026-09-15 13:45:55','2026-09-15 13:56:55',299.00,'小程序');

INSERT INTO `orders` VALUES (3381,'RT20260915003381',554,'PAID','2026-09-15 15:03:21','2026-09-15 15:12:21',218.00,'线下门店');

INSERT INTO `orders` VALUES (3382,'RT20260915003382',123,'PAID','2026-09-15 15:06:47','2026-09-15 15:59:47',330.26,'小程序');

INSERT INTO `orders` VALUES (3383,'RT20260915003383',303,'REFUNDED','2026-09-15 15:58:56','2026-09-15 16:11:56',79.00,'官网');

INSERT INTO `orders` VALUES (3384,'RT20260915003384',120,'PAID','2026-09-15 16:37:34','2026-09-15 17:37:34',24.90,'线下门店');

INSERT INTO `orders` VALUES (3385,'RT20260915003385',321,'PAID','2026-09-15 16:38:51','2026-09-15 17:27:51',179.11,'官网');

INSERT INTO `orders` VALUES (3386,'RT20260915003386',79,'PAID','2026-09-15 16:54:34','2026-09-15 16:57:34',74.10,'小程序');

INSERT INTO `orders` VALUES (3387,'RT20260915003387',263,'PAID','2026-09-15 17:24:06','2026-09-15 17:41:06',39.90,'线下门店');

INSERT INTO `orders` VALUES (3388,'RT20260915003388',234,'PAID','2026-09-15 17:30:21','2026-09-15 17:53:21',56.05,'线下门店');

INSERT INTO `orders` VALUES (3389,'RT20260915003389',153,'PAID','2026-09-15 17:47:31','2026-09-15 18:08:31',22.41,'线下门店');

INSERT INTO `orders` VALUES (3390,'RT20260915003390',281,'PAID','2026-09-15 18:02:40','2026-09-15 18:15:40',59.00,'官网');

INSERT INTO `orders` VALUES (3391,'RT20260915003391',5,'PAID','2026-09-15 18:46:40','2026-09-15 19:39:40',74.10,'线下门店');

INSERT INTO `orders` VALUES (3392,'RT20260915003392',150,'PAID','2026-09-15 21:39:29','2026-09-15 21:52:29',31.26,'小程序');

INSERT INTO `orders` VALUES (3393,'RT20260916003393',317,'PAID','2026-09-16 08:24:21','2026-09-16 09:31:21',79.80,'官网');

INSERT INTO `orders` VALUES (3394,'RT20260916003394',395,'PAID','2026-09-16 10:41:44','2026-09-16 11:56:44',269.90,'线下门店');

INSERT INTO `orders` VALUES (3395,'RT20260916003395',191,'PAID','2026-09-16 13:07:54','2026-09-16 13:53:54',68.00,'小程序');

INSERT INTO `orders` VALUES (3396,'RT20260916003396',106,'CANCELLED','2026-09-16 14:14:43',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (3397,'RT20260916003397',205,'PAID','2026-09-16 14:39:53','2026-09-16 14:40:53',399.00,'官网');

INSERT INTO `orders` VALUES (3398,'RT20260916003398',142,'PAID','2026-09-16 16:10:35','2026-09-16 16:27:35',32.90,'线下门店');

INSERT INTO `orders` VALUES (3399,'RT20260916003399',616,'PAID','2026-09-16 16:16:50','2026-09-16 17:15:50',59.00,'小程序');

INSERT INTO `orders` VALUES (3400,'RT20260916003400',108,'PAID','2026-09-16 17:01:33','2026-09-16 17:26:33',32.90,'小程序');

INSERT INTO `orders` VALUES (3401,'RT20260916003401',425,'PAID','2026-09-16 17:02:00','2026-09-16 17:39:00',32.90,'官网');

INSERT INTO `orders` VALUES (3402,'RT20260916003402',246,'PAID','2026-09-16 18:30:45','2026-09-16 19:14:45',39.00,'小程序');

INSERT INTO `orders` VALUES (3403,'RT20260916003403',74,'PAID','2026-09-16 19:52:35','2026-09-16 20:15:35',61.20,'小程序');

INSERT INTO `orders` VALUES (3404,'RT20260916003404',585,'PAID','2026-09-16 19:57:50','2026-09-16 20:42:50',232.20,'小程序');

INSERT INTO `orders` VALUES (3405,'RT20260916003405',26,'PAID','2026-09-16 21:44:35','2026-09-16 22:45:35',39.90,'线下门店');

INSERT INTO `orders` VALUES (3406,'RT20260917003406',423,'PAID','2026-09-17 10:09:03','2026-09-17 10:44:03',65.55,'官网');

INSERT INTO `orders` VALUES (3407,'RT20260917003407',392,'PAID','2026-09-17 11:40:11','2026-09-17 12:06:11',159.00,'小程序');

INSERT INTO `orders` VALUES (3408,'RT20260917003408',230,'PAID','2026-09-17 12:22:44','2026-09-17 12:38:44',56.05,'官网');

INSERT INTO `orders` VALUES (3409,'RT20260917003409',204,'CANCELLED','2026-09-17 13:29:30',NULL,39.90,'线下门店');

INSERT INTO `orders` VALUES (3410,'RT20260917003410',331,'REFUNDED','2026-09-17 14:18:03','2026-09-17 14:55:03',68.00,'小程序');

INSERT INTO `orders` VALUES (3411,'RT20260917003411',569,'PAID','2026-09-17 15:54:39','2026-09-17 16:38:39',109.45,'小程序');

INSERT INTO `orders` VALUES (3412,'RT20260917003412',36,'PAID','2026-09-17 16:55:47','2026-09-17 18:08:47',136.00,'线下门店');

INSERT INTO `orders` VALUES (3413,'RT20260917003413',123,'PAID','2026-09-17 19:50:27','2026-09-17 20:09:27',35.91,'小程序');

INSERT INTO `orders` VALUES (3414,'RT20260917003414',509,'PAID','2026-09-17 20:11:14','2026-09-17 21:26:14',47.31,'小程序');

INSERT INTO `orders` VALUES (3415,'RT20260918003415',46,'CANCELLED','2026-09-18 10:27:00',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (3416,'RT20260918003416',113,'PAID','2026-09-18 11:06:35','2026-09-18 11:19:35',39.90,'小程序');

INSERT INTO `orders` VALUES (3417,'RT20260918003417',128,'PAID','2026-09-18 11:24:09','2026-09-18 11:44:09',39.00,'小程序');

INSERT INTO `orders` VALUES (3418,'RT20260918003418',351,'PAID','2026-09-18 11:49:32','2026-09-18 12:11:32',106.05,'线下门店');

INSERT INTO `orders` VALUES (3419,'RT20260918003419',635,'PAID','2026-09-18 11:51:42','2026-09-18 12:42:42',204.00,'线下门店');

INSERT INTO `orders` VALUES (3420,'RT20260918003420',203,'PAID','2026-09-18 12:31:37','2026-09-18 13:37:37',39.90,'线下门店');

INSERT INTO `orders` VALUES (3421,'RT20260918003421',469,'PAID','2026-09-18 13:11:22','2026-09-18 14:17:22',71.10,'小程序');

INSERT INTO `orders` VALUES (3422,'RT20260918003422',371,'PAID','2026-09-18 13:23:42','2026-09-18 14:18:42',79.00,'线下门店');

INSERT INTO `orders` VALUES (3423,'RT20260918003423',263,'CANCELLED','2026-09-18 13:47:09',NULL,98.00,'小程序');

INSERT INTO `orders` VALUES (3424,'RT20260918003424',231,'PAID','2026-09-18 17:46:54','2026-09-18 18:30:54',446.71,'官网');

INSERT INTO `orders` VALUES (3425,'RT20260918003425',576,'PAID','2026-09-18 18:54:53','2026-09-18 19:44:53',79.00,'线下门店');

INSERT INTO `orders` VALUES (3426,'RT20260918003426',391,'CANCELLED','2026-09-18 19:39:26',NULL,80.10,'小程序');

INSERT INTO `orders` VALUES (3427,'RT20260918003427',320,'PAID','2026-09-18 19:47:25','2026-09-18 20:01:25',287.00,'线下门店');

INSERT INTO `orders` VALUES (3428,'RT20260919003428',101,'PAID','2026-09-19 09:58:06','2026-09-19 10:07:06',208.00,'线下门店');

INSERT INTO `orders` VALUES (3429,'RT20260919003429',135,'PAID','2026-09-19 10:46:52','2026-09-19 11:28:52',39.90,'线下门店');

INSERT INTO `orders` VALUES (3430,'RT20260919003430',113,'PAID','2026-09-19 11:01:52','2026-09-19 11:55:52',39.00,'小程序');

INSERT INTO `orders` VALUES (3431,'RT20260919003431',163,'PAID','2026-09-19 11:05:30','2026-09-19 11:07:30',175.65,'小程序');

INSERT INTO `orders` VALUES (3432,'RT20260919003432',270,'PAID','2026-09-19 14:18:25','2026-09-19 14:48:25',59.00,'官网');

INSERT INTO `orders` VALUES (3433,'RT20260919003433',419,'PAID','2026-09-19 14:52:07','2026-09-19 15:27:07',59.00,'企业采购');

INSERT INTO `orders` VALUES (3434,'RT20260919003434',318,'PAID','2026-09-19 16:33:43','2026-09-19 16:37:43',39.90,'线下门店');

INSERT INTO `orders` VALUES (3435,'RT20260919003435',311,'CANCELLED','2026-09-19 16:57:28',NULL,238.90,'企业采购');

INSERT INTO `orders` VALUES (3436,'RT20260919003436',251,'PAID','2026-09-19 17:00:26','2026-09-19 17:50:26',361.66,'小程序');

INSERT INTO `orders` VALUES (3437,'RT20260919003437',292,'PAID','2026-09-19 17:17:00','2026-09-19 17:28:00',69.00,'小程序');

INSERT INTO `orders` VALUES (3438,'RT20260919003438',331,'CANCELLED','2026-09-19 18:39:03',NULL,72.80,'小程序');

INSERT INTO `orders` VALUES (3439,'RT20260919003439',280,'PAID','2026-09-19 18:46:29','2026-09-19 19:00:29',146.00,'官网');

INSERT INTO `orders` VALUES (3440,'RT20260919003440',604,'PAID','2026-09-19 18:50:52','2026-09-19 19:35:52',75.05,'线下门店');

INSERT INTO `orders` VALUES (3441,'RT20260919003441',521,'PAID','2026-09-19 18:51:29','2026-09-19 19:26:29',109.45,'官网');

INSERT INTO `orders` VALUES (3442,'RT20260919003442',62,'CANCELLED','2026-09-19 19:31:03',NULL,418.95,'小程序');

INSERT INTO `orders` VALUES (3443,'RT20260919003443',103,'CANCELLED','2026-09-19 19:49:37',NULL,68.00,'线下门店');

INSERT INTO `orders` VALUES (3444,'RT20260919003444',273,'PAID','2026-09-19 20:35:12','2026-09-19 20:46:12',141.41,'线下门店');

INSERT INTO `orders` VALUES (3445,'RT20260919003445',489,'PAID','2026-09-19 20:53:32','2026-09-19 21:44:32',68.00,'官网');

INSERT INTO `orders` VALUES (3446,'RT20260919003446',358,'PAID','2026-09-19 21:41:13','2026-09-19 22:22:13',39.00,'小程序');

INSERT INTO `orders` VALUES (3447,'RT20260920003447',385,'PAID','2026-09-20 09:51:16','2026-09-20 09:59:16',39.00,'线下门店');

INSERT INTO `orders` VALUES (3448,'RT20260920003448',230,'PAID','2026-09-20 12:40:20','2026-09-20 13:23:20',169.10,'小程序');

INSERT INTO `orders` VALUES (3449,'RT20260920003449',241,'PAID','2026-09-20 12:52:46','2026-09-20 14:01:46',128.00,'小程序');

INSERT INTO `orders` VALUES (3450,'RT20260920003450',594,'PAID','2026-09-20 14:25:38','2026-09-20 14:47:38',1407.10,'企业采购');

INSERT INTO `orders` VALUES (3451,'RT20260920003451',253,'PAID','2026-09-20 15:31:38','2026-09-20 16:25:38',106.20,'线下门店');

INSERT INTO `orders` VALUES (3452,'RT20260920003452',58,'PAID','2026-09-20 17:22:32','2026-09-20 18:08:32',59.00,'小程序');

INSERT INTO `orders` VALUES (3453,'RT20260920003453',380,'PAID','2026-09-20 17:33:17','2026-09-20 18:14:17',39.90,'线下门店');

INSERT INTO `orders` VALUES (3454,'RT20260920003454',623,'PAID','2026-09-20 17:52:34','2026-09-20 18:14:34',57.80,'小程序');

INSERT INTO `orders` VALUES (3455,'RT20260920003455',32,'PAID','2026-09-20 18:35:34','2026-09-20 19:01:34',159.00,'线下门店');

INSERT INTO `orders` VALUES (3456,'RT20260920003456',600,'CANCELLED','2026-09-20 19:05:46',NULL,31.26,'线下门店');

INSERT INTO `orders` VALUES (3457,'RT20260920003457',504,'CANCELLED','2026-09-20 19:26:31',NULL,47.31,'小程序');

INSERT INTO `orders` VALUES (3458,'RT20260921003458',310,'REFUNDED','2026-09-21 08:20:41','2026-09-21 09:08:41',130.90,'线下门店');

INSERT INTO `orders` VALUES (3459,'RT20260921003459',381,'PAID','2026-09-21 11:02:07','2026-09-21 12:06:07',39.00,'官网');

INSERT INTO `orders` VALUES (3460,'RT20260921003460',71,'PAID','2026-09-21 11:31:35','2026-09-21 11:47:35',32.90,'线下门店');

INSERT INTO `orders` VALUES (3461,'RT20260921003461',69,'PAID','2026-09-21 11:37:10','2026-09-21 12:35:10',212.80,'官网');

INSERT INTO `orders` VALUES (3462,'RT20260921003462',249,'PAID','2026-09-21 11:41:04','2026-09-21 11:45:04',200.30,'线下门店');

INSERT INTO `orders` VALUES (3463,'RT20260921003463',289,'PAID','2026-09-21 11:52:18','2026-09-21 11:58:18',188.00,'小程序');

INSERT INTO `orders` VALUES (3464,'RT20260921003464',9,'PAID','2026-09-21 16:17:01','2026-09-21 16:42:01',39.90,'官网');

INSERT INTO `orders` VALUES (3465,'RT20260921003465',201,'REFUNDED','2026-09-21 18:00:01','2026-09-21 18:21:01',76.95,'小程序');

INSERT INTO `orders` VALUES (3466,'RT20260921003466',391,'PAID','2026-09-21 18:33:05','2026-09-21 19:33:05',79.00,'小程序');

INSERT INTO `orders` VALUES (3467,'RT20260921003467',539,'PAID','2026-09-21 18:33:40','2026-09-21 19:34:40',764.55,'线下门店');

INSERT INTO `orders` VALUES (3468,'RT20260921003468',73,'PAID','2026-09-21 19:17:44','2026-09-21 19:40:44',387.00,'线下门店');

INSERT INTO `orders` VALUES (3469,'RT20260921003469',42,'PAID','2026-09-21 20:48:50','2026-09-21 20:57:50',136.00,'小程序');

INSERT INTO `orders` VALUES (3470,'RT20260921003470',112,'PAID','2026-09-21 21:03:13','2026-09-21 22:14:13',39.90,'企业采购');

INSERT INTO `orders` VALUES (3471,'RT20260922003471',84,'PAID','2026-09-22 09:19:21','2026-09-22 10:16:21',39.90,'小程序');

INSERT INTO `orders` VALUES (3472,'RT20260922003472',373,'PAID','2026-09-22 11:55:28','2026-09-22 11:58:28',59.00,'小程序');

INSERT INTO `orders` VALUES (3473,'RT20260922003473',125,'PAID','2026-09-22 12:28:48','2026-09-22 12:58:48',152.66,'小程序');

INSERT INTO `orders` VALUES (3474,'RT20260922003474',198,'PAID','2026-09-22 12:49:41','2026-09-22 13:30:41',135.05,'线下门店');

INSERT INTO `orders` VALUES (3475,'RT20260922003475',581,'PAID','2026-09-22 13:20:09','2026-09-22 13:26:09',89.00,'线下门店');

INSERT INTO `orders` VALUES (3476,'RT20260922003476',504,'PAID','2026-09-22 14:04:31','2026-09-22 14:10:31',39.90,'企业采购');

INSERT INTO `orders` VALUES (3477,'RT20260922003477',220,'PAID','2026-09-22 15:13:36','2026-09-22 15:22:36',39.90,'官网');

INSERT INTO `orders` VALUES (3478,'RT20260922003478',434,'PAID','2026-09-22 16:39:21','2026-09-22 16:41:21',117.00,'官网');

INSERT INTO `orders` VALUES (3479,'RT20260922003479',220,'PAID','2026-09-22 16:55:56','2026-09-22 16:57:56',91.56,'小程序');

INSERT INTO `orders` VALUES (3480,'RT20260922003480',41,'PAID','2026-09-22 17:11:29','2026-09-22 17:53:29',169.00,'企业采购');

INSERT INTO `orders` VALUES (3481,'RT20260922003481',342,'REFUNDED','2026-09-22 18:35:41','2026-09-22 19:15:41',24.90,'线下门店');

INSERT INTO `orders` VALUES (3482,'RT20260922003482',117,'PAID','2026-09-22 18:57:27','2026-09-22 19:16:27',400.90,'小程序');

INSERT INTO `orders` VALUES (3483,'RT20260922003483',258,'PAID','2026-09-22 19:09:31','2026-09-22 19:57:31',39.90,'线下门店');

INSERT INTO `orders` VALUES (3484,'RT20260922003484',148,'PAID','2026-09-22 19:13:40','2026-09-22 19:24:40',89.50,'小程序');

INSERT INTO `orders` VALUES (3485,'RT20260922003485',331,'PAID','2026-09-22 19:55:58','2026-09-22 20:20:58',68.00,'小程序');

INSERT INTO `orders` VALUES (3486,'RT20260922003486',467,'PAID','2026-09-22 21:43:05','2026-09-22 22:14:05',985.00,'小程序');

INSERT INTO `orders` VALUES (3487,'RT20260922003487',118,'PAID','2026-09-22 21:49:24','2026-09-22 22:41:24',133.80,'线下门店');

INSERT INTO `orders` VALUES (3488,'RT20260923003488',593,'PAID','2026-09-23 09:00:31','2026-09-23 09:26:31',267.00,'线下门店');

INSERT INTO `orders` VALUES (3489,'RT20260923003489',438,'CANCELLED','2026-09-23 09:52:22',NULL,84.55,'官网');

INSERT INTO `orders` VALUES (3490,'RT20260923003490',103,'PAID','2026-09-23 10:47:51','2026-09-23 11:23:51',477.00,'小程序');

INSERT INTO `orders` VALUES (3491,'RT20260923003491',285,'PAID','2026-09-23 11:46:27','2026-09-23 12:34:27',142.90,'小程序');

INSERT INTO `orders` VALUES (3492,'RT20260923003492',19,'PAID','2026-09-23 11:50:24','2026-09-23 12:08:24',64.60,'官网');

INSERT INTO `orders` VALUES (3493,'RT20260923003493',406,'PAID','2026-09-23 12:19:54','2026-09-23 12:44:54',103.60,'线下门店');

INSERT INTO `orders` VALUES (3494,'RT20260923003494',210,'CANCELLED','2026-09-23 12:32:24',NULL,32.90,'小程序');

INSERT INTO `orders` VALUES (3495,'RT20260923003495',158,'PAID','2026-09-23 13:10:55','2026-09-23 13:44:55',329.10,'官网');

INSERT INTO `orders` VALUES (3496,'RT20260923003496',27,'PAID','2026-09-23 15:41:27','2026-09-23 16:43:27',148.00,'官网');

INSERT INTO `orders` VALUES (3497,'RT20260923003497',407,'PAID','2026-09-23 16:32:26','2026-09-23 16:59:26',265.65,'线下门店');

INSERT INTO `orders` VALUES (3498,'RT20260923003498',77,'PAID','2026-09-23 19:34:01','2026-09-23 19:39:01',32.90,'线下门店');

INSERT INTO `orders` VALUES (3499,'RT20260923003499',311,'PAID','2026-09-23 20:05:56','2026-09-23 21:06:56',281.55,'小程序');

INSERT INTO `orders` VALUES (3500,'RT20260923003500',129,'REFUNDED','2026-09-23 20:53:38','2026-09-23 20:54:38',69.00,'官网');

INSERT INTO `orders` VALUES (3501,'RT20260923003501',154,'PAID','2026-09-23 21:44:43','2026-09-23 22:24:43',92.90,'线下门店');

INSERT INTO `orders` VALUES (3502,'RT20260923003502',336,'PAID','2026-09-23 21:44:46','2026-09-23 22:23:46',136.00,'企业采购');

INSERT INTO `orders` VALUES (3503,'RT20260924003503',239,'REFUNDED','2026-09-24 09:54:57','2026-09-24 10:50:57',35.10,'官网');

INSERT INTO `orders` VALUES (3504,'RT20260924003504',263,'PAID','2026-09-24 10:09:38','2026-09-24 10:17:38',39.00,'小程序');

INSERT INTO `orders` VALUES (3505,'RT20260924003505',131,'PAID','2026-09-24 11:25:47','2026-09-24 12:13:47',69.00,'小程序');

INSERT INTO `orders` VALUES (3506,'RT20260924003506',353,'PAID','2026-09-24 12:23:33','2026-09-24 12:52:33',65.80,'小程序');

INSERT INTO `orders` VALUES (3507,'RT20260924003507',497,'PAID','2026-09-24 14:18:25','2026-09-24 15:23:25',218.00,'线下门店');

INSERT INTO `orders` VALUES (3508,'RT20260924003508',28,'PAID','2026-09-24 16:28:11','2026-09-24 16:34:11',32.90,'小程序');

INSERT INTO `orders` VALUES (3509,'RT20260924003509',618,'PAID','2026-09-24 16:36:19','2026-09-24 17:17:19',32.90,'小程序');

INSERT INTO `orders` VALUES (3510,'RT20260924003510',345,'CANCELLED','2026-09-24 16:54:07',NULL,160.55,'官网');

INSERT INTO `orders` VALUES (3511,'RT20260924003511',230,'PAID','2026-09-24 16:59:13','2026-09-24 17:26:13',899.00,'官网');

INSERT INTO `orders` VALUES (3512,'RT20260924003512',143,'PAID','2026-09-24 18:05:47','2026-09-24 19:04:47',186.80,'小程序');

INSERT INTO `orders` VALUES (3513,'RT20260924003513',132,'PAID','2026-09-24 18:20:06','2026-09-24 18:49:06',24.90,'线下门店');

INSERT INTO `orders` VALUES (3514,'RT20260924003514',210,'PAID','2026-09-24 21:02:58','2026-09-24 21:03:58',68.00,'小程序');

INSERT INTO `orders` VALUES (3515,'RT20260924003515',456,'PAID','2026-09-24 22:41:36','2026-09-24 23:40:36',197.00,'小程序');

INSERT INTO `orders` VALUES (3516,'RT20260925003516',79,'PAID','2026-09-25 08:59:10','2026-09-25 09:27:10',286.20,'小程序');

INSERT INTO `orders` VALUES (3517,'RT20260925003517',151,'PAID','2026-09-25 10:29:07','2026-09-25 11:13:07',39.00,'官网');

INSERT INTO `orders` VALUES (3518,'RT20260925003518',76,'PAID','2026-09-25 12:13:45','2026-09-25 12:59:45',39.00,'小程序');

INSERT INTO `orders` VALUES (3519,'RT20260925003519',76,'PAID','2026-09-25 14:58:49','2026-09-25 16:05:49',39.90,'小程序');

INSERT INTO `orders` VALUES (3520,'RT20260925003520',15,'PAID','2026-09-25 16:02:40','2026-09-25 16:50:40',80.10,'线下门店');

INSERT INTO `orders` VALUES (3521,'RT20260925003521',448,'PAID','2026-09-25 16:41:56','2026-09-25 17:56:56',24.90,'线下门店');

INSERT INTO `orders` VALUES (3522,'RT20260925003522',116,'PAID','2026-09-25 17:13:03','2026-09-25 17:37:03',177.00,'小程序');

INSERT INTO `orders` VALUES (3523,'RT20260925003523',345,'PAID','2026-09-25 17:26:30','2026-09-25 18:34:30',299.00,'线下门店');

INSERT INTO `orders` VALUES (3524,'RT20260925003524',386,'CANCELLED','2026-09-25 17:45:30',NULL,160.90,'小程序');

INSERT INTO `orders` VALUES (3525,'RT20260925003525',438,'PAID','2026-09-25 20:47:25','2026-09-25 21:46:25',128.00,'官网');

INSERT INTO `orders` VALUES (3526,'RT20260926003526',572,'PAID','2026-09-26 10:29:03','2026-09-26 11:06:03',138.61,'小程序');

INSERT INTO `orders` VALUES (3527,'RT20260926003527',202,'CANCELLED','2026-09-26 12:40:50',NULL,80.10,'企业采购');

INSERT INTO `orders` VALUES (3528,'RT20260926003528',84,'PAID','2026-09-26 15:07:26','2026-09-26 16:12:26',258.00,'线下门店');

INSERT INTO `orders` VALUES (3529,'RT20260926003529',237,'PAID','2026-09-26 15:12:07','2026-09-26 15:59:07',32.90,'线下门店');

INSERT INTO `orders` VALUES (3530,'RT20260926003530',103,'PAID','2026-09-26 16:31:47','2026-09-26 17:30:47',153.55,'小程序');

INSERT INTO `orders` VALUES (3531,'RT20260926003531',61,'PAID','2026-09-26 19:55:25','2026-09-26 20:35:25',39.90,'小程序');

INSERT INTO `orders` VALUES (3532,'RT20260926003532',39,'PAID','2026-09-26 20:41:58','2026-09-26 21:05:58',89.00,'企业采购');

INSERT INTO `orders` VALUES (3533,'RT20260926003533',558,'PAID','2026-09-26 22:00:08','2026-09-26 22:58:08',39.00,'小程序');

INSERT INTO `orders` VALUES (3534,'RT20260927003534',134,'CANCELLED','2026-09-27 09:41:40',NULL,117.00,'线下门店');

INSERT INTO `orders` VALUES (3535,'RT20260927003535',80,'PAID','2026-09-27 10:30:51','2026-09-27 10:52:51',32.90,'线下门店');

INSERT INTO `orders` VALUES (3536,'RT20260927003536',53,'PAID','2026-09-27 11:53:38','2026-09-27 12:55:38',32.90,'官网');

INSERT INTO `orders` VALUES (3537,'RT20260927003537',181,'CANCELLED','2026-09-27 12:08:36',NULL,157.90,'小程序');

INSERT INTO `orders` VALUES (3538,'RT20260927003538',36,'PAID','2026-09-27 13:12:48','2026-09-27 14:04:48',89.00,'线下门店');

INSERT INTO `orders` VALUES (3539,'RT20260927003539',257,'PAID','2026-09-27 13:50:21','2026-09-27 14:08:21',117.90,'小程序');

INSERT INTO `orders` VALUES (3540,'RT20260927003540',400,'PAID','2026-09-27 13:56:23','2026-09-27 14:27:23',24.90,'官网');

INSERT INTO `orders` VALUES (3541,'RT20260927003541',39,'PAID','2026-09-27 14:29:26','2026-09-27 14:47:26',664.05,'企业采购');

INSERT INTO `orders` VALUES (3542,'RT20260927003542',144,'PAID','2026-09-27 16:10:04','2026-09-27 16:28:04',245.00,'小程序');

INSERT INTO `orders` VALUES (3543,'RT20260927003543',206,'PAID','2026-09-27 16:24:13','2026-09-27 17:27:13',113.72,'官网');

INSERT INTO `orders` VALUES (3544,'RT20260927003544',310,'PAID','2026-09-27 16:50:28','2026-09-27 17:50:28',39.90,'小程序');

INSERT INTO `orders` VALUES (3545,'RT20260927003545',221,'PAID','2026-09-27 17:26:55','2026-09-27 17:42:55',158.00,'官网');

INSERT INTO `orders` VALUES (3546,'RT20260927003546',313,'PAID','2026-09-27 17:43:45','2026-09-27 18:11:45',103.90,'官网');

INSERT INTO `orders` VALUES (3547,'RT20260927003547',200,'PAID','2026-09-27 19:16:49','2026-09-27 20:20:49',208.00,'线下门店');

INSERT INTO `orders` VALUES (3548,'RT20260927003548',340,'PAID','2026-09-27 19:19:50','2026-09-27 20:19:50',606.10,'线下门店');

INSERT INTO `orders` VALUES (3549,'RT20260927003549',154,'PAID','2026-09-27 19:47:45','2026-09-27 19:53:45',24.90,'线下门店');

INSERT INTO `orders` VALUES (3550,'RT20260927003550',150,'PAID','2026-09-27 20:33:41','2026-09-27 21:36:41',75.05,'线下门店');

INSERT INTO `orders` VALUES (3551,'RT20260927003551',550,'PAID','2026-09-27 20:46:47','2026-09-27 21:06:47',258.00,'线下门店');

INSERT INTO `orders` VALUES (3552,'RT20260927003552',114,'PAID','2026-09-27 21:17:20','2026-09-27 21:41:20',31.26,'官网');

INSERT INTO `orders` VALUES (3553,'RT20260928003553',135,'PAID','2026-09-28 10:09:13','2026-09-28 10:55:13',78.00,'官网');

INSERT INTO `orders` VALUES (3554,'RT20260928003554',282,'PAID','2026-09-28 12:12:36','2026-09-28 12:34:36',193.91,'线下门店');

INSERT INTO `orders` VALUES (3555,'RT20260928003555',83,'PAID','2026-09-28 15:13:45','2026-09-28 15:47:45',24.90,'官网');

INSERT INTO `orders` VALUES (3556,'RT20260928003556',445,'PAID','2026-09-28 15:57:01','2026-09-28 16:13:01',65.55,'小程序');

INSERT INTO `orders` VALUES (3557,'RT20260928003557',240,'PAID','2026-09-28 17:48:20','2026-09-28 18:59:20',159.00,'线下门店');

INSERT INTO `orders` VALUES (3558,'RT20260929003558',520,'PAID','2026-09-29 15:12:41','2026-09-29 15:27:41',59.00,'小程序');

INSERT INTO `orders` VALUES (3559,'RT20260929003559',400,'PAID','2026-09-29 16:17:52','2026-09-29 16:55:52',69.00,'线下门店');

INSERT INTO `orders` VALUES (3560,'RT20260929003560',464,'CANCELLED','2026-09-29 20:05:36',NULL,280.46,'官网');

INSERT INTO `orders` VALUES (3561,'RT20260929003561',364,'PAID','2026-09-29 21:10:35','2026-09-29 22:20:35',39.90,'线下门店');

INSERT INTO `orders` VALUES (3562,'RT20260930003562',228,'PAID','2026-09-30 10:41:52','2026-09-30 11:38:52',98.00,'官网');

INSERT INTO `orders` VALUES (3563,'RT20260930003563',79,'PAID','2026-09-30 11:43:12','2026-09-30 12:10:12',78.00,'线下门店');

INSERT INTO `orders` VALUES (3564,'RT20260930003564',412,'PAID','2026-09-30 14:33:26','2026-09-30 15:40:26',116.86,'小程序');

INSERT INTO `orders` VALUES (3565,'RT20260930003565',129,'PAID','2026-09-30 16:13:04','2026-09-30 17:20:04',899.00,'官网');

INSERT INTO `orders` VALUES (3566,'RT20260930003566',138,'REFUNDED','2026-09-30 17:06:31','2026-09-30 18:06:31',119.70,'小程序');

INSERT INTO `orders` VALUES (3567,'RT20260930003567',59,'PAID','2026-09-30 18:20:24','2026-09-30 19:20:24',32.90,'企业采购');

INSERT INTO `orders` VALUES (3568,'RT20260930003568',494,'PAID','2026-09-30 18:23:38','2026-09-30 19:35:38',159.00,'官网');

INSERT INTO `orders` VALUES (3569,'RT20260930003569',198,'PAID','2026-09-30 19:05:11','2026-09-30 19:22:11',39.90,'小程序');

INSERT INTO `orders` VALUES (3570,'RT20261001003570',138,'PAID','2026-10-01 12:53:14','2026-10-01 13:39:14',155.30,'小程序');

INSERT INTO `orders` VALUES (3571,'RT20261001003571',41,'PAID','2026-10-01 16:08:34','2026-10-01 17:23:34',47.31,'线下门店');

INSERT INTO `orders` VALUES (3572,'RT20261001003572',347,'PAID','2026-10-01 16:48:42','2026-10-01 17:42:42',118.00,'小程序');

INSERT INTO `orders` VALUES (3573,'RT20261001003573',460,'PAID','2026-10-01 17:11:52','2026-10-01 17:39:52',59.00,'小程序');

INSERT INTO `orders` VALUES (3574,'RT20261001003574',273,'PAID','2026-10-01 17:28:02','2026-10-01 17:34:02',318.00,'线下门店');

INSERT INTO `orders` VALUES (3575,'RT20261001003575',431,'PAID','2026-10-01 17:42:45','2026-10-01 18:29:45',68.00,'小程序');

INSERT INTO `orders` VALUES (3576,'RT20261001003576',175,'PAID','2026-10-01 18:44:41','2026-10-01 19:45:41',185.85,'小程序');

INSERT INTO `orders` VALUES (3577,'RT20261001003577',283,'PAID','2026-10-01 19:21:10','2026-10-01 19:57:10',267.00,'官网');

INSERT INTO `orders` VALUES (3578,'RT20261001003578',361,'PAID','2026-10-01 19:41:51','2026-10-01 19:57:51',76.95,'线下门店');

INSERT INTO `orders` VALUES (3579,'RT20261001003579',379,'PAID','2026-10-01 19:45:24','2026-10-01 20:22:24',39.90,'企业采购');

INSERT INTO `orders` VALUES (3580,'RT20261001003580',54,'PAID','2026-10-01 20:48:18','2026-10-01 20:53:18',284.05,'小程序');

INSERT INTO `orders` VALUES (3581,'RT20261002003581',555,'PAID','2026-10-02 10:40:17','2026-10-02 10:51:17',32.90,'官网');

INSERT INTO `orders` VALUES (3582,'RT20261002003582',292,'PAID','2026-10-02 10:58:39','2026-10-02 11:32:39',39.90,'小程序');

INSERT INTO `orders` VALUES (3583,'RT20261002003583',68,'PAID','2026-10-02 12:50:33','2026-10-02 12:57:33',32.90,'小程序');

INSERT INTO `orders` VALUES (3584,'RT20261002003584',479,'PAID','2026-10-02 13:43:55','2026-10-02 14:41:55',24.90,'小程序');

INSERT INTO `orders` VALUES (3585,'RT20261002003585',55,'PAID','2026-10-02 15:32:57','2026-10-02 16:33:57',197.00,'线下门店');

INSERT INTO `orders` VALUES (3586,'RT20261002003586',417,'PAID','2026-10-02 16:12:31','2026-10-02 16:48:31',64.60,'小程序');

INSERT INTO `orders` VALUES (3587,'RT20261002003587',510,'PAID','2026-10-02 16:30:39','2026-10-02 17:15:39',39.00,'官网');

INSERT INTO `orders` VALUES (3588,'RT20261002003588',433,'PAID','2026-10-02 18:32:47','2026-10-02 18:36:47',39.90,'官网');

INSERT INTO `orders` VALUES (3589,'RT20261002003589',189,'PAID','2026-10-02 19:47:55','2026-10-02 20:50:55',29.61,'线下门店');

INSERT INTO `orders` VALUES (3590,'RT20261002003590',181,'PAID','2026-10-02 21:16:06','2026-10-02 21:51:06',198.00,'小程序');

INSERT INTO `orders` VALUES (3591,'RT20261003003591',51,'PAID','2026-10-03 09:21:00','2026-10-03 09:50:00',100.26,'官网');

INSERT INTO `orders` VALUES (3592,'RT20261003003592',546,'PAID','2026-10-03 10:48:14','2026-10-03 11:58:14',69.00,'小程序');

INSERT INTO `orders` VALUES (3593,'RT20261003003593',14,'PAID','2026-10-03 11:04:35','2026-10-03 12:19:35',189.05,'官网');

INSERT INTO `orders` VALUES (3594,'RT20261003003594',497,'PAID','2026-10-03 12:50:31','2026-10-03 13:42:31',151.05,'官网');

INSERT INTO `orders` VALUES (3595,'RT20261003003595',41,'PAID','2026-10-03 14:35:17','2026-10-03 15:10:17',68.00,'小程序');

INSERT INTO `orders` VALUES (3596,'RT20261003003596',251,'PAID','2026-10-03 14:56:23','2026-10-03 15:57:23',37.05,'小程序');

INSERT INTO `orders` VALUES (3597,'RT20261003003597',292,'PAID','2026-10-03 15:15:45','2026-10-03 16:08:45',24.90,'小程序');

INSERT INTO `orders` VALUES (3598,'RT20261003003598',38,'CANCELLED','2026-10-03 15:38:01',NULL,59.00,'小程序');

INSERT INTO `orders` VALUES (3599,'RT20261003003599',560,'PAID','2026-10-03 16:27:15','2026-10-03 17:36:15',318.00,'线下门店');

INSERT INTO `orders` VALUES (3600,'RT20261003003600',249,'REFUNDED','2026-10-03 17:44:53','2026-10-03 18:12:53',1867.00,'小程序');

INSERT INTO `orders` VALUES (3601,'RT20261003003601',76,'PAID','2026-10-03 18:06:43','2026-10-03 18:28:43',32.90,'线下门店');

INSERT INTO `orders` VALUES (3602,'RT20261003003602',63,'PAID','2026-10-03 18:09:16','2026-10-03 18:36:16',59.00,'线下门店');

INSERT INTO `orders` VALUES (3603,'RT20261003003603',205,'PAID','2026-10-03 18:30:54','2026-10-03 19:31:54',147.00,'线下门店');

INSERT INTO `orders` VALUES (3604,'RT20261003003604',135,'PAID','2026-10-03 19:24:58','2026-10-03 20:04:58',318.00,'小程序');

INSERT INTO `orders` VALUES (3605,'RT20261003003605',110,'PAID','2026-10-03 20:52:11','2026-10-03 21:18:11',630.90,'官网');

INSERT INTO `orders` VALUES (3606,'RT20261003003606',498,'PAID','2026-10-03 22:03:51','2026-10-03 22:11:51',61.20,'小程序');

INSERT INTO `orders` VALUES (3607,'RT20261004003607',375,'CANCELLED','2026-10-04 08:34:54',NULL,119.70,'小程序');

INSERT INTO `orders` VALUES (3608,'RT20261004003608',268,'PAID','2026-10-04 11:57:45','2026-10-04 12:22:45',104.80,'小程序');

INSERT INTO `orders` VALUES (3609,'RT20261004003609',240,'PAID','2026-10-04 12:36:58','2026-10-04 13:29:58',39.00,'小程序');

INSERT INTO `orders` VALUES (3610,'RT20261004003610',358,'CANCELLED','2026-10-04 16:44:16',NULL,899.00,'小程序');

INSERT INTO `orders` VALUES (3611,'RT20261004003611',140,'CANCELLED','2026-10-04 18:41:00',NULL,122.55,'线下门店');

INSERT INTO `orders` VALUES (3612,'RT20261004003612',194,'PAID','2026-10-04 18:56:52','2026-10-04 19:04:52',32.90,'小程序');

INSERT INTO `orders` VALUES (3613,'RT20261004003613',87,'PAID','2026-10-04 19:16:21','2026-10-04 20:03:21',79.00,'小程序');

INSERT INTO `orders` VALUES (3614,'RT20261004003614',212,'PAID','2026-10-04 19:39:01','2026-10-04 20:32:01',59.00,'线下门店');

INSERT INTO `orders` VALUES (3615,'RT20261004003615',380,'PAID','2026-10-04 20:58:49','2026-10-04 21:16:49',56.05,'官网');

INSERT INTO `orders` VALUES (3616,'RT20261004003616',264,'PAID','2026-10-04 21:47:16','2026-10-04 22:30:16',39.90,'线下门店');

INSERT INTO `orders` VALUES (3617,'RT20261005003617',83,'PAID','2026-10-05 09:44:46','2026-10-05 10:17:46',84.55,'线下门店');

INSERT INTO `orders` VALUES (3618,'RT20261005003618',163,'PAID','2026-10-05 09:45:42','2026-10-05 10:02:42',103.90,'线下门店');

INSERT INTO `orders` VALUES (3619,'RT20261005003619',471,'PAID','2026-10-05 12:20:12','2026-10-05 13:24:12',220.90,'线下门店');

INSERT INTO `orders` VALUES (3620,'RT20261005003620',176,'CANCELLED','2026-10-05 13:07:56',NULL,158.00,'小程序');

INSERT INTO `orders` VALUES (3621,'RT20261005003621',11,'PAID','2026-10-05 13:09:05','2026-10-05 13:49:05',56.56,'线下门店');

INSERT INTO `orders` VALUES (3622,'RT20261005003622',139,'PAID','2026-10-05 13:09:51','2026-10-05 13:12:51',120.26,'小程序');

INSERT INTO `orders` VALUES (3623,'RT20261005003623',398,'PAID','2026-10-05 13:45:43','2026-10-05 14:23:43',299.00,'线下门店');

INSERT INTO `orders` VALUES (3624,'RT20261005003624',338,'PAID','2026-10-05 17:32:58','2026-10-05 18:40:58',178.00,'小程序');

INSERT INTO `orders` VALUES (3625,'RT20261005003625',636,'REFUNDED','2026-10-05 17:53:07','2026-10-05 18:48:07',39.90,'官网');

INSERT INTO `orders` VALUES (3626,'RT20261005003626',203,'PAID','2026-10-05 19:52:59','2026-10-05 19:59:59',152.55,'小程序');

INSERT INTO `orders` VALUES (3627,'RT20261006003627',503,'PAID','2026-10-06 12:28:30','2026-10-06 12:44:30',68.00,'小程序');

INSERT INTO `orders` VALUES (3628,'RT20261006003628',253,'PAID','2026-10-06 12:32:44','2026-10-06 13:46:44',103.60,'小程序');

INSERT INTO `orders` VALUES (3629,'RT20261006003629',492,'PAID','2026-10-06 12:36:11','2026-10-06 12:54:11',225.91,'线下门店');

INSERT INTO `orders` VALUES (3630,'RT20261006003630',242,'PAID','2026-10-06 13:07:43','2026-10-06 14:06:43',318.00,'官网');

INSERT INTO `orders` VALUES (3631,'RT20261006003631',434,'PAID','2026-10-06 13:28:00','2026-10-06 14:30:00',39.90,'小程序');

INSERT INTO `orders` VALUES (3632,'RT20261006003632',79,'PAID','2026-10-06 13:49:30','2026-10-06 14:06:30',89.00,'官网');

INSERT INTO `orders` VALUES (3633,'RT20261006003633',84,'PAID','2026-10-06 13:52:05','2026-10-06 15:03:05',39.00,'小程序');

INSERT INTO `orders` VALUES (3634,'RT20261006003634',134,'PAID','2026-10-06 15:47:42','2026-10-06 16:27:42',4107.71,'线下门店');

INSERT INTO `orders` VALUES (3635,'RT20261006003635',73,'PAID','2026-10-06 16:23:16','2026-10-06 16:37:16',37.05,'官网');

INSERT INTO `orders` VALUES (3636,'RT20261006003636',55,'REFUNDED','2026-10-06 17:08:02','2026-10-06 17:58:02',31.26,'线下门店');

INSERT INTO `orders` VALUES (3637,'RT20261006003637',227,'PAID','2026-10-06 17:10:59','2026-10-06 18:01:59',190.95,'小程序');

INSERT INTO `orders` VALUES (3638,'RT20261006003638',430,'PAID','2026-10-06 19:00:05','2026-10-06 19:56:05',198.00,'线下门店');

INSERT INTO `orders` VALUES (3639,'RT20261006003639',55,'CANCELLED','2026-10-06 19:15:58',NULL,39.90,'小程序');

INSERT INTO `orders` VALUES (3640,'RT20261006003640',18,'PAID','2026-10-06 22:28:53','2026-10-06 22:46:53',31.26,'线下门店');

INSERT INTO `orders` VALUES (3641,'RT20261007003641',394,'PAID','2026-10-07 08:31:14','2026-10-07 08:35:14',177.90,'小程序');

INSERT INTO `orders` VALUES (3642,'RT20261007003642',507,'PAID','2026-10-07 09:19:18','2026-10-07 10:07:18',143.60,'线下门店');

INSERT INTO `orders` VALUES (3643,'RT20261007003643',338,'PAID','2026-10-07 09:51:01','2026-10-07 10:27:01',153.81,'线下门店');

INSERT INTO `orders` VALUES (3644,'RT20261007003644',55,'PAID','2026-10-07 11:30:36','2026-10-07 12:20:36',219.50,'线下门店');

INSERT INTO `orders` VALUES (3645,'RT20261007003645',532,'REFUNDED','2026-10-07 12:36:31','2026-10-07 13:24:31',200.45,'小程序');

INSERT INTO `orders` VALUES (3646,'RT20261007003646',292,'PAID','2026-10-07 16:01:06','2026-10-07 16:13:06',201.55,'小程序');

INSERT INTO `orders` VALUES (3647,'RT20261007003647',321,'PAID','2026-10-07 16:02:49','2026-10-07 16:06:49',207.00,'小程序');

INSERT INTO `orders` VALUES (3648,'RT20261007003648',21,'PAID','2026-10-07 17:13:54','2026-10-07 18:10:54',64.60,'小程序');

INSERT INTO `orders` VALUES (3649,'RT20261007003649',179,'PAID','2026-10-07 17:56:02','2026-10-07 18:33:02',233.80,'小程序');

INSERT INTO `orders` VALUES (3650,'RT20261007003650',592,'PAID','2026-10-07 18:15:44','2026-10-07 19:10:44',121.60,'线下门店');

INSERT INTO `orders` VALUES (3651,'RT20261007003651',200,'REFUNDED','2026-10-07 19:10:23','2026-10-07 19:42:23',32.90,'小程序');

INSERT INTO `orders` VALUES (3652,'RT20261007003652',233,'PAID','2026-10-07 19:11:41','2026-10-07 19:40:41',59.00,'线下门店');

INSERT INTO `orders` VALUES (3653,'RT20261007003653',220,'REFUNDED','2026-10-07 19:42:52','2026-10-07 20:31:52',24.90,'线下门店');

INSERT INTO `orders` VALUES (3654,'RT20261007003654',267,'PAID','2026-10-07 21:14:47','2026-10-07 22:11:47',24.90,'小程序');

INSERT INTO `orders` VALUES (3655,'RT20261008003655',525,'PAID','2026-10-08 09:50:19','2026-10-08 10:06:19',37.91,'线下门店');

INSERT INTO `orders` VALUES (3656,'RT20261008003656',124,'PAID','2026-10-08 10:35:12','2026-10-08 11:28:12',79.00,'小程序');

INSERT INTO `orders` VALUES (3657,'RT20261008003657',101,'PAID','2026-10-08 13:50:36','2026-10-08 14:59:36',358.00,'官网');

INSERT INTO `orders` VALUES (3658,'RT20261008003658',486,'PAID','2026-10-08 16:20:06','2026-10-08 17:07:06',37.91,'小程序');

INSERT INTO `orders` VALUES (3659,'RT20261008003659',36,'PAID','2026-10-08 17:35:09','2026-10-08 18:09:09',69.00,'线下门店');

INSERT INTO `orders` VALUES (3660,'RT20261008003660',25,'PAID','2026-10-08 18:00:52','2026-10-08 19:01:52',100.90,'官网');

INSERT INTO `orders` VALUES (3661,'RT20261008003661',193,'PAID','2026-10-08 18:17:21','2026-10-08 18:18:21',107.90,'企业采购');

INSERT INTO `orders` VALUES (3662,'RT20261008003662',220,'PAID','2026-10-08 19:56:02','2026-10-08 20:52:02',378.00,'线下门店');

INSERT INTO `orders` VALUES (3663,'RT20261008003663',119,'PAID','2026-10-08 20:18:07','2026-10-08 21:00:07',68.00,'线下门店');

INSERT INTO `orders` VALUES (3664,'RT20261009003664',263,'PAID','2026-10-09 09:12:23','2026-10-09 10:24:23',78.90,'小程序');

INSERT INTO `orders` VALUES (3665,'RT20261009003665',165,'PAID','2026-10-09 10:49:03','2026-10-09 11:46:03',79.80,'小程序');

INSERT INTO `orders` VALUES (3666,'RT20261009003666',12,'PAID','2026-10-09 13:39:51','2026-10-09 14:06:51',129.00,'小程序');

INSERT INTO `orders` VALUES (3667,'RT20261009003667',28,'PAID','2026-10-09 13:56:49','2026-10-09 15:09:49',22.41,'线下门店');

INSERT INTO `orders` VALUES (3668,'RT20261009003668',123,'PAID','2026-10-09 14:12:56','2026-10-09 15:26:56',39.90,'小程序');

INSERT INTO `orders` VALUES (3669,'RT20261009003669',20,'REFUNDED','2026-10-09 14:48:23','2026-10-09 15:32:23',166.90,'线下门店');

INSERT INTO `orders` VALUES (3670,'RT20261009003670',297,'PAID','2026-10-09 16:04:55','2026-10-09 16:28:55',155.05,'小程序');

INSERT INTO `orders` VALUES (3671,'RT20261009003671',115,'PAID','2026-10-09 16:11:38','2026-10-09 17:14:38',39.00,'线下门店');

INSERT INTO `orders` VALUES (3672,'RT20261009003672',93,'PAID','2026-10-09 16:40:24','2026-10-09 16:49:24',64.60,'线下门店');

INSERT INTO `orders` VALUES (3673,'RT20261009003673',255,'CANCELLED','2026-10-09 17:18:42',NULL,189.05,'官网');

INSERT INTO `orders` VALUES (3674,'RT20261009003674',47,'PAID','2026-10-09 17:23:25','2026-10-09 18:36:25',37.91,'小程序');

INSERT INTO `orders` VALUES (3675,'RT20261009003675',497,'PAID','2026-10-09 19:22:47','2026-10-09 20:15:47',103.60,'线下门店');

INSERT INTO `orders` VALUES (3676,'RT20261009003676',310,'PAID','2026-10-09 19:28:01','2026-10-09 19:44:01',37.05,'线下门店');

INSERT INTO `orders` VALUES (3677,'RT20261009003677',434,'PAID','2026-10-09 20:04:24','2026-10-09 21:04:24',155.05,'线下门店');

INSERT INTO `orders` VALUES (3678,'RT20261010003678',20,'PAID','2026-10-10 11:03:08','2026-10-10 11:08:08',32.90,'小程序');

INSERT INTO `orders` VALUES (3679,'RT20261010003679',573,'PAID','2026-10-10 11:20:04','2026-10-10 11:46:04',169.00,'小程序');

INSERT INTO `orders` VALUES (3680,'RT20261010003680',160,'PAID','2026-10-10 11:45:24','2026-10-10 11:51:24',169.00,'小程序');

INSERT INTO `orders` VALUES (3681,'RT20261010003681',57,'PAID','2026-10-10 11:46:04','2026-10-10 12:37:04',59.00,'线下门店');

INSERT INTO `orders` VALUES (3682,'RT20261010003682',483,'REFUNDED','2026-10-10 12:49:54','2026-10-10 13:54:54',59.00,'官网');

INSERT INTO `orders` VALUES (3683,'RT20261010003683',219,'PAID','2026-10-10 12:55:46','2026-10-10 13:23:46',39.00,'线下门店');

INSERT INTO `orders` VALUES (3684,'RT20261010003684',276,'PAID','2026-10-10 14:07:28','2026-10-10 14:51:28',65.55,'小程序');

INSERT INTO `orders` VALUES (3685,'RT20261010003685',327,'PAID','2026-10-10 14:59:21','2026-10-10 15:24:21',78.00,'小程序');

INSERT INTO `orders` VALUES (3686,'RT20261010003686',512,'PAID','2026-10-10 16:49:17','2026-10-10 17:11:17',70.20,'线下门店');

INSERT INTO `orders` VALUES (3687,'RT20261010003687',18,'PAID','2026-10-10 17:31:27','2026-10-10 18:34:27',37.91,'小程序');

INSERT INTO `orders` VALUES (3688,'RT20261010003688',29,'PAID','2026-10-10 17:57:22','2026-10-10 19:01:22',68.00,'企业采购');

INSERT INTO `orders` VALUES (3689,'RT20261010003689',633,'PAID','2026-10-10 21:28:43','2026-10-10 22:28:43',39.90,'小程序');

INSERT INTO `orders` VALUES (3690,'RT20261010003690',537,'PAID','2026-10-10 21:44:03','2026-10-10 22:55:03',299.00,'小程序');

INSERT INTO `orders` VALUES (3691,'RT20261011003691',475,'PAID','2026-10-11 09:15:27','2026-10-11 09:36:27',39.90,'小程序');

INSERT INTO `orders` VALUES (3692,'RT20261011003692',414,'PAID','2026-10-11 10:45:56','2026-10-11 10:54:56',314.80,'官网');

INSERT INTO `orders` VALUES (3693,'RT20261011003693',14,'PAID','2026-10-11 11:38:51','2026-10-11 12:19:51',321.10,'小程序');

INSERT INTO `orders` VALUES (3694,'RT20261011003694',293,'PAID','2026-10-11 12:04:39','2026-10-11 12:16:39',39.00,'小程序');

INSERT INTO `orders` VALUES (3695,'RT20261011003695',375,'CANCELLED','2026-10-11 13:11:52',NULL,79.80,'小程序');

INSERT INTO `orders` VALUES (3696,'RT20261011003696',252,'CANCELLED','2026-10-11 17:44:09',NULL,103.60,'小程序');

INSERT INTO `orders` VALUES (3697,'RT20261011003697',451,'PAID','2026-10-11 20:32:41','2026-10-11 21:41:41',78.90,'线下门店');

INSERT INTO `orders` VALUES (3698,'RT20261012003698',448,'REFUNDED','2026-10-12 10:42:01','2026-10-12 10:53:01',159.00,'线下门店');

INSERT INTO `orders` VALUES (3699,'RT20261012003699',290,'PAID','2026-10-12 13:24:45','2026-10-12 13:53:45',137.00,'官网');

INSERT INTO `orders` VALUES (3700,'RT20261012003700',526,'PAID','2026-10-12 14:16:38','2026-10-12 14:17:38',37.05,'线下门店');

INSERT INTO `orders` VALUES (3701,'RT20261012003701',240,'PAID','2026-10-12 15:11:04','2026-10-12 16:07:04',32.90,'官网');

INSERT INTO `orders` VALUES (3702,'RT20261012003702',472,'PAID','2026-10-12 16:29:43','2026-10-12 17:37:43',23.66,'官网');

INSERT INTO `orders` VALUES (3703,'RT20261012003703',440,'PAID','2026-10-12 18:02:39','2026-10-12 19:14:39',37.91,'官网');

INSERT INTO `orders` VALUES (3704,'RT20261012003704',389,'PAID','2026-10-12 20:11:37','2026-10-12 20:55:37',37.91,'企业采购');

INSERT INTO `orders` VALUES (3705,'RT20261013003705',350,'PAID','2026-10-13 11:14:43','2026-10-13 11:54:43',37.91,'小程序');

INSERT INTO `orders` VALUES (3706,'RT20261013003706',55,'PAID','2026-10-13 14:47:55','2026-10-13 15:44:55',39.00,'小程序');

INSERT INTO `orders` VALUES (3707,'RT20261013003707',80,'PAID','2026-10-13 17:29:06','2026-10-13 18:07:06',56.05,'小程序');

INSERT INTO `orders` VALUES (3708,'RT20261013003708',619,'REFUNDED','2026-10-13 17:39:51','2026-10-13 18:38:51',57.80,'小程序');

INSERT INTO `orders` VALUES (3709,'RT20261013003709',345,'PAID','2026-10-13 18:37:58','2026-10-13 19:09:58',39.00,'小程序');

INSERT INTO `orders` VALUES (3710,'RT20261013003710',106,'PAID','2026-10-13 18:40:25','2026-10-13 19:35:25',24.90,'小程序');

INSERT INTO `orders` VALUES (3711,'RT20261013003711',615,'PAID','2026-10-13 19:43:39','2026-10-13 19:58:39',133.70,'线下门店');

INSERT INTO `orders` VALUES (3712,'RT20261014003712',329,'PAID','2026-10-14 09:01:43','2026-10-14 09:24:43',146.00,'小程序');

INSERT INTO `orders` VALUES (3713,'RT20261014003713',479,'PAID','2026-10-14 12:56:21','2026-10-14 14:11:21',159.00,'小程序');

INSERT INTO `orders` VALUES (3714,'RT20261014003714',305,'PAID','2026-10-14 13:07:19','2026-10-14 13:35:19',70.97,'小程序');

INSERT INTO `orders` VALUES (3715,'RT20261014003715',183,'PAID','2026-10-14 13:57:02','2026-10-14 14:30:02',83.90,'小程序');

INSERT INTO `orders` VALUES (3716,'RT20261014003716',362,'PAID','2026-10-14 17:54:02','2026-10-14 18:59:02',175.90,'小程序');

INSERT INTO `orders` VALUES (3717,'RT20261014003717',206,'PAID','2026-10-14 19:14:55','2026-10-14 20:22:55',399.00,'官网');

INSERT INTO `orders` VALUES (3718,'RT20261015003718',518,'PAID','2026-10-15 09:26:55','2026-10-15 10:00:55',74.70,'线下门店');

INSERT INTO `orders` VALUES (3719,'RT20261015003719',439,'PAID','2026-10-15 09:55:39','2026-10-15 11:06:39',39.00,'官网');

INSERT INTO `orders` VALUES (3720,'RT20261015003720',314,'PAID','2026-10-15 11:40:46','2026-10-15 12:42:46',68.00,'线下门店');

INSERT INTO `orders` VALUES (3721,'RT20261015003721',51,'PAID','2026-10-15 11:48:51','2026-10-15 12:48:51',159.00,'线下门店');

INSERT INTO `orders` VALUES (3722,'RT20261015003722',537,'REFUNDED','2026-10-15 12:04:22','2026-10-15 13:00:22',199.00,'小程序');

INSERT INTO `orders` VALUES (3723,'RT20261015003723',113,'PAID','2026-10-15 13:11:12','2026-10-15 14:13:12',39.90,'线下门店');

INSERT INTO `orders` VALUES (3724,'RT20261015003724',455,'PAID','2026-10-15 16:10:46','2026-10-15 16:55:46',37.05,'线下门店');

INSERT INTO `orders` VALUES (3725,'RT20261015003725',465,'PAID','2026-10-15 16:46:24','2026-10-15 17:19:24',39.90,'小程序');

INSERT INTO `orders` VALUES (3726,'RT20261015003726',314,'PAID','2026-10-15 18:33:43','2026-10-15 18:46:43',24.90,'小程序');

INSERT INTO `orders` VALUES (3727,'RT20261015003727',169,'CANCELLED','2026-10-15 18:40:18',NULL,319.05,'官网');

INSERT INTO `orders` VALUES (3728,'RT20261015003728',581,'PAID','2026-10-15 20:15:38','2026-10-15 20:23:38',39.90,'小程序');

INSERT INTO `orders` VALUES (3729,'RT20261015003729',198,'PAID','2026-10-15 20:45:38','2026-10-15 21:40:38',213.30,'线下门店');

INSERT INTO `orders` VALUES (3730,'RT20261015003730',463,'PAID','2026-10-15 20:55:48','2026-10-15 20:56:48',39.00,'小程序');

INSERT INTO `orders` VALUES (3731,'RT20261016003731',450,'PAID','2026-10-16 10:04:14','2026-10-16 10:26:14',285.30,'官网');

INSERT INTO `orders` VALUES (3732,'RT20261016003732',417,'PAID','2026-10-16 12:25:15','2026-10-16 12:40:15',63.56,'小程序');

INSERT INTO `orders` VALUES (3733,'RT20261016003733',102,'PAID','2026-10-16 12:29:05','2026-10-16 13:41:05',71.90,'官网');

INSERT INTO `orders` VALUES (3734,'RT20261016003734',213,'PAID','2026-10-16 13:42:49','2026-10-16 14:34:49',190.90,'线下门店');

INSERT INTO `orders` VALUES (3735,'RT20261016003735',346,'PAID','2026-10-16 16:05:17','2026-10-16 16:35:17',169.00,'小程序');

INSERT INTO `orders` VALUES (3736,'RT20261016003736',136,'PAID','2026-10-16 16:08:05','2026-10-16 16:38:05',136.00,'小程序');

INSERT INTO `orders` VALUES (3737,'RT20261016003737',156,'PAID','2026-10-16 16:48:56','2026-10-16 17:11:56',160.66,'线下门店');

INSERT INTO `orders` VALUES (3738,'RT20261016003738',413,'PAID','2026-10-16 19:47:46','2026-10-16 20:21:46',131.10,'线下门店');

INSERT INTO `orders` VALUES (3739,'RT20261016003739',503,'PAID','2026-10-16 19:55:50','2026-10-16 21:04:50',64.80,'企业采购');

INSERT INTO `orders` VALUES (3740,'RT20261016003740',394,'CANCELLED','2026-10-16 20:04:36',NULL,899.00,'线下门店');

INSERT INTO `orders` VALUES (3741,'RT20261016003741',151,'PAID','2026-10-16 20:43:19','2026-10-16 21:34:19',135.76,'官网');

INSERT INTO `orders` VALUES (3742,'RT20261017003742',60,'CANCELLED','2026-10-17 11:54:05',NULL,149.15,'线下门店');

INSERT INTO `orders` VALUES (3743,'RT20261017003743',80,'PAID','2026-10-17 14:21:58','2026-10-17 14:44:58',160.20,'官网');

INSERT INTO `orders` VALUES (3744,'RT20261017003744',540,'PAID','2026-10-17 14:30:15','2026-10-17 14:53:15',49.80,'线下门店');

INSERT INTO `orders` VALUES (3745,'RT20261017003745',85,'PAID','2026-10-17 19:46:00','2026-10-17 19:52:00',32.90,'小程序');

INSERT INTO `orders` VALUES (3746,'RT20261017003746',444,'PAID','2026-10-17 21:13:18','2026-10-17 21:50:18',159.00,'小程序');

INSERT INTO `orders` VALUES (3747,'RT20261018003747',120,'REFUNDED','2026-10-18 10:36:26','2026-10-18 11:15:26',80.10,'小程序');

INSERT INTO `orders` VALUES (3748,'RT20261018003748',208,'PAID','2026-10-18 11:53:18','2026-10-18 12:20:18',39.00,'官网');

INSERT INTO `orders` VALUES (3749,'RT20261018003749',318,'PAID','2026-10-18 12:32:33','2026-10-18 13:37:33',82.66,'线下门店');

INSERT INTO `orders` VALUES (3750,'RT20261018003750',143,'PAID','2026-10-18 13:44:35','2026-10-18 14:59:35',69.95,'小程序');

INSERT INTO `orders` VALUES (3751,'RT20261018003751',251,'PAID','2026-10-18 13:55:22','2026-10-18 14:12:22',188.20,'小程序');

INSERT INTO `orders` VALUES (3752,'RT20261018003752',274,'CANCELLED','2026-10-18 15:42:57',NULL,35.91,'线下门店');

INSERT INTO `orders` VALUES (3753,'RT20261018003753',168,'PAID','2026-10-18 19:27:58','2026-10-18 20:02:58',84.55,'官网');

INSERT INTO `orders` VALUES (3754,'RT20261018003754',296,'PAID','2026-10-18 22:10:47','2026-10-18 22:55:47',168.21,'官网');

INSERT INTO `orders` VALUES (3755,'RT20261019003755',181,'PAID','2026-10-19 11:31:32','2026-10-19 12:00:32',56.56,'官网');

INSERT INTO `orders` VALUES (3756,'RT20261019003756',96,'PAID','2026-10-19 12:35:30','2026-10-19 13:01:30',75.05,'线下门店');

INSERT INTO `orders` VALUES (3757,'RT20261019003757',61,'PAID','2026-10-19 14:04:29','2026-10-19 15:18:29',923.90,'小程序');

INSERT INTO `orders` VALUES (3758,'RT20261019003758',505,'PAID','2026-10-19 15:38:32','2026-10-19 15:56:32',24.90,'线下门店');

INSERT INTO `orders` VALUES (3759,'RT20261019003759',55,'PAID','2026-10-19 15:43:06','2026-10-19 16:55:06',92.10,'官网');

INSERT INTO `orders` VALUES (3760,'RT20261019003760',238,'PAID','2026-10-19 17:04:25','2026-10-19 17:52:25',258.00,'官网');

INSERT INTO `orders` VALUES (3761,'RT20261019003761',85,'PAID','2026-10-19 18:08:18','2026-10-19 18:27:18',56.05,'小程序');

INSERT INTO `orders` VALUES (3762,'RT20261019003762',373,'PAID','2026-10-19 18:09:47','2026-10-19 18:37:47',258.00,'企业采购');

INSERT INTO `orders` VALUES (3763,'RT20261019003763',94,'PAID','2026-10-19 18:30:17','2026-10-19 19:28:17',106.02,'企业采购');

INSERT INTO `orders` VALUES (3764,'RT20261019003764',342,'PAID','2026-10-19 18:55:55','2026-10-19 19:00:55',69.51,'官网');

INSERT INTO `orders` VALUES (3765,'RT20261019003765',270,'PAID','2026-10-19 19:53:38','2026-10-19 20:52:38',129.20,'线下门店');

INSERT INTO `orders` VALUES (3766,'RT20261019003766',286,'PAID','2026-10-19 21:19:05','2026-10-19 22:21:05',39.90,'官网');

INSERT INTO `orders` VALUES (3767,'RT20261019003767',528,'PAID','2026-10-19 21:22:47','2026-10-19 21:26:47',63.90,'线下门店');

INSERT INTO `orders` VALUES (3768,'RT20261020003768',624,'PAID','2026-10-20 11:29:06','2026-10-20 12:18:06',37.05,'小程序');

INSERT INTO `orders` VALUES (3769,'RT20261020003769',131,'PAID','2026-10-20 12:18:18','2026-10-20 12:50:18',68.00,'小程序');

INSERT INTO `orders` VALUES (3770,'RT20261020003770',38,'PAID','2026-10-20 17:11:32','2026-10-20 17:49:32',24.90,'小程序');

INSERT INTO `orders` VALUES (3771,'RT20261020003771',463,'PAID','2026-10-20 17:15:47','2026-10-20 18:15:47',84.55,'小程序');

INSERT INTO `orders` VALUES (3772,'RT20261020003772',16,'PAID','2026-10-20 18:21:54','2026-10-20 19:32:54',37.91,'官网');

INSERT INTO `orders` VALUES (3773,'RT20261020003773',173,'CANCELLED','2026-10-20 19:01:06',NULL,102.36,'小程序');

INSERT INTO `orders` VALUES (3774,'RT20261020003774',188,'PAID','2026-10-20 19:50:20','2026-10-20 21:03:20',64.80,'线下门店');

INSERT INTO `orders` VALUES (3775,'RT20261020003775',305,'PAID','2026-10-20 19:56:14','2026-10-20 20:48:14',521.15,'小程序');

INSERT INTO `orders` VALUES (3776,'RT20261020003776',368,'PAID','2026-10-20 20:34:54','2026-10-20 20:52:54',130.51,'线下门店');

INSERT INTO `orders` VALUES (3777,'RT20261021003777',248,'PAID','2026-10-21 12:19:30','2026-10-21 12:47:30',37.05,'小程序');

INSERT INTO `orders` VALUES (3778,'RT20261021003778',134,'PAID','2026-10-21 15:19:02','2026-10-21 16:20:02',713.85,'小程序');

INSERT INTO `orders` VALUES (3779,'RT20261021003779',98,'PAID','2026-10-21 15:45:27','2026-10-21 15:55:27',39.00,'官网');

INSERT INTO `orders` VALUES (3780,'RT20261021003780',290,'PAID','2026-10-21 17:12:03','2026-10-21 18:12:03',151.05,'线下门店');

INSERT INTO `orders` VALUES (3781,'RT20261021003781',275,'REFUNDED','2026-10-21 19:42:30','2026-10-21 20:44:30',39.90,'小程序');

INSERT INTO `orders` VALUES (3782,'RT20261021003782',440,'REFUNDED','2026-10-21 19:55:09','2026-10-21 20:24:09',119.70,'小程序');

INSERT INTO `orders` VALUES (3783,'RT20261021003783',224,'PAID','2026-10-21 21:12:02','2026-10-21 22:02:02',64.60,'线下门店');

INSERT INTO `orders` VALUES (3784,'RT20261022003784',325,'PAID','2026-10-22 11:21:58','2026-10-22 12:10:58',53.10,'官网');

INSERT INTO `orders` VALUES (3785,'RT20261022003785',30,'CANCELLED','2026-10-22 14:20:40',NULL,37.91,'小程序');

INSERT INTO `orders` VALUES (3786,'RT20261022003786',76,'PAID','2026-10-22 15:55:36','2026-10-22 16:00:36',204.00,'官网');

INSERT INTO `orders` VALUES (3787,'RT20261022003787',311,'PAID','2026-10-22 16:45:07','2026-10-22 16:55:07',39.00,'小程序');

INSERT INTO `orders` VALUES (3788,'RT20261022003788',552,'PAID','2026-10-22 16:59:17','2026-10-22 17:57:17',79.00,'小程序');

INSERT INTO `orders` VALUES (3789,'RT20261022003789',485,'PAID','2026-10-22 17:51:57','2026-10-22 18:35:57',305.00,'企业采购');

INSERT INTO `orders` VALUES (3790,'RT20261022003790',528,'PAID','2026-10-22 18:39:35','2026-10-22 18:51:35',49.80,'小程序');

INSERT INTO `orders` VALUES (3791,'RT20261022003791',361,'CANCELLED','2026-10-22 19:01:49',NULL,4601.00,'线下门店');

INSERT INTO `orders` VALUES (3792,'RT20261022003792',452,'REFUNDED','2026-10-22 21:02:23','2026-10-22 21:46:23',129.00,'小程序');

INSERT INTO `orders` VALUES (3793,'RT20261023003793',369,'PAID','2026-10-23 09:44:41','2026-10-23 10:17:41',39.00,'官网');

INSERT INTO `orders` VALUES (3794,'RT20261023003794',439,'CANCELLED','2026-10-23 11:35:39',NULL,121.90,'小程序');

INSERT INTO `orders` VALUES (3795,'RT20261023003795',111,'PAID','2026-10-23 11:46:06','2026-10-23 11:51:06',183.90,'小程序');

INSERT INTO `orders` VALUES (3796,'RT20261023003796',170,'PAID','2026-10-23 16:12:53','2026-10-23 16:36:53',39.00,'线下门店');

INSERT INTO `orders` VALUES (3797,'RT20261023003797',319,'PAID','2026-10-23 17:03:30','2026-10-23 17:21:30',39.00,'企业采购');

INSERT INTO `orders` VALUES (3798,'RT20261023003798',249,'PAID','2026-10-23 18:41:16','2026-10-23 19:33:16',68.00,'官网');

INSERT INTO `orders` VALUES (3799,'RT20261023003799',151,'PAID','2026-10-23 19:23:30','2026-10-23 20:23:30',139.10,'官网');

INSERT INTO `orders` VALUES (3800,'RT20261023003800',527,'REFUNDED','2026-10-23 20:25:08','2026-10-23 20:59:08',74.70,'官网');

INSERT INTO `orders` VALUES (3801,'RT20261023003801',39,'PAID','2026-10-23 20:34:06','2026-10-23 20:45:06',39.00,'小程序');

INSERT INTO `orders` VALUES (3802,'RT20261024003802',152,'PAID','2026-10-24 09:00:51','2026-10-24 09:27:51',299.00,'线下门店');

INSERT INTO `orders` VALUES (3803,'RT20261024003803',521,'PAID','2026-10-24 10:59:49','2026-10-24 11:22:49',31.26,'线下门店');

INSERT INTO `orders` VALUES (3804,'RT20261024003804',487,'PAID','2026-10-24 11:49:28','2026-10-24 12:40:28',765.00,'线下门店');

INSERT INTO `orders` VALUES (3805,'RT20261024003805',331,'REFUNDED','2026-10-24 13:23:11','2026-10-24 14:31:11',104.00,'线下门店');

INSERT INTO `orders` VALUES (3806,'RT20261024003806',365,'PAID','2026-10-24 14:36:11','2026-10-24 15:26:11',188.00,'小程序');

INSERT INTO `orders` VALUES (3807,'RT20261024003807',237,'PAID','2026-10-24 17:03:20','2026-10-24 17:13:20',65.80,'小程序');

INSERT INTO `orders` VALUES (3808,'RT20261024003808',265,'PAID','2026-10-24 18:36:16','2026-10-24 19:08:16',59.00,'小程序');

INSERT INTO `orders` VALUES (3809,'RT20261025003809',496,'PAID','2026-10-25 10:32:46','2026-10-25 11:24:46',24.90,'官网');

INSERT INTO `orders` VALUES (3810,'RT20261025003810',468,'PAID','2026-10-25 10:50:08','2026-10-25 11:40:08',172.55,'线下门店');

INSERT INTO `orders` VALUES (3811,'RT20261025003811',403,'PAID','2026-10-25 14:11:13','2026-10-25 14:38:13',62.31,'小程序');

INSERT INTO `orders` VALUES (3812,'RT20261025003812',134,'PAID','2026-10-25 14:25:46','2026-10-25 15:10:46',32.90,'官网');

INSERT INTO `orders` VALUES (3813,'RT20261025003813',198,'PAID','2026-10-25 14:56:15','2026-10-25 15:45:15',75.05,'官网');

INSERT INTO `orders` VALUES (3814,'RT20261025003814',84,'PAID','2026-10-25 16:49:41','2026-10-25 17:05:41',39.90,'线下门店');

INSERT INTO `orders` VALUES (3815,'RT20261025003815',153,'PAID','2026-10-25 17:13:41','2026-10-25 17:30:41',199.00,'线下门店');

INSERT INTO `orders` VALUES (3816,'RT20261025003816',74,'PAID','2026-10-25 18:28:27','2026-10-25 19:28:27',463.60,'小程序');

INSERT INTO `orders` VALUES (3817,'RT20261025003817',226,'PAID','2026-10-25 19:18:46','2026-10-25 19:47:46',79.00,'小程序');

INSERT INTO `orders` VALUES (3818,'RT20261025003818',280,'CANCELLED','2026-10-25 19:31:06',NULL,39.90,'线下门店');

INSERT INTO `orders` VALUES (3819,'RT20261025003819',46,'REFUNDED','2026-10-25 19:44:33','2026-10-25 20:26:33',64.60,'小程序');

INSERT INTO `orders` VALUES (3820,'RT20261025003820',545,'PAID','2026-10-25 19:48:13','2026-10-25 20:35:13',182.60,'官网');

INSERT INTO `orders` VALUES (3821,'RT20261025003821',62,'PAID','2026-10-25 21:21:10','2026-10-25 22:00:10',72.80,'线下门店');

INSERT INTO `orders` VALUES (3822,'RT20261026003822',490,'PAID','2026-10-26 09:24:29','2026-10-26 09:32:29',39.90,'小程序');

INSERT INTO `orders` VALUES (3823,'RT20261026003823',478,'PAID','2026-10-26 12:32:13','2026-10-26 13:17:13',93.90,'小程序');

INSERT INTO `orders` VALUES (3824,'RT20261026003824',477,'PAID','2026-10-26 13:26:16','2026-10-26 14:10:16',145.75,'线下门店');

INSERT INTO `orders` VALUES (3825,'RT20261026003825',340,'PAID','2026-10-26 17:02:32','2026-10-26 17:45:32',39.90,'小程序');

INSERT INTO `orders` VALUES (3826,'RT20261026003826',551,'PAID','2026-10-26 17:39:15','2026-10-26 17:52:15',37.05,'线下门店');

INSERT INTO `orders` VALUES (3827,'RT20261026003827',436,'PAID','2026-10-26 18:45:23','2026-10-26 19:42:23',191.66,'小程序');

INSERT INTO `orders` VALUES (3828,'RT20261026003828',194,'CANCELLED','2026-10-26 19:01:13',NULL,369.20,'线下门店');

INSERT INTO `orders` VALUES (3829,'RT20261026003829',294,'REFUNDED','2026-10-26 20:19:31','2026-10-26 20:56:31',23.66,'官网');

INSERT INTO `orders` VALUES (3830,'RT20261026003830',465,'PAID','2026-10-26 20:20:30','2026-10-26 20:30:30',235.00,'小程序');

INSERT INTO `orders` VALUES (3831,'RT20261026003831',273,'PAID','2026-10-26 22:36:16','2026-10-26 23:49:16',131.10,'小程序');

INSERT INTO `orders` VALUES (3832,'RT20261027003832',16,'PENDING','2026-10-27 11:05:34',NULL,68.31,'线下门店');

INSERT INTO `orders` VALUES (3833,'RT20261027003833',298,'PENDING','2026-10-27 12:03:30',NULL,129.00,'官网');

INSERT INTO `orders` VALUES (3834,'RT20261027003834',465,'PENDING','2026-10-27 12:48:11',NULL,338.90,'线下门店');

INSERT INTO `orders` VALUES (3835,'RT20261027003835',91,'PAID','2026-10-27 15:16:51','2026-10-27 16:15:51',65.80,'官网');

INSERT INTO `orders` VALUES (3836,'RT20261027003836',113,'PAID','2026-10-27 17:07:54','2026-10-27 17:57:54',456.30,'小程序');

INSERT INTO `orders` VALUES (3837,'RT20261027003837',588,'CANCELLED','2026-10-27 17:48:18',NULL,39.00,'官网');

INSERT INTO `orders` VALUES (3838,'RT20261027003838',201,'PAID','2026-10-27 19:59:40','2026-10-27 20:09:40',32.90,'小程序');

INSERT INTO `orders` VALUES (3839,'RT20261027003839',78,'REFUNDED','2026-10-27 20:47:55','2026-10-27 21:38:55',70.26,'线下门店');

INSERT INTO `orders` VALUES (3840,'RT20261027003840',123,'PAID','2026-10-27 21:48:37','2026-10-27 22:40:37',32.90,'小程序');

INSERT INTO `orders` VALUES (3841,'RT20261028003841',417,'PAID','2026-10-28 10:03:56','2026-10-28 10:15:56',89.00,'小程序');

INSERT INTO `orders` VALUES (3842,'RT20261028003842',80,'PAID','2026-10-28 11:47:18','2026-10-28 12:15:18',79.00,'线下门店');

INSERT INTO `orders` VALUES (3843,'RT20261028003843',67,'PAID','2026-10-28 13:13:10','2026-10-28 13:46:10',59.22,'官网');

INSERT INTO `orders` VALUES (3844,'RT20261028003844',80,'PAID','2026-10-28 16:50:28','2026-10-28 18:02:28',699.00,'线下门店');

INSERT INTO `orders` VALUES (3845,'RT20261028003845',152,'PAID','2026-10-28 17:22:06','2026-10-28 17:23:06',183.90,'线下门店');

INSERT INTO `orders` VALUES (3846,'RT20261028003846',146,'PAID','2026-10-28 18:16:00','2026-10-28 19:31:00',39.00,'官网');

INSERT INTO `orders` VALUES (3847,'RT20261028003847',377,'PAID','2026-10-28 18:18:23','2026-10-28 19:15:23',62.51,'官网');

INSERT INTO `orders` VALUES (3848,'RT20261028003848',376,'PAID','2026-10-28 18:37:08','2026-10-28 18:43:08',91.90,'小程序');

INSERT INTO `orders` VALUES (3849,'RT20261028003849',220,'PAID','2026-10-28 18:45:22','2026-10-28 19:23:22',59.00,'小程序');

INSERT INTO `orders` VALUES (3850,'RT20261028003850',34,'PAID','2026-10-28 19:05:44','2026-10-28 19:35:44',32.90,'线下门店');

INSERT INTO `orders` VALUES (3851,'RT20261028003851',375,'PENDING','2026-10-28 19:35:33',NULL,68.00,'官网');

INSERT INTO `orders` VALUES (3852,'RT20261028003852',132,'PAID','2026-10-28 19:50:00','2026-10-28 20:04:00',79.00,'小程序');

INSERT INTO `orders` VALUES (3853,'RT20261028003853',351,'PAID','2026-10-28 19:54:21','2026-10-28 19:58:21',84.55,'小程序');

INSERT INTO `orders` VALUES (3854,'RT20261028003854',118,'PAID','2026-10-28 20:22:33','2026-10-28 21:12:33',31.26,'线下门店');

INSERT INTO `orders` VALUES (3855,'RT20261028003855',49,'PENDING','2026-10-28 20:28:22',NULL,367.00,'线下门店');

INSERT INTO `orders` VALUES (3856,'RT20261028003856',490,'PAID','2026-10-28 21:48:14','2026-10-28 22:12:14',74.10,'官网');

INSERT INTO `orders` VALUES (3857,'RT20261029003857',114,'PENDING','2026-10-29 08:50:46',NULL,923.90,'小程序');

INSERT INTO `orders` VALUES (3858,'RT20261029003858',4,'PENDING','2026-10-29 15:10:40',NULL,24.90,'小程序');

INSERT INTO `orders` VALUES (3859,'RT20261029003859',118,'PENDING','2026-10-29 16:00:33',NULL,68.00,'小程序');

INSERT INTO `orders` VALUES (3860,'RT20261029003860',159,'PAID','2026-10-29 16:34:08','2026-10-29 16:41:08',32.90,'小程序');

INSERT INTO `orders` VALUES (3861,'RT20261029003861',70,'PENDING','2026-10-29 17:36:28',NULL,55.31,'线下门店');

INSERT INTO `orders` VALUES (3862,'RT20261029003862',436,'PENDING','2026-10-29 18:08:39',NULL,137.00,'小程序');

INSERT INTO `orders` VALUES (3863,'RT20261029003863',483,'PAID','2026-10-29 19:04:40','2026-10-29 19:06:40',39.00,'线下门店');

INSERT INTO `orders` VALUES (3864,'RT20261029003864',615,'PAID','2026-10-29 22:26:47','2026-10-29 23:36:47',128.00,'官网');

INSERT INTO `order_items` VALUES (1,1,9,1,129,0);

INSERT INTO `order_items` VALUES (2,2,11,1,39,0);

INSERT INTO `order_items` VALUES (3,3,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (4,4,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5,5,14,1,39.9,0);

INSERT INTO `order_items` VALUES (6,6,15,1,32.9,0);

INSERT INTO `order_items` VALUES (7,7,11,1,39,0);

INSERT INTO `order_items` VALUES (8,8,17,1,69,0);

INSERT INTO `order_items` VALUES (9,9,14,1,39.9,0);

INSERT INTO `order_items` VALUES (10,10,14,1,39.9,0);

INSERT INTO `order_items` VALUES (11,11,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (12,12,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (13,13,5,1,399,0);

INSERT INTO `order_items` VALUES (14,14,4,1,59,0.10);

INSERT INTO `order_items` VALUES (15,15,12,1,79,0.05);

INSERT INTO `order_items` VALUES (16,16,12,2,79,0);

INSERT INTO `order_items` VALUES (17,16,20,1,39,0);

INSERT INTO `order_items` VALUES (18,17,9,1,129,0.05);

INSERT INTO `order_items` VALUES (19,17,13,1,68,0.05);

INSERT INTO `order_items` VALUES (20,17,19,1,199,0);

INSERT INTO `order_items` VALUES (21,18,13,1,68,0);

INSERT INTO `order_items` VALUES (22,19,14,1,39.9,0);

INSERT INTO `order_items` VALUES (23,20,13,1,68,0);

INSERT INTO `order_items` VALUES (24,20,15,1,32.9,0);

INSERT INTO `order_items` VALUES (25,21,16,1,24.9,0);

INSERT INTO `order_items` VALUES (26,22,14,1,39.9,0);

INSERT INTO `order_items` VALUES (27,22,16,1,24.9,0);

INSERT INTO `order_items` VALUES (28,23,7,1,89,0.10);

INSERT INTO `order_items` VALUES (29,23,16,1,24.9,0);

INSERT INTO `order_items` VALUES (30,24,4,1,59,0);

INSERT INTO `order_items` VALUES (31,25,14,1,39.9,0);

INSERT INTO `order_items` VALUES (32,26,11,1,39,0);

INSERT INTO `order_items` VALUES (33,26,15,1,32.9,0);

INSERT INTO `order_items` VALUES (34,27,13,3,68,0);

INSERT INTO `order_items` VALUES (35,27,14,2,39.9,0);

INSERT INTO `order_items` VALUES (36,28,16,1,24.9,0);

INSERT INTO `order_items` VALUES (37,29,18,2,159,0.05);

INSERT INTO `order_items` VALUES (38,30,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (39,30,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (40,30,18,1,159,0.05);

INSERT INTO `order_items` VALUES (41,31,5,1,399,0);

INSERT INTO `order_items` VALUES (42,32,3,1,169,0);

INSERT INTO `order_items` VALUES (43,33,11,1,39,0);

INSERT INTO `order_items` VALUES (44,33,16,1,24.9,0);

INSERT INTO `order_items` VALUES (45,34,3,1,169,0.05);

INSERT INTO `order_items` VALUES (46,34,20,1,39,0);

INSERT INTO `order_items` VALUES (47,35,15,1,32.9,0);

INSERT INTO `order_items` VALUES (48,35,19,2,199,0);

INSERT INTO `order_items` VALUES (49,36,16,1,24.9,0);

INSERT INTO `order_items` VALUES (50,37,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (51,37,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (52,38,13,1,68,0);

INSERT INTO `order_items` VALUES (53,39,4,1,59,0.10);

INSERT INTO `order_items` VALUES (54,40,13,1,68,0.05);

INSERT INTO `order_items` VALUES (55,41,15,1,32.9,0);

INSERT INTO `order_items` VALUES (56,42,14,2,39.9,0);

INSERT INTO `order_items` VALUES (57,43,8,1,159,0.10);

INSERT INTO `order_items` VALUES (58,44,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (59,45,14,1,39.9,0);

INSERT INTO `order_items` VALUES (60,46,13,2,68,0);

INSERT INTO `order_items` VALUES (61,46,14,1,39.9,0);

INSERT INTO `order_items` VALUES (62,46,19,1,199,0);

INSERT INTO `order_items` VALUES (63,47,5,1,399,0);

INSERT INTO `order_items` VALUES (64,47,14,1,39.9,0);

INSERT INTO `order_items` VALUES (65,48,12,1,79,0);

INSERT INTO `order_items` VALUES (66,48,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (67,49,11,1,39,0);

INSERT INTO `order_items` VALUES (68,50,14,1,39.9,0);

INSERT INTO `order_items` VALUES (69,51,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (70,52,13,1,68,0);

INSERT INTO `order_items` VALUES (71,53,14,1,39.9,0);

INSERT INTO `order_items` VALUES (72,54,11,1,39,0);

INSERT INTO `order_items` VALUES (73,54,13,1,68,0.05);

INSERT INTO `order_items` VALUES (74,55,7,1,89,0);

INSERT INTO `order_items` VALUES (75,55,12,1,79,0.05);

INSERT INTO `order_items` VALUES (76,55,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (77,56,3,1,169,0.05);

INSERT INTO `order_items` VALUES (78,56,15,3,32.9,0.10);

INSERT INTO `order_items` VALUES (79,57,14,1,39.9,0);

INSERT INTO `order_items` VALUES (80,57,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (81,57,17,1,69,0);

INSERT INTO `order_items` VALUES (82,58,7,1,89,0);

INSERT INTO `order_items` VALUES (83,58,15,1,32.9,0);

INSERT INTO `order_items` VALUES (84,58,17,1,69,0.10);

INSERT INTO `order_items` VALUES (85,59,11,1,39,0);

INSERT INTO `order_items` VALUES (86,60,9,2,129,0);

INSERT INTO `order_items` VALUES (87,60,12,1,79,0);

INSERT INTO `order_items` VALUES (88,61,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (89,62,11,1,39,0);

INSERT INTO `order_items` VALUES (90,63,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (91,64,12,1,79,0.05);

INSERT INTO `order_items` VALUES (92,64,15,1,32.9,0);

INSERT INTO `order_items` VALUES (93,65,15,1,32.9,0);

INSERT INTO `order_items` VALUES (94,66,20,1,39,0);

INSERT INTO `order_items` VALUES (95,67,13,1,68,0);

INSERT INTO `order_items` VALUES (96,68,11,1,39,0);

INSERT INTO `order_items` VALUES (97,68,14,2,39.9,0);

INSERT INTO `order_items` VALUES (98,69,4,1,59,0);

INSERT INTO `order_items` VALUES (99,69,20,1,39,0);

INSERT INTO `order_items` VALUES (100,70,9,1,129,0);

INSERT INTO `order_items` VALUES (101,71,12,1,79,0);

INSERT INTO `order_items` VALUES (102,71,13,1,68,0);

INSERT INTO `order_items` VALUES (103,72,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (104,73,4,1,59,0.05);

INSERT INTO `order_items` VALUES (105,73,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (106,74,7,1,89,0);

INSERT INTO `order_items` VALUES (107,75,8,1,159,0);

INSERT INTO `order_items` VALUES (108,76,12,1,79,0.05);

INSERT INTO `order_items` VALUES (109,76,14,1,39.9,0);

INSERT INTO `order_items` VALUES (110,77,6,1,299,0.10);

INSERT INTO `order_items` VALUES (111,77,7,1,89,0);

INSERT INTO `order_items` VALUES (112,77,15,1,32.9,0);

INSERT INTO `order_items` VALUES (113,78,15,1,32.9,0);

INSERT INTO `order_items` VALUES (114,79,20,1,39,0);

INSERT INTO `order_items` VALUES (115,80,15,1,32.9,0);

INSERT INTO `order_items` VALUES (116,80,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (117,81,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (118,82,11,1,39,0.05);

INSERT INTO `order_items` VALUES (119,82,14,1,39.9,0);

INSERT INTO `order_items` VALUES (120,83,13,1,68,0);

INSERT INTO `order_items` VALUES (121,84,20,2,39,0);

INSERT INTO `order_items` VALUES (122,85,12,1,79,0.05);

INSERT INTO `order_items` VALUES (123,86,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (124,87,14,1,39.9,0);

INSERT INTO `order_items` VALUES (125,88,20,1,39,0);

INSERT INTO `order_items` VALUES (126,89,3,2,169,0);

INSERT INTO `order_items` VALUES (127,90,7,2,89,0);

INSERT INTO `order_items` VALUES (128,90,17,1,69,0);

INSERT INTO `order_items` VALUES (129,91,14,1,39.9,0);

INSERT INTO `order_items` VALUES (130,92,12,1,79,0);

INSERT INTO `order_items` VALUES (131,93,13,1,68,0);

INSERT INTO `order_items` VALUES (132,93,17,1,69,0);

INSERT INTO `order_items` VALUES (133,94,15,1,32.9,0);

INSERT INTO `order_items` VALUES (134,95,13,2,68,0);

INSERT INTO `order_items` VALUES (135,95,20,1,39,0.05);

INSERT INTO `order_items` VALUES (136,96,13,1,68,0.10);

INSERT INTO `order_items` VALUES (137,97,13,1,68,0);

INSERT INTO `order_items` VALUES (138,98,7,1,89,0.10);

INSERT INTO `order_items` VALUES (139,98,11,1,39,0.05);

INSERT INTO `order_items` VALUES (140,99,15,1,32.9,0);

INSERT INTO `order_items` VALUES (141,100,9,1,129,0);

INSERT INTO `order_items` VALUES (142,101,4,1,59,0);

INSERT INTO `order_items` VALUES (143,102,12,1,79,0.05);

INSERT INTO `order_items` VALUES (144,103,20,1,39,0.10);

INSERT INTO `order_items` VALUES (145,104,14,1,39.9,0);

INSERT INTO `order_items` VALUES (146,105,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (147,106,11,1,39,0);

INSERT INTO `order_items` VALUES (148,107,14,1,39.9,0);

INSERT INTO `order_items` VALUES (149,108,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (150,109,4,1,59,0);

INSERT INTO `order_items` VALUES (151,110,8,1,159,0.10);

INSERT INTO `order_items` VALUES (152,110,9,1,129,0);

INSERT INTO `order_items` VALUES (153,111,6,1,299,0);

INSERT INTO `order_items` VALUES (154,112,3,1,169,0);

INSERT INTO `order_items` VALUES (155,112,7,1,89,0.10);

INSERT INTO `order_items` VALUES (156,112,20,2,39,0);

INSERT INTO `order_items` VALUES (157,113,9,3,129,0.05);

INSERT INTO `order_items` VALUES (158,114,3,1,169,0);

INSERT INTO `order_items` VALUES (159,114,15,1,32.9,0);

INSERT INTO `order_items` VALUES (160,115,12,1,79,0);

INSERT INTO `order_items` VALUES (161,116,10,1,699,0);

INSERT INTO `order_items` VALUES (162,117,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (163,118,3,1,169,0);

INSERT INTO `order_items` VALUES (164,118,4,1,59,0);

INSERT INTO `order_items` VALUES (165,118,13,2,68,0);

INSERT INTO `order_items` VALUES (166,119,16,1,24.9,0);

INSERT INTO `order_items` VALUES (167,119,20,1,39,0);

INSERT INTO `order_items` VALUES (168,120,13,1,68,0);

INSERT INTO `order_items` VALUES (169,120,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (170,121,15,1,32.9,0);

INSERT INTO `order_items` VALUES (171,121,19,1,199,0);

INSERT INTO `order_items` VALUES (172,122,15,2,32.9,0);

INSERT INTO `order_items` VALUES (173,123,7,1,89,0);

INSERT INTO `order_items` VALUES (174,123,11,2,39,0);

INSERT INTO `order_items` VALUES (175,124,11,2,39,0);

INSERT INTO `order_items` VALUES (176,125,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (177,125,15,2,32.9,0);

INSERT INTO `order_items` VALUES (178,126,3,3,169,0);

INSERT INTO `order_items` VALUES (179,127,11,1,39,0);

INSERT INTO `order_items` VALUES (180,128,12,1,79,0);

INSERT INTO `order_items` VALUES (181,128,14,1,39.9,0);

INSERT INTO `order_items` VALUES (182,129,5,1,399,0.10);

INSERT INTO `order_items` VALUES (183,130,3,1,169,0.05);

INSERT INTO `order_items` VALUES (184,131,13,1,68,0);

INSERT INTO `order_items` VALUES (185,132,16,1,24.9,0);

INSERT INTO `order_items` VALUES (186,133,6,1,299,0);

INSERT INTO `order_items` VALUES (187,133,7,1,89,0.05);

INSERT INTO `order_items` VALUES (188,134,7,1,89,0);

INSERT INTO `order_items` VALUES (189,135,16,1,24.9,0);

INSERT INTO `order_items` VALUES (190,136,11,1,39,0);

INSERT INTO `order_items` VALUES (191,136,20,2,39,0.10);

INSERT INTO `order_items` VALUES (192,137,11,2,39,0);

INSERT INTO `order_items` VALUES (193,137,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (194,137,20,1,39,0);

INSERT INTO `order_items` VALUES (195,138,17,1,69,0.10);

INSERT INTO `order_items` VALUES (196,139,15,1,32.9,0);

INSERT INTO `order_items` VALUES (197,139,16,1,24.9,0);

INSERT INTO `order_items` VALUES (198,140,16,1,24.9,0);

INSERT INTO `order_items` VALUES (199,141,20,1,39,0);

INSERT INTO `order_items` VALUES (200,142,9,1,129,0);

INSERT INTO `order_items` VALUES (201,143,11,1,39,0);

INSERT INTO `order_items` VALUES (202,144,4,1,59,0);

INSERT INTO `order_items` VALUES (203,145,4,1,59,0);

INSERT INTO `order_items` VALUES (204,145,15,1,32.9,0);

INSERT INTO `order_items` VALUES (205,146,5,1,399,0);

INSERT INTO `order_items` VALUES (206,146,8,2,159,0);

INSERT INTO `order_items` VALUES (207,146,17,1,69,0);

INSERT INTO `order_items` VALUES (208,147,11,1,39,0);

INSERT INTO `order_items` VALUES (209,148,9,1,129,0.05);

INSERT INTO `order_items` VALUES (210,148,13,1,68,0);

INSERT INTO `order_items` VALUES (211,149,15,1,32.9,0);

INSERT INTO `order_items` VALUES (212,150,13,2,68,0);

INSERT INTO `order_items` VALUES (213,150,18,1,159,0.05);

INSERT INTO `order_items` VALUES (214,151,18,2,159,0);

INSERT INTO `order_items` VALUES (215,152,20,1,39,0.05);

INSERT INTO `order_items` VALUES (216,153,3,1,169,0.05);

INSERT INTO `order_items` VALUES (217,153,13,1,68,0);

INSERT INTO `order_items` VALUES (218,154,3,1,169,0);

INSERT INTO `order_items` VALUES (219,155,15,1,32.9,0);

INSERT INTO `order_items` VALUES (220,155,16,1,24.9,0);

INSERT INTO `order_items` VALUES (221,156,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (222,157,13,1,68,0);

INSERT INTO `order_items` VALUES (223,157,14,1,39.9,0);

INSERT INTO `order_items` VALUES (224,158,11,1,39,0);

INSERT INTO `order_items` VALUES (225,159,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (226,160,18,1,159,0);

INSERT INTO `order_items` VALUES (227,161,7,1,89,0);

INSERT INTO `order_items` VALUES (228,162,13,1,68,0);

INSERT INTO `order_items` VALUES (229,163,11,1,39,0);

INSERT INTO `order_items` VALUES (230,164,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (231,164,15,1,32.9,0);

INSERT INTO `order_items` VALUES (232,165,14,1,39.9,0);

INSERT INTO `order_items` VALUES (233,165,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (234,166,15,1,32.9,0);

INSERT INTO `order_items` VALUES (235,167,14,1,39.9,0);

INSERT INTO `order_items` VALUES (236,168,3,1,169,0);

INSERT INTO `order_items` VALUES (237,168,13,1,68,0);

INSERT INTO `order_items` VALUES (238,169,4,2,59,0.05);

INSERT INTO `order_items` VALUES (239,170,11,2,39,0.05);

INSERT INTO `order_items` VALUES (240,170,20,1,39,0);

INSERT INTO `order_items` VALUES (241,171,14,2,39.9,0);

INSERT INTO `order_items` VALUES (242,172,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (243,173,7,3,89,0);

INSERT INTO `order_items` VALUES (244,174,12,1,79,0.10);

INSERT INTO `order_items` VALUES (245,174,14,2,39.9,0);

INSERT INTO `order_items` VALUES (246,175,15,1,32.9,0);

INSERT INTO `order_items` VALUES (247,175,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (248,176,4,2,59,0);

INSERT INTO `order_items` VALUES (249,177,5,2,399,0);

INSERT INTO `order_items` VALUES (250,178,20,1,39,0);

INSERT INTO `order_items` VALUES (251,179,17,1,69,0);

INSERT INTO `order_items` VALUES (252,180,11,1,39,0);

INSERT INTO `order_items` VALUES (253,180,13,1,68,0.05);

INSERT INTO `order_items` VALUES (254,181,4,1,59,0);

INSERT INTO `order_items` VALUES (255,182,14,1,39.9,0);

INSERT INTO `order_items` VALUES (256,183,11,1,39,0.10);

INSERT INTO `order_items` VALUES (257,184,15,1,32.9,0);

INSERT INTO `order_items` VALUES (258,185,14,1,39.9,0);

INSERT INTO `order_items` VALUES (259,186,13,1,68,0.05);

INSERT INTO `order_items` VALUES (260,186,14,2,39.9,0);

INSERT INTO `order_items` VALUES (261,187,4,1,59,0);

INSERT INTO `order_items` VALUES (262,188,16,1,24.9,0);

INSERT INTO `order_items` VALUES (263,189,4,2,59,0.10);

INSERT INTO `order_items` VALUES (264,190,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (265,191,16,1,24.9,0);

INSERT INTO `order_items` VALUES (266,192,11,1,39,0.05);

INSERT INTO `order_items` VALUES (267,193,7,1,89,0.05);

INSERT INTO `order_items` VALUES (268,194,1,2,4299,0);

INSERT INTO `order_items` VALUES (269,194,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (270,195,7,1,89,0);

INSERT INTO `order_items` VALUES (271,196,9,1,129,0);

INSERT INTO `order_items` VALUES (272,197,13,1,68,0.10);

INSERT INTO `order_items` VALUES (273,198,3,1,169,0.10);

INSERT INTO `order_items` VALUES (274,198,14,2,39.9,0);

INSERT INTO `order_items` VALUES (275,198,15,3,32.9,0.05);

INSERT INTO `order_items` VALUES (276,199,12,1,79,0);

INSERT INTO `order_items` VALUES (277,200,20,1,39,0);

INSERT INTO `order_items` VALUES (278,201,9,1,129,0);

INSERT INTO `order_items` VALUES (279,202,14,1,39.9,0);

INSERT INTO `order_items` VALUES (280,202,15,1,32.9,0);

INSERT INTO `order_items` VALUES (281,203,7,2,89,0.05);

INSERT INTO `order_items` VALUES (282,204,12,1,79,0.05);

INSERT INTO `order_items` VALUES (283,205,11,1,39,0);

INSERT INTO `order_items` VALUES (284,206,3,1,169,0);

INSERT INTO `order_items` VALUES (285,207,11,1,39,0);

INSERT INTO `order_items` VALUES (286,207,13,2,68,0);

INSERT INTO `order_items` VALUES (287,207,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (288,208,12,2,79,0);

INSERT INTO `order_items` VALUES (289,209,16,1,24.9,0);

INSERT INTO `order_items` VALUES (290,210,12,1,79,0);

INSERT INTO `order_items` VALUES (291,211,12,1,79,0.10);

INSERT INTO `order_items` VALUES (292,211,14,2,39.9,0);

INSERT INTO `order_items` VALUES (293,212,11,1,39,0.10);

INSERT INTO `order_items` VALUES (294,213,7,2,89,0);

INSERT INTO `order_items` VALUES (295,214,5,1,399,0);

INSERT INTO `order_items` VALUES (296,215,11,1,39,0);

INSERT INTO `order_items` VALUES (297,216,4,1,59,0.05);

INSERT INTO `order_items` VALUES (298,217,3,1,169,0);

INSERT INTO `order_items` VALUES (299,217,11,1,39,0);

INSERT INTO `order_items` VALUES (300,217,14,1,39.9,0);

INSERT INTO `order_items` VALUES (301,218,20,1,39,0.05);

INSERT INTO `order_items` VALUES (302,219,7,2,89,0);

INSERT INTO `order_items` VALUES (303,220,11,2,39,0);

INSERT INTO `order_items` VALUES (304,220,14,1,39.9,0);

INSERT INTO `order_items` VALUES (305,221,13,1,68,0);

INSERT INTO `order_items` VALUES (306,222,16,1,24.9,0);

INSERT INTO `order_items` VALUES (307,223,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (308,224,11,1,39,0.05);

INSERT INTO `order_items` VALUES (309,225,6,1,299,0);

INSERT INTO `order_items` VALUES (310,226,17,1,69,0.10);

INSERT INTO `order_items` VALUES (311,227,13,1,68,0);

INSERT INTO `order_items` VALUES (312,228,4,1,59,0);

INSERT INTO `order_items` VALUES (313,229,4,1,59,0.10);

INSERT INTO `order_items` VALUES (314,230,14,1,39.9,0);

INSERT INTO `order_items` VALUES (315,230,15,1,32.9,0);

INSERT INTO `order_items` VALUES (316,231,4,1,59,0);

INSERT INTO `order_items` VALUES (317,231,16,1,24.9,0);

INSERT INTO `order_items` VALUES (318,232,13,1,68,0);

INSERT INTO `order_items` VALUES (319,233,4,2,59,0);

INSERT INTO `order_items` VALUES (320,234,4,1,59,0);

INSERT INTO `order_items` VALUES (321,235,13,1,68,0.10);

INSERT INTO `order_items` VALUES (322,236,4,1,59,0);

INSERT INTO `order_items` VALUES (323,237,11,1,39,0);

INSERT INTO `order_items` VALUES (324,238,12,2,79,0);

INSERT INTO `order_items` VALUES (325,239,13,1,68,0);

INSERT INTO `order_items` VALUES (326,240,13,1,68,0);

INSERT INTO `order_items` VALUES (327,241,13,1,68,0);

INSERT INTO `order_items` VALUES (328,242,7,2,89,0);

INSERT INTO `order_items` VALUES (329,243,13,1,68,0.10);

INSERT INTO `order_items` VALUES (330,243,14,1,39.9,0);

INSERT INTO `order_items` VALUES (331,244,11,3,39,0);

INSERT INTO `order_items` VALUES (332,244,13,1,68,0);

INSERT INTO `order_items` VALUES (333,245,18,1,159,0);

INSERT INTO `order_items` VALUES (334,246,13,1,68,0);

INSERT INTO `order_items` VALUES (335,247,14,1,39.9,0);

INSERT INTO `order_items` VALUES (336,248,4,1,59,0.05);

INSERT INTO `order_items` VALUES (337,249,11,2,39,0);

INSERT INTO `order_items` VALUES (338,249,18,1,159,0);

INSERT INTO `order_items` VALUES (339,250,13,1,68,0);

INSERT INTO `order_items` VALUES (340,251,11,1,39,0);

INSERT INTO `order_items` VALUES (341,252,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (342,253,11,1,39,0);

INSERT INTO `order_items` VALUES (343,253,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (344,254,13,1,68,0);

INSERT INTO `order_items` VALUES (345,254,15,1,32.9,0);

INSERT INTO `order_items` VALUES (346,254,17,1,69,0);

INSERT INTO `order_items` VALUES (347,255,14,1,39.9,0);

INSERT INTO `order_items` VALUES (348,255,16,1,24.9,0);

INSERT INTO `order_items` VALUES (349,256,20,1,39,0.05);

INSERT INTO `order_items` VALUES (350,257,4,1,59,0);

INSERT INTO `order_items` VALUES (351,257,15,2,32.9,0);

INSERT INTO `order_items` VALUES (352,258,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (353,259,4,2,59,0);

INSERT INTO `order_items` VALUES (354,260,12,1,79,0);

INSERT INTO `order_items` VALUES (355,261,4,1,59,0.05);

INSERT INTO `order_items` VALUES (356,262,20,1,39,0);

INSERT INTO `order_items` VALUES (357,263,14,1,39.9,0);

INSERT INTO `order_items` VALUES (358,264,10,1,699,0);

INSERT INTO `order_items` VALUES (359,264,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (360,265,13,1,68,0.05);

INSERT INTO `order_items` VALUES (361,266,13,1,68,0);

INSERT INTO `order_items` VALUES (362,267,15,1,32.9,0);

INSERT INTO `order_items` VALUES (363,268,11,1,39,0.10);

INSERT INTO `order_items` VALUES (364,268,20,1,39,0);

INSERT INTO `order_items` VALUES (365,269,12,1,79,0);

INSERT INTO `order_items` VALUES (366,269,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (367,269,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (368,270,15,1,32.9,0);

INSERT INTO `order_items` VALUES (369,271,16,1,24.9,0);

INSERT INTO `order_items` VALUES (370,272,4,1,59,0.05);

INSERT INTO `order_items` VALUES (371,272,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (372,273,13,1,68,0);

INSERT INTO `order_items` VALUES (373,274,13,1,68,0);

INSERT INTO `order_items` VALUES (374,275,11,1,39,0);

INSERT INTO `order_items` VALUES (375,275,15,1,32.9,0);

INSERT INTO `order_items` VALUES (376,275,16,1,24.9,0);

INSERT INTO `order_items` VALUES (377,276,11,1,39,0.05);

INSERT INTO `order_items` VALUES (378,277,13,1,68,0);

INSERT INTO `order_items` VALUES (379,277,14,1,39.9,0);

INSERT INTO `order_items` VALUES (380,277,20,1,39,0);

INSERT INTO `order_items` VALUES (381,278,4,1,59,0);

INSERT INTO `order_items` VALUES (382,279,13,1,68,0);

INSERT INTO `order_items` VALUES (383,279,15,1,32.9,0);

INSERT INTO `order_items` VALUES (384,279,17,2,69,0);

INSERT INTO `order_items` VALUES (385,280,7,1,89,0);

INSERT INTO `order_items` VALUES (386,280,11,1,39,0.05);

INSERT INTO `order_items` VALUES (387,281,9,1,129,0.05);

INSERT INTO `order_items` VALUES (388,282,11,1,39,0.05);

INSERT INTO `order_items` VALUES (389,283,13,1,68,0);

INSERT INTO `order_items` VALUES (390,284,7,1,89,0);

INSERT INTO `order_items` VALUES (391,285,18,1,159,0);

INSERT INTO `order_items` VALUES (392,286,3,1,169,0.10);

INSERT INTO `order_items` VALUES (393,286,14,1,39.9,0);

INSERT INTO `order_items` VALUES (394,287,20,1,39,0);

INSERT INTO `order_items` VALUES (395,288,13,1,68,0.05);

INSERT INTO `order_items` VALUES (396,289,16,1,24.9,0);

INSERT INTO `order_items` VALUES (397,290,4,1,59,0);

INSERT INTO `order_items` VALUES (398,290,13,1,68,0.10);

INSERT INTO `order_items` VALUES (399,291,13,1,68,0);

INSERT INTO `order_items` VALUES (400,292,18,2,159,0);

INSERT INTO `order_items` VALUES (401,293,16,1,24.9,0);

INSERT INTO `order_items` VALUES (402,294,4,1,59,0.10);

INSERT INTO `order_items` VALUES (403,295,20,1,39,0);

INSERT INTO `order_items` VALUES (404,296,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (405,296,19,2,199,0);

INSERT INTO `order_items` VALUES (406,297,11,1,39,0.05);

INSERT INTO `order_items` VALUES (407,297,12,1,79,0);

INSERT INTO `order_items` VALUES (408,298,6,1,299,0.05);

INSERT INTO `order_items` VALUES (409,299,17,2,69,0);

INSERT INTO `order_items` VALUES (410,300,4,1,59,0);

INSERT INTO `order_items` VALUES (411,300,11,1,39,0.05);

INSERT INTO `order_items` VALUES (412,301,16,2,24.9,0);

INSERT INTO `order_items` VALUES (413,302,7,1,89,0);

INSERT INTO `order_items` VALUES (414,302,17,1,69,0);

INSERT INTO `order_items` VALUES (415,303,8,1,159,0.05);

INSERT INTO `order_items` VALUES (416,304,3,1,169,0);

INSERT INTO `order_items` VALUES (417,304,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (418,305,7,1,89,0);

INSERT INTO `order_items` VALUES (419,306,20,2,39,0);

INSERT INTO `order_items` VALUES (420,307,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (421,308,13,1,68,0);

INSERT INTO `order_items` VALUES (422,309,18,1,159,0);

INSERT INTO `order_items` VALUES (423,310,12,1,79,0);

INSERT INTO `order_items` VALUES (424,311,14,1,39.9,0);

INSERT INTO `order_items` VALUES (425,312,11,1,39,0);

INSERT INTO `order_items` VALUES (426,312,16,1,24.9,0);

INSERT INTO `order_items` VALUES (427,313,16,1,24.9,0);

INSERT INTO `order_items` VALUES (428,313,18,1,159,0);

INSERT INTO `order_items` VALUES (429,314,8,1,159,0.05);

INSERT INTO `order_items` VALUES (430,315,16,1,24.9,0);

INSERT INTO `order_items` VALUES (431,316,15,1,32.9,0);

INSERT INTO `order_items` VALUES (432,317,14,1,39.9,0);

INSERT INTO `order_items` VALUES (433,318,13,1,68,0);

INSERT INTO `order_items` VALUES (434,319,11,1,39,0);

INSERT INTO `order_items` VALUES (435,319,16,1,24.9,0);

INSERT INTO `order_items` VALUES (436,320,12,1,79,0);

INSERT INTO `order_items` VALUES (437,320,13,1,68,0);

INSERT INTO `order_items` VALUES (438,321,14,1,39.9,0);

INSERT INTO `order_items` VALUES (439,322,6,1,299,0);

INSERT INTO `order_items` VALUES (440,323,13,1,68,0);

INSERT INTO `order_items` VALUES (441,323,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (442,324,11,1,39,0);

INSERT INTO `order_items` VALUES (443,325,4,1,59,0);

INSERT INTO `order_items` VALUES (444,326,15,1,32.9,0);

INSERT INTO `order_items` VALUES (445,327,14,2,39.9,0);

INSERT INTO `order_items` VALUES (446,327,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (447,327,18,1,159,0);

INSERT INTO `order_items` VALUES (448,328,20,1,39,0);

INSERT INTO `order_items` VALUES (449,329,12,1,79,0);

INSERT INTO `order_items` VALUES (450,330,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (451,330,17,1,69,0.05);

INSERT INTO `order_items` VALUES (452,331,11,2,39,0);

INSERT INTO `order_items` VALUES (453,332,12,2,79,0);

INSERT INTO `order_items` VALUES (454,333,17,1,69,0);

INSERT INTO `order_items` VALUES (455,334,11,1,39,0.05);

INSERT INTO `order_items` VALUES (456,335,14,1,39.9,0);

INSERT INTO `order_items` VALUES (457,336,7,1,89,0.05);

INSERT INTO `order_items` VALUES (458,336,9,1,129,0);

INSERT INTO `order_items` VALUES (459,337,11,3,39,0);

INSERT INTO `order_items` VALUES (460,338,14,1,39.9,0);

INSERT INTO `order_items` VALUES (461,339,7,1,89,0);

INSERT INTO `order_items` VALUES (462,339,15,1,32.9,0);

INSERT INTO `order_items` VALUES (463,340,16,1,24.9,0);

INSERT INTO `order_items` VALUES (464,341,11,1,39,0);

INSERT INTO `order_items` VALUES (465,341,16,1,24.9,0);

INSERT INTO `order_items` VALUES (466,342,3,1,169,0);

INSERT INTO `order_items` VALUES (467,343,13,1,68,0);

INSERT INTO `order_items` VALUES (468,344,7,1,89,0);

INSERT INTO `order_items` VALUES (469,345,14,1,39.9,0);

INSERT INTO `order_items` VALUES (470,346,7,1,89,0);

INSERT INTO `order_items` VALUES (471,347,15,1,32.9,0);

INSERT INTO `order_items` VALUES (472,348,4,1,59,0);

INSERT INTO `order_items` VALUES (473,349,7,1,89,0);

INSERT INTO `order_items` VALUES (474,349,11,1,39,0);

INSERT INTO `order_items` VALUES (475,350,13,1,68,0);

INSERT INTO `order_items` VALUES (476,351,14,1,39.9,0);

INSERT INTO `order_items` VALUES (477,352,5,1,399,0);

INSERT INTO `order_items` VALUES (478,352,11,1,39,0.05);

INSERT INTO `order_items` VALUES (479,353,14,1,39.9,0);

INSERT INTO `order_items` VALUES (480,354,7,1,89,0);

INSERT INTO `order_items` VALUES (481,354,14,1,39.9,0);

INSERT INTO `order_items` VALUES (482,355,8,1,159,0);

INSERT INTO `order_items` VALUES (483,355,13,1,68,0);

INSERT INTO `order_items` VALUES (484,356,7,1,89,0.05);

INSERT INTO `order_items` VALUES (485,357,4,1,59,0.05);

INSERT INTO `order_items` VALUES (486,357,17,1,69,0);

INSERT INTO `order_items` VALUES (487,358,12,1,79,0);

INSERT INTO `order_items` VALUES (488,359,20,1,39,0);

INSERT INTO `order_items` VALUES (489,360,12,1,79,0);

INSERT INTO `order_items` VALUES (490,361,9,1,129,0.10);

INSERT INTO `order_items` VALUES (491,361,11,3,39,0);

INSERT INTO `order_items` VALUES (492,362,15,1,32.9,0);

INSERT INTO `order_items` VALUES (493,363,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (494,364,14,1,39.9,0);

INSERT INTO `order_items` VALUES (495,364,15,1,32.9,0);

INSERT INTO `order_items` VALUES (496,365,3,1,169,0);

INSERT INTO `order_items` VALUES (497,366,4,1,59,0.05);

INSERT INTO `order_items` VALUES (498,367,4,1,59,0);

INSERT INTO `order_items` VALUES (499,368,4,1,59,0);

INSERT INTO `order_items` VALUES (500,368,13,1,68,0);

INSERT INTO `order_items` VALUES (501,369,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (502,370,11,1,39,0);

INSERT INTO `order_items` VALUES (503,370,15,1,32.9,0);

INSERT INTO `order_items` VALUES (504,371,17,2,69,0);

INSERT INTO `order_items` VALUES (505,372,4,1,59,0);

INSERT INTO `order_items` VALUES (506,373,4,1,59,0);

INSERT INTO `order_items` VALUES (507,373,18,1,159,0.10);

INSERT INTO `order_items` VALUES (508,374,17,1,69,0.05);

INSERT INTO `order_items` VALUES (509,375,4,1,59,0.05);

INSERT INTO `order_items` VALUES (510,376,16,1,24.9,0);

INSERT INTO `order_items` VALUES (511,377,11,1,39,0);

INSERT INTO `order_items` VALUES (512,378,20,1,39,0);

INSERT INTO `order_items` VALUES (513,379,6,1,299,0.05);

INSERT INTO `order_items` VALUES (514,380,7,1,89,0);

INSERT INTO `order_items` VALUES (515,381,4,1,59,0);

INSERT INTO `order_items` VALUES (516,382,13,1,68,0);

INSERT INTO `order_items` VALUES (517,382,15,1,32.9,0);

INSERT INTO `order_items` VALUES (518,383,7,1,89,0);

INSERT INTO `order_items` VALUES (519,384,7,1,89,0);

INSERT INTO `order_items` VALUES (520,384,13,1,68,0);

INSERT INTO `order_items` VALUES (521,385,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (522,385,20,2,39,0.10);

INSERT INTO `order_items` VALUES (523,386,16,1,24.9,0);

INSERT INTO `order_items` VALUES (524,386,19,1,199,0.10);

INSERT INTO `order_items` VALUES (525,387,11,1,39,0.05);

INSERT INTO `order_items` VALUES (526,388,8,1,159,0);

INSERT INTO `order_items` VALUES (527,389,7,1,89,0.05);

INSERT INTO `order_items` VALUES (528,389,12,1,79,0.10);

INSERT INTO `order_items` VALUES (529,390,3,1,169,0);

INSERT INTO `order_items` VALUES (530,391,13,1,68,0);

INSERT INTO `order_items` VALUES (531,392,11,1,39,0.05);

INSERT INTO `order_items` VALUES (532,393,11,1,39,0);

INSERT INTO `order_items` VALUES (533,394,13,1,68,0);

INSERT INTO `order_items` VALUES (534,394,16,1,24.9,0);

INSERT INTO `order_items` VALUES (535,395,14,1,39.9,0);

INSERT INTO `order_items` VALUES (536,396,17,1,69,0);

INSERT INTO `order_items` VALUES (537,396,20,1,39,0);

INSERT INTO `order_items` VALUES (538,397,15,1,32.9,0);

INSERT INTO `order_items` VALUES (539,398,17,1,69,0.05);

INSERT INTO `order_items` VALUES (540,399,20,2,39,0);

INSERT INTO `order_items` VALUES (541,400,3,2,169,0.05);

INSERT INTO `order_items` VALUES (542,401,7,1,89,0.05);

INSERT INTO `order_items` VALUES (543,401,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (544,402,20,1,39,0);

INSERT INTO `order_items` VALUES (545,403,4,2,59,0);

INSERT INTO `order_items` VALUES (546,403,13,2,68,0);

INSERT INTO `order_items` VALUES (547,403,17,1,69,0);

INSERT INTO `order_items` VALUES (548,404,19,1,199,0.05);

INSERT INTO `order_items` VALUES (549,405,18,2,159,0);

INSERT INTO `order_items` VALUES (550,406,7,1,89,0);

INSERT INTO `order_items` VALUES (551,407,14,2,39.9,0);

INSERT INTO `order_items` VALUES (552,408,16,1,24.9,0);

INSERT INTO `order_items` VALUES (553,409,17,1,69,0);

INSERT INTO `order_items` VALUES (554,410,14,1,39.9,0);

INSERT INTO `order_items` VALUES (555,411,14,2,39.9,0);

INSERT INTO `order_items` VALUES (556,412,9,1,129,0);

INSERT INTO `order_items` VALUES (557,412,14,1,39.9,0);

INSERT INTO `order_items` VALUES (558,413,16,1,24.9,0);

INSERT INTO `order_items` VALUES (559,414,4,1,59,0);

INSERT INTO `order_items` VALUES (560,414,18,1,159,0);

INSERT INTO `order_items` VALUES (561,415,20,1,39,0.10);

INSERT INTO `order_items` VALUES (562,416,17,1,69,0);

INSERT INTO `order_items` VALUES (563,417,3,1,169,0.05);

INSERT INTO `order_items` VALUES (564,417,16,1,24.9,0);

INSERT INTO `order_items` VALUES (565,418,17,1,69,0);

INSERT INTO `order_items` VALUES (566,419,13,1,68,0);

INSERT INTO `order_items` VALUES (567,419,16,1,24.9,0);

INSERT INTO `order_items` VALUES (568,420,7,1,89,0.05);

INSERT INTO `order_items` VALUES (569,421,11,1,39,0);

INSERT INTO `order_items` VALUES (570,422,11,1,39,0.05);

INSERT INTO `order_items` VALUES (571,422,13,2,68,0);

INSERT INTO `order_items` VALUES (572,423,17,1,69,0.05);

INSERT INTO `order_items` VALUES (573,424,20,1,39,0.05);

INSERT INTO `order_items` VALUES (574,425,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (575,425,15,1,32.9,0);

INSERT INTO `order_items` VALUES (576,425,19,2,199,0);

INSERT INTO `order_items` VALUES (577,426,7,1,89,0.05);

INSERT INTO `order_items` VALUES (578,427,5,1,399,0);

INSERT INTO `order_items` VALUES (579,428,4,1,59,0);

INSERT INTO `order_items` VALUES (580,429,3,1,169,0);

INSERT INTO `order_items` VALUES (581,429,13,2,68,0.05);

INSERT INTO `order_items` VALUES (582,429,17,1,69,0);

INSERT INTO `order_items` VALUES (583,430,8,1,159,0);

INSERT INTO `order_items` VALUES (584,430,13,1,68,0.05);

INSERT INTO `order_items` VALUES (585,431,15,1,32.9,0);

INSERT INTO `order_items` VALUES (586,432,11,1,39,0);

INSERT INTO `order_items` VALUES (587,432,14,1,39.9,0);

INSERT INTO `order_items` VALUES (588,432,15,1,32.9,0);

INSERT INTO `order_items` VALUES (589,433,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (590,434,13,1,68,0);

INSERT INTO `order_items` VALUES (591,435,17,1,69,0);

INSERT INTO `order_items` VALUES (592,436,7,1,89,0);

INSERT INTO `order_items` VALUES (593,437,15,1,32.9,0);

INSERT INTO `order_items` VALUES (594,437,19,1,199,0);

INSERT INTO `order_items` VALUES (595,438,7,1,89,0);

INSERT INTO `order_items` VALUES (596,439,13,2,68,0.10);

INSERT INTO `order_items` VALUES (597,440,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (598,441,12,2,79,0);

INSERT INTO `order_items` VALUES (599,442,9,1,129,0);

INSERT INTO `order_items` VALUES (600,442,10,1,699,0);

INSERT INTO `order_items` VALUES (601,443,12,1,79,0);

INSERT INTO `order_items` VALUES (602,444,12,1,79,0);

INSERT INTO `order_items` VALUES (603,444,14,1,39.9,0);

INSERT INTO `order_items` VALUES (604,444,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (605,445,4,1,59,0);

INSERT INTO `order_items` VALUES (606,446,12,1,79,0);

INSERT INTO `order_items` VALUES (607,447,9,1,129,0);

INSERT INTO `order_items` VALUES (608,448,7,1,89,0);

INSERT INTO `order_items` VALUES (609,448,12,3,79,0);

INSERT INTO `order_items` VALUES (610,449,7,1,89,0);

INSERT INTO `order_items` VALUES (611,449,14,1,39.9,0);

INSERT INTO `order_items` VALUES (612,449,19,1,199,0);

INSERT INTO `order_items` VALUES (613,450,16,2,24.9,0);

INSERT INTO `order_items` VALUES (614,450,20,1,39,0.05);

INSERT INTO `order_items` VALUES (615,451,13,1,68,0);

INSERT INTO `order_items` VALUES (616,451,19,1,199,0);

INSERT INTO `order_items` VALUES (617,452,7,1,89,0.05);

INSERT INTO `order_items` VALUES (618,452,9,1,129,0);

INSERT INTO `order_items` VALUES (619,452,13,1,68,0.05);

INSERT INTO `order_items` VALUES (620,453,9,1,129,0);

INSERT INTO `order_items` VALUES (621,453,11,1,39,0);

INSERT INTO `order_items` VALUES (622,453,14,1,39.9,0);

INSERT INTO `order_items` VALUES (623,454,16,1,24.9,0);

INSERT INTO `order_items` VALUES (624,455,6,1,299,0);

INSERT INTO `order_items` VALUES (625,455,9,1,129,0);

INSERT INTO `order_items` VALUES (626,456,11,1,39,0.05);

INSERT INTO `order_items` VALUES (627,456,19,2,199,0);

INSERT INTO `order_items` VALUES (628,457,13,1,68,0);

INSERT INTO `order_items` VALUES (629,458,17,1,69,0.05);

INSERT INTO `order_items` VALUES (630,459,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (631,460,12,1,79,0);

INSERT INTO `order_items` VALUES (632,461,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (633,461,20,1,39,0);

INSERT INTO `order_items` VALUES (634,462,4,2,59,0);

INSERT INTO `order_items` VALUES (635,463,16,1,24.9,0);

INSERT INTO `order_items` VALUES (636,464,5,1,399,0.10);

INSERT INTO `order_items` VALUES (637,465,4,1,59,0);

INSERT INTO `order_items` VALUES (638,466,14,1,39.9,0);

INSERT INTO `order_items` VALUES (639,466,15,1,32.9,0);

INSERT INTO `order_items` VALUES (640,467,13,1,68,0);

INSERT INTO `order_items` VALUES (641,467,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (642,468,6,2,299,0);

INSERT INTO `order_items` VALUES (643,468,13,1,68,0.10);

INSERT INTO `order_items` VALUES (644,468,16,1,24.9,0);

INSERT INTO `order_items` VALUES (645,469,7,1,89,0.05);

INSERT INTO `order_items` VALUES (646,470,3,1,169,0);

INSERT INTO `order_items` VALUES (647,471,7,1,89,0);

INSERT INTO `order_items` VALUES (648,471,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (649,472,14,1,39.9,0);

INSERT INTO `order_items` VALUES (650,473,7,1,89,0);

INSERT INTO `order_items` VALUES (651,474,10,1,699,0);

INSERT INTO `order_items` VALUES (652,474,11,1,39,0);

INSERT INTO `order_items` VALUES (653,474,16,1,24.9,0);

INSERT INTO `order_items` VALUES (654,475,9,1,129,0);

INSERT INTO `order_items` VALUES (655,476,15,1,32.9,0);

INSERT INTO `order_items` VALUES (656,477,4,1,59,0);

INSERT INTO `order_items` VALUES (657,477,20,1,39,0.05);

INSERT INTO `order_items` VALUES (658,478,13,1,68,0);

INSERT INTO `order_items` VALUES (659,478,16,1,24.9,0);

INSERT INTO `order_items` VALUES (660,479,12,1,79,0);

INSERT INTO `order_items` VALUES (661,480,20,1,39,0.10);

INSERT INTO `order_items` VALUES (662,481,16,1,24.9,0);

INSERT INTO `order_items` VALUES (663,482,11,1,39,0);

INSERT INTO `order_items` VALUES (664,483,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (665,483,15,1,32.9,0);

INSERT INTO `order_items` VALUES (666,484,7,1,89,0);

INSERT INTO `order_items` VALUES (667,485,17,1,69,0);

INSERT INTO `order_items` VALUES (668,486,18,1,159,0.10);

INSERT INTO `order_items` VALUES (669,487,16,1,24.9,0);

INSERT INTO `order_items` VALUES (670,488,14,2,39.9,0);

INSERT INTO `order_items` VALUES (671,489,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (672,490,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (673,491,3,1,169,0.05);

INSERT INTO `order_items` VALUES (674,491,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (675,492,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (676,493,17,1,69,0);

INSERT INTO `order_items` VALUES (677,494,13,1,68,0);

INSERT INTO `order_items` VALUES (678,495,4,1,59,0);

INSERT INTO `order_items` VALUES (679,496,7,2,89,0);

INSERT INTO `order_items` VALUES (680,496,11,1,39,0);

INSERT INTO `order_items` VALUES (681,497,8,1,159,0.05);

INSERT INTO `order_items` VALUES (682,497,14,1,39.9,0);

INSERT INTO `order_items` VALUES (683,498,13,1,68,0);

INSERT INTO `order_items` VALUES (684,498,16,1,24.9,0);

INSERT INTO `order_items` VALUES (685,499,7,1,89,0);

INSERT INTO `order_items` VALUES (686,500,11,1,39,0);

INSERT INTO `order_items` VALUES (687,500,16,2,24.9,0);

INSERT INTO `order_items` VALUES (688,501,6,1,299,0.05);

INSERT INTO `order_items` VALUES (689,501,13,2,68,0);

INSERT INTO `order_items` VALUES (690,501,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (691,502,17,2,69,0);

INSERT INTO `order_items` VALUES (692,503,4,1,59,0);

INSERT INTO `order_items` VALUES (693,504,16,1,24.9,0);

INSERT INTO `order_items` VALUES (694,505,9,1,129,0.05);

INSERT INTO `order_items` VALUES (695,505,15,2,32.9,0);

INSERT INTO `order_items` VALUES (696,506,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (697,507,14,1,39.9,0);

INSERT INTO `order_items` VALUES (698,508,3,1,169,0);

INSERT INTO `order_items` VALUES (699,509,17,2,69,0);

INSERT INTO `order_items` VALUES (700,510,5,1,399,0);

INSERT INTO `order_items` VALUES (701,510,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (702,511,15,1,32.9,0);

INSERT INTO `order_items` VALUES (703,512,9,2,129,0);

INSERT INTO `order_items` VALUES (704,512,13,1,68,0);

INSERT INTO `order_items` VALUES (705,513,3,1,169,0);

INSERT INTO `order_items` VALUES (706,513,9,1,129,0);

INSERT INTO `order_items` VALUES (707,513,17,1,69,0);

INSERT INTO `order_items` VALUES (708,514,13,1,68,0.05);

INSERT INTO `order_items` VALUES (709,515,8,1,159,0);

INSERT INTO `order_items` VALUES (710,516,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (711,517,11,1,39,0);

INSERT INTO `order_items` VALUES (712,518,13,1,68,0);

INSERT INTO `order_items` VALUES (713,518,14,1,39.9,0);

INSERT INTO `order_items` VALUES (714,519,17,1,69,0);

INSERT INTO `order_items` VALUES (715,520,11,1,39,0.05);

INSERT INTO `order_items` VALUES (716,520,12,1,79,0);

INSERT INTO `order_items` VALUES (717,520,14,1,39.9,0);

INSERT INTO `order_items` VALUES (718,521,20,1,39,0.05);

INSERT INTO `order_items` VALUES (719,522,20,1,39,0);

INSERT INTO `order_items` VALUES (720,523,4,1,59,0);

INSERT INTO `order_items` VALUES (721,524,15,1,32.9,0);

INSERT INTO `order_items` VALUES (722,525,2,1,899,0);

INSERT INTO `order_items` VALUES (723,525,16,2,24.9,0);

INSERT INTO `order_items` VALUES (724,525,18,1,159,0);

INSERT INTO `order_items` VALUES (725,526,4,2,59,0);

INSERT INTO `order_items` VALUES (726,527,15,1,32.9,0);

INSERT INTO `order_items` VALUES (727,528,16,1,24.9,0);

INSERT INTO `order_items` VALUES (728,528,18,1,159,0);

INSERT INTO `order_items` VALUES (729,529,3,1,169,0);

INSERT INTO `order_items` VALUES (730,529,9,1,129,0.05);

INSERT INTO `order_items` VALUES (731,530,11,1,39,0);

INSERT INTO `order_items` VALUES (732,530,12,2,79,0.05);

INSERT INTO `order_items` VALUES (733,531,11,1,39,0);

INSERT INTO `order_items` VALUES (734,532,11,2,39,0.05);

INSERT INTO `order_items` VALUES (735,533,7,1,89,0);

INSERT INTO `order_items` VALUES (736,533,18,1,159,0);

INSERT INTO `order_items` VALUES (737,534,4,1,59,0);

INSERT INTO `order_items` VALUES (738,535,11,2,39,0);

INSERT INTO `order_items` VALUES (739,536,16,2,24.9,0);

INSERT INTO `order_items` VALUES (740,537,14,1,39.9,0);

INSERT INTO `order_items` VALUES (741,537,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (742,537,17,1,69,0);

INSERT INTO `order_items` VALUES (743,538,7,1,89,0);

INSERT INTO `order_items` VALUES (744,539,11,1,39,0.10);

INSERT INTO `order_items` VALUES (745,539,14,1,39.9,0);

INSERT INTO `order_items` VALUES (746,540,16,1,24.9,0);

INSERT INTO `order_items` VALUES (747,541,4,1,59,0.05);

INSERT INTO `order_items` VALUES (748,542,13,3,68,0);

INSERT INTO `order_items` VALUES (749,542,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (750,543,12,1,79,0);

INSERT INTO `order_items` VALUES (751,544,12,2,79,0);

INSERT INTO `order_items` VALUES (752,545,16,1,24.9,0);

INSERT INTO `order_items` VALUES (753,545,20,1,39,0);

INSERT INTO `order_items` VALUES (754,546,11,3,39,0);

INSERT INTO `order_items` VALUES (755,546,14,1,39.9,0);

INSERT INTO `order_items` VALUES (756,546,15,1,32.9,0);

INSERT INTO `order_items` VALUES (757,547,4,1,59,0);

INSERT INTO `order_items` VALUES (758,547,11,1,39,0);

INSERT INTO `order_items` VALUES (759,547,13,1,68,0);

INSERT INTO `order_items` VALUES (760,548,11,1,39,0);

INSERT INTO `order_items` VALUES (761,549,9,1,129,0);

INSERT INTO `order_items` VALUES (762,549,16,1,24.9,0);

INSERT INTO `order_items` VALUES (763,550,16,1,24.9,0);

INSERT INTO `order_items` VALUES (764,551,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (765,552,4,1,59,0);

INSERT INTO `order_items` VALUES (766,553,15,1,32.9,0);

INSERT INTO `order_items` VALUES (767,553,17,1,69,0.05);

INSERT INTO `order_items` VALUES (768,554,13,2,68,0);

INSERT INTO `order_items` VALUES (769,555,14,1,39.9,0);

INSERT INTO `order_items` VALUES (770,556,4,1,59,0);

INSERT INTO `order_items` VALUES (771,556,11,1,39,0);

INSERT INTO `order_items` VALUES (772,556,13,1,68,0);

INSERT INTO `order_items` VALUES (773,557,14,2,39.9,0);

INSERT INTO `order_items` VALUES (774,557,18,1,159,0);

INSERT INTO `order_items` VALUES (775,558,12,1,79,0);

INSERT INTO `order_items` VALUES (776,559,11,1,39,0);

INSERT INTO `order_items` VALUES (777,560,11,1,39,0);

INSERT INTO `order_items` VALUES (778,560,12,1,79,0.05);

INSERT INTO `order_items` VALUES (779,561,3,1,169,0.05);

INSERT INTO `order_items` VALUES (780,562,14,1,39.9,0);

INSERT INTO `order_items` VALUES (781,563,11,1,39,0);

INSERT INTO `order_items` VALUES (782,563,13,1,68,0);

INSERT INTO `order_items` VALUES (783,563,20,2,39,0);

INSERT INTO `order_items` VALUES (784,564,11,1,39,0);

INSERT INTO `order_items` VALUES (785,565,12,1,79,0);

INSERT INTO `order_items` VALUES (786,566,12,2,79,0.05);

INSERT INTO `order_items` VALUES (787,567,4,1,59,0);

INSERT INTO `order_items` VALUES (788,567,11,1,39,0);

INSERT INTO `order_items` VALUES (789,568,8,1,159,0.05);

INSERT INTO `order_items` VALUES (790,569,5,1,399,0);

INSERT INTO `order_items` VALUES (791,570,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (792,571,16,2,24.9,0);

INSERT INTO `order_items` VALUES (793,572,13,1,68,0);

INSERT INTO `order_items` VALUES (794,572,14,2,39.9,0);

INSERT INTO `order_items` VALUES (795,573,6,1,299,0);

INSERT INTO `order_items` VALUES (796,574,13,1,68,0.05);

INSERT INTO `order_items` VALUES (797,575,11,1,39,0);

INSERT INTO `order_items` VALUES (798,575,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (799,576,16,1,24.9,0);

INSERT INTO `order_items` VALUES (800,577,11,1,39,0);

INSERT INTO `order_items` VALUES (801,577,15,1,32.9,0);

INSERT INTO `order_items` VALUES (802,578,14,1,39.9,0);

INSERT INTO `order_items` VALUES (803,579,4,1,59,0);

INSERT INTO `order_items` VALUES (804,580,4,1,59,0);

INSERT INTO `order_items` VALUES (805,581,12,1,79,0);

INSERT INTO `order_items` VALUES (806,582,11,2,39,0);

INSERT INTO `order_items` VALUES (807,582,13,1,68,0);

INSERT INTO `order_items` VALUES (808,583,18,1,159,0);

INSERT INTO `order_items` VALUES (809,584,4,1,59,0);

INSERT INTO `order_items` VALUES (810,584,7,1,89,0);

INSERT INTO `order_items` VALUES (811,585,18,1,159,0);

INSERT INTO `order_items` VALUES (812,586,14,1,39.9,0);

INSERT INTO `order_items` VALUES (813,586,15,1,32.9,0);

INSERT INTO `order_items` VALUES (814,587,14,1,39.9,0);

INSERT INTO `order_items` VALUES (815,587,20,1,39,0);

INSERT INTO `order_items` VALUES (816,588,9,1,129,0);

INSERT INTO `order_items` VALUES (817,589,7,1,89,0);

INSERT INTO `order_items` VALUES (818,590,18,1,159,0);

INSERT INTO `order_items` VALUES (819,591,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (820,592,14,1,39.9,0);

INSERT INTO `order_items` VALUES (821,592,16,1,24.9,0);

INSERT INTO `order_items` VALUES (822,593,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (823,594,15,1,32.9,0);

INSERT INTO `order_items` VALUES (824,594,16,2,24.9,0);

INSERT INTO `order_items` VALUES (825,595,12,2,79,0);

INSERT INTO `order_items` VALUES (826,596,7,1,89,0.05);

INSERT INTO `order_items` VALUES (827,597,11,1,39,0.05);

INSERT INTO `order_items` VALUES (828,598,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (829,599,13,2,68,0);

INSERT INTO `order_items` VALUES (830,599,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (831,600,4,1,59,0);

INSERT INTO `order_items` VALUES (832,601,14,3,39.9,0);

INSERT INTO `order_items` VALUES (833,602,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (834,603,17,1,69,0);

INSERT INTO `order_items` VALUES (835,604,13,1,68,0);

INSERT INTO `order_items` VALUES (836,605,9,1,129,0);

INSERT INTO `order_items` VALUES (837,605,13,1,68,0);

INSERT INTO `order_items` VALUES (838,605,17,1,69,0);

INSERT INTO `order_items` VALUES (839,606,20,1,39,0);

INSERT INTO `order_items` VALUES (840,607,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (841,608,4,1,59,0.10);

INSERT INTO `order_items` VALUES (842,609,16,2,24.9,0);

INSERT INTO `order_items` VALUES (843,610,13,1,68,0.05);

INSERT INTO `order_items` VALUES (844,611,11,1,39,0);

INSERT INTO `order_items` VALUES (845,612,6,1,299,0);

INSERT INTO `order_items` VALUES (846,613,9,2,129,0);

INSERT INTO `order_items` VALUES (847,613,12,1,79,0);

INSERT INTO `order_items` VALUES (848,614,13,1,68,0);

INSERT INTO `order_items` VALUES (849,615,14,2,39.9,0);

INSERT INTO `order_items` VALUES (850,616,5,1,399,0.05);

INSERT INTO `order_items` VALUES (851,617,14,1,39.9,0);

INSERT INTO `order_items` VALUES (852,618,11,3,39,0);

INSERT INTO `order_items` VALUES (853,619,3,1,169,0);

INSERT INTO `order_items` VALUES (854,619,20,1,39,0);

INSERT INTO `order_items` VALUES (855,620,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (856,621,7,1,89,0.05);

INSERT INTO `order_items` VALUES (857,621,11,1,39,0);

INSERT INTO `order_items` VALUES (858,622,7,1,89,0);

INSERT INTO `order_items` VALUES (859,622,13,1,68,0);

INSERT INTO `order_items` VALUES (860,623,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (861,624,11,2,39,0);

INSERT INTO `order_items` VALUES (862,625,16,1,24.9,0);

INSERT INTO `order_items` VALUES (863,626,4,1,59,0);

INSERT INTO `order_items` VALUES (864,627,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (865,628,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (866,629,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (867,629,16,1,24.9,0);

INSERT INTO `order_items` VALUES (868,630,5,1,399,0);

INSERT INTO `order_items` VALUES (869,631,15,1,32.9,0);

INSERT INTO `order_items` VALUES (870,632,15,1,32.9,0);

INSERT INTO `order_items` VALUES (871,633,4,1,59,0);

INSERT INTO `order_items` VALUES (872,633,12,1,79,0);

INSERT INTO `order_items` VALUES (873,634,15,1,32.9,0);

INSERT INTO `order_items` VALUES (874,634,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (875,635,16,1,24.9,0);

INSERT INTO `order_items` VALUES (876,636,13,1,68,0.05);

INSERT INTO `order_items` VALUES (877,636,14,1,39.9,0);

INSERT INTO `order_items` VALUES (878,637,5,1,399,0);

INSERT INTO `order_items` VALUES (879,637,11,1,39,0);

INSERT INTO `order_items` VALUES (880,638,2,1,899,0.10);

INSERT INTO `order_items` VALUES (881,639,18,1,159,0);

INSERT INTO `order_items` VALUES (882,640,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (883,641,11,2,39,0);

INSERT INTO `order_items` VALUES (884,641,16,1,24.9,0);

INSERT INTO `order_items` VALUES (885,642,5,1,399,0);

INSERT INTO `order_items` VALUES (886,642,20,1,39,0.05);

INSERT INTO `order_items` VALUES (887,643,3,1,169,0);

INSERT INTO `order_items` VALUES (888,644,4,1,59,0);

INSERT INTO `order_items` VALUES (889,644,15,1,32.9,0);

INSERT INTO `order_items` VALUES (890,645,12,1,79,0);

INSERT INTO `order_items` VALUES (891,646,17,2,69,0);

INSERT INTO `order_items` VALUES (892,647,4,1,59,0);

INSERT INTO `order_items` VALUES (893,647,6,1,299,0.10);

INSERT INTO `order_items` VALUES (894,647,18,1,159,0);

INSERT INTO `order_items` VALUES (895,648,4,1,59,0);

INSERT INTO `order_items` VALUES (896,648,11,2,39,0);

INSERT INTO `order_items` VALUES (897,649,13,1,68,0);

INSERT INTO `order_items` VALUES (898,650,4,1,59,0);

INSERT INTO `order_items` VALUES (899,651,14,1,39.9,0);

INSERT INTO `order_items` VALUES (900,651,15,1,32.9,0);

INSERT INTO `order_items` VALUES (901,652,3,1,169,0);

INSERT INTO `order_items` VALUES (902,652,17,1,69,0);

INSERT INTO `order_items` VALUES (903,653,13,1,68,0);

INSERT INTO `order_items` VALUES (904,654,15,1,32.9,0);

INSERT INTO `order_items` VALUES (905,655,13,1,68,0);

INSERT INTO `order_items` VALUES (906,655,16,1,24.9,0);

INSERT INTO `order_items` VALUES (907,656,3,1,169,0.10);

INSERT INTO `order_items` VALUES (908,656,9,1,129,0);

INSERT INTO `order_items` VALUES (909,656,11,1,39,0);

INSERT INTO `order_items` VALUES (910,657,17,1,69,0);

INSERT INTO `order_items` VALUES (911,658,13,1,68,0);

INSERT INTO `order_items` VALUES (912,658,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (913,659,16,1,24.9,0);

INSERT INTO `order_items` VALUES (914,660,14,1,39.9,0);

INSERT INTO `order_items` VALUES (915,661,17,1,69,0.05);

INSERT INTO `order_items` VALUES (916,662,11,1,39,0);

INSERT INTO `order_items` VALUES (917,663,15,1,32.9,0);

INSERT INTO `order_items` VALUES (918,664,12,1,79,0);

INSERT INTO `order_items` VALUES (919,665,15,3,32.9,0);

INSERT INTO `order_items` VALUES (920,666,14,2,39.9,0);

INSERT INTO `order_items` VALUES (921,666,15,1,32.9,0);

INSERT INTO `order_items` VALUES (922,666,17,1,69,0);

INSERT INTO `order_items` VALUES (923,667,20,1,39,0.05);

INSERT INTO `order_items` VALUES (924,668,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (925,669,5,2,399,0);

INSERT INTO `order_items` VALUES (926,669,13,1,68,0.05);

INSERT INTO `order_items` VALUES (927,670,13,1,68,0);

INSERT INTO `order_items` VALUES (928,671,17,2,69,0);

INSERT INTO `order_items` VALUES (929,672,12,1,79,0);

INSERT INTO `order_items` VALUES (930,672,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (931,673,11,1,39,0);

INSERT INTO `order_items` VALUES (932,673,15,1,32.9,0);

INSERT INTO `order_items` VALUES (933,674,3,1,169,0.05);

INSERT INTO `order_items` VALUES (934,675,7,1,89,0);

INSERT INTO `order_items` VALUES (935,675,14,1,39.9,0);

INSERT INTO `order_items` VALUES (936,676,14,2,39.9,0);

INSERT INTO `order_items` VALUES (937,677,5,2,399,0.05);

INSERT INTO `order_items` VALUES (938,678,11,1,39,0);

INSERT INTO `order_items` VALUES (939,679,16,1,24.9,0);

INSERT INTO `order_items` VALUES (940,680,14,1,39.9,0);

INSERT INTO `order_items` VALUES (941,681,4,1,59,0.05);

INSERT INTO `order_items` VALUES (942,681,5,1,399,0);

INSERT INTO `order_items` VALUES (943,682,4,2,59,0);

INSERT INTO `order_items` VALUES (944,683,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (945,683,15,2,32.9,0);

INSERT INTO `order_items` VALUES (946,684,4,1,59,0);

INSERT INTO `order_items` VALUES (947,684,13,1,68,0);

INSERT INTO `order_items` VALUES (948,684,14,1,39.9,0);

INSERT INTO `order_items` VALUES (949,685,4,1,59,0.05);

INSERT INTO `order_items` VALUES (950,686,14,1,39.9,0);

INSERT INTO `order_items` VALUES (951,686,18,1,159,0);

INSERT INTO `order_items` VALUES (952,687,11,1,39,0);

INSERT INTO `order_items` VALUES (953,688,7,1,89,0);

INSERT INTO `order_items` VALUES (954,688,11,2,39,0);

INSERT INTO `order_items` VALUES (955,689,13,1,68,0);

INSERT INTO `order_items` VALUES (956,690,11,1,39,0);

INSERT INTO `order_items` VALUES (957,691,15,1,32.9,0);

INSERT INTO `order_items` VALUES (958,692,11,1,39,0);

INSERT INTO `order_items` VALUES (959,693,17,2,69,0);

INSERT INTO `order_items` VALUES (960,694,17,1,69,0);

INSERT INTO `order_items` VALUES (961,695,7,1,89,0);

INSERT INTO `order_items` VALUES (962,695,20,1,39,0);

INSERT INTO `order_items` VALUES (963,696,20,3,39,0.05);

INSERT INTO `order_items` VALUES (964,697,13,2,68,0);

INSERT INTO `order_items` VALUES (965,698,8,1,159,0);

INSERT INTO `order_items` VALUES (966,698,12,1,79,0);

INSERT INTO `order_items` VALUES (967,698,14,1,39.9,0);

INSERT INTO `order_items` VALUES (968,699,14,1,39.9,0);

INSERT INTO `order_items` VALUES (969,700,4,1,59,0);

INSERT INTO `order_items` VALUES (970,700,12,1,79,0);

INSERT INTO `order_items` VALUES (971,700,14,1,39.9,0);

INSERT INTO `order_items` VALUES (972,701,16,1,24.9,0);

INSERT INTO `order_items` VALUES (973,701,17,1,69,0);

INSERT INTO `order_items` VALUES (974,701,19,1,199,0.05);

INSERT INTO `order_items` VALUES (975,702,20,2,39,0);

INSERT INTO `order_items` VALUES (976,703,4,1,59,0);

INSERT INTO `order_items` VALUES (977,704,4,2,59,0.05);

INSERT INTO `order_items` VALUES (978,705,20,1,39,0);

INSERT INTO `order_items` VALUES (979,706,4,1,59,0);

INSERT INTO `order_items` VALUES (980,707,6,1,299,0);

INSERT INTO `order_items` VALUES (981,708,9,1,129,0.10);

INSERT INTO `order_items` VALUES (982,709,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (983,710,11,1,39,0);

INSERT INTO `order_items` VALUES (984,711,14,1,39.9,0);

INSERT INTO `order_items` VALUES (985,712,13,2,68,0);

INSERT INTO `order_items` VALUES (986,712,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (987,713,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (988,713,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (989,713,20,1,39,0);

INSERT INTO `order_items` VALUES (990,714,13,2,68,0.10);

INSERT INTO `order_items` VALUES (991,714,20,1,39,0);

INSERT INTO `order_items` VALUES (992,715,7,2,89,0);

INSERT INTO `order_items` VALUES (993,715,13,1,68,0);

INSERT INTO `order_items` VALUES (994,715,14,1,39.9,0);

INSERT INTO `order_items` VALUES (995,716,12,1,79,0);

INSERT INTO `order_items` VALUES (996,716,20,1,39,0);

INSERT INTO `order_items` VALUES (997,717,13,1,68,0);

INSERT INTO `order_items` VALUES (998,718,13,1,68,0);

INSERT INTO `order_items` VALUES (999,718,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1000,718,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1001,719,6,1,299,0);

INSERT INTO `order_items` VALUES (1002,719,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (1003,720,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1004,721,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1005,721,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1006,722,8,1,159,0.10);

INSERT INTO `order_items` VALUES (1007,723,4,1,59,0);

INSERT INTO `order_items` VALUES (1008,723,17,1,69,0);

INSERT INTO `order_items` VALUES (1009,724,12,1,79,0.10);

INSERT INTO `order_items` VALUES (1010,725,13,1,68,0);

INSERT INTO `order_items` VALUES (1011,726,15,3,32.9,0);

INSERT INTO `order_items` VALUES (1012,727,2,1,899,0);

INSERT INTO `order_items` VALUES (1013,727,12,1,79,0);

INSERT INTO `order_items` VALUES (1014,728,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1015,728,11,1,39,0);

INSERT INTO `order_items` VALUES (1016,729,18,1,159,0);

INSERT INTO `order_items` VALUES (1017,729,20,1,39,0);

INSERT INTO `order_items` VALUES (1018,730,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1019,730,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1020,731,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1021,732,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1022,733,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1023,734,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1024,734,20,1,39,0);

INSERT INTO `order_items` VALUES (1025,735,15,3,32.9,0);

INSERT INTO `order_items` VALUES (1026,735,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1027,736,13,1,68,0);

INSERT INTO `order_items` VALUES (1028,736,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1029,737,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1030,738,19,1,199,0.05);

INSERT INTO `order_items` VALUES (1031,739,4,1,59,0);

INSERT INTO `order_items` VALUES (1032,740,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1033,741,3,3,169,0.05);

INSERT INTO `order_items` VALUES (1034,741,11,1,39,0);

INSERT INTO `order_items` VALUES (1035,741,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1036,742,12,1,79,0);

INSERT INTO `order_items` VALUES (1037,743,4,1,59,0);

INSERT INTO `order_items` VALUES (1038,744,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1039,745,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1040,746,6,1,299,0);

INSERT INTO `order_items` VALUES (1041,746,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1042,747,12,1,79,0);

INSERT INTO `order_items` VALUES (1043,747,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1044,748,13,1,68,0);

INSERT INTO `order_items` VALUES (1045,748,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (1046,749,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1047,749,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1048,750,20,1,39,0);

INSERT INTO `order_items` VALUES (1049,751,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1050,752,4,1,59,0);

INSERT INTO `order_items` VALUES (1051,752,11,1,39,0);

INSERT INTO `order_items` VALUES (1052,753,11,1,39,0);

INSERT INTO `order_items` VALUES (1053,754,7,1,89,0);

INSERT INTO `order_items` VALUES (1054,755,20,1,39,0);

INSERT INTO `order_items` VALUES (1055,756,3,1,169,0);

INSERT INTO `order_items` VALUES (1056,756,8,1,159,0);

INSERT INTO `order_items` VALUES (1057,757,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1058,758,11,2,39,0);

INSERT INTO `order_items` VALUES (1059,759,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1060,760,12,1,79,0);

INSERT INTO `order_items` VALUES (1061,760,13,1,68,0);

INSERT INTO `order_items` VALUES (1062,761,6,1,299,0);

INSERT INTO `order_items` VALUES (1063,762,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1064,763,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1065,764,20,1,39,0);

INSERT INTO `order_items` VALUES (1066,765,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1067,766,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1068,767,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1069,768,4,2,59,0);

INSERT INTO `order_items` VALUES (1070,769,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (1071,770,4,1,59,0);

INSERT INTO `order_items` VALUES (1072,770,7,1,89,0);

INSERT INTO `order_items` VALUES (1073,771,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1074,772,9,1,129,0);

INSERT INTO `order_items` VALUES (1075,773,19,1,199,0);

INSERT INTO `order_items` VALUES (1076,774,12,1,79,0);

INSERT INTO `order_items` VALUES (1077,774,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1078,774,19,1,199,0);

INSERT INTO `order_items` VALUES (1079,775,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1080,776,17,2,69,0.05);

INSERT INTO `order_items` VALUES (1081,777,3,1,169,0);

INSERT INTO `order_items` VALUES (1082,777,20,1,39,0);

INSERT INTO `order_items` VALUES (1083,778,6,1,299,0);

INSERT INTO `order_items` VALUES (1084,779,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1085,780,13,1,68,0);

INSERT INTO `order_items` VALUES (1086,781,20,1,39,0);

INSERT INTO `order_items` VALUES (1087,782,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1088,782,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1089,783,11,1,39,0);

INSERT INTO `order_items` VALUES (1090,784,17,1,69,0);

INSERT INTO `order_items` VALUES (1091,785,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1092,786,11,2,39,0);

INSERT INTO `order_items` VALUES (1093,786,13,1,68,0.10);

INSERT INTO `order_items` VALUES (1094,787,4,1,59,0);

INSERT INTO `order_items` VALUES (1095,787,7,1,89,0);

INSERT INTO `order_items` VALUES (1096,787,19,1,199,0);

INSERT INTO `order_items` VALUES (1097,788,12,1,79,0);

INSERT INTO `order_items` VALUES (1098,789,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1099,790,7,1,89,0);

INSERT INTO `order_items` VALUES (1100,790,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1101,790,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1102,791,4,1,59,0);

INSERT INTO `order_items` VALUES (1103,792,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1104,792,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1105,792,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1106,793,8,1,159,0);

INSERT INTO `order_items` VALUES (1107,794,13,1,68,0);

INSERT INTO `order_items` VALUES (1108,795,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1109,796,12,1,79,0);

INSERT INTO `order_items` VALUES (1110,797,17,1,69,0);

INSERT INTO `order_items` VALUES (1111,798,2,2,899,0);

INSERT INTO `order_items` VALUES (1112,798,7,1,89,0);

INSERT INTO `order_items` VALUES (1113,798,17,1,69,0);

INSERT INTO `order_items` VALUES (1114,799,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1115,800,13,1,68,0);

INSERT INTO `order_items` VALUES (1116,800,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1117,801,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1118,802,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1119,802,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1120,803,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1121,803,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1122,804,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1123,805,13,1,68,0);

INSERT INTO `order_items` VALUES (1124,806,4,1,59,0);

INSERT INTO `order_items` VALUES (1125,807,9,1,129,0);

INSERT INTO `order_items` VALUES (1126,808,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1127,809,7,2,89,0);

INSERT INTO `order_items` VALUES (1128,810,12,1,79,0);

INSERT INTO `order_items` VALUES (1129,811,11,1,39,0.10);

INSERT INTO `order_items` VALUES (1130,812,8,1,159,0);

INSERT INTO `order_items` VALUES (1131,813,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1132,813,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1133,814,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1134,815,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1135,815,17,1,69,0);

INSERT INTO `order_items` VALUES (1136,816,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1137,817,11,1,39,0);

INSERT INTO `order_items` VALUES (1138,818,8,1,159,0);

INSERT INTO `order_items` VALUES (1139,818,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1140,819,8,1,159,0);

INSERT INTO `order_items` VALUES (1141,820,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1142,821,4,2,59,0);

INSERT INTO `order_items` VALUES (1143,822,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1144,822,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1145,823,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1146,824,5,1,399,0);

INSERT INTO `order_items` VALUES (1147,825,3,2,169,0);

INSERT INTO `order_items` VALUES (1148,826,5,1,399,0);

INSERT INTO `order_items` VALUES (1149,827,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1150,827,20,1,39,0);

INSERT INTO `order_items` VALUES (1151,828,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1152,829,10,1,699,0.05);

INSERT INTO `order_items` VALUES (1153,829,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1154,830,20,1,39,0);

INSERT INTO `order_items` VALUES (1155,831,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1156,832,13,1,68,0);

INSERT INTO `order_items` VALUES (1157,833,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1158,834,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1159,835,12,2,79,0);

INSERT INTO `order_items` VALUES (1160,835,17,2,69,0);

INSERT INTO `order_items` VALUES (1161,836,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1162,836,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1163,837,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1164,837,17,1,69,0.10);

INSERT INTO `order_items` VALUES (1165,838,7,1,89,0.10);

INSERT INTO `order_items` VALUES (1166,838,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1167,839,4,3,59,0);

INSERT INTO `order_items` VALUES (1168,840,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1169,840,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1170,840,20,1,39,0);

INSERT INTO `order_items` VALUES (1171,841,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1172,841,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1173,842,11,1,39,0);

INSERT INTO `order_items` VALUES (1174,843,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1175,843,19,1,199,0);

INSERT INTO `order_items` VALUES (1176,844,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1177,845,11,2,39,0.05);

INSERT INTO `order_items` VALUES (1178,846,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1179,847,12,3,79,0);

INSERT INTO `order_items` VALUES (1180,848,9,1,129,0);

INSERT INTO `order_items` VALUES (1181,848,13,2,68,0.05);

INSERT INTO `order_items` VALUES (1182,849,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1183,850,20,1,39,0);

INSERT INTO `order_items` VALUES (1184,851,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1185,851,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1186,852,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1187,852,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1188,853,18,1,159,0);

INSERT INTO `order_items` VALUES (1189,854,7,1,89,0);

INSERT INTO `order_items` VALUES (1190,855,5,2,399,0);

INSERT INTO `order_items` VALUES (1191,856,11,1,39,0);

INSERT INTO `order_items` VALUES (1192,857,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1193,858,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1194,859,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1195,860,3,1,169,0);

INSERT INTO `order_items` VALUES (1196,860,10,1,699,0.10);

INSERT INTO `order_items` VALUES (1197,860,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1198,861,11,1,39,0);

INSERT INTO `order_items` VALUES (1199,861,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1200,862,5,1,399,0);

INSERT INTO `order_items` VALUES (1201,862,13,2,68,0);

INSERT INTO `order_items` VALUES (1202,863,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1203,864,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1204,865,12,1,79,0);

INSERT INTO `order_items` VALUES (1205,865,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1206,866,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (1207,867,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1208,868,3,3,169,0);

INSERT INTO `order_items` VALUES (1209,868,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1210,869,6,3,299,0);

INSERT INTO `order_items` VALUES (1211,870,3,1,169,0);

INSERT INTO `order_items` VALUES (1212,870,8,1,159,0);

INSERT INTO `order_items` VALUES (1213,870,11,1,39,0);

INSERT INTO `order_items` VALUES (1214,871,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1215,872,11,1,39,0);

INSERT INTO `order_items` VALUES (1216,873,7,1,89,0);

INSERT INTO `order_items` VALUES (1217,873,13,2,68,0);

INSERT INTO `order_items` VALUES (1218,874,12,1,79,0);

INSERT INTO `order_items` VALUES (1219,874,20,1,39,0);

INSERT INTO `order_items` VALUES (1220,875,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1221,875,20,1,39,0);

INSERT INTO `order_items` VALUES (1222,876,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1223,876,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1224,876,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1225,877,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1226,878,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1227,879,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1228,880,7,2,89,0.10);

INSERT INTO `order_items` VALUES (1229,881,4,1,59,0);

INSERT INTO `order_items` VALUES (1230,882,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1231,882,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1232,883,7,1,89,0);

INSERT INTO `order_items` VALUES (1233,883,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1234,884,19,1,199,0);

INSERT INTO `order_items` VALUES (1235,885,12,1,79,0);

INSERT INTO `order_items` VALUES (1236,885,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1237,886,13,1,68,0);

INSERT INTO `order_items` VALUES (1238,886,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1239,886,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1240,887,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1241,887,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1242,888,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1243,889,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1244,889,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1245,889,20,1,39,0);

INSERT INTO `order_items` VALUES (1246,890,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1247,891,10,1,699,0.05);

INSERT INTO `order_items` VALUES (1248,892,6,1,299,0.10);

INSERT INTO `order_items` VALUES (1249,893,13,1,68,0);

INSERT INTO `order_items` VALUES (1250,894,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1251,895,12,1,79,0);

INSERT INTO `order_items` VALUES (1252,896,17,1,69,0);

INSERT INTO `order_items` VALUES (1253,897,3,1,169,0);

INSERT INTO `order_items` VALUES (1254,897,4,2,59,0.05);

INSERT INTO `order_items` VALUES (1255,898,13,1,68,0);

INSERT INTO `order_items` VALUES (1256,898,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1257,899,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1258,899,17,1,69,0);

INSERT INTO `order_items` VALUES (1259,900,4,1,59,0);

INSERT INTO `order_items` VALUES (1260,901,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1261,902,3,1,169,0);

INSERT INTO `order_items` VALUES (1262,902,12,1,79,0);

INSERT INTO `order_items` VALUES (1263,902,13,1,68,0);

INSERT INTO `order_items` VALUES (1264,903,11,2,39,0);

INSERT INTO `order_items` VALUES (1265,903,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1266,903,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1267,904,4,1,59,0.10);

INSERT INTO `order_items` VALUES (1268,905,18,1,159,0.05);

INSERT INTO `order_items` VALUES (1269,906,13,1,68,0);

INSERT INTO `order_items` VALUES (1270,907,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1271,907,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1272,908,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1273,909,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1274,910,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1275,911,13,1,68,0);

INSERT INTO `order_items` VALUES (1276,912,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1277,913,11,1,39,0);

INSERT INTO `order_items` VALUES (1278,913,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1279,914,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1280,914,20,1,39,0);

INSERT INTO `order_items` VALUES (1281,915,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1282,915,11,1,39,0);

INSERT INTO `order_items` VALUES (1283,916,7,1,89,0);

INSERT INTO `order_items` VALUES (1284,916,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1285,917,4,1,59,0);

INSERT INTO `order_items` VALUES (1286,917,7,1,89,0.10);

INSERT INTO `order_items` VALUES (1287,918,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1288,918,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1289,918,20,2,39,0);

INSERT INTO `order_items` VALUES (1290,919,7,1,89,0);

INSERT INTO `order_items` VALUES (1291,919,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1292,920,11,1,39,0);

INSERT INTO `order_items` VALUES (1293,921,19,1,199,0);

INSERT INTO `order_items` VALUES (1294,922,4,1,59,0);

INSERT INTO `order_items` VALUES (1295,923,11,2,39,0);

INSERT INTO `order_items` VALUES (1296,923,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1297,923,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1298,924,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1299,925,17,1,69,0);

INSERT INTO `order_items` VALUES (1300,926,13,1,68,0);

INSERT INTO `order_items` VALUES (1301,927,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1302,928,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1303,928,17,1,69,0);

INSERT INTO `order_items` VALUES (1304,929,5,1,399,0.10);

INSERT INTO `order_items` VALUES (1305,930,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1306,931,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1307,931,10,1,699,0);

INSERT INTO `order_items` VALUES (1308,932,12,1,79,0.10);

INSERT INTO `order_items` VALUES (1309,933,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1310,934,13,1,68,0);

INSERT INTO `order_items` VALUES (1311,935,20,1,39,0);

INSERT INTO `order_items` VALUES (1312,936,4,1,59,0);

INSERT INTO `order_items` VALUES (1313,937,13,1,68,0);

INSERT INTO `order_items` VALUES (1314,938,9,1,129,0);

INSERT INTO `order_items` VALUES (1315,938,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1316,939,18,1,159,0);

INSERT INTO `order_items` VALUES (1317,940,5,1,399,0);

INSERT INTO `order_items` VALUES (1318,940,11,1,39,0);

INSERT INTO `order_items` VALUES (1319,941,13,2,68,0.10);

INSERT INTO `order_items` VALUES (1320,942,20,2,39,0);

INSERT INTO `order_items` VALUES (1321,943,13,2,68,0);

INSERT INTO `order_items` VALUES (1322,944,4,1,59,0);

INSERT INTO `order_items` VALUES (1323,944,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1324,944,19,1,199,0);

INSERT INTO `order_items` VALUES (1325,945,4,1,59,0);

INSERT INTO `order_items` VALUES (1326,946,1,1,4299,0.05);

INSERT INTO `order_items` VALUES (1327,947,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1328,948,4,2,59,0.10);

INSERT INTO `order_items` VALUES (1329,949,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1330,950,6,1,299,0);

INSERT INTO `order_items` VALUES (1331,950,13,1,68,0);

INSERT INTO `order_items` VALUES (1332,951,11,1,39,0);

INSERT INTO `order_items` VALUES (1333,952,13,2,68,0);

INSERT INTO `order_items` VALUES (1334,953,11,1,39,0);

INSERT INTO `order_items` VALUES (1335,954,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1336,954,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (1337,955,4,1,59,0);

INSERT INTO `order_items` VALUES (1338,955,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1339,956,4,1,59,0);

INSERT INTO `order_items` VALUES (1340,956,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1341,956,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1342,957,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1343,957,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1344,957,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1345,958,7,1,89,0);

INSERT INTO `order_items` VALUES (1346,959,7,1,89,0);

INSERT INTO `order_items` VALUES (1347,960,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1348,961,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1349,962,11,1,39,0);

INSERT INTO `order_items` VALUES (1350,963,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1351,963,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (1352,964,13,1,68,0);

INSERT INTO `order_items` VALUES (1353,965,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1354,965,15,3,32.9,0);

INSERT INTO `order_items` VALUES (1355,965,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1356,966,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1357,966,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1358,967,12,2,79,0);

INSERT INTO `order_items` VALUES (1359,968,9,1,129,0);

INSERT INTO `order_items` VALUES (1360,969,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1361,969,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (1362,970,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1363,971,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1364,972,3,1,169,0);

INSERT INTO `order_items` VALUES (1365,973,9,1,129,0);

INSERT INTO `order_items` VALUES (1366,974,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1367,975,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1368,976,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1369,977,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1370,978,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1371,979,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1372,980,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1373,981,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1374,981,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1375,982,3,3,169,0);

INSERT INTO `order_items` VALUES (1376,982,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1377,982,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1378,983,6,1,299,0);

INSERT INTO `order_items` VALUES (1379,983,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1380,984,4,3,59,0);

INSERT INTO `order_items` VALUES (1381,985,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1382,986,4,1,59,0);

INSERT INTO `order_items` VALUES (1383,987,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1384,988,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1385,989,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1386,989,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1387,990,20,3,39,0);

INSERT INTO `order_items` VALUES (1388,991,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1389,991,20,1,39,0);

INSERT INTO `order_items` VALUES (1390,992,13,1,68,0);

INSERT INTO `order_items` VALUES (1391,992,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1392,993,4,1,59,0);

INSERT INTO `order_items` VALUES (1393,993,13,1,68,0);

INSERT INTO `order_items` VALUES (1394,994,4,1,59,0);

INSERT INTO `order_items` VALUES (1395,994,11,2,39,0);

INSERT INTO `order_items` VALUES (1396,995,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1397,996,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1398,997,3,1,169,0);

INSERT INTO `order_items` VALUES (1399,998,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1400,999,4,1,59,0);

INSERT INTO `order_items` VALUES (1401,999,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1402,1000,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1403,1000,19,1,199,0);

INSERT INTO `order_items` VALUES (1404,1001,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1405,1001,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1406,1002,6,1,299,0);

INSERT INTO `order_items` VALUES (1407,1003,17,1,69,0);

INSERT INTO `order_items` VALUES (1408,1004,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1409,1005,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1410,1006,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1411,1007,7,2,89,0);

INSERT INTO `order_items` VALUES (1412,1007,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1413,1007,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1414,1008,13,1,68,0.10);

INSERT INTO `order_items` VALUES (1415,1008,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1416,1009,5,1,399,0);

INSERT INTO `order_items` VALUES (1417,1009,20,1,39,0);

INSERT INTO `order_items` VALUES (1418,1010,11,1,39,0);

INSERT INTO `order_items` VALUES (1419,1010,13,2,68,0);

INSERT INTO `order_items` VALUES (1420,1010,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1421,1011,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1422,1012,12,1,79,0);

INSERT INTO `order_items` VALUES (1423,1012,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1424,1013,5,1,399,0);

INSERT INTO `order_items` VALUES (1425,1014,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1426,1015,7,1,89,0.10);

INSERT INTO `order_items` VALUES (1427,1016,12,1,79,0);

INSERT INTO `order_items` VALUES (1428,1017,19,1,199,0);

INSERT INTO `order_items` VALUES (1429,1018,20,1,39,0);

INSERT INTO `order_items` VALUES (1430,1019,11,2,39,0);

INSERT INTO `order_items` VALUES (1431,1020,7,1,89,0);

INSERT INTO `order_items` VALUES (1432,1021,11,1,39,0);

INSERT INTO `order_items` VALUES (1433,1022,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1434,1023,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1435,1023,18,1,159,0);

INSERT INTO `order_items` VALUES (1436,1024,9,1,129,0);

INSERT INTO `order_items` VALUES (1437,1025,7,1,89,0);

INSERT INTO `order_items` VALUES (1438,1026,3,1,169,0);

INSERT INTO `order_items` VALUES (1439,1026,13,1,68,0);

INSERT INTO `order_items` VALUES (1440,1027,13,1,68,0);

INSERT INTO `order_items` VALUES (1441,1028,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1442,1029,4,2,59,0);

INSERT INTO `order_items` VALUES (1443,1030,4,1,59,0);

INSERT INTO `order_items` VALUES (1444,1030,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1445,1031,4,1,59,0);

INSERT INTO `order_items` VALUES (1446,1031,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1447,1032,20,1,39,0);

INSERT INTO `order_items` VALUES (1448,1033,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1449,1034,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (1450,1035,13,1,68,0);

INSERT INTO `order_items` VALUES (1451,1035,18,2,159,0);

INSERT INTO `order_items` VALUES (1452,1036,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1453,1037,3,1,169,0);

INSERT INTO `order_items` VALUES (1454,1037,4,2,59,0.05);

INSERT INTO `order_items` VALUES (1455,1038,18,1,159,0);

INSERT INTO `order_items` VALUES (1456,1039,7,1,89,0);

INSERT INTO `order_items` VALUES (1457,1039,9,1,129,0);

INSERT INTO `order_items` VALUES (1458,1039,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1459,1040,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1460,1041,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1461,1042,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1462,1043,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1463,1044,20,1,39,0);

INSERT INTO `order_items` VALUES (1464,1045,6,1,299,0);

INSERT INTO `order_items` VALUES (1465,1045,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1466,1046,7,3,89,0);

INSERT INTO `order_items` VALUES (1467,1046,12,1,79,0);

INSERT INTO `order_items` VALUES (1468,1046,13,1,68,0);

INSERT INTO `order_items` VALUES (1469,1047,13,1,68,0);

INSERT INTO `order_items` VALUES (1470,1048,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1471,1049,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1472,1049,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1473,1050,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1474,1051,12,2,79,0);

INSERT INTO `order_items` VALUES (1475,1052,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1476,1053,4,1,59,0);

INSERT INTO `order_items` VALUES (1477,1054,20,1,39,0);

INSERT INTO `order_items` VALUES (1478,1055,13,1,68,0);

INSERT INTO `order_items` VALUES (1479,1056,13,1,68,0);

INSERT INTO `order_items` VALUES (1480,1057,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1481,1058,7,1,89,0);

INSERT INTO `order_items` VALUES (1482,1058,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1483,1059,3,1,169,0);

INSERT INTO `order_items` VALUES (1484,1059,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1485,1059,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1486,1060,7,1,89,0);

INSERT INTO `order_items` VALUES (1487,1061,13,1,68,0);

INSERT INTO `order_items` VALUES (1488,1061,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1489,1062,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1490,1062,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1491,1063,6,1,299,0);

INSERT INTO `order_items` VALUES (1492,1063,16,3,24.9,0);

INSERT INTO `order_items` VALUES (1493,1064,4,1,59,0);

INSERT INTO `order_items` VALUES (1494,1065,7,1,89,0);

INSERT INTO `order_items` VALUES (1495,1065,18,1,159,0);

INSERT INTO `order_items` VALUES (1496,1066,11,1,39,0);

INSERT INTO `order_items` VALUES (1497,1067,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1498,1068,11,1,39,0);

INSERT INTO `order_items` VALUES (1499,1068,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1500,1069,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1501,1070,20,1,39,0);

INSERT INTO `order_items` VALUES (1502,1071,4,1,59,0);

INSERT INTO `order_items` VALUES (1503,1072,6,1,299,0);

INSERT INTO `order_items` VALUES (1504,1072,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1505,1073,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1506,1074,11,3,39,0);

INSERT INTO `order_items` VALUES (1507,1074,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1508,1074,18,1,159,0);

INSERT INTO `order_items` VALUES (1509,1075,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1510,1076,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1511,1077,20,1,39,0);

INSERT INTO `order_items` VALUES (1512,1078,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1513,1078,20,1,39,0);

INSERT INTO `order_items` VALUES (1514,1079,4,2,59,0);

INSERT INTO `order_items` VALUES (1515,1079,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1516,1080,11,1,39,0);

INSERT INTO `order_items` VALUES (1517,1081,9,2,129,0);

INSERT INTO `order_items` VALUES (1518,1082,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1519,1082,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1520,1083,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1521,1084,4,1,59,0);

INSERT INTO `order_items` VALUES (1522,1084,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1523,1085,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1524,1086,7,1,89,0);

INSERT INTO `order_items` VALUES (1525,1086,13,1,68,0);

INSERT INTO `order_items` VALUES (1526,1086,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1527,1087,9,1,129,0.10);

INSERT INTO `order_items` VALUES (1528,1087,12,1,79,0);

INSERT INTO `order_items` VALUES (1529,1088,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1530,1088,18,1,159,0);

INSERT INTO `order_items` VALUES (1531,1089,11,1,39,0);

INSERT INTO `order_items` VALUES (1532,1089,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1533,1090,13,1,68,0);

INSERT INTO `order_items` VALUES (1534,1091,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1535,1092,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1536,1093,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1537,1093,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1538,1094,12,1,79,0);

INSERT INTO `order_items` VALUES (1539,1094,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1540,1095,4,1,59,0);

INSERT INTO `order_items` VALUES (1541,1096,9,1,129,0);

INSERT INTO `order_items` VALUES (1542,1097,13,1,68,0);

INSERT INTO `order_items` VALUES (1543,1098,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1544,1099,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1545,1100,4,1,59,0);

INSERT INTO `order_items` VALUES (1546,1101,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1547,1102,7,1,89,0);

INSERT INTO `order_items` VALUES (1548,1102,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1549,1103,20,1,39,0);

INSERT INTO `order_items` VALUES (1550,1104,13,1,68,0);

INSERT INTO `order_items` VALUES (1551,1104,19,1,199,0);

INSERT INTO `order_items` VALUES (1552,1105,18,2,159,0.10);

INSERT INTO `order_items` VALUES (1553,1106,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1554,1106,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1555,1107,17,1,69,0);

INSERT INTO `order_items` VALUES (1556,1108,7,1,89,0.10);

INSERT INTO `order_items` VALUES (1557,1108,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1558,1109,4,1,59,0);

INSERT INTO `order_items` VALUES (1559,1109,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1560,1109,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1561,1110,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1562,1111,12,1,79,0);

INSERT INTO `order_items` VALUES (1563,1111,20,1,39,0);

INSERT INTO `order_items` VALUES (1564,1112,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1565,1113,12,1,79,0);

INSERT INTO `order_items` VALUES (1566,1113,20,1,39,0);

INSERT INTO `order_items` VALUES (1567,1114,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1568,1115,11,1,39,0);

INSERT INTO `order_items` VALUES (1569,1116,2,1,899,0);

INSERT INTO `order_items` VALUES (1570,1117,11,2,39,0);

INSERT INTO `order_items` VALUES (1571,1118,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1572,1119,3,2,169,0);

INSERT INTO `order_items` VALUES (1573,1120,11,2,39,0);

INSERT INTO `order_items` VALUES (1574,1121,4,1,59,0);

INSERT INTO `order_items` VALUES (1575,1122,13,2,68,0);

INSERT INTO `order_items` VALUES (1576,1123,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1577,1124,10,1,699,0.10);

INSERT INTO `order_items` VALUES (1578,1124,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1579,1125,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1580,1126,3,1,169,0);

INSERT INTO `order_items` VALUES (1581,1127,11,3,39,0.10);

INSERT INTO `order_items` VALUES (1582,1128,11,1,39,0);

INSERT INTO `order_items` VALUES (1583,1128,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1584,1129,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1585,1129,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1586,1130,15,2,32.9,0);

INSERT INTO `order_items` VALUES (1587,1131,13,2,68,0);

INSERT INTO `order_items` VALUES (1588,1132,5,1,399,0);

INSERT INTO `order_items` VALUES (1589,1133,11,2,39,0);

INSERT INTO `order_items` VALUES (1590,1134,3,1,169,0);

INSERT INTO `order_items` VALUES (1591,1135,7,1,89,0);

INSERT INTO `order_items` VALUES (1592,1135,12,1,79,0);

INSERT INTO `order_items` VALUES (1593,1136,12,1,79,0);

INSERT INTO `order_items` VALUES (1594,1137,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (1595,1138,12,3,79,0);

INSERT INTO `order_items` VALUES (1596,1138,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1597,1139,13,1,68,0);

INSERT INTO `order_items` VALUES (1598,1140,20,1,39,0.10);

INSERT INTO `order_items` VALUES (1599,1141,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1600,1142,13,1,68,0);

INSERT INTO `order_items` VALUES (1601,1143,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1602,1144,7,1,89,0.10);

INSERT INTO `order_items` VALUES (1603,1145,4,1,59,0);

INSERT INTO `order_items` VALUES (1604,1146,12,1,79,0);

INSERT INTO `order_items` VALUES (1605,1146,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1606,1147,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1607,1148,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1608,1149,20,1,39,0);

INSERT INTO `order_items` VALUES (1609,1150,12,1,79,0);

INSERT INTO `order_items` VALUES (1610,1150,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1611,1151,14,3,39.9,0);

INSERT INTO `order_items` VALUES (1612,1152,17,2,69,0);

INSERT INTO `order_items` VALUES (1613,1153,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1614,1154,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1615,1155,13,2,68,0);

INSERT INTO `order_items` VALUES (1616,1156,11,1,39,0);

INSERT INTO `order_items` VALUES (1617,1156,20,1,39,0);

INSERT INTO `order_items` VALUES (1618,1157,9,1,129,0.10);

INSERT INTO `order_items` VALUES (1619,1157,13,1,68,0);

INSERT INTO `order_items` VALUES (1620,1158,9,1,129,0.10);

INSERT INTO `order_items` VALUES (1621,1158,11,1,39,0);

INSERT INTO `order_items` VALUES (1622,1158,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1623,1159,9,1,129,0.10);

INSERT INTO `order_items` VALUES (1624,1160,6,1,299,0);

INSERT INTO `order_items` VALUES (1625,1160,12,1,79,0);

INSERT INTO `order_items` VALUES (1626,1160,17,1,69,0);

INSERT INTO `order_items` VALUES (1627,1161,12,1,79,0);

INSERT INTO `order_items` VALUES (1628,1161,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1629,1162,13,1,68,0);

INSERT INTO `order_items` VALUES (1630,1162,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1631,1163,6,1,299,0);

INSERT INTO `order_items` VALUES (1632,1163,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1633,1163,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1634,1164,12,2,79,0);

INSERT INTO `order_items` VALUES (1635,1165,3,1,169,0);

INSERT INTO `order_items` VALUES (1636,1166,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1637,1167,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1638,1167,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1639,1167,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1640,1168,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1641,1168,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1642,1169,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1643,1170,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1644,1170,9,1,129,0);

INSERT INTO `order_items` VALUES (1645,1170,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1646,1171,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1647,1172,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1648,1173,9,2,129,0);

INSERT INTO `order_items` VALUES (1649,1174,13,1,68,0);

INSERT INTO `order_items` VALUES (1650,1174,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1651,1175,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1652,1176,11,1,39,0);

INSERT INTO `order_items` VALUES (1653,1176,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1654,1177,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1655,1177,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1656,1178,5,2,399,0.10);

INSERT INTO `order_items` VALUES (1657,1178,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1658,1179,7,1,89,0);

INSERT INTO `order_items` VALUES (1659,1179,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1660,1179,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1661,1180,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1662,1180,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1663,1180,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1664,1181,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1665,1182,11,1,39,0);

INSERT INTO `order_items` VALUES (1666,1182,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1667,1183,13,1,68,0);

INSERT INTO `order_items` VALUES (1668,1184,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1669,1185,20,1,39,0);

INSERT INTO `order_items` VALUES (1670,1186,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1671,1186,14,3,39.9,0);

INSERT INTO `order_items` VALUES (1672,1187,17,1,69,0);

INSERT INTO `order_items` VALUES (1673,1188,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1674,1189,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1675,1189,11,1,39,0);

INSERT INTO `order_items` VALUES (1676,1189,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1677,1190,4,1,59,0);

INSERT INTO `order_items` VALUES (1678,1191,11,1,39,0);

INSERT INTO `order_items` VALUES (1679,1192,3,3,169,0);

INSERT INTO `order_items` VALUES (1680,1192,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1681,1193,13,1,68,0);

INSERT INTO `order_items` VALUES (1682,1194,19,1,199,0.10);

INSERT INTO `order_items` VALUES (1683,1195,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1684,1196,4,1,59,0);

INSERT INTO `order_items` VALUES (1685,1197,4,1,59,0);

INSERT INTO `order_items` VALUES (1686,1197,9,1,129,0);

INSERT INTO `order_items` VALUES (1687,1197,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1688,1198,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1689,1199,5,2,399,0);

INSERT INTO `order_items` VALUES (1690,1200,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1691,1201,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1692,1202,3,1,169,0);

INSERT INTO `order_items` VALUES (1693,1203,4,1,59,0);

INSERT INTO `order_items` VALUES (1694,1203,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1695,1203,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1696,1204,3,1,169,0);

INSERT INTO `order_items` VALUES (1697,1204,18,1,159,0);

INSERT INTO `order_items` VALUES (1698,1205,20,2,39,0);

INSERT INTO `order_items` VALUES (1699,1206,12,1,79,0.10);

INSERT INTO `order_items` VALUES (1700,1207,13,1,68,0);

INSERT INTO `order_items` VALUES (1701,1207,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1702,1207,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1703,1208,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1704,1209,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1705,1210,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1706,1211,9,1,129,0);

INSERT INTO `order_items` VALUES (1707,1211,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1708,1212,20,1,39,0);

INSERT INTO `order_items` VALUES (1709,1213,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1710,1214,15,2,32.9,0);

INSERT INTO `order_items` VALUES (1711,1215,12,2,79,0.05);

INSERT INTO `order_items` VALUES (1712,1216,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1713,1216,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (1714,1217,11,1,39,0);

INSERT INTO `order_items` VALUES (1715,1218,12,1,79,0);

INSERT INTO `order_items` VALUES (1716,1218,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1717,1219,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1718,1220,6,1,299,0);

INSERT INTO `order_items` VALUES (1719,1220,13,1,68,0);

INSERT INTO `order_items` VALUES (1720,1220,20,2,39,0);

INSERT INTO `order_items` VALUES (1721,1221,13,1,68,0);

INSERT INTO `order_items` VALUES (1722,1221,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1723,1222,13,1,68,0);

INSERT INTO `order_items` VALUES (1724,1223,4,1,59,0);

INSERT INTO `order_items` VALUES (1725,1224,7,1,89,0);

INSERT INTO `order_items` VALUES (1726,1224,11,1,39,0);

INSERT INTO `order_items` VALUES (1727,1224,13,1,68,0);

INSERT INTO `order_items` VALUES (1728,1225,4,1,59,0);

INSERT INTO `order_items` VALUES (1729,1225,12,1,79,0);

INSERT INTO `order_items` VALUES (1730,1225,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1731,1226,13,1,68,0);

INSERT INTO `order_items` VALUES (1732,1227,8,1,159,0);

INSERT INTO `order_items` VALUES (1733,1228,3,1,169,0);

INSERT INTO `order_items` VALUES (1734,1228,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1735,1229,11,1,39,0);

INSERT INTO `order_items` VALUES (1736,1229,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1737,1230,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1738,1231,12,1,79,0);

INSERT INTO `order_items` VALUES (1739,1232,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1740,1233,3,1,169,0.10);

INSERT INTO `order_items` VALUES (1741,1233,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1742,1234,4,1,59,0);

INSERT INTO `order_items` VALUES (1743,1235,13,1,68,0);

INSERT INTO `order_items` VALUES (1744,1236,18,1,159,0);

INSERT INTO `order_items` VALUES (1745,1237,2,2,899,0.05);

INSERT INTO `order_items` VALUES (1746,1238,12,2,79,0);

INSERT INTO `order_items` VALUES (1747,1239,13,1,68,0);

INSERT INTO `order_items` VALUES (1748,1240,12,2,79,0.05);

INSERT INTO `order_items` VALUES (1749,1240,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1750,1241,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1751,1242,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1752,1242,9,2,129,0.05);

INSERT INTO `order_items` VALUES (1753,1242,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1754,1243,20,1,39,0);

INSERT INTO `order_items` VALUES (1755,1244,11,1,39,0);

INSERT INTO `order_items` VALUES (1756,1245,12,1,79,0);

INSERT INTO `order_items` VALUES (1757,1246,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1758,1247,5,1,399,0);

INSERT INTO `order_items` VALUES (1759,1248,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1760,1249,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1761,1250,11,1,39,0);

INSERT INTO `order_items` VALUES (1762,1250,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1763,1250,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1764,1251,4,1,59,0);

INSERT INTO `order_items` VALUES (1765,1251,7,1,89,0);

INSERT INTO `order_items` VALUES (1766,1252,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1767,1253,9,1,129,0);

INSERT INTO `order_items` VALUES (1768,1253,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1769,1253,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1770,1254,3,2,169,0);

INSERT INTO `order_items` VALUES (1771,1254,12,1,79,0);

INSERT INTO `order_items` VALUES (1772,1254,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1773,1255,3,1,169,0.10);

INSERT INTO `order_items` VALUES (1774,1255,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1775,1256,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1776,1257,13,1,68,0);

INSERT INTO `order_items` VALUES (1777,1258,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1778,1259,9,3,129,0);

INSERT INTO `order_items` VALUES (1779,1259,17,1,69,0);

INSERT INTO `order_items` VALUES (1780,1259,20,1,39,0);

INSERT INTO `order_items` VALUES (1781,1260,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1782,1260,17,3,69,0);

INSERT INTO `order_items` VALUES (1783,1261,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1784,1262,12,1,79,0);

INSERT INTO `order_items` VALUES (1785,1263,12,1,79,0);

INSERT INTO `order_items` VALUES (1786,1264,13,1,68,0);

INSERT INTO `order_items` VALUES (1787,1265,12,1,79,0);

INSERT INTO `order_items` VALUES (1788,1265,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1789,1266,9,1,129,0.10);

INSERT INTO `order_items` VALUES (1790,1266,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1791,1267,20,1,39,0);

INSERT INTO `order_items` VALUES (1792,1268,6,2,299,0);

INSERT INTO `order_items` VALUES (1793,1269,6,1,299,0.05);

INSERT INTO `order_items` VALUES (1794,1269,9,1,129,0);

INSERT INTO `order_items` VALUES (1795,1270,11,1,39,0);

INSERT INTO `order_items` VALUES (1796,1270,17,2,69,0);

INSERT INTO `order_items` VALUES (1797,1271,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1798,1272,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1799,1273,13,1,68,0);

INSERT INTO `order_items` VALUES (1800,1274,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1801,1274,17,1,69,0);

INSERT INTO `order_items` VALUES (1802,1275,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1803,1276,18,1,159,0);

INSERT INTO `order_items` VALUES (1804,1277,20,2,39,0.05);

INSERT INTO `order_items` VALUES (1805,1278,13,1,68,0);

INSERT INTO `order_items` VALUES (1806,1279,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1807,1280,4,2,59,0);

INSERT INTO `order_items` VALUES (1808,1280,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1809,1281,18,1,159,0);

INSERT INTO `order_items` VALUES (1810,1281,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1811,1282,3,1,169,0.10);

INSERT INTO `order_items` VALUES (1812,1283,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1813,1284,12,1,79,0);

INSERT INTO `order_items` VALUES (1814,1284,15,3,32.9,0);

INSERT INTO `order_items` VALUES (1815,1285,13,2,68,0);

INSERT INTO `order_items` VALUES (1816,1286,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1817,1286,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1818,1287,3,1,169,0);

INSERT INTO `order_items` VALUES (1819,1287,12,2,79,0.10);

INSERT INTO `order_items` VALUES (1820,1288,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1821,1289,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1822,1290,11,1,39,0);

INSERT INTO `order_items` VALUES (1823,1290,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1824,1291,13,1,68,0);

INSERT INTO `order_items` VALUES (1825,1292,4,1,59,0);

INSERT INTO `order_items` VALUES (1826,1293,13,1,68,0);

INSERT INTO `order_items` VALUES (1827,1294,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1828,1295,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1829,1296,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1830,1297,12,1,79,0);

INSERT INTO `order_items` VALUES (1831,1298,4,1,59,0);

INSERT INTO `order_items` VALUES (1832,1299,15,3,32.9,0);

INSERT INTO `order_items` VALUES (1833,1300,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1834,1300,18,1,159,0);

INSERT INTO `order_items` VALUES (1835,1301,7,1,89,0);

INSERT INTO `order_items` VALUES (1836,1301,18,2,159,0);

INSERT INTO `order_items` VALUES (1837,1302,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1838,1303,3,1,169,0);

INSERT INTO `order_items` VALUES (1839,1304,4,2,59,0);

INSERT INTO `order_items` VALUES (1840,1304,15,2,32.9,0);

INSERT INTO `order_items` VALUES (1841,1305,20,1,39,0);

INSERT INTO `order_items` VALUES (1842,1306,4,1,59,0);

INSERT INTO `order_items` VALUES (1843,1306,12,1,79,0);

INSERT INTO `order_items` VALUES (1844,1307,18,1,159,0);

INSERT INTO `order_items` VALUES (1845,1308,20,1,39,0);

INSERT INTO `order_items` VALUES (1846,1309,13,2,68,0);

INSERT INTO `order_items` VALUES (1847,1310,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1848,1310,18,1,159,0);

INSERT INTO `order_items` VALUES (1849,1311,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1850,1312,12,3,79,0);

INSERT INTO `order_items` VALUES (1851,1313,11,2,39,0);

INSERT INTO `order_items` VALUES (1852,1314,4,1,59,0);

INSERT INTO `order_items` VALUES (1853,1314,6,1,299,0);

INSERT INTO `order_items` VALUES (1854,1315,1,1,4299,0);

INSERT INTO `order_items` VALUES (1855,1315,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1856,1316,11,1,39,0);

INSERT INTO `order_items` VALUES (1857,1316,16,2,24.9,0);

INSERT INTO `order_items` VALUES (1858,1317,12,1,79,0);

INSERT INTO `order_items` VALUES (1859,1317,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1860,1317,18,1,159,0);

INSERT INTO `order_items` VALUES (1861,1318,4,3,59,0);

INSERT INTO `order_items` VALUES (1862,1318,9,2,129,0);

INSERT INTO `order_items` VALUES (1863,1319,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1864,1319,20,1,39,0);

INSERT INTO `order_items` VALUES (1865,1320,11,2,39,0);

INSERT INTO `order_items` VALUES (1866,1321,4,1,59,0);

INSERT INTO `order_items` VALUES (1867,1322,12,1,79,0);

INSERT INTO `order_items` VALUES (1868,1322,18,2,159,0.10);

INSERT INTO `order_items` VALUES (1869,1323,4,1,59,0);

INSERT INTO `order_items` VALUES (1870,1323,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1871,1324,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1872,1325,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1873,1326,11,2,39,0);

INSERT INTO `order_items` VALUES (1874,1327,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1875,1328,4,1,59,0);

INSERT INTO `order_items` VALUES (1876,1329,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1877,1330,17,1,69,0);

INSERT INTO `order_items` VALUES (1878,1331,11,1,39,0);

INSERT INTO `order_items` VALUES (1879,1332,4,2,59,0);

INSERT INTO `order_items` VALUES (1880,1332,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1881,1332,11,1,39,0);

INSERT INTO `order_items` VALUES (1882,1333,12,1,79,0);

INSERT INTO `order_items` VALUES (1883,1334,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1884,1335,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1885,1335,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1886,1336,3,1,169,0);

INSERT INTO `order_items` VALUES (1887,1337,12,2,79,0.05);

INSERT INTO `order_items` VALUES (1888,1338,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1889,1339,13,1,68,0);

INSERT INTO `order_items` VALUES (1890,1340,17,1,69,0);

INSERT INTO `order_items` VALUES (1891,1341,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1892,1342,9,1,129,0);

INSERT INTO `order_items` VALUES (1893,1342,13,1,68,0);

INSERT INTO `order_items` VALUES (1894,1343,9,1,129,0.05);

INSERT INTO `order_items` VALUES (1895,1343,13,1,68,0);

INSERT INTO `order_items` VALUES (1896,1343,15,2,32.9,0);

INSERT INTO `order_items` VALUES (1897,1344,1,1,4299,0);

INSERT INTO `order_items` VALUES (1898,1344,6,1,299,0);

INSERT INTO `order_items` VALUES (1899,1345,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1900,1346,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1901,1346,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1902,1347,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1903,1348,9,1,129,0);

INSERT INTO `order_items` VALUES (1904,1348,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1905,1349,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1906,1349,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1907,1349,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (1908,1350,7,2,89,0);

INSERT INTO `order_items` VALUES (1909,1351,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1910,1352,4,2,59,0);

INSERT INTO `order_items` VALUES (1911,1353,4,1,59,0);

INSERT INTO `order_items` VALUES (1912,1354,13,1,68,0);

INSERT INTO `order_items` VALUES (1913,1355,19,1,199,0);

INSERT INTO `order_items` VALUES (1914,1356,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1915,1357,4,1,59,0);

INSERT INTO `order_items` VALUES (1916,1357,13,1,68,0);

INSERT INTO `order_items` VALUES (1917,1358,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1918,1359,18,1,159,0);

INSERT INTO `order_items` VALUES (1919,1360,11,1,39,0.05);

INSERT INTO `order_items` VALUES (1920,1361,3,1,169,0);

INSERT INTO `order_items` VALUES (1921,1361,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1922,1362,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1923,1363,9,1,129,0);

INSERT INTO `order_items` VALUES (1924,1364,6,1,299,0);

INSERT INTO `order_items` VALUES (1925,1364,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1926,1365,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1927,1366,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (1928,1366,20,1,39,0);

INSERT INTO `order_items` VALUES (1929,1367,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1930,1367,20,1,39,0.05);

INSERT INTO `order_items` VALUES (1931,1368,11,1,39,0);

INSERT INTO `order_items` VALUES (1932,1369,9,1,129,0);

INSERT INTO `order_items` VALUES (1933,1369,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1934,1369,17,1,69,0);

INSERT INTO `order_items` VALUES (1935,1370,7,1,89,0);

INSERT INTO `order_items` VALUES (1936,1371,16,1,24.9,0);

INSERT INTO `order_items` VALUES (1937,1372,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1938,1373,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1939,1374,3,2,169,0.10);

INSERT INTO `order_items` VALUES (1940,1375,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1941,1376,13,1,68,0.05);

INSERT INTO `order_items` VALUES (1942,1376,19,1,199,0.10);

INSERT INTO `order_items` VALUES (1943,1377,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1944,1378,4,1,59,0);

INSERT INTO `order_items` VALUES (1945,1379,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1946,1379,13,1,68,0);

INSERT INTO `order_items` VALUES (1947,1380,4,1,59,0);

INSERT INTO `order_items` VALUES (1948,1380,11,1,39,0);

INSERT INTO `order_items` VALUES (1949,1381,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1950,1382,7,1,89,0.05);

INSERT INTO `order_items` VALUES (1951,1383,7,2,89,0.05);

INSERT INTO `order_items` VALUES (1952,1383,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1953,1384,12,1,79,0.05);

INSERT INTO `order_items` VALUES (1954,1385,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1955,1386,12,1,79,0);

INSERT INTO `order_items` VALUES (1956,1386,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1957,1387,6,1,299,0);

INSERT INTO `order_items` VALUES (1958,1387,12,1,79,0);

INSERT INTO `order_items` VALUES (1959,1387,18,2,159,0);

INSERT INTO `order_items` VALUES (1960,1388,13,2,68,0);

INSERT INTO `order_items` VALUES (1961,1389,11,1,39,0);

INSERT INTO `order_items` VALUES (1962,1389,17,1,69,0);

INSERT INTO `order_items` VALUES (1963,1390,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1964,1391,20,1,39,0);

INSERT INTO `order_items` VALUES (1965,1392,18,1,159,0);

INSERT INTO `order_items` VALUES (1966,1393,17,1,69,0);

INSERT INTO `order_items` VALUES (1967,1394,16,3,24.9,0);

INSERT INTO `order_items` VALUES (1968,1395,11,1,39,0);

INSERT INTO `order_items` VALUES (1969,1395,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1970,1395,20,1,39,0);

INSERT INTO `order_items` VALUES (1971,1396,11,1,39,0);

INSERT INTO `order_items` VALUES (1972,1397,13,1,68,0);

INSERT INTO `order_items` VALUES (1973,1397,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (1974,1398,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1975,1399,3,1,169,0.05);

INSERT INTO `order_items` VALUES (1976,1400,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (1977,1400,17,1,69,0.05);

INSERT INTO `order_items` VALUES (1978,1401,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (1979,1402,2,2,899,0);

INSERT INTO `order_items` VALUES (1980,1402,7,1,89,0);

INSERT INTO `order_items` VALUES (1981,1403,14,2,39.9,0);

INSERT INTO `order_items` VALUES (1982,1403,20,1,39,0);

INSERT INTO `order_items` VALUES (1983,1404,4,1,59,0.05);

INSERT INTO `order_items` VALUES (1984,1404,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1985,1405,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1986,1406,11,1,39,0);

INSERT INTO `order_items` VALUES (1987,1407,20,1,39,0);

INSERT INTO `order_items` VALUES (1988,1408,12,1,79,0);

INSERT INTO `order_items` VALUES (1989,1408,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1990,1408,15,1,32.9,0);

INSERT INTO `order_items` VALUES (1991,1409,5,2,399,0);

INSERT INTO `order_items` VALUES (1992,1410,3,1,169,0);

INSERT INTO `order_items` VALUES (1993,1410,6,3,299,0);

INSERT INTO `order_items` VALUES (1994,1410,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (1995,1411,14,1,39.9,0);

INSERT INTO `order_items` VALUES (1996,1412,6,1,299,0);

INSERT INTO `order_items` VALUES (1997,1413,12,1,79,0);

INSERT INTO `order_items` VALUES (1998,1413,20,1,39,0);

INSERT INTO `order_items` VALUES (1999,1414,13,1,68,0);

INSERT INTO `order_items` VALUES (2000,1415,3,1,169,0);

INSERT INTO `order_items` VALUES (2001,1416,19,2,199,0.05);

INSERT INTO `order_items` VALUES (2002,1417,3,1,169,0);

INSERT INTO `order_items` VALUES (2003,1417,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2004,1418,11,1,39,0);

INSERT INTO `order_items` VALUES (2005,1419,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2006,1420,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2007,1421,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2008,1422,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2009,1423,5,1,399,0);

INSERT INTO `order_items` VALUES (2010,1424,13,1,68,0);

INSERT INTO `order_items` VALUES (2011,1425,9,1,129,0);

INSERT INTO `order_items` VALUES (2012,1425,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2013,1426,3,1,169,0);

INSERT INTO `order_items` VALUES (2014,1427,12,2,79,0);

INSERT INTO `order_items` VALUES (2015,1427,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2016,1428,11,1,39,0);

INSERT INTO `order_items` VALUES (2017,1428,20,1,39,0);

INSERT INTO `order_items` VALUES (2018,1429,5,1,399,0.10);

INSERT INTO `order_items` VALUES (2019,1430,13,1,68,0);

INSERT INTO `order_items` VALUES (2020,1431,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2021,1432,13,1,68,0);

INSERT INTO `order_items` VALUES (2022,1432,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2023,1433,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2024,1434,9,1,129,0);

INSERT INTO `order_items` VALUES (2025,1434,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2026,1434,18,1,159,0);

INSERT INTO `order_items` VALUES (2027,1435,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2028,1435,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2029,1436,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2030,1436,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2031,1437,12,1,79,0);

INSERT INTO `order_items` VALUES (2032,1437,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (2033,1438,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2034,1439,13,1,68,0);

INSERT INTO `order_items` VALUES (2035,1440,12,2,79,0.05);

INSERT INTO `order_items` VALUES (2036,1441,4,1,59,0);

INSERT INTO `order_items` VALUES (2037,1442,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2038,1443,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2039,1444,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2040,1445,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2041,1445,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2042,1445,17,3,69,0);

INSERT INTO `order_items` VALUES (2043,1446,13,1,68,0);

INSERT INTO `order_items` VALUES (2044,1446,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2045,1447,4,1,59,0);

INSERT INTO `order_items` VALUES (2046,1448,6,1,299,0);

INSERT INTO `order_items` VALUES (2047,1449,9,1,129,0);

INSERT INTO `order_items` VALUES (2048,1450,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2049,1451,13,1,68,0);

INSERT INTO `order_items` VALUES (2050,1451,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2051,1452,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2052,1452,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2053,1452,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2054,1453,19,1,199,0);

INSERT INTO `order_items` VALUES (2055,1454,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2056,1455,17,1,69,0.10);

INSERT INTO `order_items` VALUES (2057,1455,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2058,1456,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2059,1457,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2060,1457,18,1,159,0);

INSERT INTO `order_items` VALUES (2061,1457,20,1,39,0.10);

INSERT INTO `order_items` VALUES (2062,1458,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2063,1459,11,1,39,0);

INSERT INTO `order_items` VALUES (2064,1459,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2065,1460,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (2066,1461,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2067,1462,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2068,1463,13,1,68,0);

INSERT INTO `order_items` VALUES (2069,1464,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2070,1465,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2071,1466,8,1,159,0);

INSERT INTO `order_items` VALUES (2072,1466,13,1,68,0);

INSERT INTO `order_items` VALUES (2073,1467,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2074,1468,3,1,169,0.05);

INSERT INTO `order_items` VALUES (2075,1468,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2076,1469,5,2,399,0);

INSERT INTO `order_items` VALUES (2077,1470,11,2,39,0);

INSERT INTO `order_items` VALUES (2078,1471,20,1,39,0);

INSERT INTO `order_items` VALUES (2079,1472,11,1,39,0);

INSERT INTO `order_items` VALUES (2080,1472,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2081,1472,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2082,1473,6,2,299,0.05);

INSERT INTO `order_items` VALUES (2083,1474,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2084,1475,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2085,1476,4,2,59,0);

INSERT INTO `order_items` VALUES (2086,1477,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2087,1478,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2088,1479,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2089,1480,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2090,1480,20,1,39,0);

INSERT INTO `order_items` VALUES (2091,1481,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2092,1481,19,1,199,0);

INSERT INTO `order_items` VALUES (2093,1482,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2094,1483,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2095,1484,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2096,1484,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2097,1484,20,1,39,0);

INSERT INTO `order_items` VALUES (2098,1485,3,2,169,0.05);

INSERT INTO `order_items` VALUES (2099,1485,20,1,39,0);

INSERT INTO `order_items` VALUES (2100,1486,5,1,399,0);

INSERT INTO `order_items` VALUES (2101,1486,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2102,1487,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2103,1488,9,1,129,0.05);

INSERT INTO `order_items` VALUES (2104,1489,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2105,1490,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2106,1491,13,1,68,0);

INSERT INTO `order_items` VALUES (2107,1492,12,1,79,0);

INSERT INTO `order_items` VALUES (2108,1493,20,1,39,0);

INSERT INTO `order_items` VALUES (2109,1494,3,1,169,0.05);

INSERT INTO `order_items` VALUES (2110,1494,9,1,129,0.05);

INSERT INTO `order_items` VALUES (2111,1494,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2112,1495,9,1,129,0);

INSERT INTO `order_items` VALUES (2113,1496,12,2,79,0);

INSERT INTO `order_items` VALUES (2114,1497,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2115,1498,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2116,1499,13,2,68,0);

INSERT INTO `order_items` VALUES (2117,1500,2,2,899,0);

INSERT INTO `order_items` VALUES (2118,1501,15,3,32.9,0);

INSERT INTO `order_items` VALUES (2119,1502,3,1,169,0);

INSERT INTO `order_items` VALUES (2120,1502,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2121,1503,3,1,169,0);

INSERT INTO `order_items` VALUES (2122,1504,13,1,68,0);

INSERT INTO `order_items` VALUES (2123,1505,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2124,1505,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2125,1506,3,1,169,0);

INSERT INTO `order_items` VALUES (2126,1507,4,1,59,0);

INSERT INTO `order_items` VALUES (2127,1508,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2128,1509,3,1,169,0.05);

INSERT INTO `order_items` VALUES (2129,1509,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2130,1510,10,2,699,0);

INSERT INTO `order_items` VALUES (2131,1511,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2132,1512,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2133,1512,18,2,159,0);

INSERT INTO `order_items` VALUES (2134,1513,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2135,1514,4,2,59,0.05);

INSERT INTO `order_items` VALUES (2136,1515,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2137,1516,9,1,129,0);

INSERT INTO `order_items` VALUES (2138,1517,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2139,1518,3,1,169,0);

INSERT INTO `order_items` VALUES (2140,1519,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2141,1520,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2142,1520,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2143,1521,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2144,1522,9,2,129,0);

INSERT INTO `order_items` VALUES (2145,1523,3,1,169,0);

INSERT INTO `order_items` VALUES (2146,1523,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2147,1523,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2148,1524,11,1,39,0);

INSERT INTO `order_items` VALUES (2149,1524,18,1,159,0.05);

INSERT INTO `order_items` VALUES (2150,1525,13,1,68,0);

INSERT INTO `order_items` VALUES (2151,1526,12,1,79,0);

INSERT INTO `order_items` VALUES (2152,1527,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2153,1528,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2154,1529,11,1,39,0);

INSERT INTO `order_items` VALUES (2155,1530,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2156,1531,13,1,68,0);

INSERT INTO `order_items` VALUES (2157,1532,3,1,169,0.05);

INSERT INTO `order_items` VALUES (2158,1533,4,1,59,0);

INSERT INTO `order_items` VALUES (2159,1533,9,1,129,0);

INSERT INTO `order_items` VALUES (2160,1533,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2161,1534,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2162,1535,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2163,1535,12,1,79,0);

INSERT INTO `order_items` VALUES (2164,1536,4,1,59,0);

INSERT INTO `order_items` VALUES (2165,1536,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2166,1537,4,1,59,0);

INSERT INTO `order_items` VALUES (2167,1538,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2168,1539,7,1,89,0);

INSERT INTO `order_items` VALUES (2169,1539,20,2,39,0);

INSERT INTO `order_items` VALUES (2170,1540,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2171,1541,13,1,68,0);

INSERT INTO `order_items` VALUES (2172,1542,11,1,39,0);

INSERT INTO `order_items` VALUES (2173,1542,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2174,1543,4,1,59,0);

INSERT INTO `order_items` VALUES (2175,1544,11,1,39,0);

INSERT INTO `order_items` VALUES (2176,1544,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (2177,1545,3,1,169,0);

INSERT INTO `order_items` VALUES (2178,1546,5,1,399,0);

INSERT INTO `order_items` VALUES (2179,1546,6,2,299,0);

INSERT INTO `order_items` VALUES (2180,1547,5,1,399,0);

INSERT INTO `order_items` VALUES (2181,1547,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2182,1548,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2183,1549,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2184,1550,19,1,199,0);

INSERT INTO `order_items` VALUES (2185,1551,11,1,39,0);

INSERT INTO `order_items` VALUES (2186,1552,11,1,39,0);

INSERT INTO `order_items` VALUES (2187,1553,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2188,1554,13,1,68,0);

INSERT INTO `order_items` VALUES (2189,1555,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2190,1556,7,1,89,0);

INSERT INTO `order_items` VALUES (2191,1556,11,1,39,0);

INSERT INTO `order_items` VALUES (2192,1557,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2193,1558,11,1,39,0);

INSERT INTO `order_items` VALUES (2194,1558,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2195,1559,18,2,159,0);

INSERT INTO `order_items` VALUES (2196,1560,6,1,299,0.10);

INSERT INTO `order_items` VALUES (2197,1560,11,1,39,0);

INSERT INTO `order_items` VALUES (2198,1561,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2199,1562,13,1,68,0);

INSERT INTO `order_items` VALUES (2200,1563,20,1,39,0);

INSERT INTO `order_items` VALUES (2201,1564,8,1,159,0);

INSERT INTO `order_items` VALUES (2202,1565,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2203,1565,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2204,1566,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2205,1566,12,1,79,0);

INSERT INTO `order_items` VALUES (2206,1566,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2207,1567,12,1,79,0);

INSERT INTO `order_items` VALUES (2208,1568,7,1,89,0);

INSERT INTO `order_items` VALUES (2209,1568,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2210,1569,11,3,39,0);

INSERT INTO `order_items` VALUES (2211,1570,13,1,68,0);

INSERT INTO `order_items` VALUES (2212,1571,3,1,169,0);

INSERT INTO `order_items` VALUES (2213,1572,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2214,1573,6,1,299,0);

INSERT INTO `order_items` VALUES (2215,1574,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2216,1574,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2217,1574,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2218,1575,3,1,169,0);

INSERT INTO `order_items` VALUES (2219,1575,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2220,1576,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2221,1577,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2222,1578,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2223,1579,4,2,59,0);

INSERT INTO `order_items` VALUES (2224,1580,11,1,39,0);

INSERT INTO `order_items` VALUES (2225,1581,9,1,129,0);

INSERT INTO `order_items` VALUES (2226,1581,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2227,1582,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2228,1582,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2229,1583,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2230,1583,16,3,24.9,0);

INSERT INTO `order_items` VALUES (2231,1584,11,1,39,0);

INSERT INTO `order_items` VALUES (2232,1584,14,3,39.9,0.05);

INSERT INTO `order_items` VALUES (2233,1584,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2234,1585,9,1,129,0);

INSERT INTO `order_items` VALUES (2235,1586,3,1,169,0);

INSERT INTO `order_items` VALUES (2236,1587,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2237,1588,12,1,79,0);

INSERT INTO `order_items` VALUES (2238,1589,18,3,159,0);

INSERT INTO `order_items` VALUES (2239,1590,1,1,4299,0.05);

INSERT INTO `order_items` VALUES (2240,1590,20,1,39,0);

INSERT INTO `order_items` VALUES (2241,1591,9,1,129,0.05);

INSERT INTO `order_items` VALUES (2242,1591,18,1,159,0);

INSERT INTO `order_items` VALUES (2243,1592,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2244,1593,4,1,59,0);

INSERT INTO `order_items` VALUES (2245,1593,17,1,69,0);

INSERT INTO `order_items` VALUES (2246,1594,4,1,59,0.10);

INSERT INTO `order_items` VALUES (2247,1594,13,2,68,0);

INSERT INTO `order_items` VALUES (2248,1595,11,1,39,0);

INSERT INTO `order_items` VALUES (2249,1596,17,1,69,0);

INSERT INTO `order_items` VALUES (2250,1597,4,1,59,0);

INSERT INTO `order_items` VALUES (2251,1598,2,1,899,0.05);

INSERT INTO `order_items` VALUES (2252,1599,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2253,1600,8,1,159,0);

INSERT INTO `order_items` VALUES (2254,1601,4,1,59,0);

INSERT INTO `order_items` VALUES (2255,1601,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2256,1602,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2257,1603,11,1,39,0);

INSERT INTO `order_items` VALUES (2258,1604,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2259,1605,7,1,89,0);

INSERT INTO `order_items` VALUES (2260,1605,13,1,68,0);

INSERT INTO `order_items` VALUES (2261,1605,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2262,1606,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2263,1606,11,1,39,0);

INSERT INTO `order_items` VALUES (2264,1606,12,3,79,0);

INSERT INTO `order_items` VALUES (2265,1607,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2266,1608,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2267,1609,4,1,59,0);

INSERT INTO `order_items` VALUES (2268,1610,3,1,169,0);

INSERT INTO `order_items` VALUES (2269,1610,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2270,1611,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2271,1612,9,1,129,0);

INSERT INTO `order_items` VALUES (2272,1613,3,1,169,0);

INSERT INTO `order_items` VALUES (2273,1614,4,1,59,0);

INSERT INTO `order_items` VALUES (2274,1615,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2275,1615,20,2,39,0.05);

INSERT INTO `order_items` VALUES (2276,1616,5,2,399,0.10);

INSERT INTO `order_items` VALUES (2277,1616,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2278,1617,11,1,39,0);

INSERT INTO `order_items` VALUES (2279,1618,12,1,79,0);

INSERT INTO `order_items` VALUES (2280,1618,20,1,39,0);

INSERT INTO `order_items` VALUES (2281,1619,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2282,1619,20,1,39,0.10);

INSERT INTO `order_items` VALUES (2283,1620,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2284,1621,11,1,39,0);

INSERT INTO `order_items` VALUES (2285,1622,9,1,129,0);

INSERT INTO `order_items` VALUES (2286,1622,12,1,79,0);

INSERT INTO `order_items` VALUES (2287,1622,17,1,69,0);

INSERT INTO `order_items` VALUES (2288,1623,12,1,79,0);

INSERT INTO `order_items` VALUES (2289,1624,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2290,1625,3,1,169,0);

INSERT INTO `order_items` VALUES (2291,1626,8,1,159,0);

INSERT INTO `order_items` VALUES (2292,1626,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (2293,1627,6,1,299,0);

INSERT INTO `order_items` VALUES (2294,1628,13,1,68,0);

INSERT INTO `order_items` VALUES (2295,1628,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2296,1629,18,1,159,0.10);

INSERT INTO `order_items` VALUES (2297,1630,14,3,39.9,0);

INSERT INTO `order_items` VALUES (2298,1631,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2299,1632,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2300,1632,17,1,69,0.10);

INSERT INTO `order_items` VALUES (2301,1633,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2302,1634,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2303,1635,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2304,1635,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2305,1636,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2306,1637,9,2,129,0);

INSERT INTO `order_items` VALUES (2307,1638,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2308,1639,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2309,1639,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2310,1640,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2311,1641,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2312,1642,4,3,59,0.05);

INSERT INTO `order_items` VALUES (2313,1643,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2314,1644,9,1,129,0);

INSERT INTO `order_items` VALUES (2315,1644,11,1,39,0);

INSERT INTO `order_items` VALUES (2316,1644,12,2,79,0.10);

INSERT INTO `order_items` VALUES (2317,1645,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2318,1646,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2319,1646,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2320,1647,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2321,1648,20,1,39,0);

INSERT INTO `order_items` VALUES (2322,1649,7,1,89,0);

INSERT INTO `order_items` VALUES (2323,1650,5,2,399,0);

INSERT INTO `order_items` VALUES (2324,1650,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2325,1651,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2326,1652,13,1,68,0);

INSERT INTO `order_items` VALUES (2327,1653,11,1,39,0);

INSERT INTO `order_items` VALUES (2328,1653,13,1,68,0);

INSERT INTO `order_items` VALUES (2329,1654,9,1,129,0);

INSERT INTO `order_items` VALUES (2330,1654,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2331,1655,7,1,89,0);

INSERT INTO `order_items` VALUES (2332,1655,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2333,1655,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2334,1656,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2335,1657,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2336,1657,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2337,1658,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2338,1659,20,1,39,0);

INSERT INTO `order_items` VALUES (2339,1660,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2340,1661,3,2,169,0);

INSERT INTO `order_items` VALUES (2341,1662,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2342,1663,5,1,399,0);

INSERT INTO `order_items` VALUES (2343,1664,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2344,1664,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2345,1665,4,1,59,0);

INSERT INTO `order_items` VALUES (2346,1665,14,3,39.9,0.05);

INSERT INTO `order_items` VALUES (2347,1665,20,1,39,0);

INSERT INTO `order_items` VALUES (2348,1666,13,1,68,0);

INSERT INTO `order_items` VALUES (2349,1667,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2350,1667,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2351,1668,14,3,39.9,0);

INSERT INTO `order_items` VALUES (2352,1668,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2353,1669,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2354,1670,13,1,68,0);

INSERT INTO `order_items` VALUES (2355,1670,17,1,69,0);

INSERT INTO `order_items` VALUES (2356,1670,18,1,159,0);

INSERT INTO `order_items` VALUES (2357,1671,17,1,69,0);

INSERT INTO `order_items` VALUES (2358,1672,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2359,1672,20,1,39,0);

INSERT INTO `order_items` VALUES (2360,1673,4,1,59,0);

INSERT INTO `order_items` VALUES (2361,1673,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2362,1673,17,1,69,0);

INSERT INTO `order_items` VALUES (2363,1674,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2364,1675,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2365,1676,11,1,39,0);

INSERT INTO `order_items` VALUES (2366,1676,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2367,1677,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2368,1678,11,1,39,0);

INSERT INTO `order_items` VALUES (2369,1679,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2370,1680,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2371,1680,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2372,1681,4,3,59,0);

INSERT INTO `order_items` VALUES (2373,1681,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2374,1681,20,2,39,0);

INSERT INTO `order_items` VALUES (2375,1682,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2376,1683,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2377,1684,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2378,1685,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2379,1686,6,1,299,0);

INSERT INTO `order_items` VALUES (2380,1687,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2381,1688,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2382,1688,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2383,1689,7,2,89,0);

INSERT INTO `order_items` VALUES (2384,1689,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2385,1689,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2386,1690,20,1,39,0);

INSERT INTO `order_items` VALUES (2387,1691,7,2,89,0);

INSERT INTO `order_items` VALUES (2388,1691,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2389,1692,4,1,59,0);

INSERT INTO `order_items` VALUES (2390,1692,12,1,79,0);

INSERT INTO `order_items` VALUES (2391,1692,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2392,1693,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2393,1693,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2394,1694,13,2,68,0);

INSERT INTO `order_items` VALUES (2395,1695,8,2,159,0);

INSERT INTO `order_items` VALUES (2396,1695,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2397,1696,17,1,69,0);

INSERT INTO `order_items` VALUES (2398,1697,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2399,1698,12,1,79,0);

INSERT INTO `order_items` VALUES (2400,1699,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2401,1699,20,1,39,0);

INSERT INTO `order_items` VALUES (2402,1700,7,1,89,0);

INSERT INTO `order_items` VALUES (2403,1701,11,1,39,0);

INSERT INTO `order_items` VALUES (2404,1701,20,1,39,0);

INSERT INTO `order_items` VALUES (2405,1702,20,1,39,0);

INSERT INTO `order_items` VALUES (2406,1703,11,1,39,0);

INSERT INTO `order_items` VALUES (2407,1704,11,1,39,0);

INSERT INTO `order_items` VALUES (2408,1704,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2409,1705,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2410,1706,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2411,1707,9,3,129,0);

INSERT INTO `order_items` VALUES (2412,1708,11,1,39,0);

INSERT INTO `order_items` VALUES (2413,1708,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2414,1709,4,1,59,0);

INSERT INTO `order_items` VALUES (2415,1709,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2416,1710,4,1,59,0);

INSERT INTO `order_items` VALUES (2417,1710,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2418,1710,18,1,159,0);

INSERT INTO `order_items` VALUES (2419,1711,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2420,1712,20,1,39,0);

INSERT INTO `order_items` VALUES (2421,1713,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2422,1714,13,1,68,0);

INSERT INTO `order_items` VALUES (2423,1714,17,1,69,0);

INSERT INTO `order_items` VALUES (2424,1715,13,1,68,0);

INSERT INTO `order_items` VALUES (2425,1715,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2426,1715,20,1,39,0);

INSERT INTO `order_items` VALUES (2427,1716,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2428,1716,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2429,1717,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2430,1718,8,2,159,0);

INSERT INTO `order_items` VALUES (2431,1719,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2432,1720,11,1,39,0);

INSERT INTO `order_items` VALUES (2433,1721,9,1,129,0);

INSERT INTO `order_items` VALUES (2434,1722,11,1,39,0);

INSERT INTO `order_items` VALUES (2435,1723,11,1,39,0);

INSERT INTO `order_items` VALUES (2436,1723,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2437,1724,6,1,299,0.05);

INSERT INTO `order_items` VALUES (2438,1724,14,3,39.9,0);

INSERT INTO `order_items` VALUES (2439,1724,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2440,1725,12,1,79,0);

INSERT INTO `order_items` VALUES (2441,1725,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2442,1726,20,1,39,0);

INSERT INTO `order_items` VALUES (2443,1727,13,1,68,0);

INSERT INTO `order_items` VALUES (2444,1728,3,1,169,0);

INSERT INTO `order_items` VALUES (2445,1728,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2446,1729,9,1,129,0);

INSERT INTO `order_items` VALUES (2447,1729,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2448,1729,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2449,1730,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2450,1730,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2451,1731,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2452,1732,13,2,68,0);

INSERT INTO `order_items` VALUES (2453,1733,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2454,1734,18,1,159,0.05);

INSERT INTO `order_items` VALUES (2455,1735,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2456,1736,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2457,1737,11,1,39,0);

INSERT INTO `order_items` VALUES (2458,1737,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2459,1738,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2460,1739,2,1,899,0.05);

INSERT INTO `order_items` VALUES (2461,1739,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2462,1740,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2463,1740,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2464,1741,11,1,39,0);

INSERT INTO `order_items` VALUES (2465,1741,14,3,39.9,0);

INSERT INTO `order_items` VALUES (2466,1742,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2467,1743,7,1,89,0);

INSERT INTO `order_items` VALUES (2468,1743,18,1,159,0);

INSERT INTO `order_items` VALUES (2469,1744,7,2,89,0);

INSERT INTO `order_items` VALUES (2470,1744,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2471,1744,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (2472,1745,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2473,1746,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2474,1747,11,1,39,0);

INSERT INTO `order_items` VALUES (2475,1748,3,1,169,0);

INSERT INTO `order_items` VALUES (2476,1748,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2477,1749,18,1,159,0);

INSERT INTO `order_items` VALUES (2478,1750,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2479,1751,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2480,1752,4,2,59,0);

INSERT INTO `order_items` VALUES (2481,1753,9,2,129,0);

INSERT INTO `order_items` VALUES (2482,1753,11,1,39,0);

INSERT INTO `order_items` VALUES (2483,1754,5,1,399,0.05);

INSERT INTO `order_items` VALUES (2484,1754,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2485,1755,7,1,89,0);

INSERT INTO `order_items` VALUES (2486,1755,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2487,1756,13,1,68,0);

INSERT INTO `order_items` VALUES (2488,1757,7,1,89,0);

INSERT INTO `order_items` VALUES (2489,1757,13,1,68,0);

INSERT INTO `order_items` VALUES (2490,1758,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2491,1758,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2492,1759,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2493,1760,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2494,1761,20,1,39,0);

INSERT INTO `order_items` VALUES (2495,1762,6,1,299,0);

INSERT INTO `order_items` VALUES (2496,1762,13,1,68,0);

INSERT INTO `order_items` VALUES (2497,1763,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2498,1764,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2499,1765,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2500,1765,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2501,1765,17,1,69,0);

INSERT INTO `order_items` VALUES (2502,1766,13,1,68,0);

INSERT INTO `order_items` VALUES (2503,1767,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2504,1767,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2505,1768,4,1,59,0);

INSERT INTO `order_items` VALUES (2506,1768,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2507,1769,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2508,1770,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2509,1771,13,1,68,0);

INSERT INTO `order_items` VALUES (2510,1772,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2511,1773,13,1,68,0);

INSERT INTO `order_items` VALUES (2512,1774,9,1,129,0);

INSERT INTO `order_items` VALUES (2513,1775,7,2,89,0);

INSERT INTO `order_items` VALUES (2514,1776,4,1,59,0);

INSERT INTO `order_items` VALUES (2515,1776,7,3,89,0);

INSERT INTO `order_items` VALUES (2516,1777,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2517,1778,17,3,69,0.10);

INSERT INTO `order_items` VALUES (2518,1779,9,1,129,0);

INSERT INTO `order_items` VALUES (2519,1780,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2520,1781,5,1,399,0.05);

INSERT INTO `order_items` VALUES (2521,1781,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2522,1781,18,1,159,0.10);

INSERT INTO `order_items` VALUES (2523,1782,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2524,1783,12,1,79,0);

INSERT INTO `order_items` VALUES (2525,1783,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2526,1784,11,1,39,0);

INSERT INTO `order_items` VALUES (2527,1784,17,2,69,0);

INSERT INTO `order_items` VALUES (2528,1785,7,1,89,0);

INSERT INTO `order_items` VALUES (2529,1785,13,1,68,0);

INSERT INTO `order_items` VALUES (2530,1786,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2531,1787,13,1,68,0);

INSERT INTO `order_items` VALUES (2532,1788,5,1,399,0);

INSERT INTO `order_items` VALUES (2533,1788,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2534,1789,5,1,399,0.10);

INSERT INTO `order_items` VALUES (2535,1789,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2536,1790,11,1,39,0);

INSERT INTO `order_items` VALUES (2537,1791,6,1,299,0.10);

INSERT INTO `order_items` VALUES (2538,1792,20,1,39,0);

INSERT INTO `order_items` VALUES (2539,1793,4,1,59,0);

INSERT INTO `order_items` VALUES (2540,1794,17,1,69,0);

INSERT INTO `order_items` VALUES (2541,1795,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2542,1796,4,1,59,0);

INSERT INTO `order_items` VALUES (2543,1796,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2544,1796,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2545,1797,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2546,1798,6,1,299,0);

INSERT INTO `order_items` VALUES (2547,1799,4,1,59,0.10);

INSERT INTO `order_items` VALUES (2548,1800,7,1,89,0);

INSERT INTO `order_items` VALUES (2549,1801,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2550,1802,12,2,79,0);

INSERT INTO `order_items` VALUES (2551,1803,9,1,129,0);

INSERT INTO `order_items` VALUES (2552,1803,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2553,1803,20,1,39,0);

INSERT INTO `order_items` VALUES (2554,1804,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (2555,1804,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2556,1805,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2557,1806,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2558,1807,12,1,79,0);

INSERT INTO `order_items` VALUES (2559,1808,3,1,169,0);

INSERT INTO `order_items` VALUES (2560,1808,12,2,79,0);

INSERT INTO `order_items` VALUES (2561,1808,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2562,1809,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2563,1810,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2564,1811,7,1,89,0);

INSERT INTO `order_items` VALUES (2565,1811,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2566,1812,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2567,1813,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2568,1814,11,1,39,0);

INSERT INTO `order_items` VALUES (2569,1814,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2570,1815,20,1,39,0);

INSERT INTO `order_items` VALUES (2571,1816,2,1,899,0);

INSERT INTO `order_items` VALUES (2572,1816,4,1,59,0);

INSERT INTO `order_items` VALUES (2573,1816,7,1,89,0);

INSERT INTO `order_items` VALUES (2574,1817,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2575,1818,3,1,169,0);

INSERT INTO `order_items` VALUES (2576,1818,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2577,1818,18,1,159,0);

INSERT INTO `order_items` VALUES (2578,1819,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2579,1819,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2580,1820,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2581,1821,19,1,199,0.05);

INSERT INTO `order_items` VALUES (2582,1822,3,1,169,0);

INSERT INTO `order_items` VALUES (2583,1823,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2584,1824,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2585,1824,18,1,159,0);

INSERT INTO `order_items` VALUES (2586,1825,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2587,1826,4,1,59,0);

INSERT INTO `order_items` VALUES (2588,1826,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2589,1826,17,1,69,0.10);

INSERT INTO `order_items` VALUES (2590,1827,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2591,1828,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2592,1829,11,2,39,0);

INSERT INTO `order_items` VALUES (2593,1830,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2594,1830,13,1,68,0);

INSERT INTO `order_items` VALUES (2595,1831,4,3,59,0);

INSERT INTO `order_items` VALUES (2596,1832,13,1,68,0);

INSERT INTO `order_items` VALUES (2597,1833,19,1,199,0.10);

INSERT INTO `order_items` VALUES (2598,1834,13,1,68,0);

INSERT INTO `order_items` VALUES (2599,1835,11,2,39,0.10);

INSERT INTO `order_items` VALUES (2600,1835,18,1,159,0.05);

INSERT INTO `order_items` VALUES (2601,1836,6,2,299,0);

INSERT INTO `order_items` VALUES (2602,1836,13,1,68,0);

INSERT INTO `order_items` VALUES (2603,1836,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2604,1837,4,1,59,0);

INSERT INTO `order_items` VALUES (2605,1837,19,1,199,0);

INSERT INTO `order_items` VALUES (2606,1838,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2607,1838,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2608,1839,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2609,1840,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2610,1841,13,1,68,0);

INSERT INTO `order_items` VALUES (2611,1842,4,1,59,0);

INSERT INTO `order_items` VALUES (2612,1842,13,1,68,0);

INSERT INTO `order_items` VALUES (2613,1843,13,2,68,0);

INSERT INTO `order_items` VALUES (2614,1844,13,1,68,0);

INSERT INTO `order_items` VALUES (2615,1844,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2616,1844,20,1,39,0);

INSERT INTO `order_items` VALUES (2617,1845,12,1,79,0);

INSERT INTO `order_items` VALUES (2618,1846,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2619,1847,4,1,59,0);

INSERT INTO `order_items` VALUES (2620,1848,7,2,89,0.10);

INSERT INTO `order_items` VALUES (2621,1849,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2622,1849,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2623,1850,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2624,1850,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2625,1851,4,1,59,0);

INSERT INTO `order_items` VALUES (2626,1852,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2627,1853,3,1,169,0);

INSERT INTO `order_items` VALUES (2628,1853,6,1,299,0);

INSERT INTO `order_items` VALUES (2629,1853,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2630,1854,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2631,1855,8,2,159,0.10);

INSERT INTO `order_items` VALUES (2632,1856,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2633,1856,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2634,1857,17,1,69,0);

INSERT INTO `order_items` VALUES (2635,1858,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2636,1859,17,1,69,0);

INSERT INTO `order_items` VALUES (2637,1859,20,1,39,0);

INSERT INTO `order_items` VALUES (2638,1860,3,1,169,0.10);

INSERT INTO `order_items` VALUES (2639,1860,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2640,1860,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2641,1861,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (2642,1862,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2643,1863,17,2,69,0);

INSERT INTO `order_items` VALUES (2644,1864,5,2,399,0);

INSERT INTO `order_items` VALUES (2645,1865,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2646,1865,17,1,69,0);

INSERT INTO `order_items` VALUES (2647,1866,2,1,899,0);

INSERT INTO `order_items` VALUES (2648,1866,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2649,1867,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2650,1868,5,1,399,0);

INSERT INTO `order_items` VALUES (2651,1868,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2652,1869,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2653,1870,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2654,1870,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2655,1871,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2656,1872,11,1,39,0);

INSERT INTO `order_items` VALUES (2657,1873,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2658,1874,4,1,59,0);

INSERT INTO `order_items` VALUES (2659,1874,13,1,68,0);

INSERT INTO `order_items` VALUES (2660,1875,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2661,1876,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2662,1877,3,1,169,0);

INSERT INTO `order_items` VALUES (2663,1877,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2664,1877,20,1,39,0.10);

INSERT INTO `order_items` VALUES (2665,1878,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2666,1879,4,1,59,0);

INSERT INTO `order_items` VALUES (2667,1879,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2668,1880,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2669,1881,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2670,1882,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2671,1883,13,1,68,0);

INSERT INTO `order_items` VALUES (2672,1884,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2673,1884,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2674,1885,4,1,59,0);

INSERT INTO `order_items` VALUES (2675,1885,5,1,399,0);

INSERT INTO `order_items` VALUES (2676,1886,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2677,1887,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2678,1888,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2679,1889,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2680,1890,3,1,169,0);

INSERT INTO `order_items` VALUES (2681,1890,13,1,68,0);

INSERT INTO `order_items` VALUES (2682,1891,9,1,129,0);

INSERT INTO `order_items` VALUES (2683,1891,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2684,1892,3,3,169,0);

INSERT INTO `order_items` VALUES (2685,1893,13,1,68,0);

INSERT INTO `order_items` VALUES (2686,1894,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2687,1895,13,1,68,0);

INSERT INTO `order_items` VALUES (2688,1896,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2689,1896,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2690,1897,13,2,68,0);

INSERT INTO `order_items` VALUES (2691,1897,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2692,1897,18,1,159,0);

INSERT INTO `order_items` VALUES (2693,1898,11,1,39,0);

INSERT INTO `order_items` VALUES (2694,1899,3,1,169,0);

INSERT INTO `order_items` VALUES (2695,1899,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2696,1900,11,1,39,0);

INSERT INTO `order_items` VALUES (2697,1900,13,1,68,0);

INSERT INTO `order_items` VALUES (2698,1901,4,1,59,0);

INSERT INTO `order_items` VALUES (2699,1901,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2700,1902,18,1,159,0);

INSERT INTO `order_items` VALUES (2701,1903,7,2,89,0.10);

INSERT INTO `order_items` VALUES (2702,1904,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2703,1904,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2704,1905,13,1,68,0);

INSERT INTO `order_items` VALUES (2705,1905,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2706,1906,13,1,68,0);

INSERT INTO `order_items` VALUES (2707,1906,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2708,1906,17,2,69,0);

INSERT INTO `order_items` VALUES (2709,1907,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2710,1908,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2711,1908,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (2712,1909,3,2,169,0);

INSERT INTO `order_items` VALUES (2713,1909,6,1,299,0);

INSERT INTO `order_items` VALUES (2714,1909,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2715,1910,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2716,1911,7,1,89,0);

INSERT INTO `order_items` VALUES (2717,1911,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2718,1912,3,1,169,0.05);

INSERT INTO `order_items` VALUES (2719,1913,19,2,199,0.10);

INSERT INTO `order_items` VALUES (2720,1914,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2721,1915,12,1,79,0);

INSERT INTO `order_items` VALUES (2722,1915,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2723,1916,13,2,68,0);

INSERT INTO `order_items` VALUES (2724,1916,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2725,1917,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2726,1918,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2727,1918,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2728,1919,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2729,1920,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2730,1921,11,1,39,0);

INSERT INTO `order_items` VALUES (2731,1921,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2732,1922,9,1,129,0);

INSERT INTO `order_items` VALUES (2733,1922,11,1,39,0);

INSERT INTO `order_items` VALUES (2734,1923,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2735,1923,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2736,1924,11,1,39,0);

INSERT INTO `order_items` VALUES (2737,1925,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2738,1926,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2739,1927,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2740,1928,13,1,68,0);

INSERT INTO `order_items` VALUES (2741,1929,13,1,68,0);

INSERT INTO `order_items` VALUES (2742,1930,7,1,89,0);

INSERT INTO `order_items` VALUES (2743,1931,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2744,1932,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2745,1933,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2746,1934,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2747,1935,11,1,39,0.10);

INSERT INTO `order_items` VALUES (2748,1935,13,2,68,0.05);

INSERT INTO `order_items` VALUES (2749,1936,3,1,169,0);

INSERT INTO `order_items` VALUES (2750,1937,9,1,129,0);

INSERT INTO `order_items` VALUES (2751,1937,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2752,1937,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2753,1938,4,1,59,0);

INSERT INTO `order_items` VALUES (2754,1938,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (2755,1939,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2756,1940,12,2,79,0.05);

INSERT INTO `order_items` VALUES (2757,1940,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2758,1940,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2759,1941,12,1,79,0);

INSERT INTO `order_items` VALUES (2760,1942,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (2761,1943,3,1,169,0);

INSERT INTO `order_items` VALUES (2762,1944,12,1,79,0);

INSERT INTO `order_items` VALUES (2763,1945,10,1,699,0.05);

INSERT INTO `order_items` VALUES (2764,1946,12,1,79,0);

INSERT INTO `order_items` VALUES (2765,1946,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2766,1947,7,1,89,0.05);

INSERT INTO `order_items` VALUES (2767,1947,11,2,39,0);

INSERT INTO `order_items` VALUES (2768,1947,13,1,68,0);

INSERT INTO `order_items` VALUES (2769,1948,7,1,89,0);

INSERT INTO `order_items` VALUES (2770,1948,9,1,129,0);

INSERT INTO `order_items` VALUES (2771,1949,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2772,1950,7,1,89,0);

INSERT INTO `order_items` VALUES (2773,1951,12,1,79,0);

INSERT INTO `order_items` VALUES (2774,1951,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2775,1952,17,1,69,0.05);

INSERT INTO `order_items` VALUES (2776,1953,13,1,68,0);

INSERT INTO `order_items` VALUES (2777,1953,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2778,1953,20,1,39,0);

INSERT INTO `order_items` VALUES (2779,1954,9,1,129,0.10);

INSERT INTO `order_items` VALUES (2780,1954,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2781,1954,17,2,69,0);

INSERT INTO `order_items` VALUES (2782,1955,12,1,79,0);

INSERT INTO `order_items` VALUES (2783,1956,11,1,39,0);

INSERT INTO `order_items` VALUES (2784,1957,5,2,399,0.05);

INSERT INTO `order_items` VALUES (2785,1958,11,1,39,0);

INSERT INTO `order_items` VALUES (2786,1958,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2787,1959,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2788,1959,7,1,89,0);

INSERT INTO `order_items` VALUES (2789,1960,4,1,59,0);

INSERT INTO `order_items` VALUES (2790,1960,7,3,89,0);

INSERT INTO `order_items` VALUES (2791,1960,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2792,1961,4,1,59,0);

INSERT INTO `order_items` VALUES (2793,1962,20,2,39,0.05);

INSERT INTO `order_items` VALUES (2794,1963,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2795,1963,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2796,1964,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2797,1964,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2798,1965,12,1,79,0);

INSERT INTO `order_items` VALUES (2799,1966,12,1,79,0);

INSERT INTO `order_items` VALUES (2800,1966,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2801,1967,3,1,169,0);

INSERT INTO `order_items` VALUES (2802,1968,17,1,69,0);

INSERT INTO `order_items` VALUES (2803,1969,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2804,1970,5,1,399,0);

INSERT INTO `order_items` VALUES (2805,1971,13,1,68,0);

INSERT INTO `order_items` VALUES (2806,1972,12,1,79,0);

INSERT INTO `order_items` VALUES (2807,1972,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2808,1973,11,1,39,0);

INSERT INTO `order_items` VALUES (2809,1973,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2810,1974,20,1,39,0);

INSERT INTO `order_items` VALUES (2811,1975,13,1,68,0);

INSERT INTO `order_items` VALUES (2812,1976,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2813,1977,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (2814,1978,6,1,299,0);

INSERT INTO `order_items` VALUES (2815,1979,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2816,1979,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2817,1980,4,1,59,0);

INSERT INTO `order_items` VALUES (2818,1980,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2819,1981,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2820,1982,3,2,169,0);

INSERT INTO `order_items` VALUES (2821,1983,15,2,32.9,0);

INSERT INTO `order_items` VALUES (2822,1984,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2823,1985,13,1,68,0);

INSERT INTO `order_items` VALUES (2824,1986,9,1,129,0);

INSERT INTO `order_items` VALUES (2825,1986,12,1,79,0);

INSERT INTO `order_items` VALUES (2826,1986,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2827,1987,7,1,89,0);

INSERT INTO `order_items` VALUES (2828,1988,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2829,1989,13,2,68,0);

INSERT INTO `order_items` VALUES (2830,1990,13,2,68,0);

INSERT INTO `order_items` VALUES (2831,1991,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2832,1992,7,1,89,0);

INSERT INTO `order_items` VALUES (2833,1993,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2834,1994,13,1,68,0);

INSERT INTO `order_items` VALUES (2835,1995,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2836,1996,12,1,79,0);

INSERT INTO `order_items` VALUES (2837,1996,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2838,1996,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2839,1997,3,1,169,0);

INSERT INTO `order_items` VALUES (2840,1997,7,1,89,0);

INSERT INTO `order_items` VALUES (2841,1998,12,1,79,0);

INSERT INTO `order_items` VALUES (2842,1999,4,1,59,0);

INSERT INTO `order_items` VALUES (2843,1999,9,1,129,0);

INSERT INTO `order_items` VALUES (2844,2000,9,1,129,0);

INSERT INTO `order_items` VALUES (2845,2001,3,2,169,0);

INSERT INTO `order_items` VALUES (2846,2001,4,1,59,0);

INSERT INTO `order_items` VALUES (2847,2002,8,1,159,0);

INSERT INTO `order_items` VALUES (2848,2003,20,1,39,0);

INSERT INTO `order_items` VALUES (2849,2004,4,1,59,0);

INSERT INTO `order_items` VALUES (2850,2005,11,2,39,0.05);

INSERT INTO `order_items` VALUES (2851,2005,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2852,2006,3,1,169,0);

INSERT INTO `order_items` VALUES (2853,2006,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2854,2007,3,1,169,0);

INSERT INTO `order_items` VALUES (2855,2008,11,1,39,0);

INSERT INTO `order_items` VALUES (2856,2009,4,1,59,0);

INSERT INTO `order_items` VALUES (2857,2010,7,1,89,0);

INSERT INTO `order_items` VALUES (2858,2010,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2859,2011,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2860,2012,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2861,2013,12,1,79,0);

INSERT INTO `order_items` VALUES (2862,2013,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2863,2014,4,2,59,0.05);

INSERT INTO `order_items` VALUES (2864,2014,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2865,2015,4,1,59,0);

INSERT INTO `order_items` VALUES (2866,2016,7,1,89,0);

INSERT INTO `order_items` VALUES (2867,2016,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2868,2016,20,2,39,0);

INSERT INTO `order_items` VALUES (2869,2017,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2870,2018,16,2,24.9,0);

INSERT INTO `order_items` VALUES (2871,2019,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2872,2020,7,2,89,0);

INSERT INTO `order_items` VALUES (2873,2020,17,1,69,0);

INSERT INTO `order_items` VALUES (2874,2021,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2875,2022,10,1,699,0);

INSERT INTO `order_items` VALUES (2876,2023,4,1,59,0.10);

INSERT INTO `order_items` VALUES (2877,2023,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (2878,2023,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2879,2024,7,1,89,0.10);

INSERT INTO `order_items` VALUES (2880,2024,11,2,39,0);

INSERT INTO `order_items` VALUES (2881,2025,18,1,159,0);

INSERT INTO `order_items` VALUES (2882,2026,9,1,129,0);

INSERT INTO `order_items` VALUES (2883,2027,7,1,89,0);

INSERT INTO `order_items` VALUES (2884,2028,10,1,699,0.05);

INSERT INTO `order_items` VALUES (2885,2029,11,1,39,0);

INSERT INTO `order_items` VALUES (2886,2030,3,2,169,0);

INSERT INTO `order_items` VALUES (2887,2030,9,1,129,0);

INSERT INTO `order_items` VALUES (2888,2031,12,1,79,0.05);

INSERT INTO `order_items` VALUES (2889,2032,13,1,68,0);

INSERT INTO `order_items` VALUES (2890,2033,11,1,39,0);

INSERT INTO `order_items` VALUES (2891,2033,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2892,2034,20,2,39,0.10);

INSERT INTO `order_items` VALUES (2893,2035,9,2,129,0);

INSERT INTO `order_items` VALUES (2894,2035,20,2,39,0);

INSERT INTO `order_items` VALUES (2895,2036,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2896,2037,10,1,699,0);

INSERT INTO `order_items` VALUES (2897,2037,18,1,159,0);

INSERT INTO `order_items` VALUES (2898,2038,4,1,59,0);

INSERT INTO `order_items` VALUES (2899,2039,9,3,129,0.10);

INSERT INTO `order_items` VALUES (2900,2040,13,1,68,0);

INSERT INTO `order_items` VALUES (2901,2041,4,1,59,0);

INSERT INTO `order_items` VALUES (2902,2042,8,1,159,0.05);

INSERT INTO `order_items` VALUES (2903,2043,4,1,59,0);

INSERT INTO `order_items` VALUES (2904,2044,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2905,2044,13,2,68,0);

INSERT INTO `order_items` VALUES (2906,2045,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2907,2046,4,1,59,0);

INSERT INTO `order_items` VALUES (2908,2046,5,1,399,0);

INSERT INTO `order_items` VALUES (2909,2046,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2910,2047,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2911,2047,11,2,39,0);

INSERT INTO `order_items` VALUES (2912,2047,17,1,69,0);

INSERT INTO `order_items` VALUES (2913,2048,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2914,2049,10,1,699,0.05);

INSERT INTO `order_items` VALUES (2915,2049,16,3,24.9,0);

INSERT INTO `order_items` VALUES (2916,2050,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2917,2051,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2918,2052,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2919,2052,12,1,79,0);

INSERT INTO `order_items` VALUES (2920,2053,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2921,2054,3,1,169,0);

INSERT INTO `order_items` VALUES (2922,2054,9,1,129,0);

INSERT INTO `order_items` VALUES (2923,2055,9,1,129,0);

INSERT INTO `order_items` VALUES (2924,2055,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (2925,2055,19,1,199,0.05);

INSERT INTO `order_items` VALUES (2926,2056,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2927,2056,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2928,2057,9,1,129,0.05);

INSERT INTO `order_items` VALUES (2929,2058,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2930,2058,14,3,39.9,0);

INSERT INTO `order_items` VALUES (2931,2059,6,1,299,0);

INSERT INTO `order_items` VALUES (2932,2060,9,1,129,0);

INSERT INTO `order_items` VALUES (2933,2060,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2934,2060,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2935,2061,9,1,129,0.05);

INSERT INTO `order_items` VALUES (2936,2062,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2937,2063,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2938,2064,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2939,2065,5,1,399,0.05);

INSERT INTO `order_items` VALUES (2940,2065,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2941,2066,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2942,2067,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2943,2067,13,1,68,0);

INSERT INTO `order_items` VALUES (2944,2067,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2945,2068,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2946,2069,4,2,59,0);

INSERT INTO `order_items` VALUES (2947,2069,18,1,159,0);

INSERT INTO `order_items` VALUES (2948,2070,9,1,129,0);

INSERT INTO `order_items` VALUES (2949,2071,7,1,89,0);

INSERT INTO `order_items` VALUES (2950,2071,19,1,199,0.10);

INSERT INTO `order_items` VALUES (2951,2072,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2952,2072,20,1,39,0);

INSERT INTO `order_items` VALUES (2953,2073,4,1,59,0);

INSERT INTO `order_items` VALUES (2954,2074,3,1,169,0);

INSERT INTO `order_items` VALUES (2955,2074,13,1,68,0);

INSERT INTO `order_items` VALUES (2956,2075,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2957,2076,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2958,2076,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (2959,2077,12,1,79,0);

INSERT INTO `order_items` VALUES (2960,2077,13,1,68,0);

INSERT INTO `order_items` VALUES (2961,2077,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2962,2078,5,1,399,0);

INSERT INTO `order_items` VALUES (2963,2079,5,1,399,0.05);

INSERT INTO `order_items` VALUES (2964,2080,13,1,68,0);

INSERT INTO `order_items` VALUES (2965,2081,11,1,39,0);

INSERT INTO `order_items` VALUES (2966,2082,20,1,39,0);

INSERT INTO `order_items` VALUES (2967,2083,6,1,299,0);

INSERT INTO `order_items` VALUES (2968,2084,13,1,68,0);

INSERT INTO `order_items` VALUES (2969,2084,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2970,2085,14,2,39.9,0);

INSERT INTO `order_items` VALUES (2971,2086,12,1,79,0.10);

INSERT INTO `order_items` VALUES (2972,2087,4,1,59,0.05);

INSERT INTO `order_items` VALUES (2973,2088,20,1,39,0);

INSERT INTO `order_items` VALUES (2974,2089,5,1,399,0);

INSERT INTO `order_items` VALUES (2975,2089,9,1,129,0);

INSERT INTO `order_items` VALUES (2976,2090,4,1,59,0);

INSERT INTO `order_items` VALUES (2977,2090,14,3,39.9,0.05);

INSERT INTO `order_items` VALUES (2978,2090,20,1,39,0.05);

INSERT INTO `order_items` VALUES (2979,2091,13,1,68,0.05);

INSERT INTO `order_items` VALUES (2980,2091,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2981,2092,12,1,79,0);

INSERT INTO `order_items` VALUES (2982,2093,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2983,2094,20,2,39,0.10);

INSERT INTO `order_items` VALUES (2984,2095,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2985,2095,17,1,69,0);

INSERT INTO `order_items` VALUES (2986,2096,5,1,399,0);

INSERT INTO `order_items` VALUES (2987,2096,16,1,24.9,0);

INSERT INTO `order_items` VALUES (2988,2097,14,1,39.9,0);

INSERT INTO `order_items` VALUES (2989,2098,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (2990,2098,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (2991,2099,15,1,32.9,0);

INSERT INTO `order_items` VALUES (2992,2100,13,1,68,0.10);

INSERT INTO `order_items` VALUES (2993,2101,11,1,39,0.05);

INSERT INTO `order_items` VALUES (2994,2101,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (2995,2102,13,1,68,0);

INSERT INTO `order_items` VALUES (2996,2103,12,1,79,0);

INSERT INTO `order_items` VALUES (2997,2104,20,1,39,0.10);

INSERT INTO `order_items` VALUES (2998,2105,7,1,89,0);

INSERT INTO `order_items` VALUES (2999,2106,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3000,2107,4,1,59,0);

INSERT INTO `order_items` VALUES (3001,2108,5,1,399,0);

INSERT INTO `order_items` VALUES (3002,2108,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3003,2109,12,2,79,0);

INSERT INTO `order_items` VALUES (3004,2110,12,1,79,0.10);

INSERT INTO `order_items` VALUES (3005,2111,4,1,59,0);

INSERT INTO `order_items` VALUES (3006,2111,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (3007,2112,6,1,299,0.10);

INSERT INTO `order_items` VALUES (3008,2113,11,2,39,0);

INSERT INTO `order_items` VALUES (3009,2113,17,1,69,0.05);

INSERT INTO `order_items` VALUES (3010,2114,13,1,68,0);

INSERT INTO `order_items` VALUES (3011,2115,9,1,129,0);

INSERT INTO `order_items` VALUES (3012,2116,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3013,2116,11,1,39,0);

INSERT INTO `order_items` VALUES (3014,2117,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3015,2118,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3016,2119,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3017,2120,11,1,39,0);

INSERT INTO `order_items` VALUES (3018,2121,11,2,39,0);

INSERT INTO `order_items` VALUES (3019,2122,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3020,2123,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3021,2124,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3022,2125,15,3,32.9,0);

INSERT INTO `order_items` VALUES (3023,2126,3,2,169,0);

INSERT INTO `order_items` VALUES (3024,2127,4,1,59,0);

INSERT INTO `order_items` VALUES (3025,2128,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3026,2129,12,1,79,0);

INSERT INTO `order_items` VALUES (3027,2130,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3028,2131,3,1,169,0);

INSERT INTO `order_items` VALUES (3029,2131,10,1,699,0.05);

INSERT INTO `order_items` VALUES (3030,2131,18,2,159,0);

INSERT INTO `order_items` VALUES (3031,2132,11,3,39,0);

INSERT INTO `order_items` VALUES (3032,2133,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3033,2134,9,1,129,0);

INSERT INTO `order_items` VALUES (3034,2135,20,1,39,0);

INSERT INTO `order_items` VALUES (3035,2136,12,1,79,0.10);

INSERT INTO `order_items` VALUES (3036,2137,13,1,68,0);

INSERT INTO `order_items` VALUES (3037,2138,4,1,59,0);

INSERT INTO `order_items` VALUES (3038,2138,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3039,2139,3,1,169,0);

INSERT INTO `order_items` VALUES (3040,2140,5,2,399,0);

INSERT INTO `order_items` VALUES (3041,2141,3,1,169,0);

INSERT INTO `order_items` VALUES (3042,2141,11,1,39,0);

INSERT INTO `order_items` VALUES (3043,2142,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3044,2143,11,1,39,0);

INSERT INTO `order_items` VALUES (3045,2144,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3046,2145,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3047,2146,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3048,2147,12,1,79,0);

INSERT INTO `order_items` VALUES (3049,2148,12,2,79,0);

INSERT INTO `order_items` VALUES (3050,2149,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3051,2149,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3052,2150,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3053,2151,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3054,2152,20,1,39,0);

INSERT INTO `order_items` VALUES (3055,2153,12,1,79,0);

INSERT INTO `order_items` VALUES (3056,2153,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3057,2154,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3058,2155,11,1,39,0);

INSERT INTO `order_items` VALUES (3059,2156,11,1,39,0);

INSERT INTO `order_items` VALUES (3060,2157,13,1,68,0);

INSERT INTO `order_items` VALUES (3061,2158,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3062,2158,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3063,2159,13,1,68,0);

INSERT INTO `order_items` VALUES (3064,2159,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3065,2160,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3066,2161,9,1,129,0);

INSERT INTO `order_items` VALUES (3067,2162,17,1,69,0);

INSERT INTO `order_items` VALUES (3068,2163,9,1,129,0);

INSERT INTO `order_items` VALUES (3069,2163,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3070,2164,13,1,68,0);

INSERT INTO `order_items` VALUES (3071,2165,3,1,169,0);

INSERT INTO `order_items` VALUES (3072,2166,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3073,2167,7,1,89,0);

INSERT INTO `order_items` VALUES (3074,2167,11,1,39,0);

INSERT INTO `order_items` VALUES (3075,2167,13,1,68,0);

INSERT INTO `order_items` VALUES (3076,2168,11,1,39,0);

INSERT INTO `order_items` VALUES (3077,2168,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (3078,2169,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3079,2169,20,1,39,0);

INSERT INTO `order_items` VALUES (3080,2170,13,1,68,0);

INSERT INTO `order_items` VALUES (3081,2170,20,1,39,0);

INSERT INTO `order_items` VALUES (3082,2171,11,1,39,0);

INSERT INTO `order_items` VALUES (3083,2172,6,1,299,0);

INSERT INTO `order_items` VALUES (3084,2173,18,1,159,0);

INSERT INTO `order_items` VALUES (3085,2174,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3086,2175,13,1,68,0);

INSERT INTO `order_items` VALUES (3087,2175,17,1,69,0);

INSERT INTO `order_items` VALUES (3088,2176,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3089,2177,10,1,699,0);

INSERT INTO `order_items` VALUES (3090,2177,13,1,68,0);

INSERT INTO `order_items` VALUES (3091,2178,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3092,2178,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3093,2179,13,1,68,0);

INSERT INTO `order_items` VALUES (3094,2180,11,1,39,0.10);

INSERT INTO `order_items` VALUES (3095,2181,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3096,2182,13,1,68,0);

INSERT INTO `order_items` VALUES (3097,2182,20,2,39,0.10);

INSERT INTO `order_items` VALUES (3098,2183,2,1,899,0);

INSERT INTO `order_items` VALUES (3099,2183,13,1,68,0);

INSERT INTO `order_items` VALUES (3100,2183,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3101,2184,1,1,4299,0);

INSERT INTO `order_items` VALUES (3102,2185,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3103,2185,20,1,39,0);

INSERT INTO `order_items` VALUES (3104,2186,17,1,69,0);

INSERT INTO `order_items` VALUES (3105,2187,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3106,2188,17,1,69,0);

INSERT INTO `order_items` VALUES (3107,2189,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3108,2190,4,1,59,0);

INSERT INTO `order_items` VALUES (3109,2191,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3110,2192,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3111,2193,13,1,68,0);

INSERT INTO `order_items` VALUES (3112,2193,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3113,2194,9,1,129,0);

INSERT INTO `order_items` VALUES (3114,2194,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3115,2194,20,1,39,0);

INSERT INTO `order_items` VALUES (3116,2195,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3117,2196,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3118,2197,4,1,59,0);

INSERT INTO `order_items` VALUES (3119,2198,17,2,69,0.05);

INSERT INTO `order_items` VALUES (3120,2199,13,1,68,0);

INSERT INTO `order_items` VALUES (3121,2200,4,1,59,0);

INSERT INTO `order_items` VALUES (3122,2200,13,1,68,0);

INSERT INTO `order_items` VALUES (3123,2201,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3124,2201,13,1,68,0);

INSERT INTO `order_items` VALUES (3125,2202,17,1,69,0.05);

INSERT INTO `order_items` VALUES (3126,2203,4,2,59,0);

INSERT INTO `order_items` VALUES (3127,2204,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3128,2205,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3129,2206,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3130,2207,20,2,39,0);

INSERT INTO `order_items` VALUES (3131,2208,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3132,2209,12,1,79,0);

INSERT INTO `order_items` VALUES (3133,2210,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3134,2210,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3135,2211,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3136,2212,4,1,59,0);

INSERT INTO `order_items` VALUES (3137,2213,5,1,399,0);

INSERT INTO `order_items` VALUES (3138,2214,4,1,59,0);

INSERT INTO `order_items` VALUES (3139,2214,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3140,2215,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3141,2216,2,1,899,0);

INSERT INTO `order_items` VALUES (3142,2216,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3143,2217,4,1,59,0);

INSERT INTO `order_items` VALUES (3144,2218,11,1,39,0.10);

INSERT INTO `order_items` VALUES (3145,2219,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3146,2220,3,1,169,0);

INSERT INTO `order_items` VALUES (3147,2221,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3148,2222,13,1,68,0);

INSERT INTO `order_items` VALUES (3149,2222,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3150,2223,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3151,2223,18,1,159,0);

INSERT INTO `order_items` VALUES (3152,2224,7,1,89,0);

INSERT INTO `order_items` VALUES (3153,2224,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3154,2225,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3155,2226,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3156,2226,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3157,2227,13,1,68,0);

INSERT INTO `order_items` VALUES (3158,2228,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3159,2228,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3160,2229,3,1,169,0);

INSERT INTO `order_items` VALUES (3161,2230,20,1,39,0);

INSERT INTO `order_items` VALUES (3162,2231,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3163,2232,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3164,2233,13,1,68,0);

INSERT INTO `order_items` VALUES (3165,2234,11,1,39,0);

INSERT INTO `order_items` VALUES (3166,2235,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3167,2236,11,1,39,0);

INSERT INTO `order_items` VALUES (3168,2237,6,1,299,0);

INSERT INTO `order_items` VALUES (3169,2237,12,1,79,0);

INSERT INTO `order_items` VALUES (3170,2238,9,1,129,0);

INSERT INTO `order_items` VALUES (3171,2238,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3172,2239,7,1,89,0);

INSERT INTO `order_items` VALUES (3173,2240,8,1,159,0);

INSERT INTO `order_items` VALUES (3174,2241,19,1,199,0);

INSERT INTO `order_items` VALUES (3175,2242,13,2,68,0);

INSERT INTO `order_items` VALUES (3176,2242,17,1,69,0);

INSERT INTO `order_items` VALUES (3177,2243,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3178,2244,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3179,2245,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3180,2246,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3181,2247,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3182,2247,19,1,199,0);

INSERT INTO `order_items` VALUES (3183,2248,9,1,129,0);

INSERT INTO `order_items` VALUES (3184,2249,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3185,2249,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3186,2250,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3187,2251,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3188,2252,9,2,129,0);

INSERT INTO `order_items` VALUES (3189,2253,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3190,2253,6,1,299,0);

INSERT INTO `order_items` VALUES (3191,2254,11,1,39,0);

INSERT INTO `order_items` VALUES (3192,2255,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3193,2256,13,1,68,0);

INSERT INTO `order_items` VALUES (3194,2257,7,1,89,0);

INSERT INTO `order_items` VALUES (3195,2258,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3196,2258,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3197,2259,13,1,68,0);

INSERT INTO `order_items` VALUES (3198,2260,7,1,89,0);

INSERT INTO `order_items` VALUES (3199,2260,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3200,2260,17,1,69,0);

INSERT INTO `order_items` VALUES (3201,2261,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3202,2262,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3203,2263,4,1,59,0);

INSERT INTO `order_items` VALUES (3204,2264,13,1,68,0);

INSERT INTO `order_items` VALUES (3205,2265,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3206,2266,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3207,2267,13,2,68,0);

INSERT INTO `order_items` VALUES (3208,2268,9,1,129,0);

INSERT INTO `order_items` VALUES (3209,2268,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3210,2268,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3211,2269,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3212,2270,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3213,2271,17,1,69,0);

INSERT INTO `order_items` VALUES (3214,2271,18,1,159,0.05);

INSERT INTO `order_items` VALUES (3215,2272,11,1,39,0);

INSERT INTO `order_items` VALUES (3216,2272,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3217,2273,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3218,2274,13,1,68,0);

INSERT INTO `order_items` VALUES (3219,2275,17,2,69,0);

INSERT INTO `order_items` VALUES (3220,2276,11,1,39,0);

INSERT INTO `order_items` VALUES (3221,2277,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3222,2278,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3223,2279,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3224,2280,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3225,2281,13,1,68,0);

INSERT INTO `order_items` VALUES (3226,2282,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3227,2282,18,3,159,0.05);

INSERT INTO `order_items` VALUES (3228,2283,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3229,2283,9,1,129,0);

INSERT INTO `order_items` VALUES (3230,2284,12,3,79,0);

INSERT INTO `order_items` VALUES (3231,2284,13,1,68,0);

INSERT INTO `order_items` VALUES (3232,2285,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3233,2285,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3234,2286,3,1,169,0);

INSERT INTO `order_items` VALUES (3235,2287,4,1,59,0);

INSERT INTO `order_items` VALUES (3236,2287,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3237,2288,13,1,68,0);

INSERT INTO `order_items` VALUES (3238,2288,18,2,159,0);

INSERT INTO `order_items` VALUES (3239,2289,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3240,2290,12,1,79,0);

INSERT INTO `order_items` VALUES (3241,2290,20,1,39,0);

INSERT INTO `order_items` VALUES (3242,2291,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3243,2292,9,2,129,0);

INSERT INTO `order_items` VALUES (3244,2293,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3245,2293,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3246,2294,4,1,59,0);

INSERT INTO `order_items` VALUES (3247,2294,9,1,129,0);

INSERT INTO `order_items` VALUES (3248,2295,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3249,2296,7,1,89,0);

INSERT INTO `order_items` VALUES (3250,2297,4,1,59,0);

INSERT INTO `order_items` VALUES (3251,2297,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3252,2297,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3253,2298,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3254,2299,5,1,399,0.05);

INSERT INTO `order_items` VALUES (3255,2299,20,1,39,0.10);

INSERT INTO `order_items` VALUES (3256,2300,7,1,89,0);

INSERT INTO `order_items` VALUES (3257,2301,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3258,2302,4,1,59,0);

INSERT INTO `order_items` VALUES (3259,2302,9,1,129,0);

INSERT INTO `order_items` VALUES (3260,2303,19,1,199,0);

INSERT INTO `order_items` VALUES (3261,2304,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3262,2305,3,1,169,0);

INSERT INTO `order_items` VALUES (3263,2305,13,1,68,0);

INSERT INTO `order_items` VALUES (3264,2305,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3265,2306,13,1,68,0);

INSERT INTO `order_items` VALUES (3266,2307,4,1,59,0);

INSERT INTO `order_items` VALUES (3267,2307,11,1,39,0);

INSERT INTO `order_items` VALUES (3268,2308,11,1,39,0);

INSERT INTO `order_items` VALUES (3269,2308,12,1,79,0);

INSERT INTO `order_items` VALUES (3270,2308,17,1,69,0);

INSERT INTO `order_items` VALUES (3271,2309,4,1,59,0);

INSERT INTO `order_items` VALUES (3272,2309,9,1,129,0);

INSERT INTO `order_items` VALUES (3273,2309,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3274,2310,13,1,68,0);

INSERT INTO `order_items` VALUES (3275,2311,13,1,68,0);

INSERT INTO `order_items` VALUES (3276,2312,11,1,39,0);

INSERT INTO `order_items` VALUES (3277,2313,9,1,129,0.10);

INSERT INTO `order_items` VALUES (3278,2313,18,1,159,0);

INSERT INTO `order_items` VALUES (3279,2314,11,1,39,0);

INSERT INTO `order_items` VALUES (3280,2314,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3281,2315,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3282,2315,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3283,2316,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3284,2317,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3285,2318,13,1,68,0);

INSERT INTO `order_items` VALUES (3286,2318,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3287,2319,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3288,2319,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3289,2319,20,1,39,0);

INSERT INTO `order_items` VALUES (3290,2320,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3291,2321,3,1,169,0);

INSERT INTO `order_items` VALUES (3292,2321,5,1,399,0);

INSERT INTO `order_items` VALUES (3293,2322,4,1,59,0);

INSERT INTO `order_items` VALUES (3294,2323,13,2,68,0.05);

INSERT INTO `order_items` VALUES (3295,2323,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3296,2324,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3297,2324,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3298,2325,4,3,59,0.10);

INSERT INTO `order_items` VALUES (3299,2326,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3300,2327,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3301,2327,20,1,39,0);

INSERT INTO `order_items` VALUES (3302,2328,10,1,699,0);

INSERT INTO `order_items` VALUES (3303,2328,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3304,2329,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3305,2330,11,1,39,0);

INSERT INTO `order_items` VALUES (3306,2330,13,1,68,0);

INSERT INTO `order_items` VALUES (3307,2331,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3308,2332,11,1,39,0);

INSERT INTO `order_items` VALUES (3309,2333,12,1,79,0);

INSERT INTO `order_items` VALUES (3310,2333,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3311,2334,12,1,79,0);

INSERT INTO `order_items` VALUES (3312,2334,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3313,2335,12,1,79,0);

INSERT INTO `order_items` VALUES (3314,2335,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (3315,2336,11,1,39,0);

INSERT INTO `order_items` VALUES (3316,2337,13,1,68,0);

INSERT INTO `order_items` VALUES (3317,2338,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (3318,2339,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3319,2339,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3320,2339,19,1,199,0);

INSERT INTO `order_items` VALUES (3321,2340,7,1,89,0);

INSERT INTO `order_items` VALUES (3322,2341,13,1,68,0);

INSERT INTO `order_items` VALUES (3323,2341,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3324,2342,4,2,59,0);

INSERT INTO `order_items` VALUES (3325,2343,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3326,2344,14,3,39.9,0);

INSERT INTO `order_items` VALUES (3327,2344,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3328,2345,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3329,2346,7,1,89,0);

INSERT INTO `order_items` VALUES (3330,2346,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3331,2347,13,2,68,0);

INSERT INTO `order_items` VALUES (3332,2348,3,2,169,0.05);

INSERT INTO `order_items` VALUES (3333,2348,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3334,2349,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3335,2349,20,1,39,0);

INSERT INTO `order_items` VALUES (3336,2350,9,2,129,0);

INSERT INTO `order_items` VALUES (3337,2351,8,1,159,0);

INSERT INTO `order_items` VALUES (3338,2351,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3339,2352,13,1,68,0.10);

INSERT INTO `order_items` VALUES (3340,2353,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3341,2353,17,1,69,0);

INSERT INTO `order_items` VALUES (3342,2354,18,1,159,0);

INSERT INTO `order_items` VALUES (3343,2355,11,1,39,0);

INSERT INTO `order_items` VALUES (3344,2356,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3345,2357,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3346,2358,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3347,2358,17,1,69,0);

INSERT INTO `order_items` VALUES (3348,2359,11,1,39,0);

INSERT INTO `order_items` VALUES (3349,2359,15,3,32.9,0);

INSERT INTO `order_items` VALUES (3350,2360,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3351,2361,13,1,68,0);

INSERT INTO `order_items` VALUES (3352,2361,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3353,2362,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3354,2363,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3355,2364,20,2,39,0);

INSERT INTO `order_items` VALUES (3356,2365,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3357,2366,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3358,2367,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3359,2368,13,1,68,0);

INSERT INTO `order_items` VALUES (3360,2369,7,3,89,0);

INSERT INTO `order_items` VALUES (3361,2370,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3362,2370,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3363,2371,3,1,169,0.10);

INSERT INTO `order_items` VALUES (3364,2372,11,1,39,0);

INSERT INTO `order_items` VALUES (3365,2372,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3366,2373,13,1,68,0);

INSERT INTO `order_items` VALUES (3367,2374,8,1,159,0);

INSERT INTO `order_items` VALUES (3368,2375,8,1,159,0.05);

INSERT INTO `order_items` VALUES (3369,2375,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3370,2376,13,1,68,0);

INSERT INTO `order_items` VALUES (3371,2377,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3372,2377,9,1,129,0.10);

INSERT INTO `order_items` VALUES (3373,2378,4,1,59,0);

INSERT INTO `order_items` VALUES (3374,2379,6,2,299,0);

INSERT INTO `order_items` VALUES (3375,2379,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3376,2380,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3377,2381,13,1,68,0);

INSERT INTO `order_items` VALUES (3378,2382,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3379,2383,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3380,2384,3,3,169,0);

INSERT INTO `order_items` VALUES (3381,2384,7,1,89,0);

INSERT INTO `order_items` VALUES (3382,2384,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3383,2385,11,1,39,0);

INSERT INTO `order_items` VALUES (3384,2386,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3385,2387,4,1,59,0);

INSERT INTO `order_items` VALUES (3386,2387,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (3387,2388,13,1,68,0.10);

INSERT INTO `order_items` VALUES (3388,2389,13,1,68,0);

INSERT INTO `order_items` VALUES (3389,2390,4,2,59,0);

INSERT INTO `order_items` VALUES (3390,2390,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3391,2391,7,1,89,0);

INSERT INTO `order_items` VALUES (3392,2391,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3393,2392,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3394,2392,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (3395,2393,3,1,169,0);

INSERT INTO `order_items` VALUES (3396,2394,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3397,2395,4,2,59,0);

INSERT INTO `order_items` VALUES (3398,2396,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3399,2397,17,1,69,0.10);

INSERT INTO `order_items` VALUES (3400,2398,12,1,79,0);

INSERT INTO `order_items` VALUES (3401,2399,17,1,69,0.10);

INSERT INTO `order_items` VALUES (3402,2400,3,1,169,0);

INSERT INTO `order_items` VALUES (3403,2400,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3404,2401,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3405,2401,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3406,2402,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3407,2403,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3408,2404,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3409,2405,4,1,59,0);

INSERT INTO `order_items` VALUES (3410,2406,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3411,2407,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3412,2408,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3413,2409,13,1,68,0);

INSERT INTO `order_items` VALUES (3414,2410,7,1,89,0);

INSERT INTO `order_items` VALUES (3415,2411,5,2,399,0);

INSERT INTO `order_items` VALUES (3416,2412,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3417,2413,11,1,39,0);

INSERT INTO `order_items` VALUES (3418,2413,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3419,2413,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3420,2414,12,1,79,0);

INSERT INTO `order_items` VALUES (3421,2415,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3422,2416,4,1,59,0);

INSERT INTO `order_items` VALUES (3423,2416,20,1,39,0);

INSERT INTO `order_items` VALUES (3424,2417,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3425,2418,9,2,129,0);

INSERT INTO `order_items` VALUES (3426,2419,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3427,2419,18,1,159,0);

INSERT INTO `order_items` VALUES (3428,2420,12,1,79,0);

INSERT INTO `order_items` VALUES (3429,2420,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3430,2421,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3431,2422,7,1,89,0);

INSERT INTO `order_items` VALUES (3432,2422,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3433,2422,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3434,2423,4,1,59,0);

INSERT INTO `order_items` VALUES (3435,2423,9,1,129,0);

INSERT INTO `order_items` VALUES (3436,2424,9,2,129,0.05);

INSERT INTO `order_items` VALUES (3437,2425,4,1,59,0);

INSERT INTO `order_items` VALUES (3438,2426,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3439,2426,20,1,39,0);

INSERT INTO `order_items` VALUES (3440,2427,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3441,2427,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3442,2428,13,1,68,0.10);

INSERT INTO `order_items` VALUES (3443,2428,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3444,2429,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3445,2430,19,1,199,0);

INSERT INTO `order_items` VALUES (3446,2431,13,2,68,0);

INSERT INTO `order_items` VALUES (3447,2432,20,2,39,0);

INSERT INTO `order_items` VALUES (3448,2433,7,2,89,0.10);

INSERT INTO `order_items` VALUES (3449,2434,13,1,68,0);

INSERT INTO `order_items` VALUES (3450,2435,4,1,59,0);

INSERT INTO `order_items` VALUES (3451,2436,12,1,79,0);

INSERT INTO `order_items` VALUES (3452,2436,13,1,68,0);

INSERT INTO `order_items` VALUES (3453,2436,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3454,2437,13,1,68,0);

INSERT INTO `order_items` VALUES (3455,2438,13,2,68,0.05);

INSERT INTO `order_items` VALUES (3456,2439,4,1,59,0);

INSERT INTO `order_items` VALUES (3457,2439,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3458,2440,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3459,2441,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3460,2442,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3461,2443,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3462,2444,9,1,129,0);

INSERT INTO `order_items` VALUES (3463,2445,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3464,2446,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (3465,2447,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3466,2448,12,1,79,0);

INSERT INTO `order_items` VALUES (3467,2449,4,1,59,0);

INSERT INTO `order_items` VALUES (3468,2450,17,1,69,0);

INSERT INTO `order_items` VALUES (3469,2451,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3470,2452,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3471,2453,5,1,399,0.05);

INSERT INTO `order_items` VALUES (3472,2453,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3473,2454,9,1,129,0);

INSERT INTO `order_items` VALUES (3474,2455,13,1,68,0);

INSERT INTO `order_items` VALUES (3475,2456,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3476,2457,4,1,59,0);

INSERT INTO `order_items` VALUES (3477,2457,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3478,2458,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3479,2459,12,1,79,0);

INSERT INTO `order_items` VALUES (3480,2459,13,2,68,0);

INSERT INTO `order_items` VALUES (3481,2460,13,1,68,0);

INSERT INTO `order_items` VALUES (3482,2461,13,1,68,0);

INSERT INTO `order_items` VALUES (3483,2461,18,1,159,0);

INSERT INTO `order_items` VALUES (3484,2462,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3485,2463,13,1,68,0);

INSERT INTO `order_items` VALUES (3486,2464,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3487,2465,20,1,39,0);

INSERT INTO `order_items` VALUES (3488,2466,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3489,2467,13,1,68,0);

INSERT INTO `order_items` VALUES (3490,2468,19,1,199,0.10);

INSERT INTO `order_items` VALUES (3491,2469,18,2,159,0);

INSERT INTO `order_items` VALUES (3492,2470,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3493,2470,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3494,2471,20,1,39,0);

INSERT INTO `order_items` VALUES (3495,2472,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3496,2473,13,2,68,0);

INSERT INTO `order_items` VALUES (3497,2473,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3498,2473,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3499,2474,13,1,68,0);

INSERT INTO `order_items` VALUES (3500,2475,4,1,59,0);

INSERT INTO `order_items` VALUES (3501,2476,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3502,2477,7,1,89,0);

INSERT INTO `order_items` VALUES (3503,2478,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3504,2479,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3505,2480,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3506,2480,17,1,69,0);

INSERT INTO `order_items` VALUES (3507,2481,13,1,68,0);

INSERT INTO `order_items` VALUES (3508,2482,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3509,2483,3,1,169,0);

INSERT INTO `order_items` VALUES (3510,2483,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3511,2484,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3512,2485,13,1,68,0);

INSERT INTO `order_items` VALUES (3513,2485,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3514,2486,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3515,2487,11,1,39,0);

INSERT INTO `order_items` VALUES (3516,2488,10,3,699,0);

INSERT INTO `order_items` VALUES (3517,2489,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3518,2490,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3519,2491,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3520,2492,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3521,2493,11,1,39,0.10);

INSERT INTO `order_items` VALUES (3522,2494,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3523,2495,17,3,69,0);

INSERT INTO `order_items` VALUES (3524,2496,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3525,2497,6,1,299,0.05);

INSERT INTO `order_items` VALUES (3526,2498,15,3,32.9,0.05);

INSERT INTO `order_items` VALUES (3527,2499,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3528,2500,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3529,2501,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3530,2502,10,1,699,0);

INSERT INTO `order_items` VALUES (3531,2503,14,2,39.9,0);

INSERT INTO `order_items` VALUES (3532,2504,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3533,2505,3,1,169,0);

INSERT INTO `order_items` VALUES (3534,2505,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3535,2506,20,1,39,0.10);

INSERT INTO `order_items` VALUES (3536,2507,4,1,59,0);

INSERT INTO `order_items` VALUES (3537,2507,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3538,2507,19,1,199,0);

INSERT INTO `order_items` VALUES (3539,2508,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3540,2509,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3541,2510,18,1,159,0);

INSERT INTO `order_items` VALUES (3542,2511,20,1,39,0);

INSERT INTO `order_items` VALUES (3543,2512,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3544,2513,12,2,79,0.05);

INSERT INTO `order_items` VALUES (3545,2514,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3546,2515,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3547,2515,17,2,69,0);

INSERT INTO `order_items` VALUES (3548,2516,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3549,2517,12,1,79,0);

INSERT INTO `order_items` VALUES (3550,2518,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3551,2519,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3552,2520,3,1,169,0.10);

INSERT INTO `order_items` VALUES (3553,2520,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3554,2521,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3555,2521,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3556,2522,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3557,2523,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3558,2524,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3559,2524,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3560,2524,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3561,2525,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3562,2526,4,3,59,0);

INSERT INTO `order_items` VALUES (3563,2527,3,1,169,0);

INSERT INTO `order_items` VALUES (3564,2528,4,1,59,0);

INSERT INTO `order_items` VALUES (3565,2529,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3566,2529,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3567,2530,4,1,59,0.10);

INSERT INTO `order_items` VALUES (3568,2531,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3569,2532,12,1,79,0);

INSERT INTO `order_items` VALUES (3570,2532,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3571,2533,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3572,2534,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3573,2534,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3574,2535,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3575,2535,13,3,68,0.05);

INSERT INTO `order_items` VALUES (3576,2536,11,1,39,0);

INSERT INTO `order_items` VALUES (3577,2536,13,1,68,0);

INSERT INTO `order_items` VALUES (3578,2537,4,1,59,0);

INSERT INTO `order_items` VALUES (3579,2538,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3580,2539,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3581,2540,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3582,2540,17,1,69,0);

INSERT INTO `order_items` VALUES (3583,2541,7,1,89,0);

INSERT INTO `order_items` VALUES (3584,2541,20,1,39,0);

INSERT INTO `order_items` VALUES (3585,2542,4,1,59,0);

INSERT INTO `order_items` VALUES (3586,2543,17,1,69,0.10);

INSERT INTO `order_items` VALUES (3587,2544,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3588,2545,4,1,59,0.10);

INSERT INTO `order_items` VALUES (3589,2546,9,1,129,0);

INSERT INTO `order_items` VALUES (3590,2546,12,1,79,0);

INSERT INTO `order_items` VALUES (3591,2547,13,1,68,0);

INSERT INTO `order_items` VALUES (3592,2547,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3593,2548,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3594,2549,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3595,2549,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3596,2550,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3597,2551,8,1,159,0);

INSERT INTO `order_items` VALUES (3598,2551,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3599,2552,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3600,2553,13,1,68,0);

INSERT INTO `order_items` VALUES (3601,2554,20,2,39,0.05);

INSERT INTO `order_items` VALUES (3602,2555,9,1,129,0);

INSERT INTO `order_items` VALUES (3603,2556,9,1,129,0);

INSERT INTO `order_items` VALUES (3604,2556,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3605,2557,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3606,2557,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3607,2558,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3608,2558,8,1,159,0);

INSERT INTO `order_items` VALUES (3609,2558,15,3,32.9,0);

INSERT INTO `order_items` VALUES (3610,2559,12,1,79,0);

INSERT INTO `order_items` VALUES (3611,2559,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3612,2560,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3613,2561,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3614,2562,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3615,2562,17,2,69,0);

INSERT INTO `order_items` VALUES (3616,2563,4,1,59,0);

INSERT INTO `order_items` VALUES (3617,2564,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3618,2565,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3619,2565,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3620,2566,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3621,2566,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3622,2567,11,2,39,0);

INSERT INTO `order_items` VALUES (3623,2567,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3624,2568,5,1,399,0);

INSERT INTO `order_items` VALUES (3625,2568,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3626,2569,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3627,2570,11,1,39,0);

INSERT INTO `order_items` VALUES (3628,2570,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3629,2571,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3630,2571,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3631,2572,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3632,2573,18,1,159,0);

INSERT INTO `order_items` VALUES (3633,2574,4,1,59,0);

INSERT INTO `order_items` VALUES (3634,2574,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3635,2575,13,1,68,0);

INSERT INTO `order_items` VALUES (3636,2576,12,1,79,0);

INSERT INTO `order_items` VALUES (3637,2577,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3638,2578,9,1,129,0);

INSERT INTO `order_items` VALUES (3639,2579,11,1,39,0);

INSERT INTO `order_items` VALUES (3640,2580,4,1,59,0);

INSERT INTO `order_items` VALUES (3641,2581,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3642,2582,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3643,2583,4,1,59,0);

INSERT INTO `order_items` VALUES (3644,2584,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3645,2585,12,1,79,0);

INSERT INTO `order_items` VALUES (3646,2586,7,1,89,0);

INSERT INTO `order_items` VALUES (3647,2586,17,1,69,0.05);

INSERT INTO `order_items` VALUES (3648,2587,20,1,39,0);

INSERT INTO `order_items` VALUES (3649,2588,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3650,2588,20,1,39,0.10);

INSERT INTO `order_items` VALUES (3651,2589,12,2,79,0);

INSERT INTO `order_items` VALUES (3652,2590,18,1,159,0);

INSERT INTO `order_items` VALUES (3653,2591,4,1,59,0);

INSERT INTO `order_items` VALUES (3654,2592,9,2,129,0);

INSERT INTO `order_items` VALUES (3655,2593,13,1,68,0);

INSERT INTO `order_items` VALUES (3656,2593,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3657,2594,5,2,399,0);

INSERT INTO `order_items` VALUES (3658,2595,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3659,2596,4,1,59,0);

INSERT INTO `order_items` VALUES (3660,2596,11,1,39,0);

INSERT INTO `order_items` VALUES (3661,2596,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3662,2597,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3663,2598,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3664,2599,11,2,39,0);

INSERT INTO `order_items` VALUES (3665,2599,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3666,2600,4,1,59,0);

INSERT INTO `order_items` VALUES (3667,2600,20,3,39,0);

INSERT INTO `order_items` VALUES (3668,2601,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3669,2602,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3670,2603,13,1,68,0);

INSERT INTO `order_items` VALUES (3671,2604,7,1,89,0);

INSERT INTO `order_items` VALUES (3672,2605,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3673,2605,18,1,159,0);

INSERT INTO `order_items` VALUES (3674,2606,13,1,68,0);

INSERT INTO `order_items` VALUES (3675,2606,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3676,2607,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3677,2608,11,1,39,0);

INSERT INTO `order_items` VALUES (3678,2609,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3679,2609,9,1,129,0);

INSERT INTO `order_items` VALUES (3680,2610,13,1,68,0);

INSERT INTO `order_items` VALUES (3681,2610,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3682,2611,13,2,68,0);

INSERT INTO `order_items` VALUES (3683,2612,5,1,399,0.05);

INSERT INTO `order_items` VALUES (3684,2613,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3685,2613,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3686,2614,11,2,39,0);

INSERT INTO `order_items` VALUES (3687,2614,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3688,2615,6,1,299,0);

INSERT INTO `order_items` VALUES (3689,2615,8,1,159,0.05);

INSERT INTO `order_items` VALUES (3690,2615,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3691,2616,10,1,699,0);

INSERT INTO `order_items` VALUES (3692,2617,7,1,89,0);

INSERT INTO `order_items` VALUES (3693,2617,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3694,2617,11,1,39,0);

INSERT INTO `order_items` VALUES (3695,2618,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3696,2618,13,3,68,0);

INSERT INTO `order_items` VALUES (3697,2619,7,1,89,0);

INSERT INTO `order_items` VALUES (3698,2619,13,1,68,0.10);

INSERT INTO `order_items` VALUES (3699,2620,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3700,2620,12,1,79,0);

INSERT INTO `order_items` VALUES (3701,2621,7,1,89,0.10);

INSERT INTO `order_items` VALUES (3702,2622,11,1,39,0);

INSERT INTO `order_items` VALUES (3703,2622,12,1,79,0);

INSERT INTO `order_items` VALUES (3704,2623,11,2,39,0);

INSERT INTO `order_items` VALUES (3705,2623,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3706,2624,7,1,89,0);

INSERT INTO `order_items` VALUES (3707,2625,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3708,2626,6,1,299,0.05);

INSERT INTO `order_items` VALUES (3709,2626,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3710,2627,8,1,159,0);

INSERT INTO `order_items` VALUES (3711,2627,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3712,2628,13,2,68,0);

INSERT INTO `order_items` VALUES (3713,2628,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3714,2629,20,1,39,0);

INSERT INTO `order_items` VALUES (3715,2630,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3716,2631,7,2,89,0.05);

INSERT INTO `order_items` VALUES (3717,2631,12,1,79,0);

INSERT INTO `order_items` VALUES (3718,2632,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3719,2633,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3720,2634,20,1,39,0.10);

INSERT INTO `order_items` VALUES (3721,2635,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3722,2635,12,1,79,0);

INSERT INTO `order_items` VALUES (3723,2636,5,1,399,0.10);

INSERT INTO `order_items` VALUES (3724,2636,11,1,39,0);

INSERT INTO `order_items` VALUES (3725,2637,7,1,89,0);

INSERT INTO `order_items` VALUES (3726,2637,11,1,39,0);

INSERT INTO `order_items` VALUES (3727,2637,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3728,2638,7,2,89,0.10);

INSERT INTO `order_items` VALUES (3729,2638,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3730,2639,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3731,2639,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3732,2640,7,1,89,0);

INSERT INTO `order_items` VALUES (3733,2640,12,1,79,0.10);

INSERT INTO `order_items` VALUES (3734,2640,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3735,2641,5,3,399,0.10);

INSERT INTO `order_items` VALUES (3736,2642,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3737,2643,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3738,2644,17,1,69,0.05);

INSERT INTO `order_items` VALUES (3739,2645,17,1,69,0);

INSERT INTO `order_items` VALUES (3740,2646,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3741,2647,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3742,2647,20,1,39,0);

INSERT INTO `order_items` VALUES (3743,2648,8,1,159,0.05);

INSERT INTO `order_items` VALUES (3744,2648,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (3745,2649,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3746,2649,13,1,68,0);

INSERT INTO `order_items` VALUES (3747,2650,20,1,39,0);

INSERT INTO `order_items` VALUES (3748,2651,7,1,89,0);

INSERT INTO `order_items` VALUES (3749,2651,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3750,2651,20,1,39,0);

INSERT INTO `order_items` VALUES (3751,2652,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3752,2652,17,1,69,0);

INSERT INTO `order_items` VALUES (3753,2653,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3754,2654,19,1,199,0.10);

INSERT INTO `order_items` VALUES (3755,2655,9,1,129,0);

INSERT INTO `order_items` VALUES (3756,2656,11,1,39,0);

INSERT INTO `order_items` VALUES (3757,2656,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3758,2657,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3759,2658,11,1,39,0);

INSERT INTO `order_items` VALUES (3760,2658,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3761,2659,16,3,24.9,0);

INSERT INTO `order_items` VALUES (3762,2660,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (3763,2661,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3764,2662,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3765,2662,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3766,2663,3,1,169,0.05);

INSERT INTO `order_items` VALUES (3767,2663,12,1,79,0);

INSERT INTO `order_items` VALUES (3768,2664,3,1,169,0);

INSERT INTO `order_items` VALUES (3769,2664,4,1,59,0);

INSERT INTO `order_items` VALUES (3770,2664,7,1,89,0);

INSERT INTO `order_items` VALUES (3771,2665,7,2,89,0);

INSERT INTO `order_items` VALUES (3772,2666,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3773,2666,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3774,2667,11,3,39,0);

INSERT INTO `order_items` VALUES (3775,2667,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3776,2668,11,1,39,0);

INSERT INTO `order_items` VALUES (3777,2668,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3778,2669,3,1,169,0);

INSERT INTO `order_items` VALUES (3779,2670,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3780,2671,7,1,89,0.05);

INSERT INTO `order_items` VALUES (3781,2671,13,1,68,0);

INSERT INTO `order_items` VALUES (3782,2672,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3783,2673,11,1,39,0);

INSERT INTO `order_items` VALUES (3784,2673,13,2,68,0.05);

INSERT INTO `order_items` VALUES (3785,2673,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3786,2674,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3787,2675,1,1,4299,0);

INSERT INTO `order_items` VALUES (3788,2675,11,1,39,0);

INSERT INTO `order_items` VALUES (3789,2675,13,1,68,0);

INSERT INTO `order_items` VALUES (3790,2676,18,1,159,0);

INSERT INTO `order_items` VALUES (3791,2677,11,1,39,0);

INSERT INTO `order_items` VALUES (3792,2678,4,1,59,0);

INSERT INTO `order_items` VALUES (3793,2678,20,2,39,0.05);

INSERT INTO `order_items` VALUES (3794,2679,4,1,59,0);

INSERT INTO `order_items` VALUES (3795,2680,7,1,89,0);

INSERT INTO `order_items` VALUES (3796,2680,11,1,39,0);

INSERT INTO `order_items` VALUES (3797,2680,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3798,2681,20,1,39,0);

INSERT INTO `order_items` VALUES (3799,2682,13,1,68,0);

INSERT INTO `order_items` VALUES (3800,2683,7,1,89,0);

INSERT INTO `order_items` VALUES (3801,2683,17,1,69,0);

INSERT INTO `order_items` VALUES (3802,2684,11,1,39,0);

INSERT INTO `order_items` VALUES (3803,2685,9,1,129,0);

INSERT INTO `order_items` VALUES (3804,2686,17,1,69,0);

INSERT INTO `order_items` VALUES (3805,2687,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3806,2687,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3807,2688,20,1,39,0);

INSERT INTO `order_items` VALUES (3808,2689,13,1,68,0);

INSERT INTO `order_items` VALUES (3809,2689,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3810,2689,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3811,2690,12,1,79,0.10);

INSERT INTO `order_items` VALUES (3812,2690,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3813,2691,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3814,2692,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3815,2692,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3816,2693,8,3,159,0);

INSERT INTO `order_items` VALUES (3817,2693,20,1,39,0);

INSERT INTO `order_items` VALUES (3818,2694,11,2,39,0.05);

INSERT INTO `order_items` VALUES (3819,2695,4,1,59,0);

INSERT INTO `order_items` VALUES (3820,2695,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3821,2696,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3822,2696,16,2,24.9,0);

INSERT INTO `order_items` VALUES (3823,2697,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3824,2698,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3825,2699,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3826,2700,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3827,2701,3,2,169,0.10);

INSERT INTO `order_items` VALUES (3828,2701,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3829,2702,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3830,2703,4,1,59,0);

INSERT INTO `order_items` VALUES (3831,2703,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3832,2704,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3833,2704,20,1,39,0);

INSERT INTO `order_items` VALUES (3834,2705,4,2,59,0);

INSERT INTO `order_items` VALUES (3835,2706,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3836,2707,13,1,68,0.05);

INSERT INTO `order_items` VALUES (3837,2708,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3838,2709,17,1,69,0);

INSERT INTO `order_items` VALUES (3839,2710,15,2,32.9,0);

INSERT INTO `order_items` VALUES (3840,2711,12,1,79,0);

INSERT INTO `order_items` VALUES (3841,2712,7,1,89,0);

INSERT INTO `order_items` VALUES (3842,2712,11,1,39,0);

INSERT INTO `order_items` VALUES (3843,2712,12,1,79,0);

INSERT INTO `order_items` VALUES (3844,2713,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3845,2713,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3846,2713,13,1,68,0);

INSERT INTO `order_items` VALUES (3847,2714,7,1,89,0);

INSERT INTO `order_items` VALUES (3848,2715,8,1,159,0.05);

INSERT INTO `order_items` VALUES (3849,2716,16,3,24.9,0);

INSERT INTO `order_items` VALUES (3850,2717,4,1,59,0);

INSERT INTO `order_items` VALUES (3851,2718,9,1,129,0);

INSERT INTO `order_items` VALUES (3852,2718,12,1,79,0);

INSERT INTO `order_items` VALUES (3853,2718,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3854,2719,9,1,129,0);

INSERT INTO `order_items` VALUES (3855,2720,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3856,2720,18,1,159,0);

INSERT INTO `order_items` VALUES (3857,2720,20,1,39,0);

INSERT INTO `order_items` VALUES (3858,2721,12,1,79,0);

INSERT INTO `order_items` VALUES (3859,2722,17,1,69,0.10);

INSERT INTO `order_items` VALUES (3860,2723,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3861,2724,12,1,79,0);

INSERT INTO `order_items` VALUES (3862,2725,7,1,89,0);

INSERT INTO `order_items` VALUES (3863,2726,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3864,2727,4,1,59,0);

INSERT INTO `order_items` VALUES (3865,2728,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3866,2729,13,1,68,0);

INSERT INTO `order_items` VALUES (3867,2729,18,1,159,0);

INSERT INTO `order_items` VALUES (3868,2730,2,2,899,0);

INSERT INTO `order_items` VALUES (3869,2730,3,1,169,0);

INSERT INTO `order_items` VALUES (3870,2730,4,1,59,0);

INSERT INTO `order_items` VALUES (3871,2731,3,1,169,0);

INSERT INTO `order_items` VALUES (3872,2731,17,1,69,0.05);

INSERT INTO `order_items` VALUES (3873,2732,9,3,129,0);

INSERT INTO `order_items` VALUES (3874,2733,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (3875,2733,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3876,2734,7,1,89,0);

INSERT INTO `order_items` VALUES (3877,2735,3,1,169,0);

INSERT INTO `order_items` VALUES (3878,2735,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3879,2736,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3880,2737,13,1,68,0);

INSERT INTO `order_items` VALUES (3881,2737,18,3,159,0);

INSERT INTO `order_items` VALUES (3882,2738,4,1,59,0);

INSERT INTO `order_items` VALUES (3883,2738,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3884,2738,18,1,159,0);

INSERT INTO `order_items` VALUES (3885,2739,4,2,59,0.05);

INSERT INTO `order_items` VALUES (3886,2739,14,2,39.9,0.10);

INSERT INTO `order_items` VALUES (3887,2739,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3888,2740,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3889,2740,20,1,39,0);

INSERT INTO `order_items` VALUES (3890,2741,4,1,59,0);

INSERT INTO `order_items` VALUES (3891,2741,13,1,68,0);

INSERT INTO `order_items` VALUES (3892,2741,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3893,2742,13,2,68,0);

INSERT INTO `order_items` VALUES (3894,2743,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (3895,2744,7,2,89,0.05);

INSERT INTO `order_items` VALUES (3896,2745,7,1,89,0);

INSERT INTO `order_items` VALUES (3897,2745,12,1,79,0);

INSERT INTO `order_items` VALUES (3898,2745,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3899,2746,13,1,68,0);

INSERT INTO `order_items` VALUES (3900,2746,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (3901,2746,18,1,159,0);

INSERT INTO `order_items` VALUES (3902,2747,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3903,2748,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3904,2748,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3905,2749,8,1,159,0.05);

INSERT INTO `order_items` VALUES (3906,2750,19,1,199,0);

INSERT INTO `order_items` VALUES (3907,2751,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3908,2752,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (3909,2752,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3910,2753,13,1,68,0);

INSERT INTO `order_items` VALUES (3911,2754,6,1,299,0.05);

INSERT INTO `order_items` VALUES (3912,2754,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3913,2755,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (3914,2756,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3915,2757,12,1,79,0);

INSERT INTO `order_items` VALUES (3916,2757,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (3917,2757,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3918,2758,10,1,699,0.05);

INSERT INTO `order_items` VALUES (3919,2758,11,2,39,0);

INSERT INTO `order_items` VALUES (3920,2758,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3921,2759,7,1,89,0);

INSERT INTO `order_items` VALUES (3922,2760,13,2,68,0);

INSERT INTO `order_items` VALUES (3923,2761,12,1,79,0);

INSERT INTO `order_items` VALUES (3924,2762,4,1,59,0.10);

INSERT INTO `order_items` VALUES (3925,2762,11,1,39,0);

INSERT INTO `order_items` VALUES (3926,2763,13,1,68,0);

INSERT INTO `order_items` VALUES (3927,2764,13,1,68,0);

INSERT INTO `order_items` VALUES (3928,2764,18,1,159,0.10);

INSERT INTO `order_items` VALUES (3929,2765,8,1,159,0);

INSERT INTO `order_items` VALUES (3930,2766,19,1,199,0);

INSERT INTO `order_items` VALUES (3931,2767,9,1,129,0);

INSERT INTO `order_items` VALUES (3932,2767,11,1,39,0);

INSERT INTO `order_items` VALUES (3933,2768,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3934,2769,13,1,68,0);

INSERT INTO `order_items` VALUES (3935,2770,3,1,169,0);

INSERT INTO `order_items` VALUES (3936,2771,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3937,2772,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3938,2772,20,1,39,0);

INSERT INTO `order_items` VALUES (3939,2773,12,1,79,0.05);

INSERT INTO `order_items` VALUES (3940,2773,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3941,2774,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3942,2774,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3943,2774,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (3944,2775,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3945,2775,17,1,69,0);

INSERT INTO `order_items` VALUES (3946,2776,11,1,39,0);

INSERT INTO `order_items` VALUES (3947,2777,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3948,2778,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3949,2779,16,3,24.9,0);

INSERT INTO `order_items` VALUES (3950,2780,12,1,79,0);

INSERT INTO `order_items` VALUES (3951,2781,7,1,89,0.10);

INSERT INTO `order_items` VALUES (3952,2782,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3953,2783,20,2,39,0);

INSERT INTO `order_items` VALUES (3954,2784,11,1,39,0.10);

INSERT INTO `order_items` VALUES (3955,2785,3,1,169,0);

INSERT INTO `order_items` VALUES (3956,2786,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3957,2787,12,2,79,0.05);

INSERT INTO `order_items` VALUES (3958,2788,3,1,169,0);

INSERT INTO `order_items` VALUES (3959,2788,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3960,2788,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (3961,2789,3,3,169,0);

INSERT INTO `order_items` VALUES (3962,2789,7,3,89,0.10);

INSERT INTO `order_items` VALUES (3963,2790,13,1,68,0);

INSERT INTO `order_items` VALUES (3964,2790,18,1,159,0);

INSERT INTO `order_items` VALUES (3965,2791,12,1,79,0);

INSERT INTO `order_items` VALUES (3966,2791,18,1,159,0);

INSERT INTO `order_items` VALUES (3967,2792,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3968,2793,8,1,159,0);

INSERT INTO `order_items` VALUES (3969,2794,4,1,59,0.05);

INSERT INTO `order_items` VALUES (3970,2795,13,2,68,0);

INSERT INTO `order_items` VALUES (3971,2795,20,1,39,0.10);

INSERT INTO `order_items` VALUES (3972,2796,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3973,2797,11,1,39,0);

INSERT INTO `order_items` VALUES (3974,2797,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3975,2798,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3976,2799,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3977,2800,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3978,2801,4,1,59,0);

INSERT INTO `order_items` VALUES (3979,2802,1,1,4299,0);

INSERT INTO `order_items` VALUES (3980,2802,11,1,39,0);

INSERT INTO `order_items` VALUES (3981,2803,3,1,169,0);

INSERT INTO `order_items` VALUES (3982,2803,4,1,59,0);

INSERT INTO `order_items` VALUES (3983,2803,11,2,39,0);

INSERT INTO `order_items` VALUES (3984,2804,9,1,129,0.05);

INSERT INTO `order_items` VALUES (3985,2805,18,1,159,0);

INSERT INTO `order_items` VALUES (3986,2806,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3987,2807,20,1,39,0.05);

INSERT INTO `order_items` VALUES (3988,2808,12,1,79,0);

INSERT INTO `order_items` VALUES (3989,2809,15,1,32.9,0);

INSERT INTO `order_items` VALUES (3990,2810,16,1,24.9,0);

INSERT INTO `order_items` VALUES (3991,2811,7,1,89,0);

INSERT INTO `order_items` VALUES (3992,2811,19,3,199,0);

INSERT INTO `order_items` VALUES (3993,2812,3,1,169,0);

INSERT INTO `order_items` VALUES (3994,2812,5,1,399,0);

INSERT INTO `order_items` VALUES (3995,2813,4,1,59,0);

INSERT INTO `order_items` VALUES (3996,2814,5,1,399,0);

INSERT INTO `order_items` VALUES (3997,2815,14,1,39.9,0);

INSERT INTO `order_items` VALUES (3998,2816,11,1,39,0.05);

INSERT INTO `order_items` VALUES (3999,2816,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4000,2817,3,1,169,0);

INSERT INTO `order_items` VALUES (4001,2817,4,1,59,0);

INSERT INTO `order_items` VALUES (4002,2817,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4003,2818,13,1,68,0);

INSERT INTO `order_items` VALUES (4004,2819,9,1,129,0);

INSERT INTO `order_items` VALUES (4005,2819,13,2,68,0.10);

INSERT INTO `order_items` VALUES (4006,2820,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4007,2821,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4008,2822,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4009,2823,4,2,59,0.10);

INSERT INTO `order_items` VALUES (4010,2823,13,1,68,0);

INSERT INTO `order_items` VALUES (4011,2823,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4012,2824,10,1,699,0.05);

INSERT INTO `order_items` VALUES (4013,2825,13,1,68,0);

INSERT INTO `order_items` VALUES (4014,2825,18,1,159,0);

INSERT INTO `order_items` VALUES (4015,2826,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4016,2827,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4017,2828,11,1,39,0);

INSERT INTO `order_items` VALUES (4018,2829,7,1,89,0);

INSERT INTO `order_items` VALUES (4019,2829,9,1,129,0.10);

INSERT INTO `order_items` VALUES (4020,2830,19,1,199,0);

INSERT INTO `order_items` VALUES (4021,2831,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (4022,2832,5,2,399,0);

INSERT INTO `order_items` VALUES (4023,2833,9,1,129,0);

INSERT INTO `order_items` VALUES (4024,2834,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4025,2834,20,2,39,0.05);

INSERT INTO `order_items` VALUES (4026,2835,12,3,79,0);

INSERT INTO `order_items` VALUES (4027,2835,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4028,2836,12,1,79,0);

INSERT INTO `order_items` VALUES (4029,2836,17,1,69,0);

INSERT INTO `order_items` VALUES (4030,2837,14,3,39.9,0);

INSERT INTO `order_items` VALUES (4031,2838,18,1,159,0);

INSERT INTO `order_items` VALUES (4032,2839,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4033,2840,12,2,79,0.05);

INSERT INTO `order_items` VALUES (4034,2840,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4035,2841,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4036,2841,13,1,68,0);

INSERT INTO `order_items` VALUES (4037,2842,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4038,2843,10,2,699,0.10);

INSERT INTO `order_items` VALUES (4039,2843,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4040,2844,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4041,2845,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4042,2846,17,1,69,0);

INSERT INTO `order_items` VALUES (4043,2846,20,1,39,0);

INSERT INTO `order_items` VALUES (4044,2847,15,2,32.9,0);

INSERT INTO `order_items` VALUES (4045,2848,18,1,159,0.05);

INSERT INTO `order_items` VALUES (4046,2849,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4047,2850,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4048,2851,18,1,159,0);

INSERT INTO `order_items` VALUES (4049,2852,17,1,69,0);

INSERT INTO `order_items` VALUES (4050,2853,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4051,2854,9,2,129,0);

INSERT INTO `order_items` VALUES (4052,2854,13,1,68,0);

INSERT INTO `order_items` VALUES (4053,2855,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4054,2855,18,1,159,0);

INSERT INTO `order_items` VALUES (4055,2856,19,1,199,0);

INSERT INTO `order_items` VALUES (4056,2857,4,3,59,0);

INSERT INTO `order_items` VALUES (4057,2858,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4058,2858,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4059,2858,17,2,69,0.10);

INSERT INTO `order_items` VALUES (4060,2859,4,1,59,0);

INSERT INTO `order_items` VALUES (4061,2860,6,2,299,0);

INSERT INTO `order_items` VALUES (4062,2860,17,1,69,0);

INSERT INTO `order_items` VALUES (4063,2860,20,2,39,0);

INSERT INTO `order_items` VALUES (4064,2861,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4065,2861,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (4066,2862,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4067,2863,7,3,89,0.10);

INSERT INTO `order_items` VALUES (4068,2864,18,1,159,0);

INSERT INTO `order_items` VALUES (4069,2865,4,1,59,0);

INSERT INTO `order_items` VALUES (4070,2865,7,1,89,0);

INSERT INTO `order_items` VALUES (4071,2866,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4072,2867,9,1,129,0);

INSERT INTO `order_items` VALUES (4073,2868,1,1,4299,0);

INSERT INTO `order_items` VALUES (4074,2869,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (4075,2870,3,1,169,0);

INSERT INTO `order_items` VALUES (4076,2870,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4077,2871,18,1,159,0);

INSERT INTO `order_items` VALUES (4078,2872,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4079,2873,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4080,2874,16,2,24.9,0);

INSERT INTO `order_items` VALUES (4081,2875,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4082,2876,4,1,59,0);

INSERT INTO `order_items` VALUES (4083,2876,12,1,79,0);

INSERT INTO `order_items` VALUES (4084,2877,13,1,68,0);

INSERT INTO `order_items` VALUES (4085,2878,14,3,39.9,0);

INSERT INTO `order_items` VALUES (4086,2879,12,1,79,0);

INSERT INTO `order_items` VALUES (4087,2880,11,2,39,0);

INSERT INTO `order_items` VALUES (4088,2881,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4089,2881,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4090,2881,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4091,2882,3,1,169,0);

INSERT INTO `order_items` VALUES (4092,2882,11,1,39,0);

INSERT INTO `order_items` VALUES (4093,2882,20,2,39,0);

INSERT INTO `order_items` VALUES (4094,2883,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4095,2883,20,1,39,0);

INSERT INTO `order_items` VALUES (4096,2884,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4097,2885,4,1,59,0);

INSERT INTO `order_items` VALUES (4098,2886,9,1,129,0);

INSERT INTO `order_items` VALUES (4099,2887,3,1,169,0);

INSERT INTO `order_items` VALUES (4100,2888,4,1,59,0);

INSERT INTO `order_items` VALUES (4101,2888,19,2,199,0);

INSERT INTO `order_items` VALUES (4102,2889,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4103,2890,4,1,59,0);

INSERT INTO `order_items` VALUES (4104,2890,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4105,2891,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4106,2892,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4107,2893,11,1,39,0);

INSERT INTO `order_items` VALUES (4108,2893,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4109,2894,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4110,2895,4,2,59,0);

INSERT INTO `order_items` VALUES (4111,2895,9,1,129,0);

INSERT INTO `order_items` VALUES (4112,2896,7,1,89,0);

INSERT INTO `order_items` VALUES (4113,2897,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4114,2897,18,1,159,0);

INSERT INTO `order_items` VALUES (4115,2898,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4116,2898,18,1,159,0.10);

INSERT INTO `order_items` VALUES (4117,2899,7,2,89,0);

INSERT INTO `order_items` VALUES (4118,2900,7,1,89,0);

INSERT INTO `order_items` VALUES (4119,2901,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4120,2901,18,2,159,0);

INSERT INTO `order_items` VALUES (4121,2902,4,1,59,0);

INSERT INTO `order_items` VALUES (4122,2903,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4123,2904,18,1,159,0);

INSERT INTO `order_items` VALUES (4124,2905,11,1,39,0);

INSERT INTO `order_items` VALUES (4125,2906,7,1,89,0);

INSERT INTO `order_items` VALUES (4126,2906,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4127,2907,5,1,399,0);

INSERT INTO `order_items` VALUES (4128,2907,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4129,2908,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4130,2909,9,1,129,0.10);

INSERT INTO `order_items` VALUES (4131,2909,11,2,39,0);

INSERT INTO `order_items` VALUES (4132,2909,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4133,2910,17,1,69,0);

INSERT INTO `order_items` VALUES (4134,2911,6,1,299,0);

INSERT INTO `order_items` VALUES (4135,2912,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4136,2913,20,3,39,0);

INSERT INTO `order_items` VALUES (4137,2914,12,1,79,0);

INSERT INTO `order_items` VALUES (4138,2914,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4139,2915,11,1,39,0);

INSERT INTO `order_items` VALUES (4140,2915,12,1,79,0);

INSERT INTO `order_items` VALUES (4141,2916,19,1,199,0);

INSERT INTO `order_items` VALUES (4142,2917,13,2,68,0);

INSERT INTO `order_items` VALUES (4143,2918,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4144,2919,13,3,68,0);

INSERT INTO `order_items` VALUES (4145,2919,18,1,159,0);

INSERT INTO `order_items` VALUES (4146,2920,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4147,2921,7,3,89,0);

INSERT INTO `order_items` VALUES (4148,2922,7,2,89,0);

INSERT INTO `order_items` VALUES (4149,2923,7,1,89,0);

INSERT INTO `order_items` VALUES (4150,2923,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4151,2923,20,1,39,0);

INSERT INTO `order_items` VALUES (4152,2924,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4153,2924,19,1,199,0);

INSERT INTO `order_items` VALUES (4154,2925,2,1,899,0.10);

INSERT INTO `order_items` VALUES (4155,2926,11,1,39,0);

INSERT INTO `order_items` VALUES (4156,2927,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4157,2928,4,1,59,0);

INSERT INTO `order_items` VALUES (4158,2928,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4159,2929,10,1,699,0);

INSERT INTO `order_items` VALUES (4160,2930,12,1,79,0);

INSERT INTO `order_items` VALUES (4161,2930,19,2,199,0);

INSERT INTO `order_items` VALUES (4162,2931,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4163,2931,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4164,2932,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4165,2933,3,2,169,0);

INSERT INTO `order_items` VALUES (4166,2933,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4167,2934,3,1,169,0);

INSERT INTO `order_items` VALUES (4168,2934,5,1,399,0);

INSERT INTO `order_items` VALUES (4169,2934,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4170,2935,9,1,129,0);

INSERT INTO `order_items` VALUES (4171,2936,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4172,2937,3,1,169,0);

INSERT INTO `order_items` VALUES (4173,2938,12,1,79,0);

INSERT INTO `order_items` VALUES (4174,2938,20,2,39,0.05);

INSERT INTO `order_items` VALUES (4175,2939,11,1,39,0);

INSERT INTO `order_items` VALUES (4176,2939,12,2,79,0.05);

INSERT INTO `order_items` VALUES (4177,2939,13,1,68,0);

INSERT INTO `order_items` VALUES (4178,2940,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (4179,2941,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4180,2942,17,3,69,0.05);

INSERT INTO `order_items` VALUES (4181,2943,10,2,699,0);

INSERT INTO `order_items` VALUES (4182,2943,17,1,69,0);

INSERT INTO `order_items` VALUES (4183,2944,11,1,39,0);

INSERT INTO `order_items` VALUES (4184,2945,15,2,32.9,0);

INSERT INTO `order_items` VALUES (4185,2946,9,2,129,0);

INSERT INTO `order_items` VALUES (4186,2947,3,1,169,0);

INSERT INTO `order_items` VALUES (4187,2947,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4188,2948,20,1,39,0);

INSERT INTO `order_items` VALUES (4189,2949,11,2,39,0.10);

INSERT INTO `order_items` VALUES (4190,2950,18,1,159,0);

INSERT INTO `order_items` VALUES (4191,2951,12,1,79,0);

INSERT INTO `order_items` VALUES (4192,2952,13,1,68,0);

INSERT INTO `order_items` VALUES (4193,2953,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4194,2954,13,2,68,0);

INSERT INTO `order_items` VALUES (4195,2955,7,1,89,0);

INSERT INTO `order_items` VALUES (4196,2956,12,1,79,0);

INSERT INTO `order_items` VALUES (4197,2956,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4198,2956,17,2,69,0);

INSERT INTO `order_items` VALUES (4199,2957,7,1,89,0);

INSERT INTO `order_items` VALUES (4200,2957,9,1,129,0);

INSERT INTO `order_items` VALUES (4201,2958,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4202,2959,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4203,2960,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4204,2960,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4205,2960,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4206,2961,4,1,59,0);

INSERT INTO `order_items` VALUES (4207,2962,3,1,169,0);

INSERT INTO `order_items` VALUES (4208,2962,15,3,32.9,0);

INSERT INTO `order_items` VALUES (4209,2963,11,1,39,0);

INSERT INTO `order_items` VALUES (4210,2963,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4211,2964,12,1,79,0);

INSERT INTO `order_items` VALUES (4212,2964,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4213,2965,13,1,68,0);

INSERT INTO `order_items` VALUES (4214,2966,3,1,169,0);

INSERT INTO `order_items` VALUES (4215,2966,7,1,89,0);

INSERT INTO `order_items` VALUES (4216,2967,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4217,2968,10,1,699,0);

INSERT INTO `order_items` VALUES (4218,2969,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4219,2970,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4220,2970,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4221,2971,3,1,169,0);

INSERT INTO `order_items` VALUES (4222,2972,17,1,69,0);

INSERT INTO `order_items` VALUES (4223,2973,13,1,68,0);

INSERT INTO `order_items` VALUES (4224,2974,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4225,2975,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4226,2976,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4227,2977,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4228,2978,9,1,129,0);

INSERT INTO `order_items` VALUES (4229,2978,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4230,2979,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4231,2980,13,1,68,0);

INSERT INTO `order_items` VALUES (4232,2981,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4233,2982,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4234,2983,12,1,79,0);

INSERT INTO `order_items` VALUES (4235,2984,13,1,68,0);

INSERT INTO `order_items` VALUES (4236,2985,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4237,2986,5,2,399,0.10);

INSERT INTO `order_items` VALUES (4238,2986,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4239,2987,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4240,2988,18,1,159,0);

INSERT INTO `order_items` VALUES (4241,2989,7,1,89,0);

INSERT INTO `order_items` VALUES (4242,2989,9,1,129,0);

INSERT INTO `order_items` VALUES (4243,2990,13,1,68,0);

INSERT INTO `order_items` VALUES (4244,2991,6,1,299,0);

INSERT INTO `order_items` VALUES (4245,2991,8,1,159,0);

INSERT INTO `order_items` VALUES (4246,2992,5,1,399,0);

INSERT INTO `order_items` VALUES (4247,2993,13,1,68,0);

INSERT INTO `order_items` VALUES (4248,2993,20,1,39,0);

INSERT INTO `order_items` VALUES (4249,2994,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (4250,2995,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4251,2996,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4252,2996,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4253,2996,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4254,2997,11,1,39,0);

INSERT INTO `order_items` VALUES (4255,2997,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4256,2998,18,3,159,0);

INSERT INTO `order_items` VALUES (4257,2999,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4258,3000,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4259,3001,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4260,3002,4,1,59,0);

INSERT INTO `order_items` VALUES (4261,3003,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4262,3004,17,1,69,0);

INSERT INTO `order_items` VALUES (4263,3005,11,1,39,0);

INSERT INTO `order_items` VALUES (4264,3006,9,1,129,0);

INSERT INTO `order_items` VALUES (4265,3007,7,1,89,0);

INSERT INTO `order_items` VALUES (4266,3008,11,1,39,0);

INSERT INTO `order_items` VALUES (4267,3008,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4268,3008,19,1,199,0);

INSERT INTO `order_items` VALUES (4269,3009,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (4270,3010,4,2,59,0);

INSERT INTO `order_items` VALUES (4271,3010,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4272,3010,13,1,68,0);

INSERT INTO `order_items` VALUES (4273,3011,20,2,39,0);

INSERT INTO `order_items` VALUES (4274,3012,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4275,3013,7,1,89,0);

INSERT INTO `order_items` VALUES (4276,3013,13,1,68,0);

INSERT INTO `order_items` VALUES (4277,3014,13,1,68,0);

INSERT INTO `order_items` VALUES (4278,3014,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4279,3015,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4280,3015,18,1,159,0);

INSERT INTO `order_items` VALUES (4281,3016,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4282,3016,13,1,68,0);

INSERT INTO `order_items` VALUES (4283,3017,9,1,129,0.10);

INSERT INTO `order_items` VALUES (4284,3018,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4285,3019,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (4286,3020,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4287,3020,12,2,79,0.05);

INSERT INTO `order_items` VALUES (4288,3020,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4289,3021,17,1,69,0);

INSERT INTO `order_items` VALUES (4290,3022,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4291,3022,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4292,3023,4,1,59,0);

INSERT INTO `order_items` VALUES (4293,3023,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4294,3024,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4295,3025,2,3,899,0);

INSERT INTO `order_items` VALUES (4296,3026,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4297,3027,12,1,79,0);

INSERT INTO `order_items` VALUES (4298,3027,13,2,68,0);

INSERT INTO `order_items` VALUES (4299,3028,11,1,39,0);

INSERT INTO `order_items` VALUES (4300,3028,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4301,3029,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4302,3029,16,3,24.9,0);

INSERT INTO `order_items` VALUES (4303,3030,3,1,169,0);

INSERT INTO `order_items` VALUES (4304,3031,7,1,89,0);

INSERT INTO `order_items` VALUES (4305,3031,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4306,3032,7,1,89,0);

INSERT INTO `order_items` VALUES (4307,3033,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4308,3033,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4309,3034,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4310,3034,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4311,3035,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4312,3036,3,1,169,0);

INSERT INTO `order_items` VALUES (4313,3036,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (4314,3037,13,1,68,0);

INSERT INTO `order_items` VALUES (4315,3038,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4316,3038,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4317,3039,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4318,3040,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4319,3040,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4320,3041,11,1,39,0);

INSERT INTO `order_items` VALUES (4321,3041,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4322,3041,17,1,69,0);

INSERT INTO `order_items` VALUES (4323,3042,16,2,24.9,0);

INSERT INTO `order_items` VALUES (4324,3043,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4325,3043,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4326,3044,11,1,39,0);

INSERT INTO `order_items` VALUES (4327,3045,4,1,59,0);

INSERT INTO `order_items` VALUES (4328,3046,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4329,3046,7,1,89,0);

INSERT INTO `order_items` VALUES (4330,3046,9,1,129,0);

INSERT INTO `order_items` VALUES (4331,3047,7,1,89,0);

INSERT INTO `order_items` VALUES (4332,3047,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4333,3047,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4334,3048,12,1,79,0);

INSERT INTO `order_items` VALUES (4335,3049,3,1,169,0);

INSERT INTO `order_items` VALUES (4336,3050,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4337,3050,12,1,79,0);

INSERT INTO `order_items` VALUES (4338,3050,18,2,159,0);

INSERT INTO `order_items` VALUES (4339,3051,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4340,3051,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4341,3051,20,1,39,0);

INSERT INTO `order_items` VALUES (4342,3052,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4343,3053,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4344,3053,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4345,3054,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4346,3054,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4347,3055,16,2,24.9,0);

INSERT INTO `order_items` VALUES (4348,3056,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4349,3057,4,1,59,0);

INSERT INTO `order_items` VALUES (4350,3057,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4351,3058,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4352,3058,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4353,3058,17,2,69,0);

INSERT INTO `order_items` VALUES (4354,3059,13,2,68,0);

INSERT INTO `order_items` VALUES (4355,3060,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4356,3061,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4357,3061,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4358,3062,9,2,129,0);

INSERT INTO `order_items` VALUES (4359,3062,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4360,3063,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4361,3063,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4362,3064,11,1,39,0);

INSERT INTO `order_items` VALUES (4363,3065,17,2,69,0);

INSERT INTO `order_items` VALUES (4364,3066,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4365,3067,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4366,3068,7,1,89,0);

INSERT INTO `order_items` VALUES (4367,3069,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4368,3070,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4369,3071,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4370,3072,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4371,3072,18,1,159,0);

INSERT INTO `order_items` VALUES (4372,3073,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4373,3074,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4374,3075,3,1,169,0);

INSERT INTO `order_items` VALUES (4375,3075,9,1,129,0);

INSERT INTO `order_items` VALUES (4376,3076,13,1,68,0);

INSERT INTO `order_items` VALUES (4377,3077,12,2,79,0);

INSERT INTO `order_items` VALUES (4378,3077,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4379,3078,9,1,129,0);

INSERT INTO `order_items` VALUES (4380,3079,4,1,59,0);

INSERT INTO `order_items` VALUES (4381,3079,9,1,129,0);

INSERT INTO `order_items` VALUES (4382,3080,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4383,3081,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4384,3081,17,1,69,0);

INSERT INTO `order_items` VALUES (4385,3082,7,1,89,0);

INSERT INTO `order_items` VALUES (4386,3083,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4387,3083,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4388,3083,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4389,3084,11,1,39,0);

INSERT INTO `order_items` VALUES (4390,3085,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4391,3086,6,1,299,0.05);

INSERT INTO `order_items` VALUES (4392,3087,13,1,68,0);

INSERT INTO `order_items` VALUES (4393,3088,3,1,169,0);

INSERT INTO `order_items` VALUES (4394,3089,4,1,59,0);

INSERT INTO `order_items` VALUES (4395,3089,17,2,69,0.10);

INSERT INTO `order_items` VALUES (4396,3090,16,3,24.9,0);

INSERT INTO `order_items` VALUES (4397,3091,13,1,68,0);

INSERT INTO `order_items` VALUES (4398,3091,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4399,3092,12,1,79,0);

INSERT INTO `order_items` VALUES (4400,3093,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4401,3094,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4402,3095,18,2,159,0);

INSERT INTO `order_items` VALUES (4403,3096,7,1,89,0);

INSERT INTO `order_items` VALUES (4404,3097,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4405,3098,4,1,59,0);

INSERT INTO `order_items` VALUES (4406,3098,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4407,3098,20,1,39,0.10);

INSERT INTO `order_items` VALUES (4408,3099,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4409,3100,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4410,3101,12,1,79,0);

INSERT INTO `order_items` VALUES (4411,3102,7,2,89,0);

INSERT INTO `order_items` VALUES (4412,3102,11,2,39,0);

INSERT INTO `order_items` VALUES (4413,3102,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4414,3103,12,2,79,0);

INSERT INTO `order_items` VALUES (4415,3103,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4416,3104,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4417,3105,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4418,3106,12,1,79,0);

INSERT INTO `order_items` VALUES (4419,3107,16,2,24.9,0);

INSERT INTO `order_items` VALUES (4420,3107,20,1,39,0);

INSERT INTO `order_items` VALUES (4421,3108,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4422,3108,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4423,3109,7,1,89,0);

INSERT INTO `order_items` VALUES (4424,3110,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4425,3111,12,1,79,0);

INSERT INTO `order_items` VALUES (4426,3111,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4427,3112,6,1,299,0);

INSERT INTO `order_items` VALUES (4428,3113,18,1,159,0);

INSERT INTO `order_items` VALUES (4429,3114,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4430,3115,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4431,3116,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4432,3116,12,2,79,0);

INSERT INTO `order_items` VALUES (4433,3117,6,1,299,0);

INSERT INTO `order_items` VALUES (4434,3118,4,2,59,0.10);

INSERT INTO `order_items` VALUES (4435,3119,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4436,3120,11,1,39,0);

INSERT INTO `order_items` VALUES (4437,3121,7,1,89,0);

INSERT INTO `order_items` VALUES (4438,3121,11,1,39,0);

INSERT INTO `order_items` VALUES (4439,3122,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4440,3123,5,1,399,0);

INSERT INTO `order_items` VALUES (4441,3124,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4442,3125,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4443,3126,10,1,699,0);

INSERT INTO `order_items` VALUES (4444,3126,11,1,39,0);

INSERT INTO `order_items` VALUES (4445,3127,13,2,68,0.05);

INSERT INTO `order_items` VALUES (4446,3128,5,1,399,0.10);

INSERT INTO `order_items` VALUES (4447,3128,11,3,39,0);

INSERT INTO `order_items` VALUES (4448,3129,20,1,39,0);

INSERT INTO `order_items` VALUES (4449,3130,13,1,68,0);

INSERT INTO `order_items` VALUES (4450,3130,17,2,69,0);

INSERT INTO `order_items` VALUES (4451,3130,18,1,159,0.10);

INSERT INTO `order_items` VALUES (4452,3131,16,3,24.9,0);

INSERT INTO `order_items` VALUES (4453,3132,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4454,3133,9,1,129,0);

INSERT INTO `order_items` VALUES (4455,3133,11,1,39,0);

INSERT INTO `order_items` VALUES (4456,3134,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4457,3135,18,1,159,0.05);

INSERT INTO `order_items` VALUES (4458,3136,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4459,3136,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4460,3137,8,1,159,0);

INSERT INTO `order_items` VALUES (4461,3138,3,1,169,0.10);

INSERT INTO `order_items` VALUES (4462,3139,7,1,89,0);

INSERT INTO `order_items` VALUES (4463,3140,17,1,69,0);

INSERT INTO `order_items` VALUES (4464,3141,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4465,3142,11,1,39,0);

INSERT INTO `order_items` VALUES (4466,3142,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4467,3143,18,1,159,0);

INSERT INTO `order_items` VALUES (4468,3144,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (4469,3145,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4470,3146,18,1,159,0);

INSERT INTO `order_items` VALUES (4471,3147,9,1,129,0);

INSERT INTO `order_items` VALUES (4472,3148,18,1,159,0.05);

INSERT INTO `order_items` VALUES (4473,3149,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4474,3149,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4475,3149,18,1,159,0);

INSERT INTO `order_items` VALUES (4476,3150,12,1,79,0);

INSERT INTO `order_items` VALUES (4477,3151,12,1,79,0);

INSERT INTO `order_items` VALUES (4478,3152,11,1,39,0);

INSERT INTO `order_items` VALUES (4479,3153,12,1,79,0);

INSERT INTO `order_items` VALUES (4480,3154,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4481,3155,7,1,89,0);

INSERT INTO `order_items` VALUES (4482,3156,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4483,3157,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (4484,3158,11,1,39,0);

INSERT INTO `order_items` VALUES (4485,3158,17,1,69,0);

INSERT INTO `order_items` VALUES (4486,3159,13,1,68,0);

INSERT INTO `order_items` VALUES (4487,3160,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4488,3161,12,1,79,0);

INSERT INTO `order_items` VALUES (4489,3162,12,1,79,0);

INSERT INTO `order_items` VALUES (4490,3162,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4491,3163,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4492,3163,13,1,68,0);

INSERT INTO `order_items` VALUES (4493,3163,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4494,3164,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4495,3165,12,1,79,0);

INSERT INTO `order_items` VALUES (4496,3166,12,1,79,0);

INSERT INTO `order_items` VALUES (4497,3167,11,2,39,0.05);

INSERT INTO `order_items` VALUES (4498,3168,3,2,169,0.10);

INSERT INTO `order_items` VALUES (4499,3168,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4500,3168,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4501,3169,14,3,39.9,0);

INSERT INTO `order_items` VALUES (4502,3170,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4503,3170,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4504,3170,20,1,39,0);

INSERT INTO `order_items` VALUES (4505,3171,11,2,39,0);

INSERT INTO `order_items` VALUES (4506,3171,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4507,3172,20,1,39,0);

INSERT INTO `order_items` VALUES (4508,3173,13,1,68,0);

INSERT INTO `order_items` VALUES (4509,3173,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4510,3174,5,1,399,0);

INSERT INTO `order_items` VALUES (4511,3175,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4512,3176,13,1,68,0);

INSERT INTO `order_items` VALUES (4513,3176,18,1,159,0.05);

INSERT INTO `order_items` VALUES (4514,3177,4,1,59,0);

INSERT INTO `order_items` VALUES (4515,3177,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4516,3178,11,1,39,0);

INSERT INTO `order_items` VALUES (4517,3179,9,1,129,0.10);

INSERT INTO `order_items` VALUES (4518,3179,13,1,68,0);

INSERT INTO `order_items` VALUES (4519,3180,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4520,3180,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4521,3181,5,1,399,0);

INSERT INTO `order_items` VALUES (4522,3181,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4523,3182,4,1,59,0);

INSERT INTO `order_items` VALUES (4524,3182,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4525,3183,16,2,24.9,0);

INSERT INTO `order_items` VALUES (4526,3184,7,1,89,0);

INSERT INTO `order_items` VALUES (4527,3184,9,1,129,0);

INSERT INTO `order_items` VALUES (4528,3185,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4529,3186,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4530,3187,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4531,3188,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4532,3188,20,1,39,0);

INSERT INTO `order_items` VALUES (4533,3189,7,1,89,0);

INSERT INTO `order_items` VALUES (4534,3190,11,1,39,0);

INSERT INTO `order_items` VALUES (4535,3191,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4536,3192,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4537,3193,12,1,79,0);

INSERT INTO `order_items` VALUES (4538,3194,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4539,3194,17,2,69,0);

INSERT INTO `order_items` VALUES (4540,3195,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4541,3196,4,1,59,0);

INSERT INTO `order_items` VALUES (4542,3196,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4543,3197,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4544,3198,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4545,3199,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4546,3200,8,1,159,0.10);

INSERT INTO `order_items` VALUES (4547,3201,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4548,3202,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4549,3203,11,1,39,0);

INSERT INTO `order_items` VALUES (4550,3203,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4551,3204,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4552,3205,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4553,3206,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4554,3207,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4555,3207,17,1,69,0);

INSERT INTO `order_items` VALUES (4556,3208,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4557,3209,13,2,68,0);

INSERT INTO `order_items` VALUES (4558,3209,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4559,3209,18,1,159,0);

INSERT INTO `order_items` VALUES (4560,3210,4,1,59,0);

INSERT INTO `order_items` VALUES (4561,3210,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4562,3211,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4563,3212,13,1,68,0);

INSERT INTO `order_items` VALUES (4564,3212,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4565,3213,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4566,3214,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4567,3214,20,1,39,0);

INSERT INTO `order_items` VALUES (4568,3215,3,1,169,0);

INSERT INTO `order_items` VALUES (4569,3216,12,1,79,0);

INSERT INTO `order_items` VALUES (4570,3216,20,2,39,0.05);

INSERT INTO `order_items` VALUES (4571,3217,8,1,159,0);

INSERT INTO `order_items` VALUES (4572,3218,4,1,59,0);

INSERT INTO `order_items` VALUES (4573,3218,12,1,79,0);

INSERT INTO `order_items` VALUES (4574,3219,9,1,129,0);

INSERT INTO `order_items` VALUES (4575,3220,13,1,68,0);

INSERT INTO `order_items` VALUES (4576,3220,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4577,3221,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4578,3222,9,2,129,0.05);

INSERT INTO `order_items` VALUES (4579,3223,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4580,3223,13,1,68,0);

INSERT INTO `order_items` VALUES (4581,3224,11,1,39,0);

INSERT INTO `order_items` VALUES (4582,3225,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4583,3226,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4584,3227,10,1,699,0);

INSERT INTO `order_items` VALUES (4585,3228,13,1,68,0);

INSERT INTO `order_items` VALUES (4586,3228,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4587,3229,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4588,3230,13,1,68,0);

INSERT INTO `order_items` VALUES (4589,3230,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (4590,3231,20,3,39,0);

INSERT INTO `order_items` VALUES (4591,3232,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4592,3233,4,1,59,0);

INSERT INTO `order_items` VALUES (4593,3233,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4594,3234,4,1,59,0);

INSERT INTO `order_items` VALUES (4595,3235,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4596,3235,18,1,159,0);

INSERT INTO `order_items` VALUES (4597,3236,20,1,39,0);

INSERT INTO `order_items` VALUES (4598,3237,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4599,3237,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4600,3238,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4601,3239,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4602,3240,18,1,159,0);

INSERT INTO `order_items` VALUES (4603,3241,11,1,39,0);

INSERT INTO `order_items` VALUES (4604,3241,12,1,79,0);

INSERT INTO `order_items` VALUES (4605,3242,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4606,3242,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4607,3243,11,1,39,0);

INSERT INTO `order_items` VALUES (4608,3243,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (4609,3244,9,1,129,0);

INSERT INTO `order_items` VALUES (4610,3244,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4611,3245,1,1,4299,0);

INSERT INTO `order_items` VALUES (4612,3246,5,1,399,0.10);

INSERT INTO `order_items` VALUES (4613,3246,11,1,39,0);

INSERT INTO `order_items` VALUES (4614,3246,12,3,79,0);

INSERT INTO `order_items` VALUES (4615,3247,9,1,129,0);

INSERT INTO `order_items` VALUES (4616,3247,11,1,39,0);

INSERT INTO `order_items` VALUES (4617,3248,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4618,3248,18,1,159,0);

INSERT INTO `order_items` VALUES (4619,3249,12,3,79,0.05);

INSERT INTO `order_items` VALUES (4620,3249,17,1,69,0);

INSERT INTO `order_items` VALUES (4621,3250,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4622,3251,13,1,68,0);

INSERT INTO `order_items` VALUES (4623,3252,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4624,3252,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4625,3252,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4626,3253,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4627,3254,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4628,3255,13,1,68,0);

INSERT INTO `order_items` VALUES (4629,3256,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4630,3257,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4631,3257,20,1,39,0);

INSERT INTO `order_items` VALUES (4632,3258,4,1,59,0);

INSERT INTO `order_items` VALUES (4633,3259,6,1,299,0);

INSERT INTO `order_items` VALUES (4634,3259,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4635,3259,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4636,3260,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4637,3260,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4638,3260,17,1,69,0);

INSERT INTO `order_items` VALUES (4639,3261,12,1,79,0);

INSERT INTO `order_items` VALUES (4640,3261,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4641,3262,13,2,68,0);

INSERT INTO `order_items` VALUES (4642,3262,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4643,3263,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4644,3264,17,2,69,0);

INSERT INTO `order_items` VALUES (4645,3265,9,3,129,0);

INSERT INTO `order_items` VALUES (4646,3266,4,1,59,0);

INSERT INTO `order_items` VALUES (4647,3266,11,2,39,0.05);

INSERT INTO `order_items` VALUES (4648,3267,13,1,68,0);

INSERT INTO `order_items` VALUES (4649,3268,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4650,3269,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4651,3270,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4652,3271,19,2,199,0);

INSERT INTO `order_items` VALUES (4653,3272,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4654,3273,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4655,3274,7,1,89,0);

INSERT INTO `order_items` VALUES (4656,3275,12,1,79,0);

INSERT INTO `order_items` VALUES (4657,3276,4,1,59,0);

INSERT INTO `order_items` VALUES (4658,3277,8,1,159,0);

INSERT INTO `order_items` VALUES (4659,3278,12,1,79,0);

INSERT INTO `order_items` VALUES (4660,3278,13,1,68,0);

INSERT INTO `order_items` VALUES (4661,3279,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4662,3279,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4663,3279,17,2,69,0);

INSERT INTO `order_items` VALUES (4664,3280,8,1,159,0.05);

INSERT INTO `order_items` VALUES (4665,3281,2,3,899,0);

INSERT INTO `order_items` VALUES (4666,3281,5,2,399,0);

INSERT INTO `order_items` VALUES (4667,3282,4,1,59,0);

INSERT INTO `order_items` VALUES (4668,3282,13,1,68,0);

INSERT INTO `order_items` VALUES (4669,3282,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4670,3283,4,1,59,0);

INSERT INTO `order_items` VALUES (4671,3284,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4672,3285,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4673,3286,8,1,159,0);

INSERT INTO `order_items` VALUES (4674,3287,3,1,169,0);

INSERT INTO `order_items` VALUES (4675,3287,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4676,3288,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4677,3289,4,1,59,0);

INSERT INTO `order_items` VALUES (4678,3290,13,1,68,0);

INSERT INTO `order_items` VALUES (4679,3291,12,1,79,0);

INSERT INTO `order_items` VALUES (4680,3292,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4681,3293,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4682,3293,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4683,3294,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4684,3294,20,1,39,0);

INSERT INTO `order_items` VALUES (4685,3295,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4686,3295,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4687,3296,19,2,199,0.05);

INSERT INTO `order_items` VALUES (4688,3297,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4689,3298,11,1,39,0);

INSERT INTO `order_items` VALUES (4690,3298,13,2,68,0);

INSERT INTO `order_items` VALUES (4691,3299,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4692,3300,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4693,3300,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4694,3300,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4695,3301,13,1,68,0);

INSERT INTO `order_items` VALUES (4696,3301,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4697,3302,13,1,68,0);

INSERT INTO `order_items` VALUES (4698,3303,7,2,89,0);

INSERT INTO `order_items` VALUES (4699,3303,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4700,3304,6,1,299,0);

INSERT INTO `order_items` VALUES (4701,3305,6,1,299,0);

INSERT INTO `order_items` VALUES (4702,3306,20,2,39,0);

INSERT INTO `order_items` VALUES (4703,3307,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4704,3307,20,2,39,0);

INSERT INTO `order_items` VALUES (4705,3308,11,2,39,0);

INSERT INTO `order_items` VALUES (4706,3308,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4707,3309,18,1,159,0);

INSERT INTO `order_items` VALUES (4708,3310,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4709,3311,6,1,299,0.10);

INSERT INTO `order_items` VALUES (4710,3311,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4711,3312,13,1,68,0);

INSERT INTO `order_items` VALUES (4712,3313,13,1,68,0);

INSERT INTO `order_items` VALUES (4713,3313,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4714,3314,9,1,129,0);

INSERT INTO `order_items` VALUES (4715,3314,12,1,79,0);

INSERT INTO `order_items` VALUES (4716,3315,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4717,3316,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4718,3317,3,1,169,0);

INSERT INTO `order_items` VALUES (4719,3317,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4720,3318,17,1,69,0);

INSERT INTO `order_items` VALUES (4721,3319,3,1,169,0);

INSERT INTO `order_items` VALUES (4722,3319,12,1,79,0);

INSERT INTO `order_items` VALUES (4723,3320,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4724,3321,20,1,39,0);

INSERT INTO `order_items` VALUES (4725,3322,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4726,3323,13,1,68,0);

INSERT INTO `order_items` VALUES (4727,3324,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4728,3325,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4729,3325,17,1,69,0);

INSERT INTO `order_items` VALUES (4730,3326,9,1,129,0);

INSERT INTO `order_items` VALUES (4731,3327,6,1,299,0);

INSERT INTO `order_items` VALUES (4732,3327,17,1,69,0);

INSERT INTO `order_items` VALUES (4733,3328,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4734,3328,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4735,3329,9,2,129,0);

INSERT INTO `order_items` VALUES (4736,3330,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4737,3330,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4738,3331,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4739,3332,13,1,68,0);

INSERT INTO `order_items` VALUES (4740,3333,17,1,69,0);

INSERT INTO `order_items` VALUES (4741,3334,17,1,69,0);

INSERT INTO `order_items` VALUES (4742,3335,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4743,3336,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4744,3337,10,1,699,0);

INSERT INTO `order_items` VALUES (4745,3338,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4746,3338,19,1,199,0);

INSERT INTO `order_items` VALUES (4747,3339,11,2,39,0);

INSERT INTO `order_items` VALUES (4748,3339,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4749,3340,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4750,3341,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4751,3342,20,1,39,0);

INSERT INTO `order_items` VALUES (4752,3343,11,1,39,0);

INSERT INTO `order_items` VALUES (4753,3344,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4754,3345,7,1,89,0);

INSERT INTO `order_items` VALUES (4755,3346,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4756,3347,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4757,3348,20,1,39,0);

INSERT INTO `order_items` VALUES (4758,3349,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4759,3350,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4760,3351,13,1,68,0);

INSERT INTO `order_items` VALUES (4761,3351,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4762,3352,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4763,3352,17,1,69,0);

INSERT INTO `order_items` VALUES (4764,3353,13,1,68,0);

INSERT INTO `order_items` VALUES (4765,3354,11,2,39,0);

INSERT INTO `order_items` VALUES (4766,3355,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4767,3355,20,2,39,0.05);

INSERT INTO `order_items` VALUES (4768,3356,3,1,169,0);

INSERT INTO `order_items` VALUES (4769,3357,11,2,39,0.10);

INSERT INTO `order_items` VALUES (4770,3357,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4771,3358,20,1,39,0);

INSERT INTO `order_items` VALUES (4772,3359,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4773,3360,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4774,3360,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4775,3361,9,1,129,0);

INSERT INTO `order_items` VALUES (4776,3361,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4777,3362,9,1,129,0);

INSERT INTO `order_items` VALUES (4778,3363,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4779,3363,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4780,3364,9,1,129,0);

INSERT INTO `order_items` VALUES (4781,3365,11,2,39,0);

INSERT INTO `order_items` VALUES (4782,3365,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4783,3366,9,2,129,0.05);

INSERT INTO `order_items` VALUES (4784,3366,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4785,3367,11,2,39,0);

INSERT INTO `order_items` VALUES (4786,3368,12,1,79,0);

INSERT INTO `order_items` VALUES (4787,3368,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4788,3369,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4789,3370,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4790,3370,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4791,3371,12,1,79,0);

INSERT INTO `order_items` VALUES (4792,3372,11,1,39,0);

INSERT INTO `order_items` VALUES (4793,3372,13,1,68,0);

INSERT INTO `order_items` VALUES (4794,3372,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4795,3373,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4796,3374,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (4797,3375,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4798,3375,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (4799,3376,8,1,159,0.05);

INSERT INTO `order_items` VALUES (4800,3376,20,1,39,0);

INSERT INTO `order_items` VALUES (4801,3377,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4802,3378,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4803,3379,12,2,79,0);

INSERT INTO `order_items` VALUES (4804,3380,6,1,299,0);

INSERT INTO `order_items` VALUES (4805,3381,4,1,59,0);

INSERT INTO `order_items` VALUES (4806,3381,18,1,159,0);

INSERT INTO `order_items` VALUES (4807,3382,6,1,299,0);

INSERT INTO `order_items` VALUES (4808,3382,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4809,3383,12,1,79,0);

INSERT INTO `order_items` VALUES (4810,3384,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4811,3385,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4812,3385,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4813,3385,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4814,3386,11,2,39,0.05);

INSERT INTO `order_items` VALUES (4815,3387,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4816,3388,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4817,3389,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (4818,3390,4,1,59,0);

INSERT INTO `order_items` VALUES (4819,3391,20,2,39,0.05);

INSERT INTO `order_items` VALUES (4820,3392,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4821,3393,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4822,3394,12,3,79,0);

INSERT INTO `order_items` VALUES (4823,3394,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4824,3395,13,1,68,0);

INSERT INTO `order_items` VALUES (4825,3396,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4826,3397,5,1,399,0);

INSERT INTO `order_items` VALUES (4827,3398,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4828,3399,4,1,59,0);

INSERT INTO `order_items` VALUES (4829,3400,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4830,3401,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4831,3402,11,1,39,0);

INSERT INTO `order_items` VALUES (4832,3403,13,1,68,0.10);

INSERT INTO `order_items` VALUES (4833,3404,9,2,129,0.10);

INSERT INTO `order_items` VALUES (4834,3405,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4835,3406,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4836,3407,18,1,159,0);

INSERT INTO `order_items` VALUES (4837,3408,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4838,3409,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4839,3410,13,1,68,0);

INSERT INTO `order_items` VALUES (4840,3411,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4841,3411,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4842,3412,13,2,68,0);

INSERT INTO `order_items` VALUES (4843,3413,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (4844,3414,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (4845,3415,11,1,39,0);

INSERT INTO `order_items` VALUES (4846,3416,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4847,3417,20,1,39,0);

INSERT INTO `order_items` VALUES (4848,3418,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4849,3418,17,1,69,0);

INSERT INTO `order_items` VALUES (4850,3419,13,3,68,0);

INSERT INTO `order_items` VALUES (4851,3420,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4852,3421,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4853,3422,12,1,79,0);

INSERT INTO `order_items` VALUES (4854,3423,4,1,59,0);

INSERT INTO `order_items` VALUES (4855,3423,11,1,39,0);

INSERT INTO `order_items` VALUES (4856,3424,3,2,169,0);

INSERT INTO `order_items` VALUES (4857,3424,14,2,39.9,0.05);

INSERT INTO `order_items` VALUES (4858,3424,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4859,3425,12,1,79,0);

INSERT INTO `order_items` VALUES (4860,3426,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4861,3427,3,1,169,0);

INSERT INTO `order_items` VALUES (4862,3427,4,2,59,0);

INSERT INTO `order_items` VALUES (4863,3428,3,1,169,0);

INSERT INTO `order_items` VALUES (4864,3428,11,1,39,0);

INSERT INTO `order_items` VALUES (4865,3429,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4866,3430,20,1,39,0);

INSERT INTO `order_items` VALUES (4867,3431,4,1,59,0.10);

INSERT INTO `order_items` VALUES (4868,3431,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4869,3432,4,1,59,0);

INSERT INTO `order_items` VALUES (4870,3433,4,1,59,0);

INSERT INTO `order_items` VALUES (4871,3434,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4872,3435,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4873,3435,19,1,199,0);

INSERT INTO `order_items` VALUES (4874,3436,3,2,169,0);

INSERT INTO `order_items` VALUES (4875,3436,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4876,3437,17,1,69,0);

INSERT INTO `order_items` VALUES (4877,3438,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4878,3438,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4879,3439,13,1,68,0);

INSERT INTO `order_items` VALUES (4880,3439,20,2,39,0);

INSERT INTO `order_items` VALUES (4881,3440,12,1,79,0.05);

INSERT INTO `order_items` VALUES (4882,3441,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4883,3441,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4884,3442,5,1,399,0.05);

INSERT INTO `order_items` VALUES (4885,3442,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4886,3443,13,1,68,0);

INSERT INTO `order_items` VALUES (4887,3444,11,1,39,0);

INSERT INTO `order_items` VALUES (4888,3444,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4889,3444,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (4890,3445,13,1,68,0);

INSERT INTO `order_items` VALUES (4891,3446,11,1,39,0);

INSERT INTO `order_items` VALUES (4892,3447,20,1,39,0);

INSERT INTO `order_items` VALUES (4893,3448,7,2,89,0.05);

INSERT INTO `order_items` VALUES (4894,3449,4,1,59,0);

INSERT INTO `order_items` VALUES (4895,3449,17,1,69,0);

INSERT INTO `order_items` VALUES (4896,3450,2,1,899,0.10);

INSERT INTO `order_items` VALUES (4897,3450,6,2,299,0);

INSERT INTO `order_items` VALUES (4898,3451,4,2,59,0.10);

INSERT INTO `order_items` VALUES (4899,3452,4,1,59,0);

INSERT INTO `order_items` VALUES (4900,3453,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4901,3454,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4902,3454,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4903,3455,18,1,159,0);

INSERT INTO `order_items` VALUES (4904,3456,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (4905,3457,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (4906,3458,4,1,59,0);

INSERT INTO `order_items` VALUES (4907,3458,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4908,3458,20,1,39,0);

INSERT INTO `order_items` VALUES (4909,3459,11,1,39,0);

INSERT INTO `order_items` VALUES (4910,3460,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4911,3461,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4912,3461,14,3,39.9,0);

INSERT INTO `order_items` VALUES (4913,3461,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4914,3462,12,1,79,0.10);

INSERT INTO `order_items` VALUES (4915,3462,13,2,68,0.05);

INSERT INTO `order_items` VALUES (4916,3463,4,1,59,0);

INSERT INTO `order_items` VALUES (4917,3463,9,1,129,0);

INSERT INTO `order_items` VALUES (4918,3464,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4919,3465,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4920,3465,20,1,39,0.05);

INSERT INTO `order_items` VALUES (4921,3466,12,1,79,0);

INSERT INTO `order_items` VALUES (4922,3467,10,1,699,0);

INSERT INTO `order_items` VALUES (4923,3467,17,1,69,0.05);

INSERT INTO `order_items` VALUES (4924,3468,9,3,129,0);

INSERT INTO `order_items` VALUES (4925,3469,13,2,68,0);

INSERT INTO `order_items` VALUES (4926,3470,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4927,3471,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4928,3472,4,1,59,0);

INSERT INTO `order_items` VALUES (4929,3473,9,1,129,0);

INSERT INTO `order_items` VALUES (4930,3473,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (4931,3474,4,1,59,0.05);

INSERT INTO `order_items` VALUES (4932,3474,12,1,79,0);

INSERT INTO `order_items` VALUES (4933,3475,7,1,89,0);

INSERT INTO `order_items` VALUES (4934,3476,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4935,3477,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4936,3478,20,3,39,0);

INSERT INTO `order_items` VALUES (4937,3479,11,1,39,0.05);

INSERT INTO `order_items` VALUES (4938,3479,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (4939,3479,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4940,3480,3,1,169,0);

INSERT INTO `order_items` VALUES (4941,3481,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4942,3482,3,2,169,0.05);

INSERT INTO `order_items` VALUES (4943,3482,14,2,39.9,0);

INSERT INTO `order_items` VALUES (4944,3483,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4945,3484,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4946,3484,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4947,3485,13,1,68,0);

INSERT INTO `order_items` VALUES (4948,3486,6,1,299,0);

INSERT INTO `order_items` VALUES (4949,3486,7,1,89,0);

INSERT INTO `order_items` VALUES (4950,3486,19,3,199,0);

INSERT INTO `order_items` VALUES (4951,3487,13,1,68,0);

INSERT INTO `order_items` VALUES (4952,3487,15,2,32.9,0);

INSERT INTO `order_items` VALUES (4953,3488,7,3,89,0);

INSERT INTO `order_items` VALUES (4954,3489,7,1,89,0.05);

INSERT INTO `order_items` VALUES (4955,3490,18,3,159,0);

INSERT INTO `order_items` VALUES (4956,3491,4,2,59,0);

INSERT INTO `order_items` VALUES (4957,3491,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4958,3492,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4959,3493,11,1,39,0);

INSERT INTO `order_items` VALUES (4960,3493,13,1,68,0.05);

INSERT INTO `order_items` VALUES (4961,3494,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4962,3495,3,1,169,0.10);

INSERT INTO `order_items` VALUES (4963,3495,17,2,69,0);

INSERT INTO `order_items` VALUES (4964,3495,20,1,39,0);

INSERT INTO `order_items` VALUES (4965,3496,4,1,59,0);

INSERT INTO `order_items` VALUES (4966,3496,7,1,89,0);

INSERT INTO `order_items` VALUES (4967,3497,8,1,159,0.05);

INSERT INTO `order_items` VALUES (4968,3497,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4969,3497,16,3,24.9,0);

INSERT INTO `order_items` VALUES (4970,3498,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4971,3499,9,1,129,0.05);

INSERT INTO `order_items` VALUES (4972,3499,18,1,159,0);

INSERT INTO `order_items` VALUES (4973,3500,17,1,69,0);

INSERT INTO `order_items` VALUES (4974,3501,13,1,68,0);

INSERT INTO `order_items` VALUES (4975,3501,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4976,3502,13,2,68,0);

INSERT INTO `order_items` VALUES (4977,3503,11,1,39,0.10);

INSERT INTO `order_items` VALUES (4978,3504,11,1,39,0);

INSERT INTO `order_items` VALUES (4979,3505,17,1,69,0);

INSERT INTO `order_items` VALUES (4980,3506,15,2,32.9,0);

INSERT INTO `order_items` VALUES (4981,3507,4,1,59,0);

INSERT INTO `order_items` VALUES (4982,3507,18,1,159,0);

INSERT INTO `order_items` VALUES (4983,3508,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4984,3509,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4985,3510,3,1,169,0.05);

INSERT INTO `order_items` VALUES (4986,3511,2,1,899,0);

INSERT INTO `order_items` VALUES (4987,3512,9,1,129,0);

INSERT INTO `order_items` VALUES (4988,3512,15,1,32.9,0);

INSERT INTO `order_items` VALUES (4989,3512,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4990,3513,16,1,24.9,0);

INSERT INTO `order_items` VALUES (4991,3514,13,1,68,0);

INSERT INTO `order_items` VALUES (4992,3515,4,2,59,0);

INSERT INTO `order_items` VALUES (4993,3515,12,1,79,0);

INSERT INTO `order_items` VALUES (4994,3516,8,2,159,0.10);

INSERT INTO `order_items` VALUES (4995,3517,11,1,39,0);

INSERT INTO `order_items` VALUES (4996,3518,11,1,39,0);

INSERT INTO `order_items` VALUES (4997,3519,14,1,39.9,0);

INSERT INTO `order_items` VALUES (4998,3520,7,1,89,0.10);

INSERT INTO `order_items` VALUES (4999,3521,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5000,3522,4,3,59,0);

INSERT INTO `order_items` VALUES (5001,3523,6,1,299,0);

INSERT INTO `order_items` VALUES (5002,3524,13,2,68,0);

INSERT INTO `order_items` VALUES (5003,3524,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5004,3525,7,1,89,0);

INSERT INTO `order_items` VALUES (5005,3525,11,1,39,0);

INSERT INTO `order_items` VALUES (5006,3526,12,1,79,0.05);

INSERT INTO `order_items` VALUES (5007,3526,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5008,3526,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5009,3527,7,1,89,0.10);

INSERT INTO `order_items` VALUES (5010,3528,3,1,169,0);

INSERT INTO `order_items` VALUES (5011,3528,7,1,89,0);

INSERT INTO `order_items` VALUES (5012,3529,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5013,3530,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5014,3530,17,1,69,0);

INSERT INTO `order_items` VALUES (5015,3531,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5016,3532,7,1,89,0);

INSERT INTO `order_items` VALUES (5017,3533,20,1,39,0);

INSERT INTO `order_items` VALUES (5018,3534,11,3,39,0);

INSERT INTO `order_items` VALUES (5019,3535,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5020,3536,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5021,3537,4,2,59,0);

INSERT INTO `order_items` VALUES (5022,3537,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5023,3538,7,1,89,0);

INSERT INTO `order_items` VALUES (5024,3539,11,2,39,0);

INSERT INTO `order_items` VALUES (5025,3539,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5026,3540,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5027,3541,10,1,699,0.05);

INSERT INTO `order_items` VALUES (5028,3542,4,3,59,0);

INSERT INTO `order_items` VALUES (5029,3542,13,1,68,0);

INSERT INTO `order_items` VALUES (5030,3543,14,3,39.9,0.05);

INSERT INTO `order_items` VALUES (5031,3544,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5032,3545,7,1,89,0);

INSERT INTO `order_items` VALUES (5033,3545,17,1,69,0);

INSERT INTO `order_items` VALUES (5034,3546,12,1,79,0);

INSERT INTO `order_items` VALUES (5035,3546,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5036,3547,9,1,129,0);

INSERT INTO `order_items` VALUES (5037,3547,12,1,79,0);

INSERT INTO `order_items` VALUES (5038,3548,4,2,59,0);

INSERT INTO `order_items` VALUES (5039,3548,5,1,399,0.10);

INSERT INTO `order_items` VALUES (5040,3548,9,1,129,0);

INSERT INTO `order_items` VALUES (5041,3549,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5042,3550,12,1,79,0.05);

INSERT INTO `order_items` VALUES (5043,3551,9,2,129,0);

INSERT INTO `order_items` VALUES (5044,3552,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5045,3553,20,2,39,0);

INSERT INTO `order_items` VALUES (5046,3554,12,2,79,0);

INSERT INTO `order_items` VALUES (5047,3554,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (5048,3555,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5049,3556,17,1,69,0.05);

INSERT INTO `order_items` VALUES (5050,3557,8,1,159,0);

INSERT INTO `order_items` VALUES (5051,3558,4,1,59,0);

INSERT INTO `order_items` VALUES (5052,3559,17,1,69,0);

INSERT INTO `order_items` VALUES (5053,3560,4,3,59,0);

INSERT INTO `order_items` VALUES (5054,3560,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5055,3560,17,1,69,0.05);

INSERT INTO `order_items` VALUES (5056,3561,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5057,3562,4,1,59,0);

INSERT INTO `order_items` VALUES (5058,3562,11,1,39,0);

INSERT INTO `order_items` VALUES (5059,3563,11,2,39,0);

INSERT INTO `order_items` VALUES (5060,3564,4,1,59,0.05);

INSERT INTO `order_items` VALUES (5061,3564,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (5062,3564,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5063,3565,2,1,899,0);

INSERT INTO `order_items` VALUES (5064,3566,14,3,39.9,0);

INSERT INTO `order_items` VALUES (5065,3567,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5066,3568,18,1,159,0);

INSERT INTO `order_items` VALUES (5067,3569,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5068,3570,13,2,68,0.10);

INSERT INTO `order_items` VALUES (5069,3570,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5070,3571,16,2,24.9,0.05);

INSERT INTO `order_items` VALUES (5071,3572,4,2,59,0);

INSERT INTO `order_items` VALUES (5072,3573,4,1,59,0);

INSERT INTO `order_items` VALUES (5073,3574,8,2,159,0);

INSERT INTO `order_items` VALUES (5074,3575,13,1,68,0);

INSERT INTO `order_items` VALUES (5075,3576,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5076,3576,14,2,39.9,0);

INSERT INTO `order_items` VALUES (5077,3576,17,1,69,0);

INSERT INTO `order_items` VALUES (5078,3577,7,3,89,0);

INSERT INTO `order_items` VALUES (5079,3578,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5080,3578,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5081,3579,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5082,3580,6,1,299,0.05);

INSERT INTO `order_items` VALUES (5083,3581,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5084,3582,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5085,3583,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5086,3584,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5087,3585,9,1,129,0);

INSERT INTO `order_items` VALUES (5088,3585,13,1,68,0);

INSERT INTO `order_items` VALUES (5089,3586,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5090,3587,11,1,39,0);

INSERT INTO `order_items` VALUES (5091,3588,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5092,3589,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (5093,3590,18,1,159,0);

INSERT INTO `order_items` VALUES (5094,3590,20,1,39,0);

INSERT INTO `order_items` VALUES (5095,3591,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5096,3591,17,1,69,0);

INSERT INTO `order_items` VALUES (5097,3592,17,1,69,0);

INSERT INTO `order_items` VALUES (5098,3593,19,1,199,0.05);

INSERT INTO `order_items` VALUES (5099,3594,18,1,159,0.05);

INSERT INTO `order_items` VALUES (5100,3595,13,1,68,0);

INSERT INTO `order_items` VALUES (5101,3596,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5102,3597,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5103,3598,4,1,59,0);

INSERT INTO `order_items` VALUES (5104,3599,8,2,159,0);

INSERT INTO `order_items` VALUES (5105,3600,2,2,899,0);

INSERT INTO `order_items` VALUES (5106,3600,17,1,69,0);

INSERT INTO `order_items` VALUES (5107,3601,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5108,3602,4,1,59,0);

INSERT INTO `order_items` VALUES (5109,3603,12,1,79,0);

INSERT INTO `order_items` VALUES (5110,3603,13,1,68,0);

INSERT INTO `order_items` VALUES (5111,3604,18,2,159,0);

INSERT INTO `order_items` VALUES (5112,3605,6,2,299,0);

INSERT INTO `order_items` VALUES (5113,3605,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5114,3606,13,1,68,0.10);

INSERT INTO `order_items` VALUES (5115,3607,14,3,39.9,0);

INSERT INTO `order_items` VALUES (5116,3608,11,1,39,0);

INSERT INTO `order_items` VALUES (5117,3608,15,2,32.9,0);

INSERT INTO `order_items` VALUES (5118,3609,20,1,39,0);

INSERT INTO `order_items` VALUES (5119,3610,2,1,899,0);

INSERT INTO `order_items` VALUES (5120,3611,9,1,129,0.05);

INSERT INTO `order_items` VALUES (5121,3612,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5122,3613,12,1,79,0);

INSERT INTO `order_items` VALUES (5123,3614,4,1,59,0);

INSERT INTO `order_items` VALUES (5124,3615,4,1,59,0.05);

INSERT INTO `order_items` VALUES (5125,3616,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5126,3617,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5127,3618,12,1,79,0);

INSERT INTO `order_items` VALUES (5128,3618,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5129,3619,4,1,59,0);

INSERT INTO `order_items` VALUES (5130,3619,9,1,129,0);

INSERT INTO `order_items` VALUES (5131,3619,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5132,3620,12,2,79,0);

INSERT INTO `order_items` VALUES (5133,3621,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5134,3621,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5135,3622,7,1,89,0);

INSERT INTO `order_items` VALUES (5136,3622,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5137,3623,6,1,299,0);

INSERT INTO `order_items` VALUES (5138,3624,7,2,89,0);

INSERT INTO `order_items` VALUES (5139,3625,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5140,3626,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5141,3626,13,1,68,0);

INSERT INTO `order_items` VALUES (5142,3627,13,1,68,0);

INSERT INTO `order_items` VALUES (5143,3628,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5144,3628,20,1,39,0);

INSERT INTO `order_items` VALUES (5145,3629,4,1,59,0);

INSERT INTO `order_items` VALUES (5146,3629,9,1,129,0);

INSERT INTO `order_items` VALUES (5147,3629,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5148,3630,8,2,159,0);

INSERT INTO `order_items` VALUES (5149,3631,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5150,3632,7,1,89,0);

INSERT INTO `order_items` VALUES (5151,3633,11,1,39,0);

INSERT INTO `order_items` VALUES (5152,3634,1,1,4299,0.05);

INSERT INTO `order_items` VALUES (5153,3634,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5154,3635,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5155,3636,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5156,3637,9,1,129,0);

INSERT INTO `order_items` VALUES (5157,3637,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5158,3637,20,1,39,0.05);

INSERT INTO `order_items` VALUES (5159,3638,9,1,129,0);

INSERT INTO `order_items` VALUES (5160,3638,17,1,69,0);

INSERT INTO `order_items` VALUES (5161,3639,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5162,3640,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5163,3641,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5164,3641,17,2,69,0);

INSERT INTO `order_items` VALUES (5165,3642,12,1,79,0);

INSERT INTO `order_items` VALUES (5166,3642,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5167,3643,9,1,129,0.05);

INSERT INTO `order_items` VALUES (5168,3643,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5169,3644,12,1,79,0);

INSERT INTO `order_items` VALUES (5170,3644,15,2,32.9,0);

INSERT INTO `order_items` VALUES (5171,3644,16,3,24.9,0);

INSERT INTO `order_items` VALUES (5172,3645,3,1,169,0.05);

INSERT INTO `order_items` VALUES (5173,3645,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5174,3646,9,1,129,0.05);

INSERT INTO `order_items` VALUES (5175,3646,12,1,79,0);

INSERT INTO `order_items` VALUES (5176,3647,12,2,79,0.10);

INSERT INTO `order_items` VALUES (5177,3647,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5178,3647,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5179,3648,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5180,3649,3,1,169,0);

INSERT INTO `order_items` VALUES (5181,3649,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5182,3649,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5183,3650,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5184,3650,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5185,3651,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5186,3652,4,1,59,0);

INSERT INTO `order_items` VALUES (5187,3653,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5188,3654,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5189,3655,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5190,3656,12,1,79,0);

INSERT INTO `order_items` VALUES (5191,3657,4,1,59,0);

INSERT INTO `order_items` VALUES (5192,3657,6,1,299,0);

INSERT INTO `order_items` VALUES (5193,3658,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5194,3659,17,1,69,0);

INSERT INTO `order_items` VALUES (5195,3660,13,1,68,0);

INSERT INTO `order_items` VALUES (5196,3660,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5197,3661,13,1,68,0);

INSERT INTO `order_items` VALUES (5198,3661,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5199,3662,6,1,299,0);

INSERT INTO `order_items` VALUES (5200,3662,12,1,79,0);

INSERT INTO `order_items` VALUES (5201,3663,13,1,68,0);

INSERT INTO `order_items` VALUES (5202,3664,11,1,39,0);

INSERT INTO `order_items` VALUES (5203,3664,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5204,3665,14,2,39.9,0);

INSERT INTO `order_items` VALUES (5205,3666,9,1,129,0);

INSERT INTO `order_items` VALUES (5206,3667,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (5207,3668,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5208,3669,4,1,59,0);

INSERT INTO `order_items` VALUES (5209,3669,13,1,68,0);

INSERT INTO `order_items` VALUES (5210,3669,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5211,3670,4,2,59,0);

INSERT INTO `order_items` VALUES (5212,3670,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5213,3671,20,1,39,0);

INSERT INTO `order_items` VALUES (5214,3672,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5215,3673,19,1,199,0.05);

INSERT INTO `order_items` VALUES (5216,3674,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5217,3675,11,1,39,0);

INSERT INTO `order_items` VALUES (5218,3675,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5219,3676,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5220,3677,4,2,59,0);

INSERT INTO `order_items` VALUES (5221,3677,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5222,3678,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5223,3679,3,1,169,0);

INSERT INTO `order_items` VALUES (5224,3680,3,1,169,0);

INSERT INTO `order_items` VALUES (5225,3681,4,1,59,0);

INSERT INTO `order_items` VALUES (5226,3682,4,1,59,0);

INSERT INTO `order_items` VALUES (5227,3683,20,1,39,0);

INSERT INTO `order_items` VALUES (5228,3684,17,1,69,0.05);

INSERT INTO `order_items` VALUES (5229,3685,11,2,39,0);

INSERT INTO `order_items` VALUES (5230,3686,20,2,39,0.10);

INSERT INTO `order_items` VALUES (5231,3687,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5232,3688,13,1,68,0);

INSERT INTO `order_items` VALUES (5233,3689,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5234,3690,6,1,299,0);

INSERT INTO `order_items` VALUES (5235,3691,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5236,3692,9,1,129,0);

INSERT INTO `order_items` VALUES (5237,3692,13,2,68,0);

INSERT INTO `order_items` VALUES (5238,3692,16,2,24.9,0);

INSERT INTO `order_items` VALUES (5239,3693,3,2,169,0.05);

INSERT INTO `order_items` VALUES (5240,3694,11,1,39,0);

INSERT INTO `order_items` VALUES (5241,3695,14,2,39.9,0);

INSERT INTO `order_items` VALUES (5242,3696,11,1,39,0);

INSERT INTO `order_items` VALUES (5243,3696,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5244,3697,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5245,3697,20,1,39,0);

INSERT INTO `order_items` VALUES (5246,3698,18,1,159,0);

INSERT INTO `order_items` VALUES (5247,3699,13,1,68,0);

INSERT INTO `order_items` VALUES (5248,3699,17,1,69,0);

INSERT INTO `order_items` VALUES (5249,3700,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5250,3701,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5251,3702,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5252,3703,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5253,3704,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5254,3705,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5255,3706,20,1,39,0);

INSERT INTO `order_items` VALUES (5256,3707,4,1,59,0.05);

INSERT INTO `order_items` VALUES (5257,3708,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5258,3708,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5259,3709,11,1,39,0);

INSERT INTO `order_items` VALUES (5260,3710,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5261,3711,4,1,59,0);

INSERT INTO `order_items` VALUES (5262,3711,16,3,24.9,0);

INSERT INTO `order_items` VALUES (5263,3712,11,2,39,0);

INSERT INTO `order_items` VALUES (5264,3712,13,1,68,0);

INSERT INTO `order_items` VALUES (5265,3713,18,1,159,0);

INSERT INTO `order_items` VALUES (5266,3714,16,3,24.9,0.05);

INSERT INTO `order_items` VALUES (5267,3715,4,1,59,0);

INSERT INTO `order_items` VALUES (5268,3715,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5269,3716,13,2,68,0);

INSERT INTO `order_items` VALUES (5270,3716,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5271,3717,5,1,399,0);

INSERT INTO `order_items` VALUES (5272,3718,16,3,24.9,0);

INSERT INTO `order_items` VALUES (5273,3719,11,1,39,0);

INSERT INTO `order_items` VALUES (5274,3720,13,1,68,0);

INSERT INTO `order_items` VALUES (5275,3721,18,1,159,0);

INSERT INTO `order_items` VALUES (5276,3722,19,1,199,0);

INSERT INTO `order_items` VALUES (5277,3723,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5278,3724,20,1,39,0.05);

INSERT INTO `order_items` VALUES (5279,3725,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5280,3726,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5281,3727,7,1,89,0);

INSERT INTO `order_items` VALUES (5282,3727,8,1,159,0.05);

INSERT INTO `order_items` VALUES (5283,3727,12,1,79,0);

INSERT INTO `order_items` VALUES (5284,3728,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5285,3729,12,3,79,0.10);

INSERT INTO `order_items` VALUES (5286,3730,11,1,39,0);

INSERT INTO `order_items` VALUES (5287,3731,4,1,59,0.10);

INSERT INTO `order_items` VALUES (5288,3731,9,2,129,0.10);

INSERT INTO `order_items` VALUES (5289,3732,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5290,3732,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5291,3733,11,1,39,0);

INSERT INTO `order_items` VALUES (5292,3733,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5293,3734,7,1,89,0);

INSERT INTO `order_items` VALUES (5294,3734,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5295,3734,17,1,69,0);

INSERT INTO `order_items` VALUES (5296,3735,3,1,169,0);

INSERT INTO `order_items` VALUES (5297,3736,13,2,68,0);

INSERT INTO `order_items` VALUES (5298,3737,13,1,68,0);

INSERT INTO `order_items` VALUES (5299,3737,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5300,3737,17,1,69,0);

INSERT INTO `order_items` VALUES (5301,3738,4,1,59,0.05);

INSERT INTO `order_items` VALUES (5302,3738,12,1,79,0.05);

INSERT INTO `order_items` VALUES (5303,3739,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5304,3739,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5305,3740,2,1,899,0);

INSERT INTO `order_items` VALUES (5306,3741,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5307,3741,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5308,3741,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5309,3742,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5310,3742,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5311,3743,7,2,89,0.10);

INSERT INTO `order_items` VALUES (5312,3744,16,2,24.9,0);

INSERT INTO `order_items` VALUES (5313,3745,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5314,3746,18,1,159,0);

INSERT INTO `order_items` VALUES (5315,3747,7,1,89,0.10);

INSERT INTO `order_items` VALUES (5316,3748,11,1,39,0);

INSERT INTO `order_items` VALUES (5317,3749,4,1,59,0);

INSERT INTO `order_items` VALUES (5318,3749,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5319,3750,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5320,3750,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5321,3751,4,1,59,0);

INSERT INTO `order_items` VALUES (5322,3751,13,2,68,0.05);

INSERT INTO `order_items` VALUES (5323,3752,14,1,39.9,0.10);

INSERT INTO `order_items` VALUES (5324,3753,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5325,3754,12,1,79,0);

INSERT INTO `order_items` VALUES (5326,3754,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5327,3754,17,1,69,0.05);

INSERT INTO `order_items` VALUES (5328,3755,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5329,3755,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5330,3756,12,1,79,0.05);

INSERT INTO `order_items` VALUES (5331,3757,2,1,899,0);

INSERT INTO `order_items` VALUES (5332,3757,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5333,3758,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5334,3759,4,1,59,0.10);

INSERT INTO `order_items` VALUES (5335,3759,20,1,39,0);

INSERT INTO `order_items` VALUES (5336,3760,9,2,129,0);

INSERT INTO `order_items` VALUES (5337,3761,4,1,59,0.05);

INSERT INTO `order_items` VALUES (5338,3762,3,1,169,0);

INSERT INTO `order_items` VALUES (5339,3762,7,1,89,0);

INSERT INTO `order_items` VALUES (5340,3763,13,1,68,0.10);

INSERT INTO `order_items` VALUES (5341,3763,16,2,24.9,0.10);

INSERT INTO `order_items` VALUES (5342,3764,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5343,3764,15,1,32.9,0.10);

INSERT INTO `order_items` VALUES (5344,3765,13,2,68,0.05);

INSERT INTO `order_items` VALUES (5345,3766,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5346,3767,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5347,3767,20,1,39,0);

INSERT INTO `order_items` VALUES (5348,3768,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5349,3769,13,1,68,0);

INSERT INTO `order_items` VALUES (5350,3770,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5351,3771,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5352,3772,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5353,3773,12,1,79,0.10);

INSERT INTO `order_items` VALUES (5354,3773,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5355,3774,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5356,3774,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5357,3775,5,1,399,0.05);

INSERT INTO `order_items` VALUES (5358,3775,11,2,39,0.05);

INSERT INTO `order_items` VALUES (5359,3775,13,1,68,0);

INSERT INTO `order_items` VALUES (5360,3776,13,1,68,0);

INSERT INTO `order_items` VALUES (5361,3776,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (5362,3777,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5363,3778,10,1,699,0.05);

INSERT INTO `order_items` VALUES (5364,3778,16,2,24.9,0);

INSERT INTO `order_items` VALUES (5365,3779,11,1,39,0);

INSERT INTO `order_items` VALUES (5366,3780,18,1,159,0.05);

INSERT INTO `order_items` VALUES (5367,3781,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5368,3782,14,3,39.9,0);

INSERT INTO `order_items` VALUES (5369,3783,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5370,3784,4,1,59,0.10);

INSERT INTO `order_items` VALUES (5371,3785,14,1,39.9,0.05);

INSERT INTO `order_items` VALUES (5372,3786,13,3,68,0);

INSERT INTO `order_items` VALUES (5373,3787,20,1,39,0);

INSERT INTO `order_items` VALUES (5374,3788,12,1,79,0);

INSERT INTO `order_items` VALUES (5375,3789,3,1,169,0);

INSERT INTO `order_items` VALUES (5376,3789,13,2,68,0);

INSERT INTO `order_items` VALUES (5377,3790,16,2,24.9,0);

INSERT INTO `order_items` VALUES (5378,3791,1,1,4299,0.10);

INSERT INTO `order_items` VALUES (5379,3791,10,1,699,0);

INSERT INTO `order_items` VALUES (5380,3791,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5381,3792,9,1,129,0);

INSERT INTO `order_items` VALUES (5382,3793,20,1,39,0);

INSERT INTO `order_items` VALUES (5383,3794,7,1,89,0);

INSERT INTO `order_items` VALUES (5384,3794,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5385,3795,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5386,3795,18,1,159,0);

INSERT INTO `order_items` VALUES (5387,3796,11,1,39,0);

INSERT INTO `order_items` VALUES (5388,3797,11,1,39,0);

INSERT INTO `order_items` VALUES (5389,3798,13,1,68,0);

INSERT INTO `order_items` VALUES (5390,3799,4,2,59,0.10);

INSERT INTO `order_items` VALUES (5391,3799,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5392,3800,16,3,24.9,0);

INSERT INTO `order_items` VALUES (5393,3801,11,1,39,0);

INSERT INTO `order_items` VALUES (5394,3802,6,1,299,0);

INSERT INTO `order_items` VALUES (5395,3803,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5396,3804,9,1,129,0);

INSERT INTO `order_items` VALUES (5397,3804,11,1,39,0);

INSERT INTO `order_items` VALUES (5398,3804,19,3,199,0);

INSERT INTO `order_items` VALUES (5399,3805,12,1,79,0.10);

INSERT INTO `order_items` VALUES (5400,3805,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5401,3806,4,1,59,0);

INSERT INTO `order_items` VALUES (5402,3806,9,1,129,0);

INSERT INTO `order_items` VALUES (5403,3807,15,2,32.9,0);

INSERT INTO `order_items` VALUES (5404,3808,4,1,59,0);

INSERT INTO `order_items` VALUES (5405,3809,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5406,3810,11,1,39,0);

INSERT INTO `order_items` VALUES (5407,3810,13,1,68,0);

INSERT INTO `order_items` VALUES (5408,3810,17,1,69,0.05);

INSERT INTO `order_items` VALUES (5409,3811,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5410,3811,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (5411,3812,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5412,3813,12,1,79,0.05);

INSERT INTO `order_items` VALUES (5413,3814,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5414,3815,19,1,199,0);

INSERT INTO `order_items` VALUES (5415,3816,5,1,399,0);

INSERT INTO `order_items` VALUES (5416,3816,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5417,3817,12,1,79,0);

INSERT INTO `order_items` VALUES (5418,3818,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5419,3819,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5420,3820,11,1,39,0);

INSERT INTO `order_items` VALUES (5421,3820,12,1,79,0);

INSERT INTO `order_items` VALUES (5422,3820,13,1,68,0.05);

INSERT INTO `order_items` VALUES (5423,3821,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5424,3821,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5425,3822,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5426,3823,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5427,3823,17,1,69,0);

INSERT INTO `order_items` VALUES (5428,3824,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5429,3824,13,1,68,0.10);

INSERT INTO `order_items` VALUES (5430,3825,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5431,3826,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5432,3827,9,1,129,0);

INSERT INTO `order_items` VALUES (5433,3827,11,1,39,0);

INSERT INTO `order_items` VALUES (5434,3827,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5435,3828,6,1,299,0);

INSERT INTO `order_items` VALUES (5436,3828,11,2,39,0.10);

INSERT INTO `order_items` VALUES (5437,3829,16,1,24.9,0.05);

INSERT INTO `order_items` VALUES (5438,3830,4,1,59,0);

INSERT INTO `order_items` VALUES (5439,3830,8,1,159,0.10);

INSERT INTO `order_items` VALUES (5440,3830,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5441,3831,17,2,69,0.05);

INSERT INTO `order_items` VALUES (5442,3832,11,1,39,0.05);

INSERT INTO `order_items` VALUES (5443,3832,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5444,3833,9,1,129,0);

INSERT INTO `order_items` VALUES (5445,3834,6,1,299,0);

INSERT INTO `order_items` VALUES (5446,3834,14,1,39.9,0);

INSERT INTO `order_items` VALUES (5447,3835,15,2,32.9,0);

INSERT INTO `order_items` VALUES (5448,3836,3,3,169,0.10);

INSERT INTO `order_items` VALUES (5449,3837,20,1,39,0);

INSERT INTO `order_items` VALUES (5450,3838,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5451,3839,11,1,39,0);

INSERT INTO `order_items` VALUES (5452,3839,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5453,3840,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5454,3841,7,1,89,0);

INSERT INTO `order_items` VALUES (5455,3842,12,1,79,0);

INSERT INTO `order_items` VALUES (5456,3843,15,2,32.9,0.10);

INSERT INTO `order_items` VALUES (5457,3844,10,1,699,0);

INSERT INTO `order_items` VALUES (5458,3845,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5459,3845,18,1,159,0);

INSERT INTO `order_items` VALUES (5460,3846,11,1,39,0);

INSERT INTO `order_items` VALUES (5461,3847,15,2,32.9,0.05);

INSERT INTO `order_items` VALUES (5462,3848,4,1,59,0);

INSERT INTO `order_items` VALUES (5463,3848,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5464,3849,4,1,59,0);

INSERT INTO `order_items` VALUES (5465,3850,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5466,3851,13,1,68,0);

INSERT INTO `order_items` VALUES (5467,3852,12,1,79,0);

INSERT INTO `order_items` VALUES (5468,3853,7,1,89,0.05);

INSERT INTO `order_items` VALUES (5469,3854,15,1,32.9,0.05);

INSERT INTO `order_items` VALUES (5470,3855,6,1,299,0);

INSERT INTO `order_items` VALUES (5471,3855,13,1,68,0);

INSERT INTO `order_items` VALUES (5472,3856,20,2,39,0.05);

INSERT INTO `order_items` VALUES (5473,3857,2,1,899,0);

INSERT INTO `order_items` VALUES (5474,3857,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5475,3858,16,1,24.9,0);

INSERT INTO `order_items` VALUES (5476,3859,13,1,68,0);

INSERT INTO `order_items` VALUES (5477,3860,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5478,3861,15,1,32.9,0);

INSERT INTO `order_items` VALUES (5479,3861,16,1,24.9,0.10);

INSERT INTO `order_items` VALUES (5480,3862,13,1,68,0);

INSERT INTO `order_items` VALUES (5481,3862,17,1,69,0);

INSERT INTO `order_items` VALUES (5482,3863,20,1,39,0);

INSERT INTO `order_items` VALUES (5483,3864,7,1,89,0);

INSERT INTO `order_items` VALUES (5484,3864,20,1,39,0);

COMMIT;
