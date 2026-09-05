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
from app.schemas.student import (
    StudentCreate,
    StudentResponse,
    StudentUpdate,
)
from app.security.permissions import require_admin
from app.services.student_service import (
    create_student,
    deactivate_student,
    get_student,
    list_students,
    update_student,
)


router = APIRouter(
    prefix="/api/students",
    tags=["Students"],
)


@router.get(
    "",
    response_model=list[StudentResponse],
)
def get_students(
    department_id: int | None = Query(
        default=None,
        gt=0,
    ),
    section_id: int | None = Query(
        default=None,
        gt=0,
    ),
    semester: int | None = Query(
        default=None,
        ge=1,
        le=12,
    ),
    status_value: str | None = Query(
        default=None,
        alias="status",
    ),
    search: str | None = None,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_students(
        db,
        department_id=department_id,
        section_id=section_id,
        semester=semester,
        status_value=status_value,
        search=search,
    )


@router.get(
    "/{student_id}",
    response_model=StudentResponse,
)
def get_student_by_id(
    student_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    student = get_student(
        db,
        student_id,
    )

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    return student


@router.post(
    "",
    response_model=StudentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_student_route(
    student_data: StudentCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_student(
        db,
        student_data,
        current_user_id=current_user.id,
    )


@router.patch(
    "/{student_id}",
    response_model=StudentResponse,
)
def update_student_route(
    student_id: int,
    student_data: StudentUpdate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_student(
        db,
        student_id,
        student_data,
        current_user_id=current_user.id,
    )


@router.delete(
    "/{student_id}",
    response_model=StudentResponse,
)
def deactivate_student_route(
    student_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return deactivate_student(
        db,
        student_id,
        current_user_id=current_user.id,
    )