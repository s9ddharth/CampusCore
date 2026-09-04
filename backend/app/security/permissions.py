from __future__ import annotations

from collections.abc import Callable

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from app.database import get_db
from app.models import User, UserRole
from app.security.jwt import decode_access_token

from sqlalchemy.orm import Session


oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/auth/token",
)


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    """
    Return the authenticated user associated with the JWT.
    """

    payload = decode_access_token(token)

    subject = payload.get("sub")

    try:
        user_id = int(subject)
    except (TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user identity in token.",
        ) from exc

    user = db.get(User, user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive.",
        )

    return user


def require_roles(*allowed_roles: UserRole) -> Callable:
    """
    Create a dependency that allows only selected roles.
    """

    def role_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action.",
            )

        return current_user

    return role_checker


require_admin = require_roles(UserRole.ADMIN)

require_faculty = require_roles(UserRole.FACULTY)

require_student = require_roles(UserRole.STUDENT)

require_admin_or_faculty = require_roles(
    UserRole.ADMIN,
    UserRole.FACULTY,
)