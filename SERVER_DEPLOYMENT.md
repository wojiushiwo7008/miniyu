# 飞书机器人服务器部署指南

## 部署步骤

### 方法一：手动部署（推荐）

1. **将项目文件上传到服务器**
   ```bash
   # 在本地执行（需要先压缩项目）
   cd f:\claudecode
   tar -czf feishurobot.tar.gz feishurobot/
   scp -P 5666 feishurobot.tar.gz bxn818204@www.woaixiaoyu.xyz:~/
   ```

2. **SSH 登录到服务器**
   ```bash
   ssh -p 5666 bxn818204@www.woaixiaoyu.xyz
   # 密码: Aaa@13278505045
   ```

3. **解压并部署**
   ```bash
   # 解压项目
   tar -xzf feishurobot.tar.gz
   cd feishurobot

   # 给部署脚本执行权限
   chmod +x deploy.sh

   # 运行部署脚本
   ./deploy.sh
   ```

### 方法二：使用 Git 部署

1. **SSH 登录到服务器**
   ```bash
   ssh -p 5666 bxn818204@www.woaixiaoyu.xyz
   ```

2. **克隆项目**
   ```bash
   # 安装 git（如果没有）
   sudo apt-get update && sudo apt-get install -y git

   # 克隆项目
   git clone https://github.com/wojiushiwo7008/feishurobot.git
   cd feishurobot

   # 切换到功能分支
   git checkout feature/optima-real-estate-ai
   ```

3. **配置环境变量**
   ```bash
   # 创建 .env 文件
   cat > .env << 'EOF'
# Feishu App Configuration
FEISHU_APP_ID=cli_a92eb7bf7d22dbd3
FEISHU_APP_SECRET=7n8j6zlj2MEqYJRFKaCNLdzC6xkUnKEc

# DeepSeek API Configuration
DEEPSEEK_API_KEY=sk-93a526f81c5a4ab9ae22f0fa33071b35

# Claude API Configuration
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4

# Server Configuration
PORT=3000
EOF
   ```

4. **运行部署脚本**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 配置公网访问

### 选项 1：使用 Cloudflare Tunnel（推荐）

1. **下载 cloudflared**
   ```bash
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
   chmod +x cloudflared-linux-amd64
   sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
   ```

2. **启动隧道**
   ```bash
   cloudflared tunnel --url http://localhost:3000
   ```

3. **记录生成的 URL**
   - 会显示类似：`https://xxx-xxx-xxx.trycloudflare.com`
   - 将这个 URL 配置到飞书 Webhook

### 选项 2：使用服务器公网 IP

如果服务器有公网 IP，可以直接使用：

1. **配置防火墙**
   ```bash
   # 开放 3000 端口
   sudo ufw allow 3000
   ```

2. **使用 Nginx 反向代理（可选）**
   ```bash
   # 安装 Nginx
   sudo apt-get install -y nginx

   # 配置反向代理
   sudo cat > /etc/nginx/sites-available/feishu-bot << 'EOF'
server {
    listen 80;
    server_name www.woaixiaoyu.xyz;

    location /webhook {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

   sudo ln -s /etc/nginx/sites-available/feishu-bot /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

3. **Webhook URL**
   - `http://www.woaixiaoyu.xyz/webhook`

## 持久化运行

### 使用 systemd 服务

1. **创建服务文件**
   ```bash
   sudo cat > /etc/systemd/system/feishu-bot.service << 'EOF'
[Unit]
Description=Feishu Bot with Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/bxn818204/feishurobot
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
   ```

2. **启用服务**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable feishu-bot
   sudo systemctl start feishu-bot
   ```

3. **管理服务**
   ```bash
   # 查看状态
   sudo systemctl status feishu-bot

   # 重启服务
   sudo systemctl restart feishu-bot

   # 查看日志
   docker logs -f feishu-deepseek-bot
   ```

## 常用命令

```bash
# 查看容器状态
docker ps

# 查看日志
docker logs -f feishu-deepseek-bot

# 重启容器
docker-compose restart

# 停止容器
docker-compose down

# 重新构建并启动
docker-compose up -d --build

# 进入容器
docker exec -it feishu-deepseek-bot sh
```

## 更新代码

```bash
cd ~/feishurobot
git pull
docker-compose down
docker-compose up -d --build
```

## 故障排查

1. **容器无法启动**
   ```bash
   docker logs feishu-deepseek-bot
   ```

2. **端口被占用**
   ```bash
   sudo lsof -i :3000
   sudo kill -9 <PID>
   ```

3. **检查网络连接**
   ```bash
   curl http://localhost:3000/health
   ```

## 安全建议

1. **修改服务器密码**
   ```bash
   passwd
   ```

2. **配置防火墙**
   ```bash
   sudo ufw enable
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

3. **定期更新系统**
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```
