from __future__ import annotations

from datetime import datetime

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class FacultySubject(Base):
    __tablename__ = "faculty_subjects"

    __table_args__ = (
        UniqueConstraint(
            "faculty_id",
            "subject_id",
            "section_id",
            name="uq_faculty_subject_section",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    faculty_id: Mapped[int] = mapped_column(
        ForeignKey("faculty.id", ondelete="CASCADE"),
        nullable=False,
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

    created_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow,
        nullable=False,
    )

    faculty: Mapped["Faculty"] = relationship(
        "Faculty",
        back_populates="assignments",
    )

    subject: Mapped["Subject"] = relationship(
        "Subject",
        back_populates="faculty_assignments",
    )

    section: Mapped["Section"] = relationship(
        "Section",
        back_populates="faculty_assignments",
    )