import hashlib
import hmac
import json
import secrets
import time
from pathlib import Path
from typing import Optional

import jwt

DATA_DIR = Path(__file__).resolve().parent.parent.parent / "data"
DATA_DIR.mkdir(exist_ok=True)
USERS_FILE = DATA_DIR / "users.json"
JWT_SECRET = secrets.token_hex(32)

def _hash(password: str) -> str:
    salt = secrets.token_hex(16)
    return salt + ":" + hashlib.sha256((salt + password).encode()).hexdigest()

def _verify(password: str, hashed: str) -> bool:
    salt, h = hashed.split(":", 1)
    return hmac.compare_digest(
        hashlib.sha256((salt + password).encode()).hexdigest(), h
    )

# 简易用户存储
def _load_users() -> dict:
    if USERS_FILE.exists():
        return json.loads(USERS_FILE.read_text(encoding="utf-8"))
    return {}

def _save_users(users: dict):
    USERS_FILE.write_text(json.dumps(users, ensure_ascii=False, indent=2), encoding="utf-8")


def register(phone: str, password: str, nickname: str = "") -> dict | None:
    """注册新用户，返回用户信息或 None"""
    users = _load_users()
    if phone in users:
        return None  # 已注册

    user = {
        "id": secrets.token_hex(8),
        "phone": phone,
        "password_hash": _hash(password),
        "nickname": nickname or f"用户{phone[-4:]}",
        "created_at": time.strftime("%Y-%m-%d %H:%M:%S"),
    }
    users[phone] = user
    _save_users(users)
    return _public_user(user)


def login(phone: str, password: str) -> dict | None:
    """登录，返回 token 和用户信息"""
    users = _load_users()
    user = users.get(phone)
    if not user:
        return None
    if not _verify(password, user["password_hash"]):
        return None

    token = jwt.encode(
        {"sub": user["id"], "phone": phone, "exp": time.time() + 86400 * 30},
        JWT_SECRET,
        algorithm="HS256",
    )
    return {"token": token, "user": _public_user(user)}


def verify_token(token: str) -> dict | None:
    """验证 JWT，返回用户信息"""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        users = _load_users()
        for u in users.values():
            if u["id"] == payload["sub"]:
                return _public_user(u)
    except jwt.PyJWTError:
        pass
    return None


def update_profile(user_id: str, nickname: str = "", gender: str = "",
                   birth_date: str = "", chronic: list = None) -> dict | None:
    """更新用户资料"""
    users = _load_users()
    for phone, u in users.items():
        if u["id"] == user_id:
            if nickname: u["nickname"] = nickname
            if gender: u["gender"] = gender
            if birth_date: u["birth_date"] = birth_date
            if chronic is not None: u["chronic_diseases"] = chronic
            _save_users(users)
            return _public_user(u)
    return None


def _public_user(user: dict) -> dict:
    return {
        "id": user["id"],
        "phone": user["phone"][:3] + "****" + user["phone"][-4:],
        "nickname": user.get("nickname", ""),
        "gender": user.get("gender", ""),
        "birth_date": user.get("birth_date", ""),
        "chronic_diseases": user.get("chronic_diseases", []),
        "created_at": user.get("created_at", ""),
    }
