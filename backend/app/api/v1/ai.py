from fastapi import APIRouter, HTTPException
from app.schemas.analysis import AnalysisRequest, AnalysisResponse
from app.services.ai_service import analyze

router = APIRouter(prefix="/ai", tags=["AI 分析"])


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_data(req: AnalysisRequest):
    """分析症状数据，返回关联、模式、风险评估、就医摘要"""
    if not req.symptoms and not req.sleeps and not req.stresses:
        raise HTTPException(status_code=400, detail="至少需要一些症状/睡眠/压力数据")

    result = await analyze(req)
    return result


@router.get("/health")
async def ai_health():
    """AI 服务健康检查"""
    return {"status": "ok", "message": "AI 分析服务正常运行"}
