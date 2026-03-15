import pymysql
import pandas as pd 
import plotly.express as px
import streamlit as st
from streamlit_autorefresh import st_autorefresh as sta
import time

sta(interval=15000, limit=0, key="silent_refresh",debounce=2)
def getdata():
    zhanghao = {
        "host": " ", 
        "user": " ", 
        "password": " ", 
        "database":  ",  
        "charset": "utf8mb4"}

    conn = pymysql.connect(**zhanghao)
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    cursor.execute("SELECT * FROM orderinfo;")
    feedback = cursor.fetchall()
    conn.close()
    return feedback

df = pd.DataFrame(getdata()).dropna()
print(df)

st.title('sale dashboard',width='content')
st.set_page_config(layout="wide")
# 第一行图表
col1, col2, col3 = st.columns([0.3, 0.3, 0.3]) 
df["sales"] = df["prices"] * df["volume"]  
with col1:
    st.subheader('Cate-vol')
    chart = px.bar(df, x='category', y="volume")
    st.plotly_chart(chart, use_container_width=True)

with col2:
    st.subheader('Cate-sale')
    sales_summary = df.groupby('category')['sales'].sum().reset_index()
    chart = px.bar(sales_summary, x='category', y="sales")
    st.plotly_chart(chart, use_container_width=True)

with col3:
    st.subheader('Stock-box')
    chart = px.box(df, x='category', y="stock")
    st.plotly_chart(chart, use_container_width=True)

# 第二行图表
col11, col21, col31 = st.columns([0.3, 0.3, 0.3]) 
with col11:
    st.subheader('STock-ratio')
    stock_pie = df.groupby('category')['stock'].sum().reset_index()
    chart = px.pie(stock_pie, names='category', values='stock')
    st.plotly_chart(chart, use_container_width=True)

with col21:
    st.subheader('Sale-mean')
    vol_mean = df.groupby('category')['volume'].mean().reset_index()
    chart = px.line(vol_mean, x='category', y="volume")
    st.plotly_chart(chart, use_container_width=True)

with col31:
    st.subheader('Violin')
    chart = px.violin(df, x='category', y="volume")
    st.plotly_chart(chart, use_container_width=True)
