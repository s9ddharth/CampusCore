from __future__ import annotations

from datetime import date
from decimal import Decimal, ROUND_HALF_UP

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import (
    Department,
    FeeStatus,
    FeeStructure,
    Student,
    StudentFee,
)
from app.schemas.fee import (
    FeeStructureCreate,
    FeeStructureUpdate,
    StudentFeeCreate,
    StudentFeeUpdate,
)
from app.utils.audit import create_audit_log


TWOPLACES = Decimal("0.01")


def money(value: Decimal) -> Decimal:
    """
    Normalize a monetary value to two decimal places.
    """
    return Decimal(value).quantize(
        TWOPLACES,
        rounding=ROUND_HALF_UP,
    )


def get_fee_structure(
    db: Session,
    fee_structure_id: int,
) -> FeeStructure | None:
    return db.get(
        FeeStructure,
        fee_structure_id,
    )


def list_fee_structures(
    db: Session,
    department_id: int | None = None,
    semester: int | None = None,
) -> list[FeeStructure]:
    statement = select(FeeStructure)

    if department_id is not None:
        statement = statement.where(
            FeeStructure.department_id == department_id
        )

    if semester is not None:
        statement = statement.where(
            FeeStructure.semester == semester
        )

    statement = statement.order_by(
        FeeStructure.semester,
        FeeStructure.id,
    )

    return list(
        db.scalars(statement).all()
    )


def validate_department(
    db: Session,
    department_id: int,
) -> Department:
    department = db.get(
        Department,
        department_id,
    )

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Department not found.",
        )

    return department


def create_fee_structure(
    db: Session,
    fee_data: FeeStructureCreate,
    current_user_id: int | None = None,
) -> FeeStructure:
    validate_department(
        db,
        fee_data.department_id,
    )

    fee_structure = FeeStructure(
        semester=fee_data.semester,
        department_id=fee_data.department_id,
        amount=money(fee_data.amount),
        due_date=fee_data.due_date,
    )

    db.add(fee_structure)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="FEE_STRUCTURE",
        entity_id=fee_structure.id,
        new_value={
            "semester": fee_structure.semester,
            "department_id": fee_structure.department_id,
            "amount": str(fee_structure.amount),
            "due_date": str(fee_structure.due_date),
        },
    )

    db.commit()
    db.refresh(fee_structure)

    return fee_structure


def update_fee_structure(
    db: Session,
    fee_structure_id: int,
    fee_data: FeeStructureUpdate,
    current_user_id: int | None = None,
) -> FeeStructure:
    fee_structure = get_fee_structure(
        db,
        fee_structure_id,
    )

    if fee_structure is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fee structure not found.",
        )

    old_value = {
        "semester": fee_structure.semester,
        "department_id": fee_structure.department_id,
        "amount": str(fee_structure.amount),
        "due_date": str(fee_structure.due_date),
    }

    if fee_data.department_id is not None:
        validate_department(
            db,
            fee_data.department_id,
        )
        fee_structure.department_id = (
            fee_data.department_id
        )

    if fee_data.semester is not None:
        fee_structure.semester = (
            fee_data.semester
        )

    if fee_data.amount is not None:
        fee_structure.amount = money(
            fee_data.amount
        )

    if fee_data.due_date is not None:
        fee_structure.due_date = (
            fee_data.due_date
        )

    new_value = {
        "semester": fee_structure.semester,
        "department_id": fee_structure.department_id,
        "amount": str(fee_structure.amount),
        "due_date": str(fee_structure.due_date),
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="UPDATE",
        entity="FEE_STRUCTURE",
        entity_id=fee_structure.id,
        old_value=old_value,
        new_value=new_value,
    )

    db.commit()
    db.refresh(fee_structure)

    return fee_structure


def delete_fee_structure(
    db: Session,
    fee_structure_id: int,
    current_user_id: int | None = None,
) -> None:
    fee_structure = get_fee_structure(
        db,
        fee_structure_id,
    )

    if fee_structure is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fee structure not found.",
        )

    old_value = {
        "semester": fee_structure.semester,
        "department_id": fee_structure.department_id,
        "amount": str(fee_structure.amount),
        "due_date": str(fee_structure.due_date),
    }

    try:
        create_audit_log(
            db,
            user_id=current_user_id,
            action="DELETE",
            entity="FEE_STRUCTURE",
            entity_id=fee_structure.id,
            old_value=old_value,
        )

        db.delete(fee_structure)
        db.commit()

    except Exception as exc:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Fee structure cannot be deleted because "
                "it is assigned to students."
            ),
        ) from exc


def get_student_fee(
    db: Session,
    student_fee_id: int,
) -> StudentFee | None:
    return db.get(
        StudentFee,
        student_fee_id,
    )


def list_student_fees(
    db: Session,
    student_id: int | None = None,
    fee_structure_id: int | None = None,
    status_value: FeeStatus | None = None,
) -> list[StudentFee]:
    statement = select(StudentFee)

    if student_id is not None:
        statement = statement.where(
            StudentFee.student_id == student_id
        )

    if fee_structure_id is not None:
        statement = statement.where(
            StudentFee.fee_structure_id
            == fee_structure_id
        )

    if status_value is not None:
        statement = statement.where(
            StudentFee.status == status_value
        )

    statement = statement.order_by(
        StudentFee.id.desc()
    )

    return list(
        db.scalars(statement).all()
    )


