#拆分订单
CREATE TABLE dim_order (
    orderid VARCHAR(50) PRIMARY KEY COMMENT '订单ID',
    user VARCHAR(50) COMMENT '用户',
    category VARCHAR(50) COMMENT '商品分类',
    stock VARCHAR(50) COMMENT '商品SKU',
    order_time DATETIME COMMENT '订单时间',
    order_channel VARCHAR(50) COMMENT '订单渠道'
) COMMENT '订单维度表';

-- （可选）用户维度表（维度拆分，更规范）
CREATE TABLE dim_user (
    user_id VARCHAR(50) PRIMARY KEY COMMENT '用户ID',
    user_name VARCHAR(50) COMMENT '用户名'
) COMMENT '用户维度表';

-- （可选）商品维度表（维度拆分，更规范）
CREATE TABLE dim_goods (
    stock VARCHAR(50) PRIMARY KEY COMMENT '商品SKU',
    category VARCHAR(50) COMMENT '商品分类',
    price DECIMAL(10,2) COMMENT '商品单价'
) COMMENT '商品维度表';

-- 订单事实表（核心，存储可累加度量）
CREATE TABLE fact_order (
    fact_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '事实ID',
    orderid VARCHAR(50) COMMENT '订单ID（关联dim_order）',
    prices DECIMAL(10,2) COMMENT '商品单价',
    volume INT COMMENT '购买数量',
    order_amount DECIMAL(10,2) COMMENT '订单金额（prices*volume）',
    FOREIGN KEY (orderid) REFERENCES dim_order(orderid)
) COMMENT '订单事实表';

------
CREATE TABLE origin_order (
    orderid VARCHAR(50),
    user VARCHAR(50),
    category VARCHAR(50),
    prices DECIMAL(10,2),
    volume INT,
    stock VARCHAR(50),
    order_time DATETIME,
    order_channel VARCHAR(50)
) COMMENT '原始订单表';
-------
-- 插入订单维度表（去重）
INSERT INTO dim_order (orderid, user, category, stock, order_time, order_channel)
SELECT DISTINCT orderid, user, category, stock, order_time, order_channel
FROM origin_order;
----------
-- 插入订单事实表（计算衍生度量order_amount）
INSERT INTO fact_order (orderid, prices, volume, order_amount)
SELECT orderid, prices, volume, prices * volume
FROM origin_order;
------------
-- 按用户维度统计订单总金额
SELECT 
    d.user,
    SUM(f.order_amount) AS total_amount
FROM fact_order f
JOIN dim_order d ON f.orderid = d.orderid
GROUP BY d.user
ORDER BY total_amount DESC;

-- 按时间+渠道维度统计订单数量
SELECT 
    DATE(d.order_time) AS order_date,
    d.order_channel,
    COUNT(f.orderid) AS order_count,
    SUM(f.volume) AS total_volume
FROM fact_order f
JOIN dim_order d ON f.orderid = d.orderid
GROUP BY DATE(d.order_time), d.order_channel;
