#!/bin/bash
# deploy-frontend.sh
# Зависимости: nginx
# Роль: отдаёт frontend.html через Nginx

set -e

# Установка Nginx
apt update
apt install -y nginx

# Скачиваем HTML
wget -O /var/www/html/index.html "https://raw.githubusercontent.com/ComradeAndrewQS37/mephi-cloud/refs/heads/main/src/frontend.html"

MANAGER_IP="10.20.15.238"
sed -i "s/localhost/$MANAGER_IP/g" /var/www/html/index.html

# Убеждаемся, что Nginx запущен
systemctl enable nginx
systemctl restart nginx

echo "Frontend deployed on http://$(hostname -I | awk '{print $1}')"