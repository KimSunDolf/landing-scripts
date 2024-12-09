#!/bin/bash

# 用户输入配置
read -p "请输入出口服务器监听端口 (例如 45018): " REALM_PORT
read -p "请输入目标服务器的 IP 地址: " DEST_IP
read -p "请输入目标服务器的端口号: " DEST_PORT

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

# 创建 systemd 服务文件
echo "创建 realm systemd 服务..."
cat <<EOF > /etc/systemd/system/realm.service
[Unit]
Description=Realm WebSocket Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/realm -l "ws://0.0.0.0:$REALM_PORT" -r "ws://$DEST_IP:$DEST_PORT"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 并启动服务
echo "启动 realm 服务..."
systemctl daemon-reload
systemctl enable realm
systemctl restart realm

# 检查服务状态
if systemctl is-active --quiet realm; then
    echo "Realm 服务已成功启动，并正在运行。"
    echo "监听端口: $REALM_PORT -> 目标服务器: $DEST_IP:$DEST_PORT"
else
    echo "Realm 服务启动失败，请检查日志！"
    journalctl -u realm
fi
