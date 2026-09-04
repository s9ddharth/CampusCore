from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class FacultyBase(BaseModel):
    employee_id: str = Field(
        min_length=2,
        max_length=50,
    )
    name: str = Field(
        min_length=2,
        max_length=150,
    )
    phone: str | None = Field(
        default=None,
        max_length=20,
    )
    department_id: int = Field(gt=0)


class FacultyCreate(FacultyBase):
    user_id: int = Field(gt=0)


class FacultyUpdate(BaseModel):
    employee_id: str | None = Field(
        default=None,
        min_length=2,
        max_length=50,
    )
    name: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )
    phone: str | None = Field(
        default=None,
        max_length=20,
    )
    department_id: int | None = Field(
        default=None,
        gt=0,
    )


class FacultyResponse(FacultyBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime