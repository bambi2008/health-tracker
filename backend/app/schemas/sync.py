from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class SyncSymptom(BaseModel):
    id: str
    body_part: str
    body_detail: str
    severity: int
    description: str = ""
    onset_type: str = "gradual"
    duration_min: Optional[int] = None
    triggers: list[str] = []
    reliefs: list[str] = []
    recorded_at: str
    created_at: str


class SyncDiet(BaseModel):
    id: str
    meal_type: str
    water_ml: int = 0
    notes: str = ""
    recorded_at: str
    created_at: str


class SyncSleep(BaseModel):
    id: str
    sleep_start: str
    sleep_end: str
    quality: int = 3
    interruptions: int = 0
    notes: str = ""
    recorded_date: str
    created_at: str


class SyncStress(BaseModel):
    id: str
    level: int
    source: str = "other"
    notes: str = ""
    recorded_at: str
    created_at: str


class SyncUploadRequest(BaseModel):
    """上传同步请求"""
    device_id: str
    symptoms: list[SyncSymptom] = []
    diets: list[SyncDiet] = []
    sleeps: list[SyncSleep] = []
    stresses: list[SyncStress] = []
    synced_at: Optional[str] = None


class SyncDownloadResponse(BaseModel):
    """下载同步响应"""
    device_id: str
    symptoms: list[SyncSymptom] = []
    diets: list[SyncDiet] = []
    sleeps: list[SyncSleep] = []
    stresses: list[SyncStress] = []
    last_synced_at: Optional[str] = None


class SyncStatusResponse(BaseModel):
    """同步状态"""
    device_id: str
    symptom_count: int = 0
    diet_count: int = 0
    sleep_count: int = 0
    stress_count: int = 0
    last_synced_at: Optional[str] = None
