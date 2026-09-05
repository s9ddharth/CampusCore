from __future__ import annotations

from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class GradeBand(Base):
    __tablename__ = "grade_bands"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True,
    )

    policy_id: Mapped[int] = mapped_column(
        ForeignKey("grade_policies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    grade: Mapped[str] = mapped_column(
        String(5),
        nullable=False,
    )

    minimum_score: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    maximum_score: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )

    grade_point: Mapped[Decimal] = mapped_column(
        Numeric(4, 2),
        nullable=False,
    )

    policy: Mapped["GradePolicy"] = relationship(
        "GradePolicy",
        back_populates="grade_bands",
    )