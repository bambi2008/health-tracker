from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services import auth_service

router = APIRouter(prefix="/auth", tags=["用户认证"])


class RegisterRequest(BaseModel):
    phone: str
    password: str
    nickname: str = ""


class LoginRequest(BaseModel):
    phone: str
    password: str


class ProfileUpdate(BaseModel):
    nickname: str = ""
    gender: str = ""
    birth_date: str = ""
    chronic_diseases: list[str] = []


@router.post("/register")
async def register(req: RegisterRequest):
    if len(req.phone) < 11 or not req.phone.isdigit():
        raise HTTPException(400, "手机号格式不正确")
    if len(req.password) < 6:
        raise HTTPException(400, "密码至少6位")

    result = auth_service.register(req.phone, req.password, req.nickname)
    if result is None:
        raise HTTPException(409, "该手机号已注册")
    return {"status": "ok", "user": result}


@router.post("/login")
async def login(req: LoginRequest):
    result = auth_service.login(req.phone, req.password)
    if result is None:
        raise HTTPException(401, "手机号或密码错误")
    return {"status": "ok", "token": result["token"], "user": result["user"]}


@router.get("/me")
async def get_me(token: str = ""):
    """根据 token 获取用户信息"""
    if not token:
        raise HTTPException(401, "请先登录")
    user = auth_service.verify_token(token)
    if user is None:
        raise HTTPException(401, "登录已过期")
    return {"status": "ok", "user": user}


@router.put("/profile")
async def update_profile(req: ProfileUpdate, token: str = ""):
    user = auth_service.verify_token(token)
    if user is None:
        raise HTTPException(401, "请先登录")

    updated = auth_service.update_profile(
        user["id"], req.nickname, req.gender, req.birth_date, req.chronic_diseases
    )
    return {"status": "ok", "user": updated}
