#!/bin/bash
# deploy-manager.sh
# Зависимости: python3, python3-pip, librdkafka-dev, postgresql-client
# Роль: REST API, отправка задач в Kafka, хранение в PostgreSQL

set -e

# Зависимости
apt update
apt install -y python3 python3-pip librdkafka-dev postgresql-client

# Скачиваем исходник
wget -O /opt/manager.py "https://raw.githubusercontent.com/ComradeAndrewQS37/mephi-cloud/refs/heads/main/src/manager.py"

# Устанавливаем Python-зависимости
pip3 install fastapi uvicorn sqlalchemy psycopg2-binary confluent-kafka

# Переменные (настрой под себя!)
export POSTGRES_URL="postgresql://transcribe_user:transcribe_pass@<POSTGRES_IP>:5432/transcribe_db"
export KAFKA_BOOTSTRAP_SERVERS="<KAFKA_IP>:9092"

# Запуск через systemd (упрощённо — можно сделать полноценный unit)
cat > /etc/systemd/system/transcribe-manager.service <<EOF
[Unit]
Description=Transcribe Manager
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt
Environment=POSTGRES_URL=$POSTGRES_URL
Environment=KAFKA_BOOTSTRAP_SERVERS=$KAFKA_BOOTSTRAP_SERVERS
ExecStart=/usr/local/bin/uvicorn manager:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable transcribe-manager
systemctl restart transcribe-manager

echo "Manager running on port 8000"