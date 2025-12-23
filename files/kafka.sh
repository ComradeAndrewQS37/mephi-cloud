#!/bin/bash

sudo apt update
sudo apt install -y openjdk-11-jdk

mkdir ~/downloads
cd ~/downloads
wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.12-3.4.0.tgz

cd ~
tar -xvzf ~/downloads/kafka_2.12-3.4.0.tgz
mv kafka_2.12-3.4.0/ kafka/

cat > "/etc/systemd/system/zookeeper.service" <<EOF
[Unit]
Description=Apache Zookeeper Service
Requires=network.target
After=network.target

[Service]
Type=simple
User=kafka
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

cat > "/etc/systemd/system/kafka.service" <<EOF
[[Unit]
Description=Apache Kafka Service that requires zookeeper service
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart= /home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start kafka