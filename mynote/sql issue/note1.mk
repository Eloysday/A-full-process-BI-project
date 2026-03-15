一、基础连接/库/表 常用命令
1. 数据库连接命令
# 本地连接 mysql -u root -p
# 远程连接 (云服务器) mysql -h 101.132.152.206 -u testdata -p testdata
2. 库操作命令
-- 查看所有库 SHOW DATABASES;
-- 创建项目库 (推荐) CREATE DATABASE testdata CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 使用库 USE testdata;
-- 删除库 (谨慎) DROP DATABASE testdata;
3. 表操作命令
-- 查看所有表SHOW TABLES;
-- 查看表结构DESC orderinfo;
-- 清空表数据 (保留结构)TRUNCATE TABLE orderinfo;
-- 删除表 (谨慎)DROP TABLE orderinfo;
-- 备份表结构+数据CREATE TABLE orderinfo_bak AS SELECT * FROM orderinfo;
二、项目核心：事实表拆分（数仓星型模型 | BI必备）
1. 原表（大宽表事实表）
业务主表：orderinfo（订单事实表）
-- 原表结构 (你的项目表)
CREATE TABLE orderinfo (
    orderid VARCHAR(32) PRIMARY KEY,    -- 订单ID
    user VARCHAR(20) NOT NULL,          -- 用户ID
    category VARCHAR(20) NOT NULL,      -- 品类
    prices INT NOT NULL,                -- 单价
    volume INT NOT NULL,                -- 销量
    stock INT NOT NULL,                 -- 库存
    order_time DATETIME NOT NULL,       -- 下单时间
    order_channel VARCHAR(20) NOT NULL  -- 渠道
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
2. 标准拆分：维度表 + 事实表（企业BI规范）
拆分目的：减少冗余、提升查询速度、适配可视化看板
-- 1. 用户维度表
CREATE TABLE dim_user (
    user_id VARCHAR(20) PRIMARY KEY,
    user_name VARCHAR(50)
) ENGINE=InnoDB;
-- 2. 品类维度表
CREATE TABLE dim_category (
    cate_name VARCHAR(20) PRIMARY KEY,
    price INT NOT NULL
) ENGINE=InnoDB;
-- 3. 渠道维度表
CREATE TABLE dim_channel (
    channel_name VARCHAR(20) PRIMARY KEY
) ENGINE=InnoDB;
-- 4. 精简订单事实表 (拆分后)
CREATE TABLE fact_order (
    orderid VARCHAR(32) PRIMARY KEY,
    user_id VARCHAR(20),
    cate_name VARCHAR(20),
    volume INT,
    stock INT,
    order_time DATETIME,
    channel_name VARCHAR(20),
    -- 外键关联
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (cate_name) REFERENCES dim_category(cate_name),
    FOREIGN KEY (channel_name) REFERENCES dim_channel(channel_name)
) ENGINE=InnoDB;
三、数据增删改查（基础命令）
-- 插入数据
INSERT INTO orderinfo (orderid,user,category,prices,volume) VALUES ('123abc','u1','Product A',50,1000);
-- 更新数据
UPDATE orderinfo SET volume=1200 WHERE orderid='123abc';
-- 删除数据
DELETE FROM orderinfo WHERE order_time < '2025-01-01';
-- 基础查询
SELECT * FROM orderinfo LIMIT 10;
四、BI看板必备：单表聚合查询
适配你的 Streamlit 可视化图表
-- 1. 按品类统计销量/销售额
SELECT 
    category,
    SUM(volume) AS total_volume,
    SUM(prices*volume) AS total_sales,
    AVG(volume) AS avg_volume
FROM orderinfo 
GROUP BY category;
-- 2. 按渠道统计
SELECT order_channel, COUNT(*) AS order_count FROM orderinfo GROUP BY order_channel;
-- 3. 按时间统计（日/月销量）
SELECT DATE(order_time) AS order_date, SUM(volume) AS daily_volume 
FROM orderinfo 
GROUP BY order_date 
ORDER BY order_date;
-- 4. 库存统计
SELECT category, SUM(stock) AS total_stock FROM orderinfo GROUP BY category;
五、核心：多表连表查询（JOIN）
1. 内连接 (INNER JOIN)：取两张表交集
-- 订单表 + 品类表 连表查询
SELECT fo.orderid, fo.volume, dc.price 
FROM fact_order fo
INNER JOIN dim_category dc ON fo.cate_name = dc.cate_name;
2. 左连接 (LEFT JOIN)：保留左表全部数据（BI最常用）
-- 所有订单 + 对应用户信息（无用户也保留订单）
SELECT fo.*, du.user_name
FROM fact_order fo
LEFT JOIN dim_user du ON fo.user_id = du.user_id;
3. 多表联合查询（3表+）
-- 完整业务数据查询
SELECT 
    fo.orderid,
    du.user_id,
    dc.cate_name,
    fo.volume,
    dc.price*fo.volume AS sales,
    fo.order_time,
    dch.channel_name
FROM fact_order fo
LEFT JOIN dim_user du ON fo.user_id = du.user_id
LEFT JOIN dim_category dc ON fo.cate_name = dc.cate_name
LEFT JOIN dim_channel dch ON fo.channel_name = dch.channel_name;
六、高级SQL（企业级/面试加分）
1. 子查询
-- 查询销量高于平均值的订单
SELECT * FROM orderinfo 
WHERE volume > (SELECT AVG(volume) FROM orderinfo);
2. 视图（简化BI查询）
-- 创建销售统计视图 (Streamlit直接查询视图)
CREATE VIEW v_sales_stat AS
SELECT 
    category,
    SUM(volume) total_volume,
    SUM(prices*volume) total_sales
FROM orderinfo GROUP BY category;
-- 查询视图
SELECT * FROM v_sales_stat;
3. 索引优化（加速看板查询）
-- 给高频查询字段建索引
CREATE INDEX idx_order_time ON orderinfo(order_time);
CREATE INDEX idx_category ON orderinfo(category);
4. 排序/分页
-- 按销售额降序 + 分页
SELECT * FROM orderinfo 
ORDER BY prices*volume DESC 
LIMIT 0,10;

七、项目RFM模型SQL（用户分层/数据分析）
-- RFM用户统计
SELECT 
    user,
    MAX(order_time) AS last_buy_time,  -- R最近消费
    COUNT(orderid) AS buy_count,       -- F消费频次
    SUM(prices*volume) AS total_sales -- M消费金额
FROM orderinfo
GROUP BY user;
八、MariaDB 运维必备命令
-- 查看数据库运行状态
SHOW STATUS;
-- 查看慢查询
SHOW VARIABLES LIKE '%slow_query%';
-- 重启服务
systemctl restart mariadb;
-- 查看连接数
SHOW PROCESSLIST;
-- 授权用户 (你的项目用户)
GRANT ALL ON testdata.* TO 'testdata'@'%' IDENTIFIED BY 'Ccc123456.';
FLUSH PRIVILEGES;

---
✅ 总结
1. MariaDB = MySQL：语法完全通用，无需适配修改
2. 事实表拆分：大宽表 → 维度表 + 事实表（星型模型）
3. BI核心：GROUP BY 聚合 + LEFT JOIN 连表查询
4. 性能优化：给时间/品类字段建索引
5. 视图：简化看板查询逻辑，提升代码可读性
6. 标准命令：TRUNCATE 清空表、DESC 查结构、LIMIT 分页
