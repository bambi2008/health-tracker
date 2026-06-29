"""简易同步数据存储 — 内存版，重启后消失。后续可替换为 SQLite/PostgreSQL"""

import json
from pathlib import Path
from typing import Optional
from app.schemas.sync import (
    SyncUploadRequest,
    SyncDownloadResponse,
    SyncStatusResponse,
    SyncSymptom,
    SyncDiet,
    SyncSleep,
    SyncStress,
)

# 数据目录
DATA_DIR = Path(__file__).resolve().parent.parent.parent / "data"
DATA_DIR.mkdir(exist_ok=True)


def _device_file(device_id: str) -> Path:
    # 简单防路径穿越
    safe = device_id.replace("/", "_").replace("\\", "_").replace("..", "_")
    return DATA_DIR / f"sync_{safe}.json"


def save(request: SyncUploadRequest) -> dict:
    """保存同步数据到磁盘"""
    data = {
        "symptoms": [s.model_dump() for s in request.symptoms],
        "diets": [d.model_dump() for d in request.diets],
        "sleeps": [s.model_dump() for s in request.sleeps],
        "stresses": [s.model_dump() for s in request.stresses],
        "synced_at": request.synced_at,
    }
    _device_file(request.device_id).write_text(
        json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    return {"status": "ok", "count": _count(data)}


def download(device_id: str) -> SyncDownloadResponse:
    """从磁盘读取同步数据"""
    f = _device_file(device_id)
    if not f.exists():
        return SyncDownloadResponse(device_id=device_id)

    raw = json.loads(f.read_text(encoding="utf-8"))
    return SyncDownloadResponse(
        device_id=device_id,
        symptoms=[SyncSymptom(**s) for s in raw.get("symptoms", [])],
        diets=[SyncDiet(**d) for d in raw.get("diets", [])],
        sleeps=[SyncSleep(**s) for s in raw.get("sleeps", [])],
        stresses=[SyncStress(**s) for s in raw.get("stresses", [])],
        last_synced_at=raw.get("synced_at"),
    )


def status(device_id: str) -> SyncStatusResponse:
    """检查同步状态"""
    f = _device_file(device_id)
    if not f.exists():
        return SyncStatusResponse(device_id=device_id)

    raw = json.loads(f.read_text(encoding="utf-8"))
    return SyncStatusResponse(
        device_id=device_id,
        symptom_count=len(raw.get("symptoms", [])),
        diet_count=len(raw.get("diets", [])),
        sleep_count=len(raw.get("sleeps", [])),
        stress_count=len(raw.get("stresses", [])),
        last_synced_at=raw.get("synced_at"),
    )


def _count(data: dict) -> dict:
    return {
        "symptoms": len(data.get("symptoms", [])),
        "diets": len(data.get("diets", [])),
        "sleeps": len(data.get("sleeps", [])),
        "stresses": len(data.get("stresses", [])),
    }
