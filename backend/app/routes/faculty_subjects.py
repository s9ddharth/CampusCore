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
from app.schemas.faculty_subject import (
    FacultySubjectCreate,
    FacultySubjectResponse,
)
from app.security.permissions import require_admin
from app.services.faculty_subject_service import (
    create_assignment,
    delete_assignment,
    get_assignment,
    list_assignments,
)


router = APIRouter(
    prefix="/api/faculty-subjects",
    tags=["Faculty Assignments"],
)


@router.get(
    "",
    response_model=list[FacultySubjectResponse],
)
def get_assignments(
    faculty_id: int | None = Query(default=None, gt=0),
    subject_id: int | None = Query(default=None, gt=0),
    section_id: int | None = Query(default=None, gt=0),
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_assignments(
        db,
        faculty_id=faculty_id,
        subject_id=subject_id,
        section_id=section_id,
    )


@router.get(
    "/{assignment_id}",
    response_model=FacultySubjectResponse,
)
def get_assignment_by_id(
    assignment_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    assignment = get_assignment(db, assignment_id)

    if assignment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found.",
        )

    return assignment


@router.post(
    "",
    response_model=FacultySubjectResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_assignment_route(
    assignment_data: FacultySubjectCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_assignment(
        db,
        assignment_data,
        current_user_id=current_user.id,
    )

@router.delete(
    "/{assignment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_assignment_route(
    assignment_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    delete_assignment(
        db,
        assignment_id,
        current_user_id=current_user.id,
    )