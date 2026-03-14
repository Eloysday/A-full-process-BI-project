#--only-binary=:all: 参数会让 pip 优先下载预编译包，能避免绝大多数 Windows 下的编译报错，是快速解决这类问题的通用技巧。
# 强制安装预编译版 greenlet
pip install --only-binary=:all: greenlet
# 之后再安装你需要的库（如 fastapi 等）
pip install fastapi uvicorn sqlalchemy pymysql --only-binary=:all:
