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


---
Matplotlib + Seaborn 静态可视化（全场景）
核心定位
离线数据分析/报告专用，静态、高清、适合导出文档，Plotly 的互补方案
1. 基础配置（必写：解决中文乱码）
import matplotlib.pyplot as plt
import seaborn as sns
plt.rcParams["font.sans-serif"] = ["SimHei"]  # 中文
plt.rcParams["axes.unicode_minus"] = False    # 负号
plt.figure(figsize=(12,6))  # 画布大小
2. 全类型图表（业务全覆盖）
# 1. 柱状图（品类销量）
sns.barplot(data=df, x="category", y="volume")
# 2. 箱线图（库存分布/异常值检测）
sns.boxplot(data=df, x="category", y="stock")
# 3. 折线图（时间趋势）
sns.lineplot(data=df, x="date", y="sales")
# 4. 饼图（占比）
df.groupby("category")["sales"].sum().plot(kind="pie")
# 5. 热力图（指标相关性）
corr = df[["volume","sales","stock"]].corr()
sns.heatmap(corr, annot=True)
# 6. 小提琴图（数据分布）
sns.violinplot(data=df, x="category", y="volume")
3. 图表美化与存储
plt.title("销售数据统计")
plt.xlabel("品类")
plt.ylabel("销量")
plt.xticks(rotation=45)
plt.tight_layout()  # 自适应布局
plt.savefig("chart.png", dpi=300)  # 高清保存
plt.show()
---
四、Streamlit + Plotly 交互式Web看板（项目核心）
核心定位
企业级实时BI看板，无需前端知识，10分钟搭建Web可视化平台，支持交互/自动刷新/远程访问
1. 基础配置（必写顺序）
import streamlit as st
import plotly.express as px
from streamlit_autorefresh import st_autorefresh
# 1. 页面配置（必须第一行）
st.set_page_config(layout="wide", page_title="实时销售看板")
# 2. 自动刷新（实时数据必备 15秒/次）
st_autorefresh(interval=15000, limit=0)
2. 页面布局（专业看板）
# 标题
st.title("📊 实时销售数据BI看板")
# 多列布局（一行3个图表）
col1, col2, col3 = st.columns(3)
# 第二行布局
col4, col5, col6 = st.columns(3)
3. Plotly 交互式图表（全场景）
# 1. 柱状图（销量）
with col1:
    st.subheader("品类销量")
    fig = px.bar(df, x="category", y="volume")
    st.plotly_chart(fig, use_container_width=True)
# 2. 销售额统计
with col2:
    fig = px.bar(df.groupby("category")["sales"].sum().reset_index(), x="category", y="sales")
    st.plotly_chart(fig)
# 3. 箱线图
with col3:
    fig = px.box(df, x="category", y="stock")
    st.plotly_chart(fig)
# 4. 饼图
with col4:
    fig = px.pie(df, names="order_channel", values="sales")
    st.plotly_chart(fig)
# 5. 时间趋势图
with col5:
    fig = px.line(df, x="date", y="sales")
    st.plotly_chart(fig)
# 6. 小提琴图
with col6:
    fig = px.violin(df, x="category", y="volume")
    st.plotly_chart(fig)
4. 数据展示组件
st.dataframe(df)  # 展示表格
st.metric("总销售额", df["sales"].sum())  # 数字卡片
st.table(df.head()) # 静态表格
5. 服务器部署命令（必备）
# 后台运行，公网可访问
nohup streamlit run app.py --server.address 0.0.0.0 --server.port 8501 > log.log 2>&1 &

###快速模板
# 1. 连接数据库
conn = pymysql.connect(**DB_CONFIG)
# 2. 读取数据
df = pd.read_sql("SELECT * FROM orderinfo", conn)
# 3. 清洗数据
df = df.dropna().drop_duplicates()
# 4. 计算业务字段
df["sales"] = df["prices"] * df["volume"]
# 5. 统计聚合
result = df.groupby("category")["sales"].sum().reset_index()
# 6. 可视化/Web展示
st.plotly_chart(px.bar(result, x="category", y="sales"))
