import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.api.v1.ai import router as ai_router
from app.api.v1.sync import router as sync_router

settings = get_settings()

app = FastAPI(
    title="健康症状追踪 API",
    description="症状分析、数据同步后端服务",
    version="0.1.0",
)

# CORS — 允许 Flutter App 跨域请求
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 路由
app.include_router(ai_router, prefix="/api/v1")
app.include_router(sync_router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"service": "health_tracker", "version": "0.1.0"}


@app.get("/health")
async def health():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
