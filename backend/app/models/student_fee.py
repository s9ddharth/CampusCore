from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from enum import Enum

from sqlalchemy import Enum as SQLEnum, ForeignKey, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class FeeStatus(str, Enum):
    PENDING = "PENDING"
    PARTIAL = "PARTIAL"
    PAID = "PAID"
    OVERDUE = "OVERDUE"


class StudentFee(Base):
    __tablename__ = "student_fees"

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "fee_structure_id",
            name="uq_student_fee_structure",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    fee_structure_id: Mapped[int] = mapped_column(
        ForeignKey("fee_structures.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    amount_due: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )

    amount_paid: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        default=0,
        nullable=False,
    )

    status: Mapped[FeeStatus] = mapped_column(
        SQLEnum(FeeStatus),
        default=FeeStatus.PENDING,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow,
        nullable=False,
    )

    updated_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
    )

    student: Mapped["Student"] = relationship(
        "Student",
        back_populates="student_fees",
    )

    fee_structure: Mapped["FeeStructure"] = relationship(
        "FeeStructure",
        back_populates="student_fees",
    )

    payments: Mapped[list["Payment"]] = relationship(
        "Payment",
        back_populates="student_fee",
        cascade="all, delete-orphan",
    )