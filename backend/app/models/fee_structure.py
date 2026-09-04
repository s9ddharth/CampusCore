from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class FeeStructure(Base):
    __tablename__ = "fee_structures"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(150), nullable=False)  # e.g., "Tuition Fee B.Tech 2025"
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=False)
    academic_year = Column(String(20), nullable=False)
    amount = Column(Float, nullable=False)
    due_date = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    student_fees = relationship("StudentFee", back_populates="fee_structure")