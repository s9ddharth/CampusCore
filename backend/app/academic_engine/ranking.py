from typing import List
from .types import ProcessedGradeResult

def assign_ranks(results: List[ProcessedGradeResult]) -> List[ProcessedGradeResult]:
    """
    Assigns sequential cohort rank to passing students sorted by normalized score.
    """
    sorted_res = sorted(results, key=lambda r: r.normalized_score, reverse=True)
    rank = 1
    for item in sorted_res:
        if item.is_pass:
            item.rank = rank
            rank += 1
        else:
            item.rank = None
    return sorted_res