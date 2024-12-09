#!/bin/bash

# 读取用户输入
read -p "请输入监听端口 (默认45014): " LISTEN_PORT
LISTEN_PORT=${LISTEN_PORT:-45014}

read -p "请输入转发IP地址 (默认127.0.0.1): " FORWARD_IP
FORWARD_IP=${FORWARD_IP:-127.0.0.1}

read -p "请输入转发端口 (默认3380): " FORWARD_PORT
FORWARD_PORT=${FORWARD_PORT:-3380}

# 检查并安装 realm
if ! command -v realm &> /dev/null; then
    echo "正在安装 realm..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    # 下载并安装
    if wget https://github.com/zhboner/realm/releases/download/v2.4.1/realm-x86_64-unknown-linux-gnu.tar.gz; then
        # 确保下载成功后再继续
        if tar -xzf realm-x86_64-unknown-linux-gnu.tar.gz; then
            # 确保解压成功后再继续
            if mv realm-x86_64-unknown-linux-gnu/realm /usr/local/bin/; then
                chmod +x /usr/local/bin/realm
                echo "realm 安装成功"
            else
                echo "移动 realm 失败"
                exit 1
            fi
        else
            echo "解压失败"
            exit 1
        fi
    else
        echo "下载失败"
        exit 1
    fi
    
    # 清理临时文件
    cd -
    rm -rf $TEMP_DIR
fi

# 创建服务文件
cat > /etc/systemd/system/realm.service << EOF
[Unit]
Description=Realm WebSocket Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/realm -l "ws://0.0.0.0:${LISTEN_PORT}" -r "ws://${FORWARD_IP}:${FORWARD_PORT}"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable realm
systemctl restart realm

# 检查服务状态
if systemctl is-active --quiet realm; then
    echo "Realm 服务已成功启动"
    echo "配置信息："
    echo "监听端口: ${LISTEN_PORT}"
    echo "转发到: ${FORWARD_IP}:${FORWARD_PORT}"
else
    echo "服务启动失败，查看日志："
    journalctl -u realm --no-pager -n 20
fi
