from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import User
from app.schemas.user import UserCreate, UserUpdate
from app.security.password import hash_password
from app.utils.audit import create_audit_log


def get_user(
    db: Session,
    user_id: int,
) -> User | None:
    return db.get(User, user_id)


def get_user_by_email(
    db: Session,
    email: str,
) -> User | None:
    statement = select(User).where(
        User.email == email
    )
    return db.scalar(statement)


def list_users(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> list[User]:
    statement = (
        select(User)
        .order_by(User.id)
        .offset(skip)
        .limit(limit)
    )

    return list(db.scalars(statement).all())


def create_user(
    db: Session,
    user_data: UserCreate,
    current_user_id: int | None = None,
) -> User:
    existing_user = get_user_by_email(
        db,
        str(user_data.email),
    )

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists.",
        )

    user = User(
        email=str(user_data.email),
        password_hash=hash_password(user_data.password),
        role=user_data.role,
        is_active=user_data.is_active,
    )

    db.add(user)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="USER",
        entity_id=user.id,
        new_value={
            "email": user.email,
            "role": user.role.value,
            "is_active": user.is_active,
        },
    )

    db.commit()
    db.refresh(user)

    return user


def update_user(
    db: Session,
    user_id: int,
    user_data: UserUpdate,
    current_user_id: int | None = None,
) -> User:
    user = get_user(db, user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    old_value = {
        "email": user.email,
        "role": user.role.value,
        "is_active": user.is_active,
    }

    if user_data.email is not None:
        existing_user = get_user_by_email(
            db,
            str(user_data.email),
        )

        if (
            existing_user is not None
            and existing_user.id != user.id
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A user with this email already exists.",
            )

        user.email = str(user_data.email)

    if user_data.role is not None:
        user.role = user_data.role

    if user_data.is_active is not None:
        user.is_active = user_data.is_active

    if user_data.password is not None:
        user.password_hash = hash_password(
            user_data.password
        )

    new_value = {
        "email": user.email,
        "role": user.role.value,
        "is_active": user.is_active,
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="UPDATE",
        entity="USER",
        entity_id=user.id,
        old_value=old_value,
        new_value=new_value,
    )

    db.commit()
    db.refresh(user)

    return user


def deactivate_user(
    db: Session,
    user_id: int,
    current_user_id: int | None = None,
) -> User:
    user = get_user(db, user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    old_value = {
        "is_active": user.is_active,
    }

    user.is_active = False

    create_audit_log(
        db,
        user_id=current_user_id,
        action="DEACTIVATE",
        entity="USER",
        entity_id=user.id,
        old_value=old_value,
        new_value={
            "is_active": user.is_active,
        },
    )

    db.commit()
    db.refresh(user)

    return user