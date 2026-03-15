PyMySQL 数据库交互核心（全场景用法）
1. 标准连接配置（安全/通用）
# 配置
DB_CONFIG = {
    "host": "服务器IP",
    "user": "用户名",
    "password": "密码",
    "database": "库名",
    "charset": "utf8mb4"
}

# 创建连接
conn = pymysql.connect(**DB_CONFIG)
cursor = conn.cursor(pymysql.cursors.DictCursor)  # 字典格式返回
2. 数据查询（全场景）
# 1. 全表查询（看板主用法）
cursor.execute("SELECT * FROM orderinfo")
data = cursor.fetchall()  # 全部数据
# 2. 分页查询（大数据量）
cursor.execute("SELECT * FROM orderinfo LIMIT 10 OFFSET 0")
# 3. 条件查询
cursor.execute("SELECT * FROM orderinfo WHERE category=%s", ("Product A",))
# 4. 聚合查询
cursor.execute("SELECT category,SUM(sales) FROM orderinfo GROUP BY category")
3. 数据写入（项目生成数据必备）

# 1. 单条写入
sql = "INSERT INTO orderinfo(orderid,user) VALUES (%s,%s)"
cursor.execute(sql, ("O1001","U001"))
# 2. 批量写入（10万条高性能）
sql = "INSERT INTO orderinfo VALUES (%s,%s,%s,%s,%s,%s,%s,%s)"
cursor.executemany(sql, data_list) 
conn.commit()  # 必须提交
4. 数据更新与删除
# 更新
cursor.execute("UPDATE orderinfo SET volume=1000 WHERE orderid=%s", ("O1001",))
# 删除
cursor.execute("DELETE FROM orderinfo WHERE order_time<%s", ("2025-01-01",))
# 清空表（保留结构）
cursor.execute("TRUNCATE TABLE orderinfo")
conn.commit()
5. 事务与异常处理
try:
    cursor.execute(sql)
    conn.commit()
except Exception as e:
    conn.rollback()  # 失败回滚
    print("错误：",e)
finally:
    cursor.close()
    conn.close()  # 必关连接
6. 配合 Pandas（最优用法）
df = pd.read_sql("SELECT * FROM orderinfo", conn)
result, x="category", y="sales"))
