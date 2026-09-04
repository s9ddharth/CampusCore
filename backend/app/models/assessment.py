from __future__ import annotations

from datetime import date, datetime
from enum import Enum

from sqlalchemy import Date, Enum as SQLEnum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class AssessmentType(str, Enum):
    CAT1 = "CAT1"
    CAT2 = "CAT2"
    TEE = "TEE"
    INTERNAL = "INTERNAL"
    OTHER = "OTHER"


class AssessmentStatus(str, Enum):
    DRAFT = "DRAFT"
    OPEN = "OPEN"
    LOCKED = "LOCKED"
    FINALIZED = "FINALIZED"


class Assessment(Base):
    __tablename__ = "assessments"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    section_id: Mapped[int] = mapped_column(
        ForeignKey("sections.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    assessment_type: Mapped[AssessmentType] = mapped_column(
        SQLEnum(AssessmentType),
        nullable=False,
        index=True,
    )

    max_marks: Mapped[int] = mapped_column(
        nullable=False,
    )

    assessment_date: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
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

    status: Mapped[AssessmentStatus] = mapped_column(
        SQLEnum(AssessmentStatus),
        default=AssessmentStatus.DRAFT,
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

    subject: Mapped["Subject"] = relationship(
        "Subject",
    )

    section: Mapped["Section"] = relationship(
        "Section",
    )

    marks: Mapped[list["Mark"]] = relationship(
        "Mark",
        back_populates="assessment",
        cascade="all, delete-orphan",
    )