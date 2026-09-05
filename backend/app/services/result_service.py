from __future__ import annotations

from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import (
    Faculty,
    FacultySubject,
    GradePolicy,
    Section,
    SemesterResult,
    Student,
    StudentResult,
    Subject,
)
from app.services.grade_engine import (
    build_subject_results,
    calculate_gpa,
    persist_subject_results,
)


# =========================================================
# HELPERS
# =========================================================

def get_policy(
    db: Session,
    policy_id: int | None = None,
) -> GradePolicy:

    if policy_id is not None:
        policy = db.scalar(
            select(GradePolicy).where(
                GradePolicy.id == policy_id
            )
        )
    else:
        policy = db.scalar(
            select(GradePolicy)
            .where(
                GradePolicy.active.is_(True)
            )
            .order_by(
                GradePolicy.id.desc()
            )
        )

    if policy is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Grade policy not found.",
        )

    return policy


def get_student_by_id(
    db: Session,
    student_id: int,
) -> Student:

    student = db.scalar(
        select(Student).where(
            Student.id == student_id
        )
    )

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    return student


def get_subject(
    db: Session,
    subject_id: int,
) -> Subject:

    subject = db.scalar(
        select(Subject).where(
            Subject.id == subject_id
        )
    )

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    return subject


def get_section(
    db: Session,
    section_id: int,
) -> Section:

    section = db.scalar(
        select(Section).where(
            Section.id == section_id
        )
    )

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    return section


def verify_faculty_subject_access(
    db: Session,
    user_id: int,
    subject_id: int,
    section_id: int,
) -> None:

    faculty = db.scalar(
        select(Faculty).where(
            Faculty.user_id == user_id
        )
    )

    if faculty is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty profile not found.",
        )

    assignment = db.scalar(
        select(FacultySubject).where(
            FacultySubject.faculty_id == faculty.id,
            FacultySubject.subject_id == subject_id,
            FacultySubject.section_id == section_id,
        )
    )

    if assignment is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "You are not assigned to this "
                "subject and section."
            ),
        )


# =========================================================
# SUBJECT RESULT CALCULATION
# =========================================================

def calculate_subject_result(
    db: Session,
    *,
    subject_id: int,
    section_id: int,
    semester: int,
    academic_year: str,
    policy_id: int | None = None,
) -> list[StudentResult]:

    subject = get_subject(
        db,
        subject_id,
    )

    section = get_section(
        db,
        section_id,
    )

    if subject.semester != semester:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Subject semester does not match "
                "the requested semester."
            ),
        )

    if section.semester != semester:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Section semester does not match "
                "the requested semester."
            ),
        )

    if subject.department_id != section.department_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Subject and section belong to "
                "different departments."
            ),
        )

    policy = get_policy(
        db,
        policy_id,
    )

    try:
        calculated_results = build_subject_results(
            db=db,
            subject_id=subject_id,
            section_id=section_id,
            semester=semester,
            academic_year=academic_year,
            policy=policy,
        )

        persisted_results = persist_subject_results(
            db=db,
            subject_id=subject_id,
            semester=semester,
            academic_year=academic_year,
            policy=policy,
            calculated_results=calculated_results,
        )

        db.commit()

        for result in persisted_results:
            db.refresh(result)

        return persisted_results

    except ValueError as exc:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc

    except Exception:
        db.rollback()
        raise


# =========================================================
# SUBJECT RESULTS
# =========================================================

def get_subject_results(
    db: Session,
    *,
    subject_id: int,
    semester: int,
    academic_year: str,
) -> list[StudentResult]:

    return list(
        db.scalars(
            select(StudentResult)
            .where(
                StudentResult.subject_id == subject_id,
                StudentResult.semester == semester,
                StudentResult.academic_year
                == academic_year,
            )
            .order_by(
                StudentResult.rank.asc()
            )
        ).all()
    )


def get_student_results(
    db: Session,
    *,
    student_id: int,
    semester: int | None = None,
    academic_year: str | None = None,
) -> list[StudentResult]:

    conditions = [
        StudentResult.student_id == student_id
    ]

    if semester is not None:
        conditions.append(
            StudentResult.semester == semester
        )

    if academic_year is not None:
        conditions.append(
            StudentResult.academic_year
            == academic_year
        )

    return list(
        db.scalars(
            select(StudentResult)
            .where(*conditions)
            .order_by(
                StudentResult.semester.asc(),
                StudentResult.subject_id.asc(),
            )
        ).all()
    )


