from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import settings
from app.models import User
from app.schemas.auth import LoginRequest
from app.security.jwt import create_access_token
from app.security.password import verify_password


def authenticate_user(
    db: Session,
    login_data: LoginRequest,
) -> User:
    """
    Authenticate a user using email and password.
    """

    statement = select(User).where(
        User.email == login_data.email
    )

    user = db.scalar(statement)

    if user is None or not verify_password(
        login_data.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive.",
        )

    return user


def login(
    db: Session,
    login_data: LoginRequest,
) -> dict[str, object]:
    """
    Authenticate the user and return an access token.
    """

    user = authenticate_user(db, login_data)

    token = create_access_token(
        subject=str(user.id),
        role=user.role.value,
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
    }