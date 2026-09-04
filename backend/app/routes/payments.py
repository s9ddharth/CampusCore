from __future__ import annotations

from fastapi import (
    APIRouter,
    Depends,
    Query,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.payment import (
    PaymentCreate,
    PaymentResponse,
)
from app.security.permissions import require_admin
from app.services.payment_service import (
    list_payments,
    record_payment,
)


router = APIRouter(
    prefix="/api/payments",
    tags=["Payments"],
)


@router.get(
    "",
    response_model=list[PaymentResponse],
)
def get_payments(
    student_fee_id: int | None = Query(
        default=None,
        gt=0,
    ),
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_payments(
        db,
        student_fee_id=student_fee_id,
    )


@router.post(
    "",
    response_model=PaymentResponse,
    status_code=201,
)
def create_payment(
    payment_data: PaymentCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return record_payment(
        db,
        current_user,
        payment_data,
    )