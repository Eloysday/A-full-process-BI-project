from fastapi import FastAPI
from sqlalchemy import create_engine
import pandas as pd

app = FastAPI(title="BI fastapi")


DB_URL = "mysql+pymysql://username:password@ip:port/databasename-name"
engine = create_engine(DB_URL)
@app.get("/")
def home():
    return {"message": "service satrt success"}
@app.get("/data")
def get_data():
    sql = "SELECT * FROM refresh_data LIMIT 10"
    df = pd.read_sql(sql, engine)
    # 返回JSON格式，前端/BI报表直接可用
    return df.to_dict(orient="records")
  
#使用pymysql链接数据库
@app.get("/pydata")
def get_data():
    zhanghao = {
        "host": " ", 
        "user": " ", 
        "password": " ", 
        "database": " ",  
        "charset": "utf8mb4"}
    conn = pymysql.connect(**zhanghao)
    sql = "SELECT * FROM refresh_data LIMIT 10"
    df = pd.read_sql(sql, conn)  # pandas 直接支持 pymysql
    conn.close()
    # ======================================
    return df.to_dict(orient="records")
