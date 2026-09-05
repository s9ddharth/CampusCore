from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class SubjectBase(BaseModel):
    code: str = Field(min_length=2, max_length=30)
    name: str = Field(min_length=2, max_length=150)
    credits: Decimal = Field(gt=0, le=20)
    semester: int = Field(ge=1, le=12)
    department_id: int = Field(gt=0)


class SubjectCreate(SubjectBase):
    pass


class SubjectUpdate(BaseModel):
    code: str | None = Field(
        default=None,
        min_length=2,
        max_length=30,
    )
    name: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )
    credits: Decimal | None = Field(
        default=None,
        gt=0,
        le=20,
    )
    semester: int | None = Field(
        default=None,
        ge=1,
        le=12,
    )
    department_id: int | None = Field(
        default=None,
        gt=0,
    )


class SubjectResponse(SubjectBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime