#!/bin/bash

echo "开始部署..."

# 拉取最新代码
git fetch origin
git checkout feature/optima-real-estate-ai
git pull origin feature/optima-real-estate-ai

# 创建 .env 文件
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
PORT=3002
EOF

# 开放 3002 端口
if command -v ufw &> /dev/null; then
  sudo ufw allow 3002/tcp 2>/dev/null || true
fi

# 重启容器
docker-compose down
docker-compose up -d --build

echo "部署完成！"
echo "容器状态："
docker ps | grep feishu
