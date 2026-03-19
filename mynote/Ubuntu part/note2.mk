Ubuntu 完整版运维笔记：从权限到定时任务

一、Ubuntu 文件权限 核心笔记（必背！面试/部署通用）

1. 权限三剑客：谁能操作文件？

Linux 所有文件/文件夹权限，都分为 3 类用户：

属主 (User/Owner)  → 文件的创建者、项目管理员
属组 (Group)       → 同组用户（多人协作开发）
其他 (Others)      → 服务器上的陌生人、匿名用户

2. 权限三操作：能做什么？

r = read  读权限   → 数字 4
w = write 写权限   → 数字 2
x = exec  执行权限 → 数字 1

3. 数字权限组合（最常用，直接背）

- 755 → 脚本/程序必备权限（属主可读写执行，其他人只读执行）

- 644 → 普通文件权限（配置/代码/日志，属主可写，其他人只读）

- 777 → 最大权限（严禁生产环境使用）

4. 权限修改核心命令

# 1. 修改文件/文件夹权限（最常用）
chmod 755 脚本名.sh    # 给脚本加 执行+运行权限
chmod 644 文件名.py    # 普通代码文件权限

# 2. 修改文件归属（属主:属组）
chown -R root:root 文件夹名  # 把文件所有者改为root（管理员）

5. 一句话记忆

755 = 我能全操作，别人只能看和运行
644 = 我能改，别人只能看


---
二、项目 一键启动脚本（完整版）

作用：一键停止旧服务 → 启动 Streamlit 看板 → 启动 FastAPI 接口 → 后台运行

创建文件：start.sh

#!/bin/bash
# 项目一键启动脚本 BI看板 + 数据接口
# 权限：chmod 755 start.sh
# 运行：./start.sh

# ===================== 配置区（修改为你的文件名） =====================
STREAMLIT_FILE="visual_streamlit.py"  # 看板脚本
FASTAPI_FILE="api_server.py"          # 接口脚本
LOG_PATH="./logs"                     # 日志文件夹

# 创建日志文件夹
mkdir -p $LOG_PATH

# ===================== 1. 停止旧进程（避免端口冲突） =====================
echo "正在关闭旧服务..."
pkill -f "streamlit"
pkill -f "uvicorn"
sleep 2

# ===================== 2. 启动 Streamlit 看板 =====================
echo "启动 Streamlit 看板 (端口 8501)..."
nohup python3.10 -m streamlit run $STREAMLIT_FILE \
--server.address 0.0.0.0 \
--server.port 8501 > $LOG_PATH/streamlit.log 2>&1 &

# ===================== 3. 启动 FastAPI 接口 =====================
echo "启动 FastAPI 接口 (端口 8000)..."
nohup uvicorn $FASTAPI_FILE:app \
--host 0.0.0.0 \
--port 8000 > $LOG_PATH/fastapi.log 2>&1 &

# ===================== 完成 =====================
echo "服务启动成功！"
echo "Streamlit: http://服务器IP:8501"
echo "FastAPI: http://服务器IP:8000"
ps -ef | grep -E "streamlit|uvicorn" | grep -v grep

授权 + 运行命令

# 1. 给脚本加执行权限（必须！）
chmod 755 start.sh

# 2. 一键运行
./start.sh


---
三、项目 定时启动/定时任务脚本（crontab）

作用：定时重启服务、定时更新数据库、定时清理日志（企业级必备）

1. 定时任务配置命令

# 编辑定时任务
crontab -e

# 查看定时任务
crontab -l

2. 常用定时规则

# 每天凌晨 2 点 重启项目服务
0 2 * * * /root/start.sh

# 每 5 分钟 刷新一次数据（运行你的数据生成脚本）
*/5 * * * * python3 /root/data_generate.py

# 每小时 清理一次日志
0 * * * * > /root/logs/streamlit.log

3. 定时任务格式（必记）

分 时 日 月 周  执行命令


---
四、项目 一键停止脚本（完整版）

创建文件：stop.sh

#!/bin/bash
# 一键停止所有项目服务
chmod 755 stop.sh

echo "正在停止服务..."
pkill -f "streamlit"
pkill -f "uvicorn"
echo "已停止所有服务"
ps -ef | grep -E "streamlit|uvicorn" | grep -v grep

授权运行：

chmod 755 stop.sh
./stop.sh


---
五、Ubuntu 项目权限 标准配置（直接复制运行）

# 1. 进入项目根目录
cd /root/你的项目文件夹

# 2. 给所有 sh 脚本加执行权限
chmod 755 *.sh

# 3. 给 py 代码文件设置安全权限
chmod 644 *.py

# 4. 设置日志文件夹可读写
chmod -R 755 logs/

# 5. 修改整个项目归属为 root 管理员
chown -R root:root /root/你的项目文件夹


---
六、GitHub 笔记精简总结（直接复制）

1. 权限规则

- 属主(User)：文件创建者/管理员

- 属组(Group)：协作开发组

- 其他(Others)：匿名用户

- 755：脚本执行权限（推荐）

- 644：代码文件安全权限（推荐）

- 命令：chmod 755 xxx.sh chown -R 属主:属组 文件夹

2. 一键启动

chmod 755 start.sh && ./start.sh

3. 定时任务

- 定时重启：0 2 * * * /root/start.sh

- 定时刷新数据：*/5 * * * * python3 data_generate.py

4. 服务管理

- 启动：./start.sh

- 停止：./stop.sh

- 查看日志：cat logs/streamlit.log
