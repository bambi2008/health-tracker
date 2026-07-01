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


@router.post("/parse-voice")
async def parse_voice(req: dict):
    """把自然语言语音转文字结果解析成结构化症状"""
    text = req.get("text", "")
    if not text:
        return {"error": "empty text"}

    settings = get_settings()
    if not settings.deepseek_api_key:
        return _fallback_parse(text)

    import httpx
    import json as _json

    prompt = f"""将用户的自然语言描述解析为结构化症状JSON。用户说："{text}"

返回JSON格式（只返回JSON，不要其他文字）：
{{
  "body_part": "head/neck/chest/abdomen/back/limb/skin/general",
  "body_detail": "具体部位中文",
  "severity": 1-10的整数,
  "description": "整理后的症状描述",
  "onset_type": "sudden/gradual/persistent/intermittent",
  "triggers": ["触发因素"],
  "reliefs": ["缓解方式"],
  "duration_min": 持续时间分钟数或null
}}"""

    body = _json.dumps({
        "model": settings.deepseek_model,
        "messages": [
            {"role": "system", "content": "你是医疗语音助手，将患者口语转为结构化数据。"},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.1, "max_tokens": 500,
    }, ensure_ascii=False).encode("utf-8")

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(
                f"{settings.deepseek_base_url}/v1/chat/completions",
                headers={"Authorization": f"Bearer {settings.deepseek_api_key}", "Content-Type": "application/json; charset=utf-8"},
                content=body,
            )
            resp.raise_for_status()
            data = resp.json()
            content = data["choices"][0]["message"]["content"]
            return _json.loads(content)
    except Exception:
        return _fallback_parse(text)


def _fallback_parse(text: str) -> dict:
    """离线关键词兜底"""
    import re
    result = {"body_part": "general", "body_detail": "全身性", "severity": 5, "description": text,
              "onset_type": "gradual", "triggers": [], "reliefs": [], "duration_min": None}

    parts = {"头": ["head","头部整体"], "太阳穴": ["head","左侧太阳穴"], "脖子": ["neck","颈部"],
             "颈椎": ["neck","颈部"], "肩膀": ["neck","颈部"], "胸": ["chest","胸骨/中央"],
             "心": ["chest","心区"], "胃": ["abdomen","胃区"], "肚子": ["abdomen","上腹部"],
             "腰": ["back","下背部/腰部"], "背": ["back","上背部"], "脚": ["limb","右脚"],
             "足底": ["limb","右脚"], "膝盖": ["limb","右膝"], "手臂": ["limb","右臂"],
             "皮肤": ["skin","面部"], "皮疹": ["skin","面部"]}
    for k, v in parts.items():
        if k in text: result["body_part"], result["body_detail"] = v[0], v[1]; break

    if re.search(r'[8-9]分|很.*(?:严重|厉害|疼)|剧烈|受不了', text): result["severity"] = 8
    elif re.search(r'[6-7]分|比较.*(?:严重|厉害|疼)|明显', text): result["severity"] = 6
    elif re.search(r'[4-5]分|有点|稍微|一般', text): result["severity"] = 4
    elif re.search(r'[1-3]分|轻微|一点点', text): result["severity"] = 2

    if re.search(r'突然|一下子|猛地', text): result["onset_type"] = "sudden"
    elif re.search(r'一直|持续|老是|总是|每天', text): result["onset_type"] = "persistent"
    elif re.search(r'一阵|时好时坏|偶尔', text): result["onset_type"] = "intermittent"

    triggers = []
    if re.search(r'熬夜|没睡|睡不好|失眠', text): triggers.append("熬夜")
    if re.search(r'累|疲劳|加班', text): triggers.append("劳累")
    if re.search(r'压力|焦虑|紧张|担心', text): triggers.append("压力")
    if re.search(r'吃|辣|油腻|喝酒|咖啡', text): triggers.append("饮食")
    if re.search(r'看屏幕|看手机|电脑', text): triggers.append("长时间看屏幕")
    result["triggers"] = triggers
    return result


from app.config import get_settings
