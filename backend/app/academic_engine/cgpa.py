from typing import List

def calculate_cgpa(semester_gpas: List[float], semester_credits: List[int]) -> float:
    """
    Calculates Cumulative CGPA across all completed semesters.
    """
    if not semester_credits or sum(semester_credits) == 0:
        return 0.0
    
    weighted_gpa = sum(gpa * cr for gpa, cr in zip(semester_gpas, semester_credits))
    return round(weighted_gpa / sum(semester_credits), 2)