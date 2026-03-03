#!/bin/bash

# Webhook 服务安装和启动脚本

echo "=== 安装 Webhook 自动部署服务 ==="

# 1. 检查 Node.js 是否安装
if ! command -v node &> /dev/null; then
    echo "Node.js 未安装，正在安装..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✓ Node.js 已安装: $(node --version)"
fi

# 2. 检查 npm 是否安装
if ! command -v npm &> /dev/null; then
    echo "npm 未安装"
    exit 1
else
    echo "✓ npm 已安装: $(npm --version)"
fi

# 3. 安装 PM2（进程管理器）
if ! command -v pm2 &> /dev/null; then
    echo "安装 PM2..."
    sudo npm install -g pm2
else
    echo "✓ PM2 已安装: $(pm2 --version)"
fi

# 4. 创建 webhook 目录
WEBHOOK_DIR="$HOME/miniyu-webhook"
mkdir -p $WEBHOOK_DIR
cd $WEBHOOK_DIR

# 5. 复制 webhook 文件
echo "设置 webhook 服务..."
cat > package.json << 'EOF'
{
  "name": "deploy-webhook",
  "version": "1.0.0",
  "description": "GitHub webhook service for auto deployment",
  "main": "deploy-webhook.js",
  "scripts": {
    "start": "node deploy-webhook.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > deploy-webhook.js << 'EOF'
const express = require('express');
const { exec } = require('child_process');
const crypto = require('crypto');
const path = require('path');

const app = express();
const PORT = process.env.WEBHOOK_PORT || 9000;
const SECRET = process.env.WEBHOOK_SECRET || 'miniyu-webhook-secret-2024';
const DEPLOY_DIR = process.env.DEPLOY_DIR || path.join(process.env.HOME, 'miniyu');

app.use(express.json());

function log(message) {
  console.log(`[${new Date().toISOString()}] ${message}`);
}

app.post('/webhook', (req, res) => {
  log('收到 webhook 请求');

  const signature = req.headers['x-hub-signature-256'];
  if (signature && SECRET) {
    const hmac = crypto.createHmac('sha256', SECRET);
    const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');

    if (signature !== digest) {
      log('签名验证失败');
      return res.status(401).send('Invalid signature');
    }
    log('签名验证成功');
  }

  const event = req.headers['x-github-event'];
  log(`事件类型: ${event}`);

  if (event === 'push') {
    const branch = req.body.ref ? req.body.ref.split('/').pop() : '';
    log(`推送分支: ${branch}`);

    if (branch === 'feature/optima-real-estate-ai') {
      log('触发部署...');

      const deployScript = `cd ${DEPLOY_DIR} && bash deploy.sh`;
      exec(deployScript, (error, stdout, stderr) => {
        if (error) {
          log(`部署错误: ${error.message}`);
          console.error(stderr);
          return;
        }
        log('部署成功');
        log(`输出: ${stdout}`);
        if (stderr) log(`警告: ${stderr}`);
      });

      res.status(200).json({
        status: 'success',
        message: 'Deployment triggered',
        branch: branch
      });
    } else {
      log(`忽略分支: ${branch}`);
      res.status(200).json({
        status: 'ignored',
        message: 'Branch not configured for deployment',
        branch: branch
      });
    }
  } else {
    log(`忽略事件: ${event}`);
    res.status(200).json({
      status: 'ignored',
      message: 'Event not configured',
      event: event
    });
  }
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Webhook server is running',
    port: PORT,
    deployDir: DEPLOY_DIR
  });
});

app.post('/deploy-manual', (req, res) => {
  log('手动触发部署');

  const deployScript = `cd ${DEPLOY_DIR} && bash deploy.sh`;
  exec(deployScript, (error, stdout) => {
    if (error) {
      log(`部署错误: ${error.message}`);
      return res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
    log('部署成功');
    res.status(200).json({
      status: 'success',
      message: 'Deployment completed',
      output: stdout
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  log(`Webhook 服务器运行在端口 ${PORT}`);
  log(`部署目录: ${DEPLOY_DIR}`);
});
EOF

# 6. 安装依赖
echo "安装依赖..."
npm install

# 7. 开放 9000 端口
echo "开放 9000 端口..."
sudo ufw allow 9000/tcp 2>/dev/null || true

# 8. 使用 PM2 启动服务
echo "启动 webhook 服务..."
pm2 stop webhook 2>/dev/null || true
pm2 delete webhook 2>/dev/null || true
pm2 start deploy-webhook.js --name webhook
pm2 save
pm2 startup

echo ""
echo "=== Webhook 服务安装完成 ==="
echo ""
echo "服务地址: http://www.woaixiaoyu.xyz:9000"
echo "健康检查: curl http://localhost:9000/health"
echo ""
echo "管理命令:"
echo "  查看状态: pm2 status"
echo "  查看日志: pm2 logs webhook"
echo "  重启服务: pm2 restart webhook"
echo "  停止服务: pm2 stop webhook"
echo ""
echo "下一步: 在 GitHub 仓库中配置 Webhook"
echo "  URL: http://www.woaixiaoyu.xyz:9000/webhook"
echo "  Content type: application/json"
echo "  Secret: miniyu-webhook-secret-2024"
echo "  Events: Just the push event"
