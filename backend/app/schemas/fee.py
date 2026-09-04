from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.student_fee import FeeStatus


class FeeStructureBase(BaseModel):
    semester: int = Field(ge=1, le=12)
    department_id: int = Field(gt=0)
    amount: Decimal = Field(gt=0)
    due_date: date


class FeeStructureCreate(FeeStructureBase):
    pass


class FeeStructureUpdate(BaseModel):
    semester: int | None = Field(
        default=None,
        ge=1,
        le=12,
    )
    department_id: int | None = Field(
        default=None,
        gt=0,
    )
    amount: Decimal | None = Field(
        default=None,
        gt=0,
    )
    due_date: date | None = None


class FeeStructureResponse(FeeStructureBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class StudentFeeCreate(BaseModel):
    student_id: int = Field(gt=0)
    fee_structure_id: int = Field(gt=0)


class StudentFeeUpdate(BaseModel):
    amount_due: Decimal | None = Field(
        default=None,
        gt=0,
    )
    status: FeeStatus | None = None


class StudentFeeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    fee_structure_id: int
    amount_due: Decimal
    amount_paid: Decimal
    status: FeeStatus
    created_at: datetime
    updated_at: datetime


class FeeSummary(BaseModel):
    student_fee_id: int
    amount_due: Decimal
    amount_paid: Decimal
    balance: Decimal
    status: FeeStatus
    due_date: date