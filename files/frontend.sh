#!/bin/bash

sudo apt update
sudo apt install -y apache2


cd /var/www/html
rm index.html
wget https://raw.githubusercontent.com/ComradeAndrewQS37/mephi-cloud/refs/heads/main/files/index.html

MANAGER_IP="10.10.10.10"
sed -i "s/MANAGER_IP/$MANAGER_IP/g" index.html
