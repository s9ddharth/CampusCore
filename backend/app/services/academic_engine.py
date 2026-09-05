from __future__ import annotations

from decimal import Decimal
from typing import Any

from sqlalchemy.orm import Session

from app.database.models import (
    Assessment,
    GradeBand,
    GradePolicy,
    Mark,
    SemesterResult,
    Student,
    StudentResult,
    Subject,
)


class AcademicEngine:
    """
    Backend-authoritative academic evaluation engine for PS-6 ERP.

    Rules:
    - Marks are validated against assessment maximums.
    - Missing required assessments produce INCOMPLETE and are not graded.
    - TEE < pass_tee_min => F.
    - Qualifying score < pass_total_min => F.
    - Failed students are excluded from relative S-grade ranking.
    - Top N eligible students receive S.
    - Remaining eligible students receive configurable A-E bands.
    - GPA/SGPA/CGPA are credit-weighted.
    """

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _as_float(value: Any) -> float:
        """
        Safely convert SQLAlchemy Numeric values / ints / floats to float
        for calculations and API responses.
        """
        if value is None:
            return 0.0

        if isinstance(value, Decimal):
            return float(value)

        return float(value)

    @staticmethod
    def _active_policy(db: Session) -> GradePolicy | None:
        """
        There is no 'active' column in the SQL schema.

        We therefore treat the newest policy as the current policy.
        Historical policies remain stored and results preserve policy_id.
        """
        return (
            db.query(GradePolicy)
            .order_by(
                GradePolicy.version.desc(),
                GradePolicy.id.desc(),
            )
            .first()
        )

    @staticmethod
    def _normalize_to_scale(
        raw_total: float,
        max_total: float,
        qualifying_scale: float,
    ) -> float:
        """
        Normalize the raw assessment total to the configured qualifying scale.

        Example:
            raw total = 88
            raw maximum = 220
            qualifying scale = 200

            normalized = 88 / 220 * 200
        """
        if max_total <= 0:
            raise ValueError("Assessment maximum total must be greater than zero")

        if qualifying_scale <= 0:
            raise ValueError("Qualifying scale must be greater than zero")

        return (raw_total / max_total) * qualifying_scale

    @staticmethod
    def _find_band(
        bands: list[GradeBand],
        score: float,
    ) -> GradeBand | None:
        """
        Find an A-E grade band containing the normalized score.
        S is assigned separately through relative ranking.
        """
        for band in bands:
            if band.grade.upper() == "S":
                continue

            min_score = (
                float(band.min_score)
                if band.min_score is not None
                else float("-inf")
            )

            max_score = (
                float(band.max_score)
                if band.max_score is not None
                else float("inf")
            )

            if min_score <= score <= max_score:
                return band

        return None

    @staticmethod
    def _s_band(
        bands: list[GradeBand],
    ) -> GradeBand | None:
        for band in bands:
            if band.grade.upper() == "S":
                return band
        return None

    # ------------------------------------------------------------------
    # Subject evaluation
    # ------------------------------------------------------------------

    @staticmethod
    def calculate_subject_results(
        db: Session,
        subject_id: int,
        actor_user_id: int,
    ) -> dict[str, Any]:
        """
        Calculate and persist results for every active student taking the
        selected subject.

        The calculation is entirely backend-side.
        """

        subject = db.get(Subject, subject_id)

        if subject is None:
            raise ValueError("Subject not found")

        policy = AcademicEngine._active_policy(db)

        if policy is None:
            raise ValueError("No grading policy configured")

        assessments = (
            db.query(Assessment)
            .filter(Assessment.subject_id == subject_id)
            .order_by(Assessment.sequence.asc(), Assessment.id.asc())
            .all()
        )

        if not assessments:
            raise ValueError(
                "No assessments configured for this subject"
            )

        bands = (
            db.query(GradeBand)
            .filter(GradeBand.policy_id == policy.id)
            .order_by(GradeBand.id.asc())
            .all()
        )

        if not bands:
            raise ValueError(
                "No grade bands configured for the current grading policy"
            )

        s_band = AcademicEngine._s_band(bands)

        if s_band is None:
            raise ValueError(
                "Current grading policy has no S grade band"
            )

        students = (
            db.query(Student)
            .filter(Student.status.in_(["ACTIVE", "active"]))
            .order_by(Student.roll_no.asc())
            .all()
        )

        evaluation_rows: list[dict[str, Any]] = []

        assessment_ids = {assessment.id for assessment in assessments}

        # --------------------------------------------------------------
        # Evaluate every student
        # --------------------------------------------------------------

        for student in students:
            mark_rows = (
                db.query(Mark)
                .filter(
                    Mark.student_id == student.id,
                    Mark.subject_id == subject_id,
                    Mark.assessment_id.in_(assessment_ids),
                )
                .all()
            )

            marks_by_assessment = {
                mark.assessment_id: mark
                for mark in mark_rows
            }

            # ----------------------------------------------------------
            # Missing required assessment
            # ----------------------------------------------------------

            missing_assessments = [
                assessment.name
                for assessment in assessments
                if assessment.id not in marks_by_assessment
            ]

            if missing_assessments:
                evaluation_rows.append(
                    {
                        "student": student,
                        "tee": 0.0,
                        "raw_total": 0.0,
                        "max_total": sum(
                            AcademicEngine._as_float(a.max_marks)
                            for a in assessments
                        ),
                        "qualifying": 0.0,
                        "status": "INCOMPLETE",
                        "missing_assessments": missing_assessments,
                    }
                )
                continue

            # ----------------------------------------------------------
            # Validate and collect marks
            # ----------------------------------------------------------

            raw_total = 0.0
            max_total = 0.0
            tee_marks: float | None = None

            for assessment in assessments:
                mark = marks_by_assessment[assessment.id]

                score = AcademicEngine._as_float(mark.marks)
                maximum = AcademicEngine._as_float(assessment.max_marks)

                if score < 0:
                    raise ValueError(
                        f"Marks cannot be negative for "
                        f"{student.roll_no} / {assessment.name}"
                    )

                if score > maximum:
                    raise ValueError(
                        f"Invalid marks for "
                        f"{student.roll_no} / {assessment.name}: "
                        f"{score} exceeds maximum {maximum}"
                    )

                raw_total += score
                max_total += maximum

                if assessment.name.strip().upper() == "TEE":
                    tee_marks = score

            # ----------------------------------------------------------
            # Normalize to configured 200-point scale
            # ----------------------------------------------------------

            qualifying_scale = AcademicEngine._as_float(
                policy.qualifying_scale
            )

            qualifying_score = AcademicEngine._normalize_to_scale(
                raw_total=raw_total,
                max_total=max_total,
                qualifying_scale=qualifying_scale,
            )

            # ----------------------------------------------------------
            # Apply mandatory F conditions
            # ----------------------------------------------------------

            pass_tee_min = AcademicEngine._as_float(
                policy.pass_tee_min
            )

            pass_total_min = AcademicEngine._as_float(
                policy.pass_total_min
            )

            # A missing TEE is treated as incomplete.
            if tee_marks is None:
                evaluation_status = "INCOMPLETE"

            elif tee_marks < pass_tee_min:
                evaluation_status = "FAIL"

            elif qualifying_score < pass_total_min:
                evaluation_status = "FAIL"

            else:
                evaluation_status = "ELIGIBLE"

            evaluation_rows.append(
                {
                    "student": student,
                    "tee": tee_marks or 0.0,
                    "raw_total": raw_total,
                    "max_total": max_total,
                    "qualifying": qualifying_score,
                    "status": evaluation_status,
                    "missing_assessments": [],
                }
            )

        # --------------------------------------------------------------
        # Relative ranking
        # --------------------------------------------------------------

        eligible = [
            row
            for row in evaluation_rows
            if row["status"] == "ELIGIBLE"
        ]

        # Deterministic tie-breaker from the blueprint:
        #
        # 1. normalized qualifying score DESC
        # 2. TEE marks DESC
        # 3. raw total DESC
        # 4. roll number ASC
        eligible.sort(
            key=lambda row: (
                -float(row["qualifying"]),
                -float(row["tee"]),
                -float(row["raw_total"]),
                str(row["student"].roll_no),
            )
        )

        top_s_count = max(
            0,
            int(policy.top_s_count),
        )

        s_student_ids = {
            row["student"].id
            for row in eligible[:top_s_count]
        }

        # --------------------------------------------------------------
        # Persist results
        # --------------------------------------------------------------

        processed_count = 0
        incomplete_count = 0
        failed_count = 0
        eligible_count = 0
        s_count = 0

        for row in evaluation_rows:
            student = row["student"]
            status_value = row["status"]

            existing = (
                db.query(StudentResult)
                .filter(
                    StudentResult.student_id == student.id,
                    StudentResult.subject_id == subject_id,
                )
                .first()
            )

            # ----------------------------------------------------------
            # INCOMPLETE
            # ----------------------------------------------------------

            if status_value == "INCOMPLETE":
                grade = "INCOMPLETE"
                grade_point = 0.0

                incomplete_count += 1

            # ----------------------------------------------------------
            # FAIL
            # ----------------------------------------------------------

            elif status_value == "FAIL":
                grade = "F"
                grade_point = 0.0

                failed_count += 1

            # ----------------------------------------------------------
            # S
            # ----------------------------------------------------------

            elif student.id in s_student_ids:
                grade = "S"
                grade_point = AcademicEngine._as_float(
                    s_band.grade_point
                )

                eligible_count += 1
                s_count += 1

            # ----------------------------------------------------------
            # A-E
            # ----------------------------------------------------------

            else:
                grade_band = AcademicEngine._find_band(
                    bands=bands,
                    score=float(row["qualifying"]),
                )

                if grade_band is None:
                    raise ValueError(
                        f"No grade band found for qualifying score "
                        f"{row['qualifying']:.2f} for student "
                        f"{student.roll_no}"
                    )

                grade = grade_band.grade
                grade_point = AcademicEngine._as_float(
                    grade_band.grade_point
                )

                eligible_count += 1

            # ----------------------------------------------------------
            # Save / update result
            # ----------------------------------------------------------

            if existing is None:
                existing = StudentResult(
                    student_id=student.id,
                    subject_id=subject_id,
                    total_score=row["qualifying"],
                    grade=grade,
                    grade_point=grade_point,
                    result_status=status_value,
                    policy_id=policy.id,
                )

                db.add(existing)

            else:
                existing.total_score = row["qualifying"]
                existing.grade = grade
                existing.grade_point = grade_point
                existing.result_status = status_value
                existing.policy_id = policy.id

            processed_count += 1

        db.commit()

        # --------------------------------------------------------------
        # Recalculate SGPA for affected students
        # --------------------------------------------------------------

        affected_students = {
            row["student"].id
            for row in evaluation_rows
        }

        for student_id in affected_students:
            AcademicEngine.recalculate_gpa(
                db,
                student_id,
                subject.semester,
            )

        # --------------------------------------------------------------
        # Return useful API response
        # --------------------------------------------------------------

        return {
            "subject_id": subject_id,
            "subject_code": subject.code,
            "subject_name": subject.name,
            "policy_id": policy.id,
            "policy_version": policy.version,
            "qualifying_scale": qualifying_scale,
            "pass_tee_min": pass_tee_min,
            "pass_total_min": pass_total_min,
            "top_s_count": top_s_count,
            "processed": processed_count,
            "eligible": eligible_count,
            "failed": failed_count,
            "incomplete": incomplete_count,
            "s_grade_count": s_count,
            "eligible_ranked": [
                {
                    "rank": index + 1,
                    "student_id": row["student"].id,
                    "roll_no": row["student"].roll_no,
                    "name": row["student"].name,
                    "tee": round(float(row["tee"]), 2),
                    "raw_total": round(
                        float(row["raw_total"]),
                        2,
                    ),
                    "score": round(
                        float(row["qualifying"]),
                        2,
                    ),
                    "grade": (
                        "S"
                        if row["student"].id in s_student_ids
                        else None
                    ),
                }
                for index, row in enumerate(eligible)
            ],
        }

    # ------------------------------------------------------------------
    # SGPA / GPA
    # ------------------------------------------------------------------

    @staticmethod
    def recalculate_gpa(
        db: Session,
        student_id: int,
        semester: int,
    ) -> dict[str, Any]:
        """
        Calculate credit-weighted SGPA for one semester.

        INCOMPLETE results are excluded from the calculation.
        """

        rows = (
            db.query(StudentResult, Subject)
            .join(
                Subject,
                Subject.id == StudentResult.subject_id,
            )
            .filter(
                StudentResult.student_id == student_id,
                Subject.semester == semester,
                StudentResult.result_status != "INCOMPLETE",
            )
            .all()
        )

        total_credits = 0.0
        weighted_points = 0.0

        for result, subject in rows:
            credits = AcademicEngine._as_float(
                subject.credits
            )

            grade_point = AcademicEngine._as_float(
                result.grade_point
            )

            total_credits += credits
            weighted_points += credits * grade_point

        sgpa = (
            round(weighted_points / total_credits, 2)
            if total_credits > 0
            else 0.0
        )

        existing = (
            db.query(SemesterResult)
            .filter(
                SemesterResult.student_id == student_id,
                SemesterResult.semester == semester,
            )
            .first()
        )

        if existing is None:
            existing = SemesterResult(
                student_id=student_id,
                semester=semester,
                sgpa=sgpa,
                total_credits=total_credits,
            )

            db.add(existing)

        else:
            existing.sgpa = sgpa
            existing.total_credits = total_credits

        db.commit()

        return {
            "student_id": student_id,
            "semester": semester,
            "sgpa": sgpa,
            "total_credits": round(
                total_credits,
                2,
            ),
        }

    # ------------------------------------------------------------------
    # CGPA
    # ------------------------------------------------------------------

    @staticmethod
    def cgpa(
        db: Session,
        student_id: int,
    ) -> float:
        """
        Calculate cumulative credit-weighted GPA across all completed
        subjects.

        CGPA = Σ(credit × grade point) / Σ(credit)
        """

        rows = (
            db.query(StudentResult, Subject)
            .join(
                Subject,
                Subject.id == StudentResult.subject_id,
            )
            .filter(
                StudentResult.student_id == student_id,
                StudentResult.result_status != "INCOMPLETE",
            )
            .all()
        )

        total_credits = 0.0
        weighted_points = 0.0

        for result, subject in rows:
            credits = AcademicEngine._as_float(
                subject.credits
            )

            grade_point = AcademicEngine._as_float(
                result.grade_point
            )

            total_credits += credits
            weighted_points += credits * grade_point

        if total_credits <= 0:
            return 0.0

        return round(
            weighted_points / total_credits,
            2,
        )