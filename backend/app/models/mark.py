from sqlalchemy import Column, Integer, Float, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Mark(Base):
    __tablename__ = "marks"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    assessment_id = Column(Integer, ForeignKey("assessments.id"), nullable=False)
    obtained_marks = Column(Float, nullable=False)
    submitted_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (UniqueConstraint('student_id', 'assessment_id', name='_student_assessment_uc'),)

    # Relationships
    student = relationship("Student", back_populates="marks")
    assessment = relationship("Assessment", back_populates="marks")