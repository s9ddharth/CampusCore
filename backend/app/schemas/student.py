from __future__ import annotations

from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class StudentBase(BaseModel):
    roll_no: str = Field(
        min_length=2,
        max_length=50,
    )
    name: str = Field(
        min_length=2,
        max_length=150,
    )
    dob: date | None = None
    phone: str | None = Field(
        default=None,
        max_length=20,
    )
    email: EmailStr
    semester: int = Field(
        ge=1,
        le=12,
    )
    department_id: int = Field(gt=0)
    section_id: int = Field(gt=0)
    status: str = Field(
        default="ACTIVE",
        min_length=1,
        max_length=30,
    )


class StudentCreate(StudentBase):
    user_id: int = Field(gt=0)


class StudentUpdate(BaseModel):
    roll_no: str | None = Field(
        default=None,
        min_length=2,
        max_length=50,
    )
    name: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )
    dob: date | None = None
    phone: str | None = Field(
        default=None,
        max_length=20,
    )
    email: EmailStr | None = None
    semester: int | None = Field(
        default=None,
        ge=1,
        le=12,
    )
    department_id: int | None = Field(
        default=None,
        gt=0,
    )
    section_id: int | None = Field(
        default=None,
        gt=0,
    )
    status: str | None = Field(
        default=None,
        min_length=1,
        max_length=30,
    )


class StudentResponse(StudentBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime