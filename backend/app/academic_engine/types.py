from dataclasses import dataclass
from typing import Optional, List, Dict

@dataclass
class StudentScoreInput:
    student_id: int
    roll_number: str
    cat_score: float      # Max 50 (or weighted 30)
    da_score: float       # Digital Assignments / Quizzes (Max 20)
    tee_score: float      # Term End Exam (Max 100)
    attendance_pct: float # e.g., 78.5 for 78.5%

@dataclass
class ProcessedGradeResult:
    student_id: int
    roll_number: str
    raw_total: float
    normalized_score: float
    grade: str
    grade_point: int
    is_pass: bool
    fail_reason: Optional[str] = None
    rank: Optional[int] = None