def validate_student(
    db: Session,
    student_id: int,
) -> Student:
    student = db.get(
        Student,
        student_id,
    )

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    return student


def refresh_fee_status(
    fee: StudentFee,
) -> StudentFee:
    fee.amount_due = money(
        fee.amount_due
    )

    fee.amount_paid = money(
        fee.amount_paid
    )

    due_date = (
        fee.fee_structure.due_date
        if fee.fee_structure is not None
        else None
    )

    if fee.amount_paid >= fee.amount_due:
        fee.status = FeeStatus.PAID

    elif fee.amount_paid > Decimal("0.00"):
        if (
            due_date is not None
            and due_date < date.today()
        ):
            fee.status = FeeStatus.OVERDUE
        else:
            fee.status = FeeStatus.PARTIAL

    else:
        if (
            due_date is not None
            and due_date < date.today()
        ):
            fee.status = FeeStatus.OVERDUE
        else:
            fee.status = FeeStatus.PENDING

    return fee


def assign_student_fee(
    db: Session,
    fee_data: StudentFeeCreate,
    current_user_id: int | None = None,
) -> StudentFee:
    student = validate_student(
        db,
        fee_data.student_id,
    )

    fee_structure = get_fee_structure(
        db,
        fee_data.fee_structure_id,
    )

    if fee_structure is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fee structure not found.",
        )

    if (
        student.department_id
        != fee_structure.department_id
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Fee structure department does not "
                "match the student's department."
            ),
        )

    if (
        student.semester
        != fee_structure.semester
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Fee structure semester does not "
                "match the student's semester."
            ),
        )

    existing_statement = select(
        StudentFee
    ).where(
        StudentFee.student_id
        == fee_data.student_id,
        StudentFee.fee_structure_id
        == fee_data.fee_structure_id,
    )

    existing = db.scalar(
        existing_statement
    )

    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "This fee has already been assigned "
                "to the student."
            ),
        )

    student_fee = StudentFee(
        student_id=student.id,
        fee_structure_id=fee_structure.id,
        amount_due=money(
            fee_structure.amount
        ),
        amount_paid=Decimal("0.00"),
        status=FeeStatus.PENDING,
    )

    refresh_fee_status(
        student_fee
    )

    db.add(student_fee)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="STUDENT_FEE",
        entity_id=student_fee.id,
        new_value={
            "student_id": student_fee.student_id,
            "fee_structure_id": (
                student_fee.fee_structure_id
            ),
            "amount_due": str(
                student_fee.amount_due
            ),
            "amount_paid": str(
                student_fee.amount_paid
            ),
            "status": student_fee.status.value,
        },
    )

    db.commit()
    db.refresh(student_fee)

    return student_fee


def update_student_fee(
    db: Session,
    student_fee_id: int,
    fee_data: StudentFeeUpdate,
    current_user_id: int | None = None,
) -> StudentFee:
    student_fee = get_student_fee(
        db,
        student_fee_id,
    )

    if student_fee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student fee not found.",
        )

    old_value = {
        "amount_due": str(
            student_fee.amount_due
        ),
        "amount_paid": str(
            student_fee.amount_paid
        ),
        "status": student_fee.status.value,
    }

    if fee_data.amount_due is not None:
        new_amount_due = money(
            fee_data.amount_due
        )

        if (
            new_amount_due
            < student_fee.amount_paid
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    "Amount due cannot be less than "
                    "amount already paid."
                ),
            )

        student_fee.amount_due = (
            new_amount_due
        )

    # Status is calculated by the backend.
    # Do not allow clients to force an invalid state.
    refresh_fee_status(
        student_fee
    )

    new_value = {
        "amount_due": str(
            student_fee.amount_due
        ),
        "amount_paid": str(
            student_fee.amount_paid
        ),
        "status": student_fee.status.value,
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="UPDATE",
        entity="STUDENT_FEE",
        entity_id=student_fee.id,
        old_value=old_value,
        new_value=new_value,
    )

    db.commit()
    db.refresh(student_fee)

    return student_fee


def get_fee_summary(
    db: Session,
    student_fee_id: int,
) -> dict[str, object]:
    student_fee = get_student_fee(
        db,
        student_fee_id,
    )

    if student_fee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student fee not found.",
        )

    refresh_fee_status(
        student_fee
    )

    balance = money(
        student_fee.amount_due
        - student_fee.amount_paid
    )

    return {
        "student_fee_id": student_fee.id,
        "amount_due": money(
            student_fee.amount_due
        ),
        "amount_paid": money(
            student_fee.amount_paid
        ),
        "balance": max(
            balance,
            Decimal("0.00"),
        ),
        "status": student_fee.status,
        "due_date": (
            student_fee
            .fee_structure
            .due_date
        ),
    }