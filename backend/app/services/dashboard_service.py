from __future__ import annotations

from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import (
    Department,
    Faculty,
    FacultySubject,
    GradePolicy,
    Section,
    SemesterResult,
    Student,
    StudentResult,
    Subject,
    User,
)

from app.services.result_service import (
    calculate_student_cgpa,
)


def get_admin_dashboard(
    db: Session,
) -> dict:

    return {
        "total_users": db.scalar(
            select(func.count(User.id))
        ) or 0,

        "total_students": db.scalar(
            select(func.count(Student.id))
        ) or 0,

        "total_faculty": db.scalar(
            select(func.count(Faculty.id))
        ) or 0,

        "total_departments": db.scalar(
            select(func.count(Department.id))
        ) or 0,

        "total_sections": db.scalar(
            select(func.count(Section.id))
        ) or 0,

        "total_subjects": db.scalar(
            select(func.count(Subject.id))
        ) or 0,
    }


def get_faculty_dashboard(
    db: Session,
    user_id: int,
) -> dict:

    faculty = db.scalar(
        select(Faculty).where(
            Faculty.user_id == user_id
        )
    )

    if faculty is None:
        return {
            "faculty_id": 0,
            "assigned_subjects": 0,
            "assigned_sections": 0,
            "total_students": 0,
        }

    assignments = db.scalars(
        select(FacultySubject).where(
            FacultySubject.faculty_id
            == faculty.id
        )
    ).all()

    subject_ids = {
        assignment.subject_id
        for assignment in assignments
    }

    section_ids = {
        assignment.section_id
        for assignment in assignments
    }

    total_students = 0

    if section_ids:
        total_students = db.scalar(
            select(func.count(Student.id))
            .where(
                Student.section_id.in_(
                    section_ids
                ),
                Student.status == "ACTIVE",
            )
        ) or 0

    return {
        "faculty_id": faculty.id,
        "assigned_subjects": len(subject_ids),
        "assigned_sections": len(section_ids),
        "total_students": total_students,
    }


def get_student_dashboard(
    db: Session,
    user_id: int,
) -> dict:

    student = db.scalar(
        select(Student).where(
            Student.user_id == user_id
        )
    )

    if student is None:
        return {
            "student_id": 0,
            "roll_no": "",
            "name": "",
            "semester": 0,
            "department_id": 0,
            "section_id": 0,
            "total_results": 0,
            "latest_gpa": None,
            "cgpa": Decimal("0.00"),
            "total_credits": Decimal("0.00"),
        }

    total_results = db.scalar(
        select(func.count(StudentResult.id))
        .where(
            StudentResult.student_id
            == student.id
        )
    ) or 0

    latest_semester = db.scalar(
        select(SemesterResult)
        .where(
            SemesterResult.student_id
            == student.id
        )
        .order_by(
            SemesterResult.semester.desc(),
            SemesterResult.id.desc(),
        )
        .limit(1)
    )

    cgpa_data = calculate_student_cgpa(
        db=db,
        student_id=student.id,
    )

    return {
        "student_id": student.id,
        "roll_no": student.roll_no,
        "name": student.name,
        "semester": student.semester,
        "department_id": student.department_id,
        "section_id": student.section_id,
        "total_results": total_results,
        "latest_gpa": (
            latest_semester.gpa
            if latest_semester is not None
            else None
        ),
        "cgpa": cgpa_data["cgpa"],
        "total_credits": cgpa_data[
            "total_credits"
        ],
    }