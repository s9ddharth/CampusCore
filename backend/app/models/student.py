from __future__ import annotations

from datetime import date, datetime

from sqlalchemy import Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Student(Base):
    __tablename__ = "students"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )

    roll_no: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    dob: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
    )

    phone: Mapped[str | None] = mapped_column(
        String(20),
        nullable=True,
    )

    email: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        index=True,
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

    section_id: Mapped[int] = mapped_column(
        ForeignKey("sections.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="ACTIVE",
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

    user: Mapped["User"] = relationship(
        "User",
        back_populates="student",
    )

    department: Mapped["Department"] = relationship(
        "Department",
        back_populates="students",
    )

    section: Mapped["Section"] = relationship(
        "Section",
        back_populates="students",
    )

    attendance: Mapped[list["Attendance"]] = relationship(
        "Attendance",
        back_populates="student",
        cascade="all, delete-orphan",
    )

    student_fees: Mapped[list["StudentFee"]] = relationship(
        "StudentFee",
        back_populates="student",
        cascade="all, delete-orphan",
    )