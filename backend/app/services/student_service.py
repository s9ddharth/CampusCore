from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models import Department, Section, Student, User, UserRole
from app.schemas.student import StudentCreate, StudentUpdate
from app.utils.audit import create_audit_log


VALID_STUDENT_STATUSES = {
    "ACTIVE",
    "INACTIVE",
    "GRADUATED",
    "SUSPENDED",
}


def get_student(
    db: Session,
    student_id: int,
) -> Student | None:
    return db.get(Student, student_id)


def get_student_by_roll_no(
    db: Session,
    roll_no: str,
) -> Student | None:
    statement = select(Student).where(
        Student.roll_no == roll_no
    )
    return db.scalar(statement)


def list_students(
    db: Session,
    department_id: int | None = None,
    section_id: int | None = None,
    semester: int | None = None,
    status_value: str | None = None,
    search: str | None = None,
) -> list[Student]:
    statement = select(Student)

    if department_id is not None:
        statement = statement.where(
            Student.department_id == department_id
        )

    if section_id is not None:
        statement = statement.where(
            Student.section_id == section_id
        )

    if semester is not None:
        statement = statement.where(
            Student.semester == semester
        )

    if status_value is not None:
        statement = statement.where(
            Student.status == status_value.upper()
        )

    if search:
        search_value = f"%{search.strip()}%"

        statement = statement.where(
            or_(
                Student.name.ilike(search_value),
                Student.roll_no.ilike(search_value),
                Student.email.ilike(search_value),
            )
        )

    statement = statement.order_by(
        Student.roll_no,
    )

    return list(db.scalars(statement).all())


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

    if user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The selected user does not have the STUDENT role.",
        )

    return user


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


def validate_section(
    db: Session,
    section_id: int,
) -> Section:
    section = db.get(Section, section_id)

    if section is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Section not found.",
        )

    return section


def validate_academic_relationship(
    db: Session,
    department_id: int,
    section_id: int,
    semester: int,
) -> None:
    department = validate_department(
        db,
        department_id,
    )

    section = validate_section(
        db,
        section_id,
    )

    if section.department_id != department.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Student department and section "
                "must belong together."
            ),
        )

    if section.semester != semester:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Student semester must match "
                "the section semester."
            ),
        )


def check_duplicate(
    db: Session,
    roll_no: str | None = None,
    user_id: int | None = None,
    exclude_student_id: int | None = None,
) -> bool:
    conditions = []

    if roll_no is not None:
        conditions.append(Student.roll_no == roll_no)

    if user_id is not None:
        conditions.append(Student.user_id == user_id)

    if not conditions:
        return False

    statement = select(Student).where(
        or_(*conditions)
    )

    if exclude_student_id is not None:
        statement = statement.where(
            Student.id != exclude_student_id
        )

    return db.scalar(statement) is not None


def validate_status(status_value: str) -> str:
    normalized = status_value.strip().upper()

    if normalized not in VALID_STUDENT_STATUSES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Invalid student status. Allowed values: "
                + ", ".join(sorted(VALID_STUDENT_STATUSES))
            ),
        )

    return normalized


def create_student(
    db: Session,
    student_data: StudentCreate,
    current_user_id: int | None = None,
) -> Student:
    validate_user(
        db,
        student_data.user_id,
    )

    validate_academic_relationship(
        db,
        department_id=student_data.department_id,
        section_id=student_data.section_id,
        semester=student_data.semester,
    )

    roll_no = student_data.roll_no.strip().upper()

    if check_duplicate(
        db,
        roll_no=roll_no,
        user_id=student_data.user_id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "A student already exists for this "
                "roll number or user."
            ),
        )

    student = Student(
        user_id=student_data.user_id,
        roll_no=roll_no,
        name=student_data.name.strip(),
        dob=student_data.dob,
        phone=student_data.phone,
        email=str(student_data.email),
        semester=student_data.semester,
        department_id=student_data.department_id,
        section_id=student_data.section_id,
        status=validate_status(student_data.status),
    )

    db.add(student)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user_id,
        action="CREATE",
        entity="STUDENT",
        entity_id=student.id,
        new_value={
            "roll_no": student.roll_no,
            "name": student.name,
            "email": student.email,
            "semester": student.semester,
            "department_id": student.department_id,
            "section_id": student.section_id,
            "status": student.status,
        },
    )

    db.commit()
    db.refresh(student)

    return student


def update_student(
    db: Session,
    student_id: int,
    student_data: StudentUpdate,
    current_user_id: int | None = None,
) -> Student:
    student = get_student(db, student_id)

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    old_value = {
        "roll_no": student.roll_no,
        "name": student.name,
        "email": student.email,
        "semester": student.semester,
        "department_id": student.department_id,
        "section_id": student.section_id,
        "status": student.status,
    }

    if student_data.roll_no is not None:
        student.roll_no = student_data.roll_no.strip().upper()

    if student_data.name is not None:
        student.name = student_data.name.strip()

    if student_data.dob is not None:
        student.dob = student_data.dob

    if student_data.phone is not None:
        student.phone = student_data.phone

    if student_data.email is not None:
        student.email = str(student_data.email)

    if student_data.department_id is not None:
        student.department_id = student_data.department_id

    if student_data.section_id is not None:
        student.section_id = student_data.section_id

    if student_data.semester is not None:
        student.semester = student_data.semester

    if student_data.status is not None:
        student.status = validate_status(
            student_data.status
        )

    validate_academic_relationship(
        db,
        department_id=student.department_id,
        section_id=student.section_id,
        semester=student.semester,
    )

    if check_duplicate(
        db,
        roll_no=student.roll_no,
        exclude_student_id=student.id,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "A student with this roll number already exists."
            ),
        )

    new_value = {
        "roll_no": student.roll_no,
        "name": student.name,
        "email": student.email,
        "semester": student.semester,
        "department_id": student.department_id,
        "section_id": student.section_id,
        "status": student.status,
    }

    create_audit_log(
        db,
        user_id=current_user_id,
        action="UPDATE",
        entity="STUDENT",
        entity_id=student.id,
        old_value=old_value,
        new_value=new_value,
    )

    db.commit()
    db.refresh(student)

    return student


def deactivate_student(
    db: Session,
    student_id: int,
    current_user_id: int | None = None,
) -> Student:
    student = get_student(db, student_id)

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    old_value = {
        "status": student.status,
    }

    student.status = "INACTIVE"

    create_audit_log(
        db,
        user_id=current_user_id,
        action="DEACTIVATE",
        entity="STUDENT",
        entity_id=student.id,
        old_value=old_value,
        new_value={
            "status": student.status,
        },
    )

    db.commit()
    db.refresh(student)

    return student