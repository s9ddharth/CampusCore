from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import (
    Faculty,
    FacultySubject,
    Section,
    Subject,
)
from app.schemas.faculty_subject import FacultySubjectCreate
from app.utils.audit import create_audit_log


def get_assignment(
    db: Session,
    assignment_id: int,
) -> FacultySubject | None:
    return db.get(FacultySubject, assignment_id)


def list_assignments(
    db: Session,
    faculty_id: int | None = None,
    subject_id: int | None = None,
    section_id: int | None = None,
) -> list[FacultySubject]:
    statement = select(FacultySubject)

    if faculty_id is not None:
        statement = statement.where(
            FacultySubject.faculty_id == faculty_id
        )

    if subject_id is not None:
        statement = statement.where(
            FacultySubject.subject_id == subject_id
        )

    if section_id is not None:
        statement = statement.where(
            FacultySubject.section_id == section_id
        )

    statement = statement.order_by(FacultySubject.id)

    return list(db.scalars(statement).all())


def validate_related_records(
    db: Session,
    faculty_id: int,
    subject_id: int,
    section_id: int,
) -> None:
    faculty = db.get(Faculty, faculty_id)

    if faculty is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found.",
        )

    subject = db.get(Subject, subject_id)

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    section = db.get(Section, section_id)

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    # The subject and section should belong to the same department.
    if subject.department_id != section.department_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Subject and section must belong to the same department."
            ),
        )

    # The faculty should also belong to that department.
    if faculty.department_id != section.department_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Faculty, subject, and section must belong "
                "to the same department."
            ),
        )


def create_assignment(
    db: Session,
    assignment_data: FacultySubjectCreate,
    current_user_id: int | None = None,
) -> FacultySubject:
    validate_related_records(
        db,
        faculty_id=assignment_data.faculty_id,
        subject_id=assignment_data.subject_id,
        section_id=assignment_data.section_id,
    )

    existing_statement = select(FacultySubject).where(
        FacultySubject.faculty_id == assignment_data.faculty_id,
        FacultySubject.subject_id == assignment_data.subject_id,
        FacultySubject.section_id == assignment_data.section_id,
    )

    existing = db.scalar(existing_statement)

    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "This faculty-subject-section "
                "assignment already exists."
            ),
        )

    assignment = FacultySubject(
        faculty_id=assignment_data.faculty_id,
        subject_id=assignment_data.subject_id,
        section_id=assignment_data.section_id,
    )

    db.add(assignment)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="FACULTY_ASSIGNMENT",
        entity_id=assignment.id,
        new_value={
            "faculty_id": assignment.faculty_id,
            "subject_id": assignment.subject_id,
            "section_id": assignment.section_id,
        },
    )

    db.commit()
    db.refresh(assignment)

    return assignment

def delete_assignment(
    db: Session,
    assignment_id: int,
    current_user_id: int | None = None,
) -> None:
    assignment = get_assignment(
        db,
        assignment_id,
    )

    if assignment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found.",
        )

    old_value = {
        "faculty_id": assignment.faculty_id,
        "subject_id": assignment.subject_id,
        "section_id": assignment.section_id,
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="DELETE",
        entity="FACULTY_ASSIGNMENT",
        entity_id=assignment.id,
        old_value=old_value,
    )

    db.delete(assignment)
    db.commit()