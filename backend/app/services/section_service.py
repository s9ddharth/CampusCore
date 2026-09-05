from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Department, Section
from app.schemas.section import SectionCreate, SectionUpdate


def get_section(
    db: Session,
    section_id: int,
) -> Section | None:
    return db.get(Section, section_id)


def list_sections(
    db: Session,
    department_id: int | None = None,
    semester: int | None = None,
    academic_year: str | None = None,
) -> list[Section]:
    statement = select(Section)

    if department_id is not None:
        statement = statement.where(
            Section.department_id == department_id
        )

    if semester is not None:
        statement = statement.where(
            Section.semester == semester
        )

    if academic_year is not None:
        statement = statement.where(
            Section.academic_year == academic_year
        )

    statement = statement.order_by(
        Section.semester,
        Section.name,
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
    name: str,
    semester: int,
    academic_year: str,
    department_id: int,
    exclude_section_id: int | None = None,
) -> bool:
    statement = select(Section).where(
        Section.name == name,
        Section.semester == semester,
        Section.academic_year == academic_year,
        Section.department_id == department_id,
    )

    if exclude_section_id is not None:
        statement = statement.where(
            Section.id != exclude_section_id
        )

    return db.scalar(statement) is not None


def create_section(
    db: Session,
    section_data: SectionCreate,
) -> Section:
    validate_department(
        db,
        section_data.department_id,
    )

    name = section_data.name.strip()
    academic_year = section_data.academic_year.strip()

    if check_duplicate(
        db,
        name=name,
        semester=section_data.semester,
        academic_year=academic_year,
        department_id=section_data.department_id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This section already exists.",
        )

    section = Section(
        name=name,
        semester=section_data.semester,
        academic_year=academic_year,
        department_id=section_data.department_id,
    )

    db.add(section)
    db.commit()
    db.refresh(section)

    return section


def update_section(
    db: Session,
    section_id: int,
    section_data: SectionUpdate,
) -> Section:
    section = get_section(db, section_id)

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    if section_data.department_id is not None:
        validate_department(
            db,
            section_data.department_id,
        )
        section.department_id = section_data.department_id

    if section_data.name is not None:
        section.name = section_data.name.strip()

    if section_data.semester is not None:
        section.semester = section_data.semester

    if section_data.academic_year is not None:
        section.academic_year = section_data.academic_year.strip()

    if check_duplicate(
        db,
        name=section.name,
        semester=section.semester,
        academic_year=section.academic_year,
        department_id=section.department_id,
        exclude_section_id=section.id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This section already exists.",
        )

    db.commit()
    db.refresh(section)

    return section


def delete_section(
    db: Session,
    section_id: int,
) -> None:
    section = get_section(db, section_id)

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    try:
        db.delete(section)
        db.commit()

    except Exception as exc:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Section cannot be deleted because it is "
                "being used by other records."
            ),
        ) from exc