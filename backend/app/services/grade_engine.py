from __future__ import annotations

from decimal import Decimal, ROUND_HALF_UP
from typing import Iterable

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import (
    Assessment,
    AssessmentType,
    GradeBand,
    GradePolicy,
    Mark,
    Student,
    StudentResult,
)


ZERO = Decimal("0")
TWO_PLACES = Decimal("0.01")


def to_decimal(value) -> Decimal:
    if value is None:
        return ZERO

    if isinstance(value, Decimal):
        return value

    return Decimal(str(value))


def money_decimal(value: Decimal) -> Decimal:
    return value.quantize(
        TWO_PLACES,
        rounding=ROUND_HALF_UP,
    )


# =========================================================
# NORMALIZATION
# =========================================================

def normalize_score(
    raw_total: Decimal,
    raw_scale: Decimal,
    policy: GradePolicy,
) -> Decimal:
    raw_total = to_decimal(raw_total)
    raw_scale = to_decimal(raw_scale)
    target_scale = to_decimal(policy.total_scale)

    if raw_scale <= ZERO:
        raise ValueError(
            "Raw assessment scale must be greater than zero."
        )

    if target_scale <= ZERO:
        raise ValueError(
            "Policy total scale must be greater than zero."
        )

    normalized = (
        raw_total / raw_scale
    ) * target_scale

    return money_decimal(normalized)


# =========================================================
# ELIGIBILITY
# =========================================================

def is_tee_pass(
    tee_score: Decimal,
    policy: GradePolicy,
) -> bool:
    return (
        to_decimal(tee_score)
        >= to_decimal(policy.tee_pass_mark)
    )


def is_qualifying(
    normalized_score: Decimal,
    policy: GradePolicy,
) -> bool:
    return (
        to_decimal(normalized_score)
        >= to_decimal(policy.qualifying_threshold)
    )


def is_eligible(
    normalized_score: Decimal,
    tee_score: Decimal,
    policy: GradePolicy,
) -> bool:
    return (
        is_tee_pass(tee_score, policy)
        and is_qualifying(normalized_score, policy)
    )


# =========================================================
# ABSOLUTE GRADE BANDS
# =========================================================

def get_grade_band(
    normalized_score: Decimal,
    bands: Iterable[GradeBand],
) -> GradeBand | None:
    score = to_decimal(normalized_score)

    ordered_bands = sorted(
        bands,
        key=lambda band: to_decimal(
            band.minimum_score
        ),
        reverse=True,
    )

    for band in ordered_bands:
        minimum = to_decimal(
            band.minimum_score
        )
        maximum = to_decimal(
            band.maximum_score
        )

        if minimum <= score <= maximum:
            return band

    return None


def calculate_absolute_grade(
    normalized_score: Decimal,
    tee_score: Decimal,
    policy: GradePolicy,
    grade_bands: Iterable[GradeBand],
) -> tuple[str, Decimal]:
    if not is_eligible(
        normalized_score,
        tee_score,
        policy,
    ):
        return "F", ZERO

    band = get_grade_band(
        normalized_score,
        grade_bands,
    )

    if band is None:
        return "F", ZERO

    return (
        str(band.grade),
        to_decimal(band.grade_point),
    )


# =========================================================
# RELATIVE RANKING
# =========================================================

def rank_eligible_students(
    results: list[dict],
) -> list[dict]:
    eligible = [
        result
        for result in results
        if result["eligible"]
    ]

    eligible.sort(
        key=lambda result: (
            -to_decimal(
                result["normalized_score"]
            ),
            -to_decimal(
                result["tee_score"]
            ),
            -to_decimal(
                result["raw_total"]
            ),
            result["student_id"],
        )
    )

    for rank, result in enumerate(
        eligible,
        start=1,
    ):
        result["rank"] = rank

    return eligible


# =========================================================
# RELATIVE GRADING
# =========================================================

def apply_relative_grading(
    results: list[dict],
    policy: GradePolicy,
    grade_bands: Iterable[GradeBand],
) -> list[dict]:

    results = [
        dict(result)
        for result in results
    ]

    bands = list(grade_bands)

    s_band = next(
        (
            band
            for band in bands
            if str(band.grade).upper() == "S"
        ),
        None,
    )

    # -----------------------------------------------------
    # Mark F / eligible
    # -----------------------------------------------------

    eligible_results = []

    for result in results:
        result["rank"] = None

        result["eligible"] = is_eligible(
            result["normalized_score"],
            result["tee_score"],
            policy,
        )

        if not result["eligible"]:
            result["grade"] = "F"
            result["grade_point"] = ZERO
        else:
            eligible_results.append(result)

    # -----------------------------------------------------
    # Rank eligible students
    # -----------------------------------------------------

    ranked = rank_eligible_students(
        eligible_results
    )

    top_n = max(
        int(policy.top_s_count),
        0,
    )

    # -----------------------------------------------------
    # Top N -> S
    # -----------------------------------------------------

    for result in ranked[:top_n]:
        result["grade"] = "S"

        if s_band is not None:
            result["grade_point"] = to_decimal(
                s_band.grade_point
            )
        else:
            raise ValueError(
                "Grade policy must contain an S grade band."
            )

    # -----------------------------------------------------
    # Remaining eligible -> A/B/C/D/E
    # -----------------------------------------------------

    for result in ranked[top_n:]:
        grade, grade_point = calculate_absolute_grade(
            normalized_score=result["normalized_score"],
            tee_score=result["tee_score"],
            policy=policy,
            grade_bands=bands,
        )

        result["grade"] = grade
        result["grade_point"] = grade_point

    return results


