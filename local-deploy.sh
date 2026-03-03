#!/bin/bash

# 本地部署脚本 - 通过 SSH 部署到远程服务器

SERVER_HOST="www.woaixiaoyu.xyz"
SERVER_PORT="5666"
SERVER_USER="bxn818204"
SERVER_PASSWORD="Aaa@13278505045"

echo "=== 开始部署到服务器 ==="

# 使用 sshpass 连接服务器并执行部署
sshpass -p "$SERVER_PASSWORD" ssh -p $SERVER_PORT -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_HOST << 'ENDSSH'
cd ~

# 克隆或更新代码
if [ -d "miniyu" ]; then
  echo "更新代码..."
  cd miniyu
  git fetch origin
  git checkout feature/optima-real-estate-ai
  git pull origin feature/optima-real-estate-ai
else
  echo "克隆代码..."
  git clone https://github.com/wojiushiwo7008/miniyu.git
  cd miniyu
  git checkout feature/optima-real-estate-ai
fi

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
docker-compose down 2>/dev/null || true
docker-compose up -d --build

echo ""
echo "等待容器启动..."
sleep 5

echo ""
echo "=== 容器状态 ==="
docker ps | grep feishu || docker ps

echo ""
echo "=== 容器日志 ==="
docker logs --tail 30 feishu-deepseek-bot || echo "容器未找到"

ENDSSH

echo ""
echo "=== 部署完成 ==="
echo ""
echo "测试服务: curl http://www.woaixiaoyu.xyz:3002/health"
