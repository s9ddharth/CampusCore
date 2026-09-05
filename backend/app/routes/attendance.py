from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.attendance import (
    AttendanceCreate,
    AttendanceResponse,
    AttendanceUpdate,
    BulkAttendanceCreate,
)
from app.security.permissions import (
    get_current_user,
    require_admin,
)
from app.services.attendance_service import (
    bulk_mark_attendance,
    get_student_attendance_summary,
    list_attendance,
    mark_attendance,
    update_attendance,
)


router = APIRouter(
    prefix="/api/attendance",
    tags=["Attendance"],
)


@router.post(
    "",
    response_model=AttendanceResponse,
    status_code=201,
)
def create_attendance(
    attendance_data: AttendanceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return mark_attendance(
        db,
        current_user,
        attendance_data,
    )


@router.post(
    "/bulk",
    response_model=list[AttendanceResponse],
    status_code=201,
)
def create_bulk_attendance(
    attendance_data: BulkAttendanceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return bulk_mark_attendance(
        db,
        current_user,
        attendance_data,
    )


@router.get(
    "",
    response_model=list[AttendanceResponse],
)
def get_attendance(
    student_id: int | None = Query(default=None, gt=0),
    subject_id: int | None = Query(default=None, gt=0),
    section_id: int | None = Query(default=None, gt=0),
    attendance_date: date | None = None,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_attendance(
        db,
        student_id=student_id,
        subject_id=subject_id,
        section_id=section_id,
        attendance_date=attendance_date,
    )


@router.get(
    "/student/{student_id}/summary",
)
def student_attendance_summary(
    student_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return get_student_attendance_summary(
        db,
        student_id,
    )


@router.patch(
    "/{attendance_id}",
    response_model=AttendanceResponse,
)
def edit_attendance(
    attendance_id: int,
    attendance_data: AttendanceUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return update_attendance(
        db,
        current_user,
        attendance_id,
        attendance_data,
    )