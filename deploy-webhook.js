const express = require('express');
const { exec } = require('child_process');
const crypto = require('crypto');
const path = require('path');

const app = express();
const PORT = process.env.WEBHOOK_PORT || 9000;
const SECRET = process.env.WEBHOOK_SECRET || 'miniyu-webhook-secret-2024';
const DEPLOY_DIR = process.env.DEPLOY_DIR || path.join(process.env.HOME, 'miniyu');

app.use(express.json());

// 日志函数
function log(message) {
  console.log(`[${new Date().toISOString()}] ${message}`);
}

// GitHub Webhook 端点
app.post('/webhook', (req, res) => {
  log('收到 webhook 请求');

  // 验证 GitHub webhook 签名（可选，如果配置了 secret）
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

  // 只处理 push 事件
  if (event === 'push') {
    const branch = req.body.ref ? req.body.ref.split('/').pop() : '';
    log(`推送分支: ${branch}`);

    if (branch === 'feature/optima-real-estate-ai') {
      log('触发部署...');

      // 执行部署脚本
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

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Webhook server is running',
    port: PORT,
    deployDir: DEPLOY_DIR
  });
});

// 手动触发部署（用于测试）
app.post('/deploy-manual', (req, res) => {
  log('手动触发部署');

  const deployScript = `cd ${DEPLOY_DIR} && bash deploy.sh`;
  exec(deployScript, (error, stdout, stderr) => {
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
