# worker.py (упрощённая версия без реального pocketsphinx)
import os
import json
import logging
from confluent_kafka import Consumer, Producer

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")

consumer = Consumer({
    'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
    'group.id': 'worker-group',
    'auto.offset.reset': 'earliest'
})
consumer.subscribe(['transcription_tasks'])

producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS})

def delivery_report(err, msg):
    if err:
        logger.error(f"Kafka send failed: {err}")
    else:
        logger.info(f"Result sent")

logger.info("Worker started...")

while True:
    msg = consumer.poll(timeout=1.0)
    if msg is None:
        continue
    if msg.error():
        logger.error(f"Consumer error: {msg.error()}")
        continue

    try:
        data = json.loads(msg.value().decode('utf-8'))
        task_id = data['task_id']
        audio_path = data['audio_path']

        logger.info(f"Processing task {task_id}...")

        # Эмуляция результата
        text = f"Virtual machine"
        result = {"task_id": task_id, "text": text}
        logger.info(f"Emulated result: {text}")

    except Exception as e:
        logger.error(f"Error: {e}")
        result = {"task_id": task_id, "error": str(e)}

    producer.produce(
        'transcription_results',
        key=task_id,
        value=json.dumps(result).encode('utf-8'),
        callback=delivery_report
    )
    producer.poll(0)
    consumer.commit(msg)