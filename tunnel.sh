#!/bin/bash

read -p "请输入监听端口号:" A_PORT
read -p "请输入落地地址:" IP
read -p "请输入服务端口号:" B_PORT

if ! command -v socat &> /dev/null; then
  apt update
  apt install -y socat
fi

cat <<EOF > /etc/systemd/system/socat-${A_PORT}.service  
[Unit]
Description=Socat Service

[Service]
ExecStart=/usr/bin/socat TCP6-LISTEN:${A_PORT},fork TCP:${IP}:${B_PORT}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable socat-${A_PORT}.service
systemctl start socat-${A_PORT}.service
systemctl status socat-${A_PORT}.service