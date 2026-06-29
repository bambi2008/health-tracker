from fastapi import APIRouter, HTTPException
from app.schemas.sync import SyncUploadRequest, SyncDownloadResponse, SyncStatusResponse
from app.services import sync_store

router = APIRouter(prefix="/sync", tags=["数据同步"])


@router.post("/upload", summary="上传同步数据")
async def upload(request: SyncUploadRequest):
    """将 App 本地数据上传备份到服务器"""
    result = sync_store.save(request)
    return result


@router.get("/download/{device_id}", response_model=SyncDownloadResponse, summary="下载同步数据")
async def download(device_id: str):
    """从服务器下载备份数据"""
    return sync_store.download(device_id)


@router.get("/status/{device_id}", response_model=SyncStatusResponse, summary="同步状态")
async def check_status(device_id: str):
    """查看服务器上的数据概览"""
    return sync_store.status(device_id)
