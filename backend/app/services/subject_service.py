from __future__ import annotations

from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models import Department, Subject
from app.schemas.subject import SubjectCreate, SubjectUpdate


def get_subject(
    db: Session,
    subject_id: int,
) -> Subject | None:
    return db.get(Subject, subject_id)


def list_subjects(
    db: Session,
    department_id: int | None = None,
    semester: int | None = None,
) -> list[Subject]:
    statement = select(Subject)

    if department_id is not None:
        statement = statement.where(
            Subject.department_id == department_id
        )

    if semester is not None:
        statement = statement.where(
            Subject.semester == semester
        )

    statement = statement.order_by(
        Subject.semester,
        Subject.code,
    )

    return list(db.scalars(statement).all())


def validate_department(
    db: Session,
    department_id: int,
) -> Department:
    department = db.get(Department, department_id)

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Department not found.",
        )

    return department


def check_duplicate(
    db: Session,
    code: str,
    exclude_subject_id: int | None = None,
) -> bool:
    statement = select(Subject).where(
        Subject.code == code
    )

    if exclude_subject_id is not None:
        statement = statement.where(
            Subject.id != exclude_subject_id
        )

    return db.scalar(statement) is not None


def create_subject(
    db: Session,
    subject_data: SubjectCreate,
) -> Subject:
    validate_department(
        db,
        subject_data.department_id,
    )

    code = subject_data.code.strip().upper()
    name = subject_data.name.strip()

    if check_duplicate(db, code):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A subject with this code already exists.",
        )

    subject = Subject(
        code=code,
        name=name,
        credits=Decimal(subject_data.credits),
        semester=subject_data.semester,
        department_id=subject_data.department_id,
    )

    db.add(subject)
    db.commit()
    db.refresh(subject)

    return subject


def update_subject(
    db: Session,
    subject_id: int,
    subject_data: SubjectUpdate,
) -> Subject:
    subject = get_subject(db, subject_id)

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    if subject_data.department_id is not None:
        validate_department(
            db,
            subject_data.department_id,
        )
        subject.department_id = subject_data.department_id

    if subject_data.code is not None:
        subject.code = subject_data.code.strip().upper()

    if subject_data.name is not None:
        subject.name = subject_data.name.strip()

    if subject_data.credits is not None:
        subject.credits = Decimal(subject_data.credits)

    if subject_data.semester is not None:
        subject.semester = subject_data.semester

    if check_duplicate(
        db,
        subject.code,
        exclude_subject_id=subject.id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A subject with this code already exists.",
        )

    db.commit()
    db.refresh(subject)

    return subject


def delete_subject(
    db: Session,
    subject_id: int,
) -> None:
    subject = get_subject(db, subject_id)

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    try:
        db.delete(subject)
        db.commit()

    except Exception as exc:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Subject cannot be deleted because it is "
                "being used by other records."
            ),
        ) from exc