from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models import Department, Faculty, User, UserRole
from app.schemas.faculty import FacultyCreate, FacultyUpdate
from app.utils.audit import create_audit_log


def get_faculty(
    db: Session,
    faculty_id: int,
) -> Faculty | None:
    return db.get(Faculty, faculty_id)


def list_faculty(
    db: Session,
    department_id: int | None = None,
) -> list[Faculty]:
    statement = select(Faculty)

    if department_id is not None:
        statement = statement.where(
            Faculty.department_id == department_id
        )

    statement = statement.order_by(
        Faculty.name,
        Faculty.employee_id,
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


def validate_user(
    db: Session,
    user_id: int,
) -> User:
    user = db.get(User, user_id)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    if user.role != UserRole.FACULTY:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The selected user does not have the FACULTY role.",
        )

    return user


def check_duplicate(
    db: Session,
    employee_id: str | None = None,
    user_id: int | None = None,
    exclude_faculty_id: int | None = None,
) -> bool:
    conditions = []

    if employee_id is not None:
        conditions.append(Faculty.employee_id == employee_id)

    if user_id is not None:
        conditions.append(Faculty.user_id == user_id)

    if not conditions:
        return False

    statement = select(Faculty).where(
        or_(*conditions)
    )

    if exclude_faculty_id is not None:
        statement = statement.where(
            Faculty.id != exclude_faculty_id
        )

    return db.scalar(statement) is not None


def create_faculty(
    db: Session,
    faculty_data: FacultyCreate,
    current_user_id: int | None = None,
) -> Faculty:
    validate_department(
        db,
        faculty_data.department_id,
    )

    validate_user(
        db,
        faculty_data.user_id,
    )

    employee_id = faculty_data.employee_id.strip().upper()
    name = faculty_data.name.strip()

    if check_duplicate(
        db,
        employee_id=employee_id,
        user_id=faculty_data.user_id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "A faculty record already exists for this "
                "employee ID or user."
            ),
        )

    faculty = Faculty(
        user_id=faculty_data.user_id,
        employee_id=employee_id,
        name=name,
        phone=faculty_data.phone,
        department_id=faculty_data.department_id,
    )

    db.add(faculty)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="FACULTY",
        entity_id=faculty.id,
        new_value={
            "user_id": faculty.user_id,
            "employee_id": faculty.employee_id,
            "name": faculty.name,
            "phone": faculty.phone,
            "department_id": faculty.department_id,
        },
    )

    db.commit()
    db.refresh(faculty)

    return faculty


def update_faculty(
    db: Session,
    faculty_id: int,
    faculty_data: FacultyUpdate,
    current_user_id: int | None = None,
) -> Faculty:
    faculty = get_faculty(db, faculty_id)

    if faculty is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found.",
        )

    old_value = {
        "employee_id": faculty.employee_id,
        "name": faculty.name,
        "phone": faculty.phone,
        "department_id": faculty.department_id,
    }

    if faculty_data.department_id is not None:
        validate_department(
            db,
            faculty_data.department_id,
        )
        faculty.department_id = faculty_data.department_id

    if faculty_data.employee_id is not None:
        faculty.employee_id = (
            faculty_data.employee_id.strip().upper()
        )

    if faculty_data.name is not None:
        faculty.name = faculty_data.name.strip()

    if faculty_data.phone is not None:
        faculty.phone = faculty_data.phone

    if check_duplicate(
        db,
        employee_id=faculty.employee_id,
        exclude_faculty_id=faculty.id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "A faculty member with this employee ID "
                "already exists."
            ),
        )

    new_value = {
        "employee_id": faculty.employee_id,
        "name": faculty.name,
        "phone": faculty.phone,
        "department_id": faculty.department_id,
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="UPDATE",
        entity="FACULTY",
        entity_id=faculty.id,
        old_value=old_value,
        new_value=new_value,
    )

    db.commit()
    db.refresh(faculty)

    return faculty