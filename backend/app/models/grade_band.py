from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class GradeBand(Base):
    __tablename__ = "grade_bands"

    id = Column(Integer, primary_key=True, index=True)
    policy_id = Column(Integer, ForeignKey("grade_policies.id"), nullable=False)
    grade = Column(String(5), nullable=False)  # e.g., "S", "A", "B", "C", "D", "E", "F"
    min_normalized = Column(Float, nullable=False)
    max_normalized = Column(Float, nullable=False)
    grade_point = Column(Integer, nullable=False)

    # Relationships
    policy = relationship("GradePolicy", back_populates="grade_bands")