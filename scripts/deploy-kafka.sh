#!/bin/bash
# deploy-kafka.sh
# Зависимости: openjdk-17-jre, wget, tar
# Роль: брокер сообщений (transcription_tasks, transcription_results)

set -e

# Установка Java
apt update
apt install -y openjdk-17-jre wget tar

# Скачиваем Kafka
KAFKA_VERSION=3.8.0
SCALA_VERSION=2.13
cd /opt
wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} kafka
rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# Конфигурация KRaft
cat > /opt/kafka/config/kraft/server.properties <<EOF
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9093
listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
advertised.listeners=PLAINTEXT://$(hostname -I | awk '{print $1}'):9092
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/tmp/kafka-logs
num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
log.retention.hours=168
EOF

# Форматируем хранилище
cd /opt/kafka
bin/kafka-storage.sh format -t $(bin/kafka-storage.sh random-uuid) -c config/kraft/server.properties

# Создаём топики после запуска (в фоне)
cat > /opt/kafka/create-topics.sh <<'EOF'
#!/bin/bash
sleep 10
/opt/kafka/bin/kafka-topics.sh --create --topic transcription_tasks --partitions 1 --replication-factor 1 --bootstrap-server localhost:9092
/opt/kafka/bin/kafka-topics.sh --create --topic transcription_results --partitions 1 --replication-factor 1 --bootstrap-server localhost:9092
EOF
chmod +x /opt/kafka/create-topics.sh

# Запуск Kafka в фоне
nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties > /var/log/kafka.log 2>&1 &
/opt/kafka/create-topics.sh &

echo "Kafka started on port 9092"