from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.subject import (
    SubjectCreate,
    SubjectResponse,
    SubjectUpdate,
)
from app.security.permissions import require_admin
from app.services.subject_service import (
    create_subject,
    delete_subject,
    get_subject,
    list_subjects,
    update_subject,
)


router = APIRouter(
    prefix="/api/subjects",
    tags=["Subjects"],
)


@router.get(
    "",
    response_model=list[SubjectResponse],
)
def get_subjects(
    department_id: int | None = Query(default=None, gt=0),
    semester: int | None = Query(default=None, ge=1, le=12),
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_subjects(
        db,
        department_id=department_id,
        semester=semester,
    )


@router.get(
    "/{subject_id}",
    response_model=SubjectResponse,
)
def get_subject_by_id(
    subject_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    subject = get_subject(db, subject_id)

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    return subject


@router.post(
    "",
    response_model=SubjectResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_subject_route(
    subject_data: SubjectCreate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_subject(db, subject_data)


@router.patch(
    "/{subject_id}",
    response_model=SubjectResponse,
)
def update_subject_route(
    subject_id: int,
    subject_data: SubjectUpdate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_subject(
        db,
        subject_id,
        subject_data,
    )


@router.delete(
    "/{subject_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_subject_route(
    subject_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    delete_subject(db, subject_id)