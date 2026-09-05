from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, Integer, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class GradePolicy(Base):
    __tablename__ = "grade_policies"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    version: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    qualifying_threshold: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    total_scale: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    tee_pass_mark: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        default=Decimal("40.00"),
        nullable=False,
    )

    top_s_count: Mapped[int] = mapped_column(
        default=5,
        nullable=False,
    )

    active: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        index=True,
    )

    effective_from: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    effective_to: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow,
        nullable=False,
    )

    grade_bands: Mapped[list["GradeBand"]] = relationship(
        "GradeBand",
        back_populates="policy",
        cascade="all, delete-orphan",
    )