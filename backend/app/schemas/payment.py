from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class PaymentCreate(BaseModel):
    student_fee_id: int = Field(gt=0)
    amount: Decimal = Field(gt=0)
    paid_on: date
    reference_no: str = Field(
        min_length=2,
        max_length=100,
    )


class PaymentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_fee_id: int
    amount: Decimal
    paid_on: date
    reference_no: str
    recorded_by: int
    created_at: datetime