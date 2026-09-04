def check_student_eligibility(attendance_pct: float, tee_score: float) -> tuple[bool, str | None]:
    """
    Validates institutional eligibility constraints:
    - Attendance < 75% -> Auto-fail (Shortage)
    - TEE Score < 40 -> Auto-fail (End-Sem Threshold Failure)
    """
    if attendance_pct < 75.0:
        return False, "ATTENDANCE_SHORTAGE"
    if tee_score < 40.0:
        return False, "TEE_FAILED"
    return True, None