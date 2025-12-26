#!/bin/bash
# deploy-worker.sh
# Зависимости: python3, python3-pip, librdkafka-dev, pocketsphinx, swig
# Роль: потребитель Kafka, расшифровка через PocketSphinx

set -e

# Зависимости для PocketSphinx
apt update
apt install -y python3 python3-pip librdkafka-dev swig libpocketsphinx-dev libsphinxbase-dev

# Скачиваем исходник
wget -O /opt/worker.py "https://raw.githubusercontent.com/ComradeAndrewQS37/mephi-cloud/refs/heads/main/src/worker.py"

# Устанавливаем Python-пакеты
pip3 install pocketsphinx confluent-kafka

# Переменная Kafka
export KAFKA_BOOTSTRAP_SERVERS="<KAFKA_IP>:9092"

# Systemd-сервис
cat > /etc/systemd/system/transcribe-worker.service <<EOF
[Unit]
Description=Transcribe Worker
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt
Environment=KAFKA_BOOTSTRAP_SERVERS=$KAFKA_BOOTSTRAP_SERVERS
ExecStart=/usr/bin/python3 worker.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable transcribe-worker
systemctl restart transcribe-worker

echo "Worker started (listening to Kafka)"