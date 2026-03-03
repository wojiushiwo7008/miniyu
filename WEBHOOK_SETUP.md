# Webhook 自动部署配置指南

## 步骤 1：在服务器上安装 Webhook 服务

登录到你的服务器，执行以下命令：

```bash
# 下载安装脚本（如果代码已经在服务器上）
cd ~/miniyu
bash setup-webhook.sh
```

或者直接执行完整安装命令：

```bash
curl -o- https://raw.githubusercontent.com/wojiushiwo7008/miniyu/feature/optima-real-estate-ai/setup-webhook.sh | bash
```

安装完成后，webhook 服务会自动启动在 9000 端口。

## 步骤 2：验证 Webhook 服务

```bash
# 检查服务状态
pm2 status

# 测试健康检查
curl http://localhost:9000/health

# 查看日志
pm2 logs webhook
```

## 步骤 3：在 GitHub 配置 Webhook

1. 访问你的 GitHub 仓库：https://github.com/wojiushiwo7008/miniyu

2. 点击 **Settings** → **Webhooks** → **Add webhook**

3. 填写配置：
   - **Payload URL**: `http://www.woaixiaoyu.xyz:9000/webhook`
   - **Content type**: `application/json`
   - **Secret**: `miniyu-webhook-secret-2024`
   - **Which events**: 选择 `Just the push event`
   - **Active**: 勾选

4. 点击 **Add webhook**

## 步骤 4：测试自动部署

推送代码到 `feature/optima-real-estate-ai` 分支：

```bash
git add .
git commit -m "Test webhook deployment"
git push origin feature/optima-real-estate-ai
```

然后查看：
- GitHub Webhook 页面的 "Recent Deliveries"（应该显示成功）
- 服务器上的 webhook 日志：`pm2 logs webhook`
- 应用是否自动更新：`docker ps`

## 手动触发部署（测试用）

```bash
curl -X POST http://localhost:9000/deploy-manual
```

## 管理命令

```bash
# 查看 webhook 服务状态
pm2 status

# 查看实时日志
pm2 logs webhook

# 重启服务
pm2 restart webhook

# 停止服务
pm2 stop webhook

# 删除服务
pm2 delete webhook
```

## 故障排查

### Webhook 服务无法启动

```bash
# 检查端口是否被占用
netstat -tlnp | grep 9000

# 查看详细日志
pm2 logs webhook --lines 100
```

### GitHub Webhook 显示失败

1. 检查服务器防火墙是否开放 9000 端口
2. 检查 webhook 服务是否运行：`pm2 status`
3. 查看 GitHub Webhook 的错误信息
4. 检查服务器日志：`pm2 logs webhook`

### 部署没有触发

1. 确认推送的是 `feature/optima-real-estate-ai` 分支
2. 查看 webhook 日志确认是否收到请求
3. 检查 deploy.sh 脚本是否有执行权限：`chmod +x ~/miniyu/deploy.sh`

## 安全建议

1. 使用强密码作为 Webhook Secret
2. 考虑使用 HTTPS（需要配置 SSL 证书）
3. 限制 9000 端口只允许 GitHub 的 IP 访问（可选）

## 架构说明

```
GitHub Push → GitHub Webhook → 服务器 9000 端口 → deploy.sh → Docker 重新部署
```

每次推送代码到 GitHub，会自动触发服务器上的部署流程，无需手动操作。
