from __future__ import annotations

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    status,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.user import UserCreate, UserResponse, UserUpdate
from app.security.permissions import require_admin
from app.services.user_service import (
    create_user,
    deactivate_user,
    get_user,
    list_users,
    update_user,
)


router = APIRouter(
    prefix="/api/users",
    tags=["Users"],
)


@router.get(
    "",
    response_model=list[UserResponse],
)
def get_users(
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=500),
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_users(
        db,
        skip=skip,
        limit=limit,
    )


@router.get(
    "/{user_id}",
    response_model=UserResponse,
)
def get_user_by_id(
    user_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    user = get_user(db, user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    return user


@router.post(
    "",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_user_route(
    user_data: UserCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_user(
        db,
        user_data,
        current_user_id=current_user.id,
    )


@router.patch(
    "/{user_id}",
    response_model=UserResponse,
)
def update_user_route(
    user_id: int,
    user_data: UserUpdate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_user(
        db,
        user_id,
        user_data,
        current_user_id=current_user.id,
    )


@router.delete(
    "/{user_id}",
    response_model=UserResponse,
)
def deactivate_user_route(
    user_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return deactivate_user(
        db,
        user_id,
        current_user_id=current_user.id,
    )