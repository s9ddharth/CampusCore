from enum import Enum as PyEnum
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class PaymentMode(str, PyEnum):
    CASH = "CASH"
    CARD = "CARD"
    UPI = "UPI"
    NET_BANKING = "NET_BANKING"
    CHEQUE = "CHEQUE"

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    student_fee_id = Column(Integer, ForeignKey("student_fees.id"), nullable=False)
    amount_paid = Column(Float, nullable=False)
    transaction_reference = Column(String(100), unique=True, nullable=False)
    payment_mode = Column(Enum(PaymentMode), nullable=False)
    payment_date = Column(DateTime, default=datetime.utcnow)

    # Relationships
    student_fee = relationship("StudentFee", back_populates="payments")