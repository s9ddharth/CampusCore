from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Student, User
from app.security.permissions import get_current_user
from app.services.report_service import (
    generate_student_result_excel,
    generate_student_result_pdf,
)


router = APIRouter(
    prefix="/api/reports",
    tags=["Reports"],
)


def role_name(user: User) -> str:
    role = user.role

    if hasattr(role, "value"):
        return str(role.value).upper()

    value = str(role).upper()

    if "." in value:
        value = value.split(".")[-1]

    return value


def get_student_for_user(
    db: Session,
    user: User,
) -> Student | None:

    return db.query(Student).filter(
        Student.user_id == user.id
    ).first()


def authorize_student_report(
    db: Session,
    current_user: User,
    student_id: int,
) -> None:

    role = role_name(current_user)

    if role in {"ADMIN", "FACULTY"}:
        return

    if role == "STUDENT":
        student = get_student_for_user(
            db,
            current_user,
        )

        if student is None:
            raise HTTPException(
                status_code=403,
                detail="Student profile not found.",
            )

        if student.id != student_id:
            raise HTTPException(
                status_code=403,
                detail=(
                    "Students can only access "
                    "their own reports."
                ),
            )

        return

    raise HTTPException(
        status_code=403,
        detail="You do not have permission.",
    )


# =========================================================
# EXCEL
# =========================================================

@router.get(
    "/results/{student_id}/excel",
)
def student_result_excel(
    student_id: int,
    semester: int | None = None,
    academic_year: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    authorize_student_report(
        db,
        current_user,
        student_id,
    )

    output = generate_student_result_excel(
        db,
        student_id=student_id,
        semester=semester,
        academic_year=academic_year,
    )

    return StreamingResponse(
        output,
        media_type=(
            "application/vnd.openxmlformats-"
            "officedocument.spreadsheetml.sheet"
        ),
        headers={
            "Content-Disposition": (
                f'attachment; '
                f'filename="student_{student_id}_result.xlsx"'
            )
        },
    )


# =========================================================
# PDF
# =========================================================

@router.get(
    "/results/{student_id}/pdf",
)
def student_result_pdf(
    student_id: int,
    semester: int | None = None,
    academic_year: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    authorize_student_report(
        db,
        current_user,
        student_id,
    )

    output = generate_student_result_pdf(
        db,
        student_id=student_id,
        semester=semester,
        academic_year=academic_year,
    )

    return StreamingResponse(
        output,
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; '
                f'filename="student_{student_id}_result.pdf"'
            )
        },
    )