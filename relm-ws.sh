#!/bin/bash

# 用户输入配置
read -p "请输入出口服务器监听端口 (例如 45018): " REALM_PORT
read -p "请输入目标服务器的 IP 地址: " DEST_IP
read -p "请输入目标服务器的端口号: " DEST_PORT
read -p "请输入加密通信密码: " PASSWORD
read -p "请选择协议 (ws 或 wss，默认为 ws): " PROTOCOL

# 默认协议为 ws
PROTOCOL=${PROTOCOL:-ws}

# 检查是否安装 realm
if ! command -v realm &> /dev/null; then
    echo "Realm 未安装，正在安装..."
    wget https://github.com/zhboner/realm/releases/download/v2.4.1/realm-x86_64-unknown-linux-gnu.tar.gz -O realm.tar.gz
    tar -xzf realm.tar.gz
    mv realm /usr/local/bin/
    chmod +x /usr/local/bin/realm
    echo "Realm 安装完成"
else
    echo "Realm 已安装"
fi

# 检查是否有正在运行的 realm 实例
if pgrep -f "realm" > /dev/null; then
    echo "检测到正在运行的 realm 实例，重启服务..."
    pkill -f "realm"
fi

# 启动 realm 服务
echo "启动 Realm 服务..."
nohup realm -l "$PROTOCOL://0.0.0.0:$REALM_PORT" -r "$PROTOCOL://$DEST_IP:$DEST_PORT" -p "$PASSWORD" > /var/log/realm.log 2>&1 &

# 验证服务是否启动
if pgrep -f "realm" > /dev/null; then
    echo "Realm 服务已成功启动，监听端口 $REALM_PORT -> $DEST_IP:$DEST_PORT"
    echo "日志文件路径: /var/log/realm.log"
else
    echo "Realm 服务启动失败，请检查配置！"
fi
