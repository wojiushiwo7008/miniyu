# 飞书机器人远程部署指南

## 方案 1：使用 Docker Context（推荐）

如果你的服务器开启了 Docker 远程 API，可以直接从本地部署到远程服务器。

### 配置 Docker 远程连接

```bash
# 在本地创建 Docker context
docker context create remote-server \
  --docker "host=tcp://www.woaixiaoyu.xyz:2375"

# 切换到远程 context
docker context use remote-server

# 验证连接
docker ps
```

### 部署命令

```bash
cd f:\claudecode\feishurobot
docker-compose up -d --build
```

---

## 方案 2：使用 Portainer（Web UI 管理）

### 在服务器上安装 Portainer

```bash
docker volume create portainer_data
docker run -d -p 9000:9000 -p 8000:8000 \
  --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### 访问 Portainer

1. 打开浏览器访问：`http://www.woaixiaoyu.xyz:9000`
2. 创建管理员账号
3. 选择 "Local" 环境
4. 在 Stacks 中创建新 Stack
5. 粘贴 docker-compose.yml 内容
6. 添加环境变量
7. 点击 Deploy

---

## 方案 3：使用 Watchtower 自动更新

### 在服务器上安装 Watchtower

```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --interval 300
```

Watchtower 会自动检测并更新容器。

---

## 方案 4：使用 GitHub Actions 自动部署

创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy to Server

on:
  push:
    branches: [ feature/optima-real-estate-ai ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: www.woaixiaoyu.xyz
          username: bxn818204
          password: ${{ secrets.SERVER_PASSWORD }}
          port: 5666
          script: |
            cd ~/miniyu
            git pull origin feature/optima-real-estate-ai
            docker-compose down
            docker-compose up -d --build
```

---

## 方案 5：使用 Webhook 自动部署

### 在服务器上安装 webhook

```bash
# 安装 webhook
sudo apt-get install webhook

# 创建 webhook 配置
cat > /etc/webhook.conf << 'EOF'
[
  {
    "id": "deploy-feishu-bot",
    "execute-command": "/home/bxn818204/deploy.sh",
    "command-working-directory": "/home/bxn818204/miniyu"
  }
]
EOF

# 创建部署脚本
cat > /home/bxn818204/deploy.sh << 'EOF'
#!/bin/bash
cd ~/miniyu
git pull origin feature/optima-real-estate-ai
docker-compose down
docker-compose up -d --build
EOF

chmod +x /home/bxn818204/deploy.sh

# 启动 webhook
webhook -hooks /etc/webhook.conf -verbose
```

### 触发部署

```bash
curl http://www.woaixiaoyu.xyz:9000/hooks/deploy-feishu-bot
```

---

## 方案 6：使用 WinSCP + PuTTY（Windows 用户）

1. 下载 WinSCP：https://winscp.net/
2. 连接信息：
   - 主机：www.woaixiaoyu.xyz
   - 端口：5666
   - 用户：bxn818204
   - 密码：Aaa@13278505045
3. 上传项目文件到 `~/miniyu`
4. 使用 PuTTY 连接执行部署命令

---

## 推荐方案

**最简单：** 方案 2（Portainer Web UI）
**最自动：** 方案 4（GitHub Actions）
**最灵活：** 方案 1（Docker Context）

选择一个适合你的方案即可！
