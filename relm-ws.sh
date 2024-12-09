#!/bin/bash

# 读取用户输入
read -p "请输入监听端口 (默认3380): " LISTEN_PORT
LISTEN_PORT=${LISTEN_PORT:-3380}

read -p "请输入本地转发端口 (默认3380): " LOCAL_PORT
LOCAL_PORT=${LOCAL_PORT:-3380}

# 检查并安装 realm
if ! command -v realm &> /dev/null; then
    echo "正在安装 realm..."
    wget https://github.com/zhboner/realm/releases/download/v2.4.1/realm-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf realm.tar.gz
    mv realm /usr/local/bin/
    rm realm.tar.gz
    chmod +x /usr/local/bin/realm
fi

# 创建服务文件
cat > /etc/systemd/system/realm.service << EOF
[Unit]
Description=Realm WebSocket Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/realm -l "ws://0.0.0.0:${LISTEN_PORT}" -r "ws://127.0.0.1:${LOCAL_PORT}"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable realm
systemctl restart realm

# 检查状态
echo "服务已启动，配置如下："
echo "监听端口: ${LISTEN_PORT}"
echo "转发到: 127.0.0.1:${LOCAL_PORT}"
