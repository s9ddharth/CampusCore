import numpy as np
from typing import Dict, List
from .types import StudentScoreInput

def normalize_cohort_scores(scores: List[StudentScoreInput]) -> Dict[int, float]:
    """
    Normalizes raw totals across a cohort using mean and standard deviation.
    Formula: Normalized = 50 + 10 * ((Raw - Mean) / StdDev)
    Clamped strictly to [0.0, 100.0] range.
    """
    raw_totals = [s.cat_score + s.da_score + s.tee_score for s in scores]
    
    mean = float(np.mean(raw_totals))
    std_dev = float(np.std(raw_totals)) if float(np.std(raw_totals)) > 0 else 1.0

    normalized_map = {}
    for student in scores:
        raw = student.cat_score + student.da_score + student.tee_score
        z_score = (raw - mean) / std_dev
        norm_score = round(min(100.0, max(0.0, 50.0 + (10.0 * z_score))), 2)
        normalized_map[student.student_id] = norm_score

    return normalized_map