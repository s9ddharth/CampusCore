from datetime import datetime, timedelta, timezone

import jwt

from fastapi import APIRouter, Depends, HTTPException, status

from pydantic import BaseModel, EmailStr, Field

from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_roles

from app.config.settings import settings

from app.database.database import get_db

from app.database.models import Department, Faculty, Section, Student, User

from app.security import hash_password, verify_password


router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"],
)


# ============================================================================
# REQUEST MODELS
# ============================================================================

class LoginRequest(BaseModel):
    # Login accepts the seeded demo identities such as @erp.local.
    # Registration still uses EmailStr for real account creation.
    email: str = Field(min_length=1, max_length=255)
    password: str = Field(min_length=1)


class RegisterRequest(BaseModel):
    """
    Public registration.

    STUDENT:
        name
        email
        password
        roll_no
        department_id
        semester
        section
        phone

    FACULTY:
        name
        email
        password
        department_id
    """

    name: str | None = None
    email: EmailStr
    password: str = Field(min_length=6)
    role: str = "STUDENT"

    roll_no: str | None = None
    department_id: int | None = None
    semester: int | None = None
    section: int | None = None
    phone: str | None = None


class AdminCreateUserRequest(BaseModel):
    """
    Administrator-only account creation.

    Supports:
        ADMIN
        FACULTY
        STUDENT
    """

    name: str | None = None
    email: EmailStr
    password: str = Field(min_length=6)
    role: str = "STUDENT"

    roll_no: str | None = None
    department_id: int | None = None
    semester: int | None = None
    section: int | None = None
    phone: str | None = None


# ============================================================================
# JWT
# ============================================================================

def create_access_token(user_id: int) -> str:
    payload = {
        "sub": str(user_id),
        "exp": datetime.now(timezone.utc)
        + timedelta(
            minutes=settings.access_token_expire_minutes
        ),
    }

    return jwt.encode(
        payload,
        settings.jwt_secret_key,
        algorithm="HS256",
    )


# ============================================================================
# HELPERS
# ============================================================================

def normalize_role(role: str) -> str:
    return role.strip().upper()


def normalize_email(email: str) -> str:
    return email.strip().lower()


def user_response(user: User) -> dict:
    return {
        "id": user.id,
        "email": user.email,
        "role": str(user.role).upper(),
        "status": str(user.status).upper(),
    }


# ============================================================================
# REGISTRATION VALIDATION
# ============================================================================

def validate_student_registration(request) -> None:
    missing = []

    if not request.name or not request.name.strip():
        missing.append("name")

    if not request.roll_no or not request.roll_no.strip():
        missing.append("roll_no")

    if request.department_id is None:
        missing.append("department_id")

    if request.semester is None:
        missing.append("semester")

    if request.section is None:
        missing.append("section")

    if missing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Student registration requires: "
                + ", ".join(missing)
            ),
        )

    if request.semester < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Semester must be at least 1",
        )


def validate_faculty_registration(request) -> None:
    if not request.name or not request.name.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Faculty name is required",
        )

    if request.department_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Faculty registration requires department_id",
        )


# ============================================================================
# DATABASE VALIDATION
# ============================================================================

def validate_student_references(
    db: Session,
    *,
    department_id: int,
    section_id: int,
    semester: int,
) -> None:
    department = (
        db.query(Department)
        .filter(Department.id == department_id)
        .first()
    )

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected department does not exist",
        )

    section = (
        db.query(Section)
        .filter(Section.id == section_id)
        .first()
    )

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected section does not exist",
        )

    if int(section.semester) != int(semester):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"Selected section belongs to semester "
                f"{section.semester}, not semester {semester}"
            ),
        )

    if (
        getattr(section, "department_id", None) is not None
        and int(section.department_id) != int(department_id)
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected section does not belong to the selected department",
        )


def validate_faculty_references(
    db: Session,
    *,
    department_id: int,
) -> None:
    department = (
        db.query(Department)
        .filter(Department.id == department_id)
        .first()
    )

    if department is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected department does not exist",
        )


# ============================================================================
# USER + PROFILE CREATION
# ============================================================================

def create_user_and_profile(
    *,
    db: Session,
    email: str,
    password: str,
    role: str,
    name: str | None = None,
    roll_no: str | None = None,
    department_id: int | None = None,
    semester: int | None = None,
    section: int | None = None,
    phone: str | None = None,
) -> User:

    # ------------------------------------------------------------------------
    # Duplicate email
    # ------------------------------------------------------------------------

    existing_user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    # ------------------------------------------------------------------------
    # Student validation
    # ------------------------------------------------------------------------

    if role == "STUDENT":
        if not name or not name.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student name is required",
            )

        if not roll_no or not roll_no.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student roll number is required",
            )

        if department_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student department is required",
            )

        if semester is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student semester is required",
            )

        if semester < 1:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student semester must be at least 1",
            )

        if section is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student section is required",
            )

        validate_student_references(
            db,
            department_id=department_id,
            section_id=section,
            semester=semester,
        )

        existing_student = (
            db.query(Student)
            .filter(Student.roll_no == roll_no.strip())
            .first()
        )

        if existing_student is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Roll number already exists",
            )

    # ------------------------------------------------------------------------
    # Faculty validation
    # ------------------------------------------------------------------------

    if role == "FACULTY":
        if not name or not name.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Faculty name is required",
            )

        if department_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Faculty department is required",
            )

        validate_faculty_references(
            db,
            department_id=department_id,
        )

    # ------------------------------------------------------------------------
    # Create login account
    # ------------------------------------------------------------------------

    user = User(
        email=email,
        password_hash=hash_password(password),
        role=role,
        status="ACTIVE",
    )

    db.add(user)

    # Give SQLAlchemy the generated user ID.
    db.flush()

    # ------------------------------------------------------------------------
    # Create linked profile
    # ------------------------------------------------------------------------

    if role == "STUDENT":
        student = Student(
            user_id=user.id,
            roll_no=roll_no.strip(),
            name=name.strip(),
            department_id=department_id,
            semester=semester,
            section=section,
            phone=phone.strip() if phone else None,
            email=email,
            status="ACTIVE",
        )

        db.add(student)

    elif role == "FACULTY":
        faculty = Faculty(
            user_id=user.id,
            department_id=department_id,
        )

        db.add(faculty)

    elif role == "ADMIN":
        # ADMIN uses only the users table.
        pass

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role must be ADMIN, FACULTY or STUDENT",
        )

    db.commit()
    db.refresh(user)

    return user


