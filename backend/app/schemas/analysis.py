from pydantic import BaseModel, Field
from typing import Optional


# ===== 输入 =====

class SymptomEntry(BaseModel):
    body_part: str = Field(..., description="身体部位大类")
    body_detail: str = Field(..., description="具体部位")
    severity: int = Field(..., ge=1, le=10)
    description: str = Field("")
    onset_type: str = Field("gradual")
    duration_min: Optional[int] = Field(None)
    triggers: list[str] = Field(default_factory=list)
    reliefs: list[str] = Field(default_factory=list)
    recorded_at: str = Field("")


class DietEntry(BaseModel):
    meal_type: str = "breakfast"
    water_ml: int = 0
    notes: str = ""
    recorded_at: str = ""


class SleepEntry(BaseModel):
    sleep_start: str = ""
    sleep_end: str = ""
    quality: int = Field(3, ge=1, le=5)
    interruptions: int = 0
    recorded_date: str = ""


class StressEntry(BaseModel):
    level: int = Field(5, ge=1, le=10)
    source: str = "other"
    notes: str = ""
    recorded_at: str = ""


class AnalysisRequest(BaseModel):
    symptoms: list[SymptomEntry] = Field(default_factory=list)
    diets: list[DietEntry] = Field(default_factory=list)
    sleeps: list[SleepEntry] = Field(default_factory=list)
    stresses: list[StressEntry] = Field(default_factory=list)
    user_info: Optional[str] = Field(None)


# ===== 输出 =====

class CorrelationFinding(BaseModel):
    factor: str = Field(...)
    symptom: str = Field(...)
    strength: str = Field(...)
    mechanism: str = Field("", description="病理生理机制")
    evidence_level: str = Field("C", description="循证等级 A/B/C")
    description: str = Field(...)


class PatternFinding(BaseModel):
    pattern: str = Field(...)
    description: str = Field(...)
    clinical_context: str = Field("", description="该模式的临床背景")
    confidence: str = Field("medium")


class RiskAssessment(BaseModel):
    level: str = "low"
    summary: str = ""
    suggested_department: str = ""
    suggested_tests: str = Field("", description="建议检查项目")
    urgency: str = "normal"


class DoctorSummary(BaseModel):
    brief: str = ""
    timeline: str = ""
    key_points: list[str] = Field(default_factory=list)
    questions_to_ask: list[str] = Field(default_factory=list)
    differential_diagnosis: list[str] = Field(default_factory=list)


class AnalysisResponse(BaseModel):
    correlations: list[CorrelationFinding] = Field(default_factory=list)
    patterns: list[PatternFinding] = Field(default_factory=list)
    risk: Optional[RiskAssessment] = None
    doctor_summary: Optional[DoctorSummary] = None
    model_used: str = ""

    model_config = {"protected_namespaces": ()}
