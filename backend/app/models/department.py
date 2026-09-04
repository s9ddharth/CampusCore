from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Department(Base):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(20), unique=True, nullable=False, index=True)  # e.g., "CSE"
    name = Column(String(150), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    students = relationship("Student", back_populates="department")
    faculties = relationship("Faculty", back_populates="department")
    sections = relationship("Section", back_populates="department")
    subjects = relationship("Subject", back_populates="department")