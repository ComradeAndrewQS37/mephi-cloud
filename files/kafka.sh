#!/bin/bash

sudo apt update
sudo apt install -y openjdk21-jre

cd /opt
wget https://dlcdn.apache.org/kafka/4.1.1/kafka-4.1.1-src.tgz
tar -xzf kafka-4.1.1-src.tgz
cd kafka-4.1.1-src

bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
bin/kafka-server-start.sh -daemon config/server.properties

bin/kafka-topics.sh --create --topic speech-to-text.requests \
 --bootstrap-server localhost:9092
bin/kafka-topics.sh --create --topic speech-to-text.responses \
 --bootstrap-server localhost:9092
