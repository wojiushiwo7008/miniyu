#!/bin/bash

# 飞书机器人服务器部署脚本

echo "=== 飞书机器人部署脚本 ==="
echo ""

# 1. 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
else
    echo "✓ Docker 已安装"
fi

# 2. 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose 未安装，正在安装..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "✓ Docker Compose 已安装"
fi

# 3. 停止旧容器（如果存在）
echo ""
echo "停止旧容器..."
docker-compose down 2>/dev/null || true

# 4. 构建并启动容器
echo ""
echo "构建并启动容器..."
docker-compose up -d --build

# 5. 检查容器状态
echo ""
echo "检查容器状态..."
docker ps | grep feishu

# 6. 显示日志
echo ""
echo "最近的日志："
docker logs --tail 20 feishu-deepseek-bot

echo ""
echo "=== 部署完成 ==="
echo ""
echo "查看实时日志: docker logs -f feishu-deepseek-bot"
echo "重启容器: docker-compose restart"
echo "停止容器: docker-compose down"
