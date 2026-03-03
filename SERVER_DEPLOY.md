# 服务器部署指南

## 方式 1：直接在服务器上执行（推荐）

请登录到你的服务器，然后执行以下命令：

```bash
# 1. 进入家目录
cd ~

# 2. 克隆或更新代码
if [ -d "miniyu" ]; then
  cd miniyu
  git fetch origin
  git checkout feature/optima-real-estate-ai
  git pull origin feature/optima-real-estate-ai
else
  git clone https://github.com/wojiushiwo7008/miniyu.git
  cd miniyu
  git checkout feature/optima-real-estate-ai
fi

# 3. 创建 .env 配置文件
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
PORT=3002
EOF

# 4. 开放 3002 端口（如果需要）
sudo ufw allow 3002/tcp 2>/dev/null || true

# 5. 停止旧容器并启动新容器
docker-compose down
docker-compose up -d --build

# 6. 查看容器状态
docker ps | grep feishu

# 7. 查看日志
docker logs --tail 30 feishu-deepseek-bot
```

## 方式 2：一键部署命令

复制以下整个命令块，粘贴到服务器终端执行：

```bash
cd ~ && \
([ -d "miniyu" ] && cd miniyu && git fetch origin && git checkout feature/optima-real-estate-ai && git pull origin feature/optima-real-estate-ai || git clone https://github.com/wojiushiwo7008/miniyu.git && cd miniyu && git checkout feature/optima-real-estate-ai) && \
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
PORT=3002
EOF
sudo ufw allow 3002/tcp 2>/dev/null || true && \
docker-compose down && \
docker-compose up -d --build && \
sleep 5 && \
echo "=== 容器状态 ===" && \
docker ps | grep feishu && \
echo "" && \
echo "=== 容器日志 ===" && \
docker logs --tail 30 feishu-deepseek-bot
```

## 测试部署

部署完成后，测试服务是否正常：

```bash
curl http://localhost:3002/health
```

或从外部测试：

```bash
curl http://www.woaixiaoyu.xyz:3002/health
```

## 常用管理命令

```bash
# 查看容器状态
docker ps

# 查看实时日志
docker logs -f feishu-deepseek-bot

# 重启容器
docker-compose restart

# 停止容器
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```
