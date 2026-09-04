from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Subject(Base):
    __tablename__ = "subjects"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(150), nullable=False)
    credits = Column(Integer, nullable=False, default=3)
    semester = Column(Integer, nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    department = relationship("Department", back_populates="subjects")
    faculty_allocations = relationship("FacultySubject", back_populates="subject")
    assessments = relationship("Assessment", back_populates="subject")
    attendances = relationship("Attendance", back_populates="subject")
    academic_results = relationship("AcademicResult", back_populates="subject")
    student_results = relationship("StudentResult", back_populates="subject")