#!/bin/bash
# Portainer 一键安装脚本

echo "安装 Portainer..."

# 创建数据卷
docker volume create portainer_data

# 启动 Portainer
docker run -d \
  -p 9000:9000 \
  -p 8000:8000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo ""
echo "✅ Portainer 安装完成！"
echo ""
echo "访问地址: http://www.woaixiaoyu.xyz:9000"
echo ""
echo "首次访问需要创建管理员账号"
