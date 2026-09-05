<<<<<<< HEAD
from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str


class RegisterResponse(BaseModel):
    id: int
    name: str | None
    email: str
    message: str
=======
from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class CurrentUserResponse(BaseModel):
    id: int
    email: EmailStr
    role: str
    is_active: bool
>>>>>>> 4bfe9cef61d35ba36c297a87a737c3ee62ed3836
