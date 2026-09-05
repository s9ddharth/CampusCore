from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class SectionBase(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    semester: int = Field(ge=1, le=12)
    academic_year: str = Field(min_length=4, max_length=20)
    department_id: int = Field(gt=0)


class SectionCreate(SectionBase):
    pass


class SectionUpdate(BaseModel):
    name: str | None = Field(
        default=None,
        min_length=1,
        max_length=50,
    )
    semester: int | None = Field(
        default=None,
        ge=1,
        le=12,
    )
    academic_year: str | None = Field(
        default=None,
        min_length=4,
        max_length=20,
    )
    department_id: int | None = Field(
        default=None,
        gt=0,
    )


class SectionResponse(SectionBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime