from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class SemesterResult(Base):
    __tablename__ = "semester_results"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    semester: Mapped[int] = mapped_column(
        nullable=False,
        index=True,
    )

    academic_year: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        index=True,
    )

    gpa: Mapped[Decimal] = mapped_column(
        Numeric(4, 2),
        nullable=False,
    )

    total_credits: Mapped[Decimal] = mapped_column(
        Numeric(6, 2),
        nullable=False,
    )

    status: Mapped[str] = mapped_column(
        String(20),
        default="DRAFT",
        nullable=False,
        index=True,
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
    )