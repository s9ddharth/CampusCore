from typing import List
from .types import StudentScoreInput, ProcessedGradeResult
from .normalization import normalize_cohort_scores
from .grading import assign_relative_grades
from .ranking import assign_ranks

class AcademicEngine:
    @staticmethod
    def run_cohort_evaluation(scores: List[StudentScoreInput]) -> List[ProcessedGradeResult]:
        """
        Master Pipeline Trigger:
        1. Normalizes raw cohort marks
        2. Applies attendance/TEE checks and relative S-E/F grading
        3. Computes cohort ranks
        """
        if not scores:
            return []
        
        normalized_map = normalize_cohort_scores(scores)
        graded_results = assign_relative_grades(scores, normalized_map)
        final_ranked_results = assign_ranks(graded_results)
        
        return final_ranked_results