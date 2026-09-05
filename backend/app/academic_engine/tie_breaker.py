from typing import List
from .types import StudentScoreInput

def resolve_ties(candidates: List[StudentScoreInput]) -> List[StudentScoreInput]:
    """
    Resolves ties among identical normalized scores using multi-level criteria:
    1. Higher TEE Score
    2. Higher CAT Score
    3. Higher Attendance Percentage
    """
    return sorted(
        candidates,
        key=lambda s: (s.tee_score, s.cat_score, s.attendance_pct),
        reverse=True
    )