#!/bin/bash
# deploy-postgres.sh
# Зависимости: postgresql, postgresql-contrib
# Роль: хранит задачи расшифровки

set -e

# Установка PostgreSQL 14 (доступен в Ubuntu 22.04)
apt update
apt install -y postgresql postgresql-contrib

# Настройка: слушать все интерфейсы
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/14/main/postgresql.conf

# Разрешить подключения по паролю с любого IP
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf

# Создаём БД и пользователя
sudo -u postgres psql -c "CREATE USER transcribe_user WITH PASSWORD 'transcribe_pass';"
sudo -u postgres psql -c "CREATE DATABASE transcribe_db;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE transcribe_db TO transcribe_user;"

# Перезапуск
systemctl restart postgresql

echo "PostgreSQL ready on port 5432"