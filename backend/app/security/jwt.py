from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from fastapi import HTTPException, status

from app.config import settings


ALGORITHM = "HS256"


def create_access_token(
    subject: str,
    role: str,
    expires_minutes: int | None = None,
) -> str:
    """
    Create a JWT access token.
    """

    if not subject:
        raise ValueError("Token subject cannot be empty.")

    expire_minutes = (
        expires_minutes
        if expires_minutes is not None
        else settings.access_token_expire_minutes
    )

    now = datetime.now(timezone.utc)
    expires_at = now + timedelta(minutes=expire_minutes)

    payload: dict[str, Any] = {
        "sub": subject,
        "role": role,
        "iat": now,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        settings.jwt_secret,
        algorithm=ALGORITHM,
    )


def decode_access_token(token: str) -> dict[str, Any]:
    """
    Decode and validate a JWT access token.
    """

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token.",
        )

    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[ALGORITHM],
        )
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token has expired.",
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token.",
        ) from exc

    subject = payload.get("sub")
    role = payload.get("role")

    if not subject or not role:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token payload.",
        )

    return payload