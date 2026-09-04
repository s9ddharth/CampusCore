# backend/app/models/grade_policy.py
import enum
from datetime import datetime
from sqlalchemy import String, Integer, Float, Boolean, ForeignKey, Enum, DateTime, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base

class GradeBandMethod(str, enum.Enum):
    ABSOLUTE = "ABSOLUTE"
    PERCENTILE = "PERCENTILE"

class GradePolicy(Base):
    __tablename__ = "grade_policies"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    version: Mapped[str] = mapped_column(String(50), unique=True, index=True) # e.g., "2026.1-CSE"
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    
    # Thresholds and baselines
    normalized_scale: Mapped[float] = mapped_column(Float, default=100.0) # Scale to normalize against
    min_tee_pass_score: Mapped[float] = mapped_column(Float, default=40.0) # Rule 3: F if TEE < 40
    min_qualifying_total: Mapped[float] = mapped_column(Float, default=40.0) # Configurable threshold
    top_s_count: Mapped[int] = mapped_column(Integer, default=5) # Top N get S
    
    bands: Mapped[list["GradeBand"]] = relationship("GradeBand", back_populates="policy", cascade="all, delete-orphan")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class GradeBand(Base):
    __tablename__ = "grade_bands"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    policy_id: Mapped[int] = mapped_column(Integer, ForeignKey("grade_policies.id"), nullable=False)
    grade: Mapped[str] = mapped_column(String(5), nullable=False) # "A", "B", "C", "D", "E", "F", "S"
    min_score: Mapped[float] = mapped_column(Float, nullable=False) # Normalized lower bound
    max_score: Mapped[float] = mapped_column(Float, nullable=False) # Normalized upper bound
    grade_point: Mapped[float] = mapped_column(Float, nullable=False) # e.g., S=10, A=9, B=8...
    
    policy: Mapped["GradePolicy"] = relationship("GradePolicy", back_populates="bands")