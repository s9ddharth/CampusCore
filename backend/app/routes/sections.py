from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.section import (
    SectionCreate,
    SectionResponse,
    SectionUpdate,
)
from app.security.permissions import require_admin
from app.services.section_service import (
    create_section,
    delete_section,
    get_section,
    list_sections,
    update_section,
)


router = APIRouter(
    prefix="/api/sections",
    tags=["Sections"],
)


@router.get(
    "",
    response_model=list[SectionResponse],
)
def get_sections(
    department_id: int | None = Query(default=None, gt=0),
    semester: int | None = Query(default=None, ge=1, le=12),
    academic_year: str | None = None,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_sections(
        db,
        department_id=department_id,
        semester=semester,
        academic_year=academic_year,
    )


@router.get(
    "/{section_id}",
    response_model=SectionResponse,
)
def get_section_by_id(
    section_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    section = get_section(db, section_id)

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    return section


@router.post(
    "",
    response_model=SectionResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_section_route(
    section_data: SectionCreate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_section(db, section_data)


@router.patch(
    "/{section_id}",
    response_model=SectionResponse,
)
def update_section_route(
    section_id: int,
    section_data: SectionUpdate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_section(
        db,
        section_id,
        section_data,
    )


@router.delete(
    "/{section_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_section_route(
    section_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    delete_section(db, section_id)