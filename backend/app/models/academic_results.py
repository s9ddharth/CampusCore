# backend/app/models/academic_results.py
from datetime import datetime
from sqlalchemy import String, Integer, Float, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base

class StudentResult(Base):
    __tablename__ = "student_results"
    __table_args__ = (
        UniqueConstraint("student_id", "subject_id", "semester", name="uq_student_subject_sem"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    student_id: Mapped[int] = mapped_column(Integer, ForeignKey("students.id"), index=True)
    subject_id: Mapped[int] = mapped_column(Integer, ForeignKey("subjects.id"), index=True)
    semester: Mapped[int] = mapped_column(Integer, nullable=False)
    
    raw_total: Mapped[float] = mapped_column(Float, nullable=False)
    max_raw_total: Mapped[float] = mapped_column(Float, nullable=False)
    normalized_score: Mapped[float] = mapped_column(Float, nullable=False)
    tee_score: Mapped[float] = mapped_column(Float, nullable=False)
    
    grade: Mapped[str] = mapped_column(String(5), nullable=False)
    grade_point: Mapped[float] = mapped_column(Float, nullable=False)
    credits: Mapped[int] = mapped_column(Integer, nullable=False)
    is_pass: Mapped[bool] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class SemesterResult(Base):
    __tablename__ = "semester_results"
    __table_args__ = (
        UniqueConstraint("student_id", "semester", name="uq_student_sem_summary"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    student_id: Mapped[int] = mapped_column(Integer, ForeignKey("students.id"), index=True)
    semester: Mapped[int] = mapped_column(Integer, nullable=False)
    
    credits_registered: Mapped[int] = mapped_column(Integer, nullable=False)
    credits_earned: Mapped[int] = mapped_column(Integer, nullable=False)
    gpa: Mapped[float] = mapped_column(Float, nullable=False)
    cgpa: Mapped[float] = mapped_column(Float, nullable=False)
    finalized_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)