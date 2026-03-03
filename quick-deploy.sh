#!/bin/bash
# 飞书机器人一键部署脚本
# 使用方法：chmod +x quick-deploy.sh && ./quick-deploy.sh

echo "=========================================="
echo "  飞书机器人一键部署脚本"
echo "=========================================="
echo ""

# 1. 克隆或更新代码
echo "📦 步骤 1/5: 获取最新代码..."
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

# 2. 配置环境变量
echo ""
echo "⚙️  步骤 2/5: 配置环境变量..."
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
PORT=3001
EOF
echo "✓ 环境变量配置完成"

# 3. 停止旧容器
echo ""
echo "🛑 步骤 3/5: 停止旧容器..."
docker-compose down 2>/dev/null || echo "没有运行中的容器"

# 4. 构建并启动新容器
echo ""
echo "🚀 步骤 4/5: 构建并启动容器..."
docker-compose up -d --build

# 5. 等待容器启动
echo ""
echo "⏳ 步骤 5/5: 等待容器启动..."
sleep 5

# 显示结果
echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "📊 容器状态："
docker ps | grep -E "CONTAINER|feishu"
echo ""
echo "📝 最近日志："
docker logs --tail 20 feishu-deepseek-bot
echo ""
echo "=========================================="
echo "✅ Webhook URL: http://www.woaixiaoyu.xyz:3001/webhook"
echo "=========================================="
echo ""
echo "常用命令："
echo "  查看日志: docker logs -f feishu-deepseek-bot"
echo "  重启容器: docker-compose restart"
echo "  停止容器: docker-compose down"
echo ""
