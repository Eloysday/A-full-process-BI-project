Streamlit + Plotly 交互式Web看板（项目核心）
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
