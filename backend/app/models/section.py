from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Section(Base):
    __tablename__ = "sections"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)  # e.g., "CSE-A"
    academic_year = Column(String(20), nullable=False)  # e.g., "2025-2026"
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    department = relationship("Department", back_populates="sections")
    students = relationship("Student", back_populates="section")
    faculty_allocations = relationship("FacultySubject", back_populates="section")
    attendances = relationship("Attendance", back_populates="section")