# =========================================================
# GPA
# =========================================================

def calculate_student_gpa(
    db: Session,
    *,
    student_id: int,
    semester: int,
    academic_year: str,
) -> SemesterResult:

    get_student_by_id(
        db,
        student_id,
    )

    results = list(
        db.scalars(
            select(StudentResult)
            .where(
                StudentResult.student_id
                == student_id,
                StudentResult.semester
                == semester,
                StudentResult.academic_year
                == academic_year,
            )
        ).all()
    )

    if not results:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "No subject results found for "
                "this student."
            ),
        )

    subject_ids = {
        result.subject_id
        for result in results
    }

    subjects = db.scalars(
        select(Subject).where(
            Subject.id.in_(subject_ids)
        )
    ).all()

    subject_credits = {
        subject.id: Decimal(
            str(subject.credits)
        )
        for subject in subjects
    }

    gpa = calculate_gpa(
        results=results,
        subject_credits=subject_credits,
    )

    total_credits = sum(
        subject_credits.values(),
        Decimal("0"),
    )

    semester_result = db.scalar(
        select(SemesterResult).where(
            SemesterResult.student_id
            == student_id,
            SemesterResult.semester
            == semester,
            SemesterResult.academic_year
            == academic_year,
        )
    )

    if semester_result is None:
        semester_result = SemesterResult(
            student_id=student_id,
            semester=semester,
            academic_year=academic_year,
        )

        db.add(semester_result)

    semester_result.gpa = gpa
    semester_result.total_credits = (
        total_credits
    )
    semester_result.status = "CALCULATED"

    db.commit()
    db.refresh(semester_result)

    return semester_result


def calculate_all_student_gpas(
    db: Session,
    *,
    semester: int,
    academic_year: str,
) -> list[SemesterResult]:

    student_ids = db.scalars(
        select(
            StudentResult.student_id
        )
        .where(
            StudentResult.semester == semester,
            StudentResult.academic_year
            == academic_year,
        )
        .distinct()
    ).all()

    results = []

    for student_id in student_ids:
        results.append(
            calculate_student_gpa(
                db=db,
                student_id=student_id,
                semester=semester,
                academic_year=academic_year,
            )
        )

    return results


def get_semester_result(
    db: Session,
    *,
    student_id: int,
    semester: int,
    academic_year: str,
) -> SemesterResult | None:

    return db.scalar(
        select(SemesterResult).where(
            SemesterResult.student_id
            == student_id,
            SemesterResult.semester
            == semester,
            SemesterResult.academic_year
            == academic_year,
        )
    )


# =========================================================
# CGPA
# =========================================================

def calculate_student_cgpa(
    db: Session,
    *,
    student_id: int,
) -> dict:

    get_student_by_id(
        db,
        student_id,
    )

    results = list(
        db.scalars(
            select(StudentResult).where(
                StudentResult.student_id
                == student_id,
                StudentResult.status.in_(
                    [
                        "CALCULATED",
                        "REVIEWED",
                        "FINALIZED",
                    ]
                ),
            )
        ).all()
    )

    if not results:
        return {
            "student_id": student_id,
            "cgpa": Decimal("0.00"),
            "total_credits": Decimal("0.00"),
            "semesters_completed": 0,
        }

    subject_ids = {
        result.subject_id
        for result in results
    }

    subjects = db.scalars(
        select(Subject).where(
            Subject.id.in_(subject_ids)
        )
    ).all()

    credits_by_subject = {
        subject.id: Decimal(
            str(subject.credits)
        )
        for subject in subjects
    }

    weighted_points = Decimal("0")
    total_credits = Decimal("0")

    for result in results:
        credits = credits_by_subject.get(
            result.subject_id,
            Decimal("0"),
        )

        if credits <= Decimal("0"):
            continue

        weighted_points += (
            credits
            * Decimal(str(result.grade_point))
        )

        total_credits += credits

    if total_credits <= Decimal("0"):
        cgpa = Decimal("0.00")
    else:
        cgpa = (
            weighted_points
            / total_credits
        ).quantize(Decimal("0.01"))

    semesters = {
        (
            result.semester,
            result.academic_year,
        )
        for result in results
    }

    return {
        "student_id": student_id,
        "cgpa": cgpa,
        "total_credits": total_credits.quantize(
            Decimal("0.01")
        ),
        "semesters_completed": len(
            semesters
        ),
    }