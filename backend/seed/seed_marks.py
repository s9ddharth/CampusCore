from __future__ import annotations

from decimal import Decimal

from sqlalchemy import select

from app.database import SessionLocal
from app.models import (
    Assessment,
    Mark,
    Student,
    User,
)


SEMESTER = "3"
ACADEMIC_YEAR = "2026-27"


MARKS = {
    "STU001": [48, 47, 96, 19],
    "STU002": [47, 46, 94, 19],
    "STU003": [46, 45, 92, 18],
    "STU004": [45, 44, 90, 18],
    "STU005": [44, 43, 88, 18],
    "STU006": [40, 39, 80, 16],
    "STU007": [30, 30, 70, 15],
    "STU008": [45, 42, 38, 15],
}


def seed_marks() -> None:
    db = SessionLocal()

    try:
        faculty_user = db.scalar(
            select(User).where(
                User.email == "faculty1@campuscore.in"
            )
        )

        if faculty_user is None:
            raise RuntimeError(
                "faculty1@campuscore.in not found."
            )

        assessments = db.scalars(
            select(Assessment).where(
                Assessment.name.in_(
                    ["CAT1", "CAT2", "TEE", "Internal"]
                ),
                Assessment.semester == SEMESTER,
                Assessment.academic_year == ACADEMIC_YEAR,
            )
        ).all()

        if len(assessments) != 4:
            raise RuntimeError(
                "Expected 4 assessments. "
                "Run seed_assessments first."
            )

        assessment_by_name = {
            assessment.name: assessment
            for assessment in assessments
        }

        students = db.scalars(
            select(Student).where(
                Student.roll_number.in_(list(MARKS.keys())),
                Student.is_active.is_(True),
            )
        ).all()

        found_roll_numbers = {
            student.roll_number
            for student in students
        }

        missing = set(MARKS.keys()) - found_roll_numbers

        if missing:
            raise RuntimeError(
                f"Missing students: {sorted(missing)}"
            )

        for student in students:
            values = MARKS[student.roll_number]

            assessment_order = [
                assessment_by_name["CAT1"],
                assessment_by_name["CAT2"],
                assessment_by_name["TEE"],
                assessment_by_name["Internal"],
            ]

            for assessment, marks_value in zip(
                assessment_order,
                values,
            ):
                existing = db.scalar(
                    select(Mark).where(
                        Mark.assessment_id == assessment.id,
                        Mark.student_id == student.id,
                    )
                )

                if existing is None:
                    db.add(
                        Mark(
                            assessment_id=assessment.id,
                            student_id=student.id,
                            marks=Decimal(str(marks_value)),
                            entered_by=faculty_user.id,
                        )
                    )
                else:
                    existing.marks = Decimal(
                        str(marks_value)
                    )
                    existing.entered_by = faculty_user.id

        db.commit()

        print("MARKS SEEDED")

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_marks()