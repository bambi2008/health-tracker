import json
import httpx
from app.config import get_settings
from app.schemas.analysis import (
    AnalysisRequest,
    AnalysisResponse,
    CorrelationFinding,
    PatternFinding,
    RiskAssessment,
    DoctorSummary,
)

SYSTEM_PROMPT = """你是一位循证医学专家和临床数据分析师。你的任务是基于用户记录的症状、饮食、睡眠、压力数据，提供专业、有据可查的分析。

## 核心原则
1. 每个结论必须有数据支撑或医学文献依据。无法确定的，明确标注"证据不足"
2. 优先引用已知的病理生理机制（如炎症通路、神经内分泌轴、免疫应答等）
3. 参考典型临床表现模式（如肿瘤相关性疲乏 CRF、化疗后贫血、慢性疼痛-睡眠障碍循环等）
4. 你的分析仅供参考，绝对不能替代专业医疗诊断

## 分析方法
- 相关性分析：计算因素间的时序关联和强度
- 机制解释：从病理生理角度解释为什么会出现这种关联
- 风险分层：基于症状组合、持续时间、严重度评估紧急程度
- 鉴别线索：提供可能的检查方向，帮助缩小诊断范围

## 输出 JSON 格式（严格按此结构）：
{
  "correlations": [
    {
      "factor": "因素名",
      "symptom": "关联症状",
      "strength": "strong/moderate/weak",
      "mechanism": "病理生理机制解释，引用已知医学知识",
      "evidence_level": "A/B/C  (A=有高质量RCT支持，B=观察性研究或临床共识，C=案例报告或理论推测)",
      "description": "人类可读的关联描述"
    }
  ],
  "patterns": [
    {
      "pattern": "模式名",
      "description": "基于数据的模式描述",
      "clinical_context": "该模式在哪些疾病或状态中常见",
      "confidence": "high/medium/low"
    }
  ],
  "risk": {
    "level": "low/medium/high",
    "summary": "风险评估摘要，包含鉴别诊断线索",
    "suggested_department": "建议首诊科室",
    "suggested_tests": "建议检查项目",
    "urgency": "normal/soon/urgent"
  },
  "doctor_summary": {
    "brief": "一句话概括，适合直接念给医生听",
    "timeline": "按时间顺序的症状演变",
    "key_points": ["医生应关注的关键信息"],
    "questions_to_ask": ["就诊时建议问医生的问题"],
    "differential_diagnosis": ["需要排除的鉴别诊断"]
  }
}"""


def build_user_prompt(req: AnalysisRequest) -> str:
    """构造给 AI 的分析 prompt"""
    parts = []

    if req.user_info:
        parts.append(f"## 用户信息\n{req.user_info}")

    if req.symptoms:
        lines = ["## 症状记录"]
        for i, s in enumerate(req.symptoms, 1):
            triggers = "、".join(s.triggers) if s.triggers else "无"
            reliefs = "、".join(s.reliefs) if s.reliefs else "无"
            lines.append(
                f"{i}. [{s.recorded_at[:10]}] {s.body_detail} "
                f"严重度{s.severity}/10 发作:{s.onset_type} "
                f"持续:{s.duration_min or '?'}分钟\n"
                f"   描述:{s.description or '无'}\n"
                f"   触发:{triggers}  缓解:{reliefs}"
            )
        parts.append("\n".join(lines))

    if req.sleeps:
        lines = ["## 睡眠记录"]
        for i, s in enumerate(req.sleeps, 1):
            dur = ""
            try:
                start = s.sleep_start[:16]
                end = s.sleep_end[:16]
                dur = f"{start} → {end}"
            except Exception:
                dur = "未知"
            lines.append(
                f"{i}. [{s.recorded_date[:10]}] {dur} "
                f"质量{s.quality}/5 中断{s.interruptions}次"
            )
        parts.append("\n".join(lines))

    if req.stresses:
        lines = ["## 压力记录"]
        for i, s in enumerate(req.stresses, 1):
            lines.append(
                f"{i}. [{s.recorded_at[:10]}] 水平{s.level}/10 "
                f"来源:{s.source} 备注:{s.notes or '无'}"
            )
        parts.append("\n".join(lines))

    if req.diets:
        lines = ["## 饮食记录"]
        for i, d in enumerate(req.diets, 1):
            lines.append(
                f"{i}. [{d.recorded_at[:10]}] {d.meal_type} "
                f"饮水{d.water_ml}ml 备注:{d.notes or '无'}"
            )
        parts.append("\n".join(lines))

    return "\n\n".join(parts)


async def analyze(req: AnalysisRequest) -> AnalysisResponse:
    """调用 DeepSeek 进行分析"""
    settings = get_settings()

    if not settings.deepseek_api_key:
        return AnalysisResponse(model_used="none (no API key)")

    user_prompt = build_user_prompt(req)
    data_count = len(req.symptoms) + len(req.sleeps) + len(req.stresses)
    if data_count < 2:
        return AnalysisResponse(model_used="none (insufficient data)")

    import json as _json

    request_body = _json.dumps(
        {
            "model": settings.deepseek_model,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": 0.3,
            "max_tokens": 2048,
            "response_format": {"type": "json_object"},
        },
        ensure_ascii=False,
    ).encode("utf-8")

    async with httpx.AsyncClient(timeout=60.0) as client:
        try:
            resp = await client.post(
                f"{settings.deepseek_base_url}/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.deepseek_api_key}",
                    "Content-Type": "application/json; charset=utf-8",
                },
                content=request_body,
            )
            resp.raise_for_status()
            data = resp.json()
            content = data["choices"][0]["message"]["content"]
            result = json.loads(content)

            return AnalysisResponse(
                correlations=[
                    CorrelationFinding(**c) for c in result.get("correlations", [])
                ],
                patterns=[
                    PatternFinding(**p) for p in result.get("patterns", [])
                ],
                risk=RiskAssessment(**result["risk"]) if result.get("risk") else None,
                doctor_summary=DoctorSummary(**result["doctor_summary"])
                if result.get("doctor_summary")
                else None,
                model_used=settings.deepseek_model,
            )

        except httpx.HTTPStatusError as e:
            return AnalysisResponse(
                model_used=f"error: HTTP {e.response.status_code}"
            )
        except Exception:
            return AnalysisResponse(
                model_used="error: API call failed (check API key)"
            )
