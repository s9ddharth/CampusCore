from __future__ import annotations

from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.attendance import AttendanceStatus


class AttendanceCreate(BaseModel):
    student_id: int = Field(gt=0)
    subject_id: int = Field(gt=0)
    date: date
    status: AttendanceStatus


class AttendanceUpdate(BaseModel):
    status: AttendanceStatus


class AttendanceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    subject_id: int
    date: date
    status: AttendanceStatus
    marked_by: int
    created_at: datetime
    updated_at: datetime


class BulkAttendanceItem(BaseModel):
    student_id: int = Field(gt=0)
    status: AttendanceStatus


class BulkAttendanceCreate(BaseModel):
    subject_id: int = Field(gt=0)
    section_id: int = Field(gt=0)
    date: date
    records: list[BulkAttendanceItem] = Field(
        min_length=1,
    )