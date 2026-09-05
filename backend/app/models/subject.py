from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Subject(Base):
    __tablename__ = "subjects"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    code: Mapped[str] = mapped_column(
        String(30),
        unique=True,
        nullable=False,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    credits: Mapped[Decimal] = mapped_column(
        Numeric(4, 2),
        nullable=False,
    )

    semester: Mapped[int] = mapped_column(
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
        back_populates="subjects",
    )

    faculty_assignments: Mapped[list["FacultySubject"]] = relationship(
        "FacultySubject",
        back_populates="subject",
        cascade="all, delete-orphan",
    )

    attendances: Mapped[list["Attendance"]] = relationship(
        "Attendance",
        back_populates="subject",
    )