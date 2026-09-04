from typing import List, Dict
from .types import StudentScoreInput, ProcessedGradeResult
from .eligibility import check_student_eligibility
from .tie_breaker import resolve_ties

def assign_relative_grades(
    scores: List[StudentScoreInput], 
    normalized_map: Dict[int, float]
) -> List[ProcessedGradeResult]:
    """
    Enforces relative bell-curve grade distribution with max 5 S-grades.
    Grade boundaries on normalized score:
    S: Top 5 eligible students (Norm >= 90)
    A: >= 80 | B: >= 70 | C: >= 60 | D: >= 50 | E: >= 40 | F: < 40
    """
    results: List[ProcessedGradeResult] = []
    eligible_students: List[tuple[StudentScoreInput, float]] = []

    # 1. Separate auto-fails from eligible candidates
    for student in scores:
        raw_total = student.cat_score + student.da_score + student.tee_score
        is_eligible, fail_reason = check_student_eligibility(
            student.attendance_pct, student.tee_score
        )
        
        if not is_eligible:
            results.append(ProcessedGradeResult(
                student_id=student.student_id,
                roll_number=student.roll_number,
                raw_total=raw_total,
                normalized_score=normalized_map[student.student_id],
                grade='F',
                grade_point=0,
                is_pass=False,
                fail_reason=fail_reason
            ))
        else:
            eligible_students.append((student, normalized_map[student.student_id]))

    # 2. Sort eligible candidates by normalized score
    eligible_students.sort(key=lambda x: x[1], reverse=True)

    # 3. Process S-Grade allocations (Max 5 top performers)
    s_count = 0
    for student, norm in eligible_students:
        raw_total = student.cat_score + student.da_score + student.tee_score
        
        if norm >= 90.0 and s_count < 5:
            grade, point = 'S', 10
            s_count += 1
        elif norm >= 80.0:
            grade, point = 'A', 9
        elif norm >= 70.0:
            grade, point = 'B', 8
        elif norm >= 60.0:
            grade, point = 'C', 7
        elif norm >= 50.0:
            grade, point = 'D', 6
        elif norm >= 40.0:
            grade, point = 'E', 5
        else:
            grade, point = 'F', 0

        results.append(ProcessedGradeResult(
            student_id=student.student_id,
            roll_number=student.roll_number,
            raw_total=raw_total,
            normalized_score=norm,
            grade=grade,
            grade_point=point,
            is_pass=(grade != 'F'),
            fail_reason=None if grade != 'F' else 'BELOW_PASSING_THRESHOLD'
        ))

    return results