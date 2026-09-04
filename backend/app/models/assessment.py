from enum import Enum as PyEnum
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class AssessmentType(str, PyEnum):
    CAT = "CAT"
    DA_QUIZ = "DA_QUIZ"
    TEE = "TEE"

class Assessment(Base):
    __tablename__ = "assessments"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)  # e.g., "CAT-1", "Assignment 1", "TEE"
    type = Column(Enum(AssessmentType), nullable=False)
    max_marks = Column(Float, nullable=False)
    weightage = Column(Float, nullable=False)  # Weightage in total calculation (%)
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    subject = relationship("Subject", back_populates="assessments")
    marks = relationship("Mark", back_populates="assessment")