#!/bin/bash
# 开放 3002 端口的脚本

echo "开放 3002 端口..."

# 检查是否使用 ufw 防火墙
if command -v ufw &> /dev/null; then
    echo "使用 ufw 开放端口..."
    sudo ufw allow 3002/tcp
    sudo ufw status
fi

# 检查是否使用 firewalld
if command -v firewall-cmd &> /dev/null; then
    echo "使用 firewalld 开放端口..."
    sudo firewall-cmd --permanent --add-port=3002/tcp
    sudo firewall-cmd --reload
    sudo firewall-cmd --list-ports
fi

# 检查是否使用 iptables
if command -v iptables &> /dev/null; then
    echo "使用 iptables 开放端口..."
    sudo iptables -A INPUT -p tcp --dport 3002 -j ACCEPT
    sudo iptables -L -n | grep 3002
fi

echo "端口配置完成！"
