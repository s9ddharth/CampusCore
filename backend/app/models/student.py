from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Student(Base):
    __tablename__ = "students"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    roll_number = Column(String(50), unique=True, nullable=False, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    section_id = Column(Integer, ForeignKey("sections.id"), nullable=True)
    current_semester = Column(Integer, default=1)
    batch_year = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="student")
    department = relationship("Department", back_populates="students")
    section = relationship("Section", back_populates="students")
    marks = relationship("Mark", back_populates="student")
    attendances = relationship("Attendance", back_populates="student")
    student_fees = relationship("StudentFee", back_populates="student")
    academic_results = relationship("AcademicResult", back_populates="student")
    student_results = relationship("StudentResult", back_populates="student")
    semester_results = relationship("SemesterResult", back_populates="student")