# ============================================================================
# PUBLIC REGISTRATION OPTIONS
# ============================================================================

@router.get("/registration-options")
def registration_options(
    db: Session = Depends(get_db),
):
    """
    Public endpoint used by the registration screen.

    No JWT is required because a user needs these options
    before they have an account.
    """

    departments = (
        db.query(Department)
        .order_by(Department.name.asc())
        .all()
    )

    sections = (
        db.query(Section)
        .order_by(
            Section.semester.asc(),
            Section.name.asc(),
        )
        .all()
    )

    return {
        "departments": [
            {
                "id": department.id,
                "name": department.name,
                "code": department.code,
            }
            for department in departments
        ],
        "sections": [
            {
                "id": section.id,
                "name": section.name,
                "semester": section.semester,
                "department_id": getattr(
                    section,
                    "department_id",
                    None,
                ),
                "academic_year": getattr(
                    section,
                    "academic_year",
                    None,
                ),
            }
            for section in sections
        ],
    }


# ============================================================================
# LOGIN
# ============================================================================

@router.post("/login")
def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    email = normalize_email(
        str(request.email)
    )

    user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )

    if str(user.status).upper() != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is inactive",
        )

    if not verify_password(
        request.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )

    return {
        "access_token": create_access_token(
            user.id
        ),
        "token_type": "bearer",
        "user": user_response(user),
    }


# ============================================================================
# PUBLIC REGISTRATION
# ============================================================================

@router.post(
    "/register",
    status_code=status.HTTP_201_CREATED,
)
def register(
    request: RegisterRequest,
    db: Session = Depends(get_db),
):
    email = normalize_email(
        str(request.email)
    )

    role = normalize_role(
        request.role
    )

    # Public registration is deliberately restricted.
    if role not in {
        "FACULTY",
        "STUDENT",
    }:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Public registration is available "
                "only for FACULTY or STUDENT"
            ),
        )

    if role == "STUDENT":
        validate_student_registration(
            request
        )

    if role == "FACULTY":
        validate_faculty_registration(
            request
        )

    try:
        user = create_user_and_profile(
            db=db,
            email=email,
            password=request.password,
            role=role,
            name=request.name,
            roll_no=request.roll_no,
            department_id=request.department_id,
            semester=request.semester,
            section=request.section,
            phone=request.phone,
        )

        response = user_response(user)

        if role == "STUDENT":
            response["profile"] = {
                "type": "student",
                "roll_no": request.roll_no,
                "name": request.name,
                "department_id": request.department_id,
                "semester": request.semester,
                "section": request.section,
            }

        elif role == "FACULTY":
            response["profile"] = {
                "type": "faculty",
                "department_id": request.department_id,
            }

        return response

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create account",
        )


# ============================================================================
# ADMIN ACCOUNT CREATION
# ============================================================================

@router.post(
    "/admin/create-user",
    status_code=status.HTTP_201_CREATED,
)
def admin_create_user(
    request: AdminCreateUserRequest,
    db: Session = Depends(get_db),
    _: User = Depends(
        require_roles("ADMIN")
    ),
):
    """
    Administrator-only account creation.

    Supports:
        ADMIN
        FACULTY
        STUDENT
    """

    email = normalize_email(
        str(request.email)
    )

    role = normalize_role(
        request.role
    )

    if role not in {
        "ADMIN",
        "FACULTY",
        "STUDENT",
    }:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role must be ADMIN, FACULTY or STUDENT",
        )

    if role == "STUDENT":
        validate_student_registration(
            request
        )

    if role == "FACULTY":
        validate_faculty_registration(
            request
        )

    try:
        user = create_user_and_profile(
            db=db,
            email=email,
            password=request.password,
            role=role,
            name=request.name,
            roll_no=request.roll_no,
            department_id=request.department_id,
            semester=request.semester,
            section=request.section,
            phone=request.phone,
        )

        response = user_response(user)

        if role == "STUDENT":
            response["profile"] = {
                "type": "student",
                "roll_no": request.roll_no,
                "name": request.name,
                "department_id": request.department_id,
                "semester": request.semester,
                "section": request.section,
            }

        elif role == "FACULTY":
            response["profile"] = {
                "type": "faculty",
                "department_id": request.department_id,
            }

        return response

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create account",
        )


# ============================================================================
# CURRENT USER
# ============================================================================

@router.get("/me")
def me(
    user: User = Depends(
        get_current_user
    ),
):
    return {
        "authenticated": True,
        "user": user_response(user),
    }