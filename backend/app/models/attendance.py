from sqlalchemy import Column, Integer, Float, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Attendance(Base):
    __tablename__ = "attendances"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=False)
    section_id = Column(Integer, ForeignKey("sections.id"), nullable=False)
    classes_attended = Column(Integer, default=0, nullable=False)
    total_classes = Column(Integer, default=0, nullable=False)
    attendance_percentage = Column(Float, default=0.0, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (UniqueConstraint('student_id', 'subject_id', name='_student_subject_attendance_uc'),)

    # Relationships
    student = relationship("Student", back_populates="attendances")
    subject = relationship("Subject", back_populates="attendances")
    section = relationship("Section", back_populates="attendances")