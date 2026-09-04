from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.department import (
    DepartmentCreate,
    DepartmentResponse,
    DepartmentUpdate,
)
from app.security.permissions import require_admin
from app.services.department_service import (
    create_department,
    delete_department,
    get_department,
    list_departments,
    update_department,
)


router = APIRouter(
    prefix="/api/departments",
    tags=["Departments"],
)


@router.get(
    "",
    response_model=list[DepartmentResponse],
)
def get_departments(
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_departments(db)


@router.get(
    "/{department_id}",
    response_model=DepartmentResponse,
)
def get_department_by_id(
    department_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    department = get_department(db, department_id)

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Department not found.",
        )

    return department


@router.post(
    "",
    response_model=DepartmentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_department_route(
    department_data: DepartmentCreate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_department(db, department_data)


@router.patch(
    "/{department_id}",
    response_model=DepartmentResponse,
)
def update_department_route(
    department_id: int,
    department_data: DepartmentUpdate,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_department(
        db,
        department_id,
        department_data,
    )


@router.delete(
    "/{department_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_department_route(
    department_id: int,
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    delete_department(db, department_id)