#!/bin/bash

# 获取所有网卡的IPv6地址
ipv6_addrs=$(ip -6 addr show scope global | grep "inet6" | awk '{print $2}' | cut -d'/' -f1)

# 检查是否存在IPv6地址
if [ -z "$ipv6_addrs" ]; then
    echo "当前 VPS 不支持 IPv6!"
else
    # 输出找到的IPv6地址
    echo "检测到的 IPv6 地址:"
    echo "$ipv6_addrs"
fi