# =========================================================
# COLLECT MARKS
# =========================================================

def collect_subject_marks(
    db: Session,
    subject_id: int,
    section_id: int,
    semester: int,
    academic_year: str,
) -> list[dict]:

    assessments = db.scalars(
        select(Assessment).where(
            Assessment.subject_id == subject_id,
            Assessment.section_id == section_id,
            Assessment.semester == semester,
            Assessment.academic_year == academic_year,
        )
    ).all()

    if not assessments:
        raise ValueError(
            "No assessments found for this subject, "
            "section, semester and academic year."
        )

    students = db.scalars(
        select(Student).where(
            Student.section_id == section_id,
            Student.semester == semester,
            Student.status == "ACTIVE",
        )
    ).all()

    if not students:
        raise ValueError(
            "No active students found in this section."
        )

    assessment_ids = [
        assessment.id
        for assessment in assessments
    ]

    marks = db.scalars(
        select(Mark).where(
            Mark.assessment_id.in_(
                assessment_ids
            )
        )
    ).all()

    marks_by_student: dict[
        int, dict[int, Decimal]
    ] = {}

    for mark in marks:
        marks_by_student.setdefault(
            mark.student_id,
            {},
        )

        marks_by_student[
            mark.student_id
        ][mark.assessment_id] = to_decimal(
            mark.marks
        )

    raw_scale = sum(
        (
            to_decimal(
                assessment.max_marks
            )
            for assessment in assessments
        ),
        ZERO,
    )

    results = []

    for student in students:
        student_marks = marks_by_student.get(
            student.id,
            {},
        )

        raw_total = ZERO
        tee_score = ZERO

        for assessment in assessments:
            mark = student_marks.get(
                assessment.id,
                ZERO,
            )

            raw_total += mark

            if (
                assessment.assessment_type
                == AssessmentType.TEE
            ):
                tee_score += mark

        results.append(
            {
                "student_id": student.id,
                "raw_total": money_decimal(
                    raw_total
                ),
                "raw_scale": money_decimal(
                    raw_scale
                ),
                "tee_score": money_decimal(
                    tee_score
                ),
            }
        )

    return results


# =========================================================
# BUILD SUBJECT RESULTS
# =========================================================

def build_subject_results(
    db: Session,
    subject_id: int,
    section_id: int,
    semester: int,
    academic_year: str,
    policy: GradePolicy,
) -> list[dict]:

    grade_bands = db.scalars(
        select(GradeBand)
        .where(
            GradeBand.policy_id == policy.id
        )
        .order_by(
            GradeBand.minimum_score.desc()
        )
    ).all()

    if not grade_bands:
        raise ValueError(
            "No grade bands configured for this policy."
        )

    raw_results = collect_subject_marks(
        db=db,
        subject_id=subject_id,
        section_id=section_id,
        semester=semester,
        academic_year=academic_year,
    )

    calculated = []

    for result in raw_results:
        normalized_score = normalize_score(
            raw_total=result["raw_total"],
            raw_scale=result["raw_scale"],
            policy=policy,
        )

        calculated.append(
            {
                "student_id": result["student_id"],
                "raw_total": result["raw_total"],
                "tee_score": result["tee_score"],
                "normalized_score": normalized_score,
                "eligible": is_eligible(
                    normalized_score,
                    result["tee_score"],
                    policy,
                ),
                "grade": None,
                "grade_point": ZERO,
                "rank": None,
            }
        )

    return apply_relative_grading(
        results=calculated,
        policy=policy,
        grade_bands=grade_bands,
    )


# =========================================================
# PERSIST SUBJECT RESULTS
# =========================================================

def persist_subject_results(
    db: Session,
    subject_id: int,
    semester: int,
    academic_year: str,
    policy: GradePolicy,
    calculated_results: list[dict],
) -> list[StudentResult]:

    persisted = []

    for calculated in calculated_results:
        existing = db.scalar(
            select(StudentResult).where(
                StudentResult.student_id
                == calculated["student_id"],
                StudentResult.subject_id
                == subject_id,
                StudentResult.semester
                == semester,
                StudentResult.academic_year
                == academic_year,
            )
        )

        if existing is None:
            existing = StudentResult(
                student_id=calculated["student_id"],
                subject_id=subject_id,
                policy_id=policy.id,
                semester=semester,
                academic_year=academic_year,
            )

            db.add(existing)

        existing.policy_id = policy.id
        existing.normalized_score = (
            calculated["normalized_score"]
        )
        existing.raw_total = (
            calculated["raw_total"]
        )
        existing.tee_score = (
            calculated["tee_score"]
        )
        existing.grade = calculated["grade"]
        existing.grade_point = (
            calculated["grade_point"]
        )
        existing.rank = calculated["rank"]
        existing.status = "CALCULATED"

        persisted.append(existing)

    db.flush()

    return persisted


# =========================================================
# GPA
# =========================================================

def calculate_gpa(
    results: Iterable[StudentResult],
    subject_credits: dict[int, Decimal],
) -> Decimal:

    weighted_points = ZERO
    total_credits = ZERO

    for result in results:
        credits = to_decimal(
            subject_credits.get(
                result.subject_id,
                ZERO,
            )
        )

        if credits <= ZERO:
            continue

        weighted_points += (
            credits
            * to_decimal(result.grade_point)
        )

        total_credits += credits

    if total_credits <= ZERO:
        return ZERO

    return money_decimal(
        weighted_points / total_credits
    )