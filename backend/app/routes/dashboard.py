from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.dashboard import (
    AdminDashboardResponse,
    DashboardResponse,
    FacultyDashboardResponse,
    StudentDashboardResponse,
)
from app.security.permissions import get_current_user
from app.services.dashboard_service import (
    get_admin_dashboard,
    get_faculty_dashboard,
    get_student_dashboard,
)


router = APIRouter(
    prefix="/api/dashboard",
    tags=["Dashboard"],
)


def role_name(user: User) -> str:
    role = user.role

    if hasattr(role, "value"):
        return str(role.value).upper()

    value = str(role).upper()

    if "." in value:
        value = value.split(".")[-1]

    return value


@router.get(
    "/admin",
    response_model=AdminDashboardResponse,
)
def admin_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    if role_name(current_user) != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required.",
        )

    return get_admin_dashboard(db)


@router.get(
    "/faculty",
    response_model=FacultyDashboardResponse,
)
def faculty_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    if role_name(current_user) != "FACULTY":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty access required.",
        )

    return get_faculty_dashboard(
        db,
        current_user.id,
    )


@router.get(
    "/student",
    response_model=StudentDashboardResponse,
)
def student_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    if role_name(current_user) != "STUDENT":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Student access required.",
        )

    return get_student_dashboard(
        db,
        current_user.id,
    )


@router.get(
    "/me",
    response_model=DashboardResponse,
)
def my_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    role = role_name(current_user)

    if role == "ADMIN":
        return {
            "role": role,
            "data": get_admin_dashboard(db),
        }

    if role == "FACULTY":
        return {
            "role": role,
            "data": get_faculty_dashboard(
                db,
                current_user.id,
            ),
        }

    if role == "STUDENT":
        return {
            "role": role,
            "data": get_student_dashboard(
                db,
                current_user.id,
            ),
        }

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Unsupported user role.",
    )