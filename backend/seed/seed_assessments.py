from __future__ import annotations

from datetime import date
from decimal import Decimal

from sqlalchemy import select

from app.database import SessionLocal
from app.models import (
    Assessment,
    AssessmentStatus,
    AssessmentType,
    Department,
    Section,
    Subject,
)


SEMESTER = "3"
ACADEMIC_YEAR = "2026-27"


def get_or_create(
    db,
    model,
    *,
    filters: dict,
    values: dict,
):
    instance = db.scalar(
        select(model).filter_by(**filters)
    )

    if instance is not None:
        return instance

    instance = model(**values)
    db.add(instance)
    db.flush()

    return instance


def seed_assessments() -> None:
    db = SessionLocal()

    try:
        department = db.scalar(
            select(Department).where(
                Department.code == "CSE"
            )
        )

        if department is None:
            raise RuntimeError(
                "CSE department not found. "
                "Run the department seed first."
            )

        section = db.scalar(
            select(Section).where(
                Section.name == "CSE-A"
            )
        )

        if section is None:
            raise RuntimeError(
                "CSE-A section not found. "
                "Run the section seed first."
            )

        subject = db.scalar(
            select(Subject).where(
                Subject.code == "CS301"
            )
        )

        if subject is None:
            raise RuntimeError(
                "CS301 subject not found. "
                "Run the subject seed first."
            )

        assessment_data = [
            {
                "name": "CAT1",
                "assessment_type": AssessmentType.CAT1,
                "max_marks": Decimal("50"),
                "assessment_date": date(2026, 8, 10),
            },
            {
                "name": "CAT2",
                "assessment_type": AssessmentType.CAT2,
                "max_marks": Decimal("50"),
                "assessment_date": date(2026, 8, 20),
            },
            {
                "name": "TEE",
                "assessment_type": AssessmentType.TEE,
                "max_marks": Decimal("100"),
                "assessment_date": date(2026, 8, 30),
            },
            {
                "name": "Internal",
                "assessment_type": AssessmentType.INTERNAL,
                "max_marks": Decimal("20"),
                "assessment_date": date(2026, 8, 25),
            },
        ]

        for item in assessment_data:
            get_or_create(
                db,
                Assessment,
                filters={
                    "subject_id": subject.id,
                    "section_id": section.id,
                    "name": item["name"],
                    "semester": SEMESTER,
                    "academic_year": ACADEMIC_YEAR,
                },
                values={
                    "subject_id": subject.id,
                    "section_id": section.id,
                    "name": item["name"],
                    "assessment_type": item["assessment_type"],
                    "max_marks": item["max_marks"],
                    "assessment_date": item["assessment_date"],
                    "semester": SEMESTER,
                    "academic_year": ACADEMIC_YEAR,
                    "status": AssessmentStatus.FINALIZED,
                },
            )

        db.commit()

        print("ASSESSMENTS SEEDED")

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_assessments()