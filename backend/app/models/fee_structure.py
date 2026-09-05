from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import Date, ForeignKey, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class FeeStructure(Base):
    __tablename__ = "fee_structures"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    semester: Mapped[int] = mapped_column(
        nullable=False,
        index=True,
    )

    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    amount: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )

    due_date: Mapped[date] = mapped_column(
        Date,
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

    department: Mapped["Department"] = relationship(
        "Department",
        back_populates="fee_structures",
    )

    student_fees: Mapped[list["StudentFee"]] = relationship(
        "StudentFee",
        back_populates="fee_structure",
        cascade="all, delete-orphan",
    )