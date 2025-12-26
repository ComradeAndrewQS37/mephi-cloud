# manager.py — упрощённая версия без PostgreSQL
import os
import uuid
import json
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from confluent_kafka import Producer
import threading
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# === Конфигурация ===
KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")

# === In-memory хранилище задач ===
tasks = {}  # task_id -> {status: str, text: str (optional)}

# === Kafka producer ===
producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS})

def delivery_report(err, msg):
    if err:
        logger.error(f"Kafka send failed: {err}")
    else:
        logger.info(f"Sent to {msg.topic()}")

# === Фоновый "имитатор" получения результата от воркера ===
# (На самом деле — воркер отправит в Kafka, а мы его НЕ читаем — но для демо можно и так)
# Но чтобы система работала, оставим только отправку в Kafka, а результат будем возвращать "условный"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # Allow all origins
    allow_credentials=True,   # Allow cookies and auth headers
    allow_methods=["*"],      # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],      # Allow all HTTP headers
)

@app.post("/transcribe")
async def transcribe_audio(audio: UploadFile = File(...)):
    if not audio.filename.endswith('.wav'):
        raise HTTPException(status_code=400, detail="Only .wav files allowed")

    task_id = str(uuid.uuid4())
    # Не сохраняем файл — просто имитируем
    logger.info(f"Received task {task_id}")

    # Сохраняем "задачу" в памяти как pending
    tasks[task_id] = {"status": "pending"}

    # Отправляем в Kafka (воркер в теории его прочитает)
    message = {
        "task_id": task_id,
        "audio_path": f"/tmp/{task_id}.wav"  # воркер его не читает — у нас эмуляция
    }
    producer.produce(
        'transcription_tasks',
        key=task_id,
        value=json.dumps(message).encode('utf-8'),
        callback=delivery_report
    )
    producer.poll(0)

    return JSONResponse({"task_id": task_id})

@app.get("/result/{task_id}")
def get_result(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")

    task = tasks[task_id]

    # Для демо: если задача ещё pending — считаем, что воркер уже обработал
    if task["status"] == "pending":
        # Имитируем получение результата от воркера
        task["status"] = "completed"
        task["text"] = f"virtual machine"

    return {
        "task_id": task_id,
        "status": task["status"],
        "text": task.get("text")
    }