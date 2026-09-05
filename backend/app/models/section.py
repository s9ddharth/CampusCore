from __future__ import annotations

from datetime import datetime

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Section(Base):
    __tablename__ = "sections"

    __table_args__ = (
        UniqueConstraint(
            "name",
            "semester",
            "academic_year",
            "department_id",
            name="uq_section_semester_year_department",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    name: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
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

    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id", ondelete="RESTRICT"),
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

    department: Mapped["Department"] = relationship(
        "Department",
        back_populates="sections",
    )

    students: Mapped[list["Student"]] = relationship(
        "Student",
        back_populates="section",
    )

    faculty_assignments: Mapped[list["FacultySubject"]] = relationship(
        "FacultySubject",
        back_populates="section",
        cascade="all, delete-orphan",
    )