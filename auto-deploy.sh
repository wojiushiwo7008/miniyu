#!/bin/bash

# 飞书机器人自动部署脚本
# 服务器: www.woaixiaoyu.xyz:5666
# 用户: bxn818204

echo "=== 飞书机器人自动部署 ==="
echo ""

# 1. 克隆项目
echo "1. 克隆项目..."
cd ~
if [ -d "miniyu" ]; then
    echo "项目已存在，更新代码..."
    cd miniyu
    git fetch origin
    git checkout feature/optima-real-estate-ai
    git pull origin feature/optima-real-estate-ai
else
    echo "克隆新项目..."
    git clone https://github.com/wojiushiwo7008/miniyu.git
    cd miniyu
    git checkout feature/optima-real-estate-ai
fi

# 2. 创建 .env 文件
echo ""
echo "2. 配置环境变量..."
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
PORT=3000
EOF

echo "✓ 环境变量配置完成"

# 3. 停止旧容器
echo ""
echo "3. 停止旧容器..."
docker-compose down 2>/dev/null || true

# 4. 构建并启动容器
echo ""
echo "4. 构建并启动容器..."
docker-compose up -d --build

# 5. 等待容器启动
echo ""
echo "5. 等待容器启动..."
sleep 5

# 6. 检查容器状态
echo ""
echo "6. 检查容器状态..."
docker ps | grep feishu

# 7. 显示日志
echo ""
echo "7. 容器日志："
docker logs --tail 30 feishu-deepseek-bot

echo ""
echo "=== 部署完成 ==="
echo ""
echo "容器已启动，监听端口: 3000"
echo ""
echo "下一步："
echo "1. 配置 Cloudflare Tunnel 或 Nginx"
echo "2. 更新飞书 Webhook URL"
echo ""
echo "查看实时日志: docker logs -f feishu-deepseek-bot"
