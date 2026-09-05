from __future__ import annotations

from datetime import datetime

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Department(Base):
    __tablename__ = "departments"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    name: Mapped[str] = mapped_column(
        String(150),
        unique=True,
        nullable=False,
    )

    code: Mapped[str] = mapped_column(
        String(30),
        unique=True,
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

    students: Mapped[list["Student"]] = relationship(
        "Student",
        back_populates="department",
    )

    faculty: Mapped[list["Faculty"]] = relationship(
        "Faculty",
        back_populates="department",
    )

    subjects: Mapped[list["Subject"]] = relationship(
        "Subject",
        back_populates="department",
    )

    sections: Mapped[list["Section"]] = relationship(
        "Section",
        back_populates="department",
    )

    fee_structures: Mapped[list["FeeStructure"]] = relationship(
        "FeeStructure",
        back_populates="department",
        cascade="all, delete-orphan",
    )