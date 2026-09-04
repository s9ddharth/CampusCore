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
from app.schemas.faculty import (
    FacultyCreate,
    FacultyResponse,
    FacultyUpdate,
)
from app.security.permissions import require_admin
from app.services.faculty_service import (
    create_faculty,
    get_faculty,
    list_faculty,
    update_faculty,
)


router = APIRouter(
    prefix="/api/faculty",
    tags=["Faculty"],
)


@router.get(
    "",
    response_model=list[FacultyResponse],
)
def get_faculty_list(
    department_id: int | None = Query(default=None, gt=0),
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_faculty(
        db,
        department_id=department_id,
    )


@router.get(
    "/{faculty_id}",
    response_model=FacultyResponse,
)
def get_faculty_by_id(
    faculty_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    faculty = get_faculty(
        db,
        faculty_id,
    )

    if faculty is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found.",
        )

    return faculty


@router.post(
    "",
    response_model=FacultyResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_faculty_route(
    faculty_data: FacultyCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_faculty(
        db,
        faculty_data,
        current_user_id=current_user.id,
    )


@router.patch(
    "/{faculty_id}",
    response_model=FacultyResponse,
)
def update_faculty_route(
    faculty_id: int,
    faculty_data: FacultyUpdate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_faculty(
        db,
        faculty_id,
        faculty_data,
        current_user_id=current_user.id,
    )