from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models import Department
from app.schemas.department import (
    DepartmentCreate,
    DepartmentUpdate,
)


def get_department(
    db: Session,
    department_id: int,
) -> Department | None:
    return db.get(Department, department_id)


def list_departments(
    db: Session,
) -> list[Department]:
    statement = select(Department).order_by(Department.name)
    return list(db.scalars(statement).all())


def create_department(
    db: Session,
    department_data: DepartmentCreate,
) -> Department:
    name = department_data.name.strip()
    code = department_data.code.strip().upper()

    statement = select(Department).where(
        or_(
            Department.name == name,
            Department.code == code,
        )
    )

    if db.scalar(statement) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Department name or code already exists.",
        )

    department = Department(
        name=name,
        code=code,
    )

    db.add(department)
    db.commit()
    db.refresh(department)

    return department


def update_department(
    db: Session,
    department_id: int,
    department_data: DepartmentUpdate,
) -> Department:
    department = get_department(db, department_id)

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Department not found.",
        )

    if department_data.name is not None:
        department.name = department_data.name.strip()

    if department_data.code is not None:
        department.code = department_data.code.strip().upper()

    duplicate_statement = select(Department).where(
        or_(
            Department.name == department.name,
            Department.code == department.code,
        ),
        Department.id != department.id,
    )

    if db.scalar(duplicate_statement) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Department name or code already exists.",
        )

    db.commit()
    db.refresh(department)

    return department


def delete_department(
    db: Session,
    department_id: int,
) -> None:
    department = get_department(db, department_id)

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Department not found.",
        )

    try:
        db.delete(department)
        db.commit()
    except Exception as exc:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Department cannot be deleted because it is "
                "being used by other records."
            ),
        ) from exc