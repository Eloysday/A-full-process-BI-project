# 环境配置
1. 换源必做：pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
2. 安装依赖：pip install pymysql pandas plotly streamlit streamlit-autorefresh fastapi uvicorn python-dotenv
3. 运行看板：streamlit run xxx.py
4. 运行接口：uvicorn xxx:app --reload

uvicorn：FastAPI 专用启动工具，负责运行数据接口服务
#--only-binary=:all: 参数会让 pip 优先下载预编译包，能避免绝大多数 Windows 下的编译报错，之后再安装需要的库（如 fastapi 等）
pip install fastapi uvicorn sqlalchemy pymysql --only-binary=:all:
