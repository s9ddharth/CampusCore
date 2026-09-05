from typing import List

def calculate_gpa(grade_points: List[int], course_credits: List[int]) -> float:
    """
    Calculates Semester GPA: Sum(Grade Point * Credits) / Sum(Credits)
    """
    if not course_credits or sum(course_credits) == 0:
        return 0.0
    
    total_points = sum(gp * cr for gp, cr in zip(grade_points, course_credits))
    return round(total_points / sum(course_credits), 2)