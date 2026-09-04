from __future__ import annotations

from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Payment, StudentFee, User
from app.schemas.payment import PaymentCreate
from app.services.fee_service import (
    money,
    refresh_fee_status,
)
from app.utils.audit import create_audit_log


def get_payment(
    db: Session,
    payment_id: int,
) -> Payment | None:
    return db.get(
        Payment,
        payment_id,
    )


def list_payments(
    db: Session,
    student_fee_id: int | None = None,
) -> list[Payment]:
    statement = select(Payment)

    if student_fee_id is not None:
        statement = statement.where(
            Payment.student_fee_id == student_fee_id
        )

    statement = statement.order_by(
        Payment.paid_on.desc(),
        Payment.id.desc(),
    )

    return list(
        db.scalars(statement).all()
    )


def record_payment(
    db: Session,
    current_user: User,
    payment_data: PaymentCreate,
) -> Payment:
    student_fee = db.get(
        StudentFee,
        payment_data.student_fee_id,
    )

    if student_fee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student fee not found.",
        )

    reference_no = payment_data.reference_no.strip()

    reference_statement = select(Payment).where(
        Payment.reference_no == reference_no
    )

    existing_reference = db.scalar(
        reference_statement
    )

    if existing_reference is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Payment reference number already exists.",
        )

    amount = money(payment_data.amount)
    amount_due = money(student_fee.amount_due)
    amount_paid = money(student_fee.amount_paid)

    balance = money(
        amount_due - amount_paid
    )

    if amount <= Decimal("0.00"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment amount must be greater than zero.",
        )

    if amount > balance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"Payment exceeds outstanding balance "
                f"of {balance:.2f}."
            ),
        )

    payment = Payment(
        student_fee_id=student_fee.id,
        amount=amount,
        paid_on=payment_data.paid_on,
        reference_no=reference_no,
        recorded_by=current_user.id,
    )

    student_fee.amount_paid = money(
        student_fee.amount_paid + amount
    )

    db.add(payment)

    refresh_fee_status(
        student_fee
    )

    db.flush()

    create_audit_log(
        db,
        user_id=current_user.id,
        action="CREATE",
        entity="PAYMENT",
        entity_id=payment.id,
        new_value={
            "student_fee_id": payment.student_fee_id,
            "amount": str(payment.amount),
            "paid_on": str(payment.paid_on),
            "reference_no": payment.reference_no,
            "recorded_by": payment.recorded_by,
            "new_amount_paid": str(
                student_fee.amount_paid
            ),
            "new_status": student_fee.status.value,
        },
    )

    db.commit()
    db.refresh(payment)

    return payment