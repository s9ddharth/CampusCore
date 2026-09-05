from __future__ import annotations

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.auth import (
    CurrentUserResponse,
    LoginRequest,
    TokenResponse,
)
from app.security.permissions import get_current_user
from app.services.auth_service import (
    authenticate_user,
    login,
)


router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"],
)


@router.post(
    "/login",
    response_model=TokenResponse,
)
def login_route(
    login_data: LoginRequest,
    db: Session = Depends(get_db),
) -> dict[str, object]:
    return login(db, login_data)


@router.post(
    "/token",
    response_model=TokenResponse,
)
def token_route(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
) -> dict[str, object]:
    login_data = LoginRequest(
        email=form_data.username,
        password=form_data.password,
    )

    user = authenticate_user(db, login_data)

    from app.config import settings
    from app.security.jwt import create_access_token

    token = create_access_token(
        subject=str(user.id),
        role=user.role.value,
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }


@router.get(
    "/me",
    response_model=CurrentUserResponse,
)
def get_me(
    current_user=Depends(get_current_user),
) -> CurrentUserResponse:
    return CurrentUserResponse(
        id=current_user.id,
        email=current_user.email,
        role=current_user.role.value,
        is_active=current_user.is_active,
    )