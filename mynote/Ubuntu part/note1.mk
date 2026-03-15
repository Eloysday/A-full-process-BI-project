#!/bin/bash
# 项目：实时BI数据看板 + FastAPI数据接口
# 环境：Streamlit + MariaDB(MySQL) + Python3.10 + Nginx
# 适配：你的订单数据可视化项目

# 1. 系统基础更新
apt update -y && apt upgrade -y
apt install -y wget curl software-properties-common apt-transport-https

# 2. 安装Nginx（反向代理/网页服务）
apt install -y nginx
systemctl enable --now nginx

# 3. 安装MariaDB（MySQL兼容数据库）
apt install -y mariadb-server
systemctl enable --now mariadb

# 数据库安全配置（手动执行：设置root密码 + 一路回车）
# mysql_secure_installation

# 4. 数据库远程访问配置（服务器必备）
cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.bak
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
# 【必须修改】替换为你的数据库密码
mysql -uroot -p -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '你的数据库密码'; FLUSH PRIVILEGES;"
systemctl restart mariadb

# 5. 防火墙放行端口（项目核心端口）
ufw enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 3306/tcp
ufw allow 8501/tcp  # Streamlit看板
ufw allow 8000/tcp  # FastAPI接口
ufw reload

# 6. 安装Python3.10环境
add-apt-repository -y ppa:deadsnakes/ppa
apt update -y
apt install -y python3.10 python3.10-pip

# 清华源加速 + 安装所有必需库
pip3.10 install pymysql pandas plotly streamlit streamlit-autorefresh fastapi uvicorn -i https://pypi.tuna.tsinghua.edu.cn/simple

# 1. 启动Streamlit可视化看板（端口8501）
nohup python3.10 -m streamlit run /root/你的看板文件.py --server.address 0.0.0.0 --server.port 8501 > streamlit.log 2>&1 &
# 2. 启动FastAPI数据接口（端口8000）
nohup uvicorn 你的接口文件:app --host 0.0.0.0 --port 8000 > fastapi.log 2>&1 &
# 启动参数说明
--server.address 0.0.0.0  # 允许公网访问（必填）
--server.port 8501       # 指定看板端口（规范写法）
nohup                    # 后台运行，关闭终端不停止
streamlit.log            # 运行日志，方便排查问题


# 查看后台运行进程
ps aux | grep python
ps aux | grep streamlit
ps aux | grep uvicorn

# 关闭进程（替换PID为实际进程号）
kill -9 PID

# 查看日志
cat streamlit.log
cat fastapi.log

# 重启数据库
systemctl restart mariadb
