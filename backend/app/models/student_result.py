from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from enum import Enum

from sqlalchemy import Enum as SQLEnum, ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ResultStatus(str, Enum):
    DRAFT = "DRAFT"
    CALCULATED = "CALCULATED"
    REVIEWED = "REVIEWED"
    FINALIZED = "FINALIZED"


class StudentResult(Base):
    __tablename__ = "student_results"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    policy_id: Mapped[int] = mapped_column(
        ForeignKey("grade_policies.id", ondelete="RESTRICT"),
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

    normalized_score: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    raw_total: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    tee_score: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    grade: Mapped[str] = mapped_column(
        String(5),
        nullable=False,
        index=True,
    )

    grade_point: Mapped[Decimal] = mapped_column(
        Numeric(4, 2),
        nullable=False,
    )

    rank: Mapped[int | None] = mapped_column(
        nullable=True,
    )

    status: Mapped[ResultStatus] = mapped_column(
        SQLEnum(ResultStatus),
        default=ResultStatus.DRAFT,
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

    subject: Mapped["Subject"] = relationship(
        "Subject",
    )

    policy: Mapped["GradePolicy"] = relationship(
        "GradePolicy",
    )