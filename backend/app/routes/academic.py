from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Faculty, Student, User
from app.schemas.academic import (
    CalculateGPARequest,
    CalculateSubjectRequest,
    SemesterResultResponse,
    StudentCGPAResponse,
    StudentResultResponse,
    SubjectResultResponse,
)
from app.security.permissions import get_current_user
from app.services.result_service import (
    calculate_all_student_gpas,
    calculate_student_cgpa,
    calculate_student_gpa,
    calculate_subject_result,
    get_semester_result,
    get_student_results,
    get_subject_results,
    verify_faculty_subject_access,
)


router = APIRouter(
    prefix="/api/academic",
    tags=["Academic"],
)


# =========================================================
# ROLE HELPERS
# =========================================================

def role_name(user: User) -> str:
    role = user.role

    if hasattr(role, "value"):
        return str(role.value).upper()

    value = str(role).upper()

    if "." in value:
        value = value.split(".")[-1]

    return value


def require_admin_or_faculty(
    user: User,
) -> User:

    if role_name(user) not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only admin or faculty can "
                "perform this action."
            ),
        )

    return user


def get_student_for_user(
    db: Session,
    user: User,
) -> Student:

    student = db.scalar(
        select(Student).where(
            Student.user_id == user.id
        )
    )

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Student profile not found.",
        )

    return student


# =========================================================
# CALCULATE SUBJECT RESULTS
# =========================================================

@router.post(
    "/results/calculate",
    response_model=list[SubjectResultResponse],
)
def calculate_results(
    payload: CalculateSubjectRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    role = role_name(current_user)

    if role == "FACULTY":
        verify_faculty_subject_access(
            db=db,
            user_id=current_user.id,
            subject_id=payload.subject_id,
            section_id=payload.section_id,
        )

    elif role != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only admin or assigned faculty "
                "can calculate results."
            ),
        )

    return calculate_subject_result(
        db=db,
        subject_id=payload.subject_id,
        section_id=payload.section_id,
        semester=payload.semester,
        academic_year=payload.academic_year,
        policy_id=payload.policy_id,
    )


# =========================================================
# VIEW SUBJECT RESULTS
# =========================================================

@router.get(
    "/results/subject/{subject_id}",
    response_model=list[SubjectResultResponse],
)
def get_results_for_subject(
    subject_id: int,
    semester: int,
    academic_year: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    role = role_name(current_user)

    if role not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only admin or faculty can "
                "view class results."
            ),
        )

    return get_subject_results(
        db=db,
        subject_id=subject_id,
        semester=semester,
        academic_year=academic_year,
    )


# =========================================================
# VIEW STUDENT RESULTS
# =========================================================

@router.get(
    "/results/student/{student_id}",
    response_model=list[StudentResultResponse],
)
def get_results_for_student(
    student_id: int,
    semester: int | None = None,
    academic_year: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    role = role_name(current_user)

    if role == "STUDENT":
        student = get_student_for_user(
            db,
            current_user,
        )

        if student.id != student_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Students can only "
                    "view their own results."
                ),
            )

    elif role not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission.",
        )

    return get_student_results(
        db=db,
        student_id=student_id,
        semester=semester,
        academic_year=academic_year,
    )


# =========================================================
# GPA CALCULATION
# =========================================================

@router.post(
    "/gpa/calculate",
    response_model=SemesterResultResponse,
)
def calculate_gpa_for_student(
    payload: CalculateGPARequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    role = role_name(current_user)

    if role == "STUDENT":
        student = get_student_for_user(
            db,
            current_user,
        )

        if student.id != payload.student_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Students can only "
                    "calculate their own GPA."
                ),
            )

    elif role not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission.",
        )

    return calculate_student_gpa(
        db=db,
        student_id=payload.student_id,
        semester=payload.semester,
        academic_year=payload.academic_year,
    )


# =========================================================
# GET GPA
# =========================================================

@router.get(
    "/gpa/{student_id}",
    response_model=SemesterResultResponse,
)
def get_gpa(
    student_id: int,
    semester: int,
    academic_year: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    role = role_name(current_user)

    if role == "STUDENT":
        student = get_student_for_user(
            db,
            current_user,
        )

        if student.id != student_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Students can only "
                    "view their own GPA."
                ),
            )

    elif role not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission.",
        )

    result = get_semester_result(
        db=db,
        student_id=student_id,
        semester=semester,
        academic_year=academic_year,
    )

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Semester result not found.",
        )

    return result


# =========================================================
# CGPA
# =========================================================

@router.get(
    "/cgpa/{student_id}",
    response_model=StudentCGPAResponse,
)
def get_cgpa(
    student_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    role = role_name(current_user)

    if role == "STUDENT":
        student = get_student_for_user(
            db,
            current_user,
        )

        if student.id != student_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Students can only "
                    "view their own CGPA."
                ),
            )

    elif role not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission.",
        )

    return calculate_student_cgpa(
        db=db,
        student_id=student_id,
    )


# =========================================================
# CALCULATE ALL GPAs
# =========================================================

@router.post(
    "/gpa/calculate-all",
    response_model=list[SemesterResultResponse],
)
def calculate_all_gpa(
    semester: int,
    academic_year: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    require_admin_or_faculty(
        current_user
    )

    return calculate_all_student_gpas(
        db=db,
        semester=semester,
        academic_year=academic_year,
    )