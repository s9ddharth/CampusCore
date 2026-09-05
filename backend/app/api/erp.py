from __future__ import annotations

import io
from datetime import date
from decimal import Decimal
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import Response
from openpyxl import Workbook
from pydantic import BaseModel, EmailStr, Field
from reportlab.pdfgen import canvas
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_roles
from app.database.database import get_db
from app.database.models import (
    Assessment,
    Attendance,
    AuditLog,
    Department,
    Faculty,
    FacultySubject,
    FeeStructure,
    GradeBand,
    GradePolicy,
    Mark,
    Payment,
    Section,
    SemesterResult,
    Student,
    StudentFee,
    StudentResult,
    Subject,
    User,
)
from app.security import hash_password
from app.services.academic_engine import AcademicEngine


router = APIRouter(
    prefix="/api",
    tags=["ERP"],
)


# ============================================================================
# Request models
# ============================================================================


class StudentIn(BaseModel):
    roll_no: str = Field(min_length=1, max_length=50)
    name: str = Field(min_length=1, max_length=150)
    department_id: int
    semester: int = Field(ge=1)
    section: int
    phone: str | None = Field(default=None, max_length=20)
    email: EmailStr
    status: str = "ACTIVE"


class AttendanceIn(BaseModel):
    student_id: int
    subject_id: int
    date: date
    status: str


class PaymentIn(BaseModel):
    student_fee_id: int
    amount: float = Field(gt=0)
    reference_no: str = Field(min_length=1, max_length=100)


class MarksIn(BaseModel):
    student_id: int
    subject_id: int
    assessment_id: int
    marks: float = Field(ge=0)


class AssessmentIn(BaseModel):
    subject_id: int
    name: str = Field(min_length=1, max_length=100)
    max_marks: float = Field(gt=0)
    weightage: float = Field(ge=0)
    sequence: int = Field(ge=1)


class PolicyIn(BaseModel):
    name: str = Field(
        default="PS-6 Configurable Grading Policy",
        min_length=1,
        max_length=150,
    )
    pass_tee_min: float = Field(default=40, ge=0)
    pass_total_min: float = Field(default=80, ge=0)
    top_s_count: int = Field(default=5, ge=1)
    qualifying_scale: float = Field(default=200, gt=0)
    effective_semester: int | None = Field(default=None, ge=1)

    # Optional grade bands. If omitted, existing bands remain unchanged.
    bands: list["GradeBandIn"] | None = None


class GradeBandIn(BaseModel):
    grade: str = Field(min_length=1, max_length=2)
    min_score: float | None = None
    max_score: float | None = None
    grade_point: float = Field(ge=0)


class FeeStructureIn(BaseModel):
    semester: int = Field(ge=1)
    department_id: int
    amount: float = Field(ge=0)
    due_date: date


class StudentFeeIn(BaseModel):
    student_id: int
    fee_structure_id: int
    amount_due: float = Field(ge=0)
    amount_paid: float = Field(default=0, ge=0)
    status: str = "PENDING"


class SectionIn(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    semester: int = Field(ge=1)
    department_id: int
    academic_year: str = Field(min_length=1, max_length=20)


class SubjectIn(BaseModel):
    code: str = Field(min_length=1, max_length=30)
    name: str = Field(min_length=1, max_length=150)
    credits: float = Field(gt=0)
    semester: int = Field(ge=1)
    department_id: int


class FacultyCreateIn(BaseModel):
    user_id: int
    department_id: int


# ============================================================================
# Helpers
# ============================================================================


def _role(user: User) -> str:
    return str(user.role).upper()


def _status(value: Any) -> str:
    return str(value).upper()


def _float(value: Any) -> float:
    if value is None:
        return 0.0
    if isinstance(value, Decimal):
        return float(value)
    return float(value)


def _faculty_for_user(
    db: Session,
    user: User,
) -> Faculty | None:
    return (
        db.query(Faculty)
        .filter(Faculty.user_id == user.id)
        .first()
    )


def _faculty_can_subject(
    db: Session,
    user: User,
    subject_id: int,
) -> bool:
    """
    Admin can access everything.
    Faculty can access only subjects assigned to them.
    Students cannot use faculty/admin operations.
    """
    if _role(user) == "ADMIN":
        return True

    if _role(user) != "FACULTY":
        return False

    faculty = _faculty_for_user(db, user)

    if faculty is None:
        return False

    return (
        db.query(FacultySubject)
        .filter(
            FacultySubject.faculty_id == faculty.id,
            FacultySubject.subject_id == subject_id,
        )
        .first()
        is not None
    )


def _faculty_can_student_subject(
    db: Session,
    user: User,
    student: Student,
    subject_id: int,
) -> bool:
    """
    For faculty, require both:
    - subject assignment
    - section assignment matching the student's section
    """
    if _role(user) == "ADMIN":
        return True

    if _role(user) != "FACULTY":
        return False

    faculty = _faculty_for_user(db, user)

    if faculty is None:
        return False

    return (
        db.query(FacultySubject)
        .filter(
            FacultySubject.faculty_id == faculty.id,
            FacultySubject.subject_id == subject_id,
            FacultySubject.section_id == student.section,
        )
        .first()
        is not None
    )


def _student_for_user(
    db: Session,
    user: User,
) -> Student | None:
    return (
        db.query(Student)
        .filter(Student.user_id == user.id)
        .first()
    )


def _serialize_policy(
    policy: GradePolicy | None,
    bands: list[GradeBand],
) -> dict[str, Any]:
    if policy is None:
        return {
            "policy": None,
            "bands": [],
        }

    return {
        "policy": {
            "id": policy.id,
            "name": policy.name,
            "pass_tee_min": _float(policy.pass_tee_min),
            "pass_total_min": _float(policy.pass_total_min),
            "top_s_count": policy.top_s_count,
            "qualifying_scale": _float(policy.qualifying_scale),
            "effective_semester": policy.effective_semester,
            "version": policy.version,
            "created_at": (
                policy.created_at.isoformat()
                if policy.created_at
                else None
            ),
        },
        "bands": [
            {
                "id": band.id,
                "policy_id": band.policy_id,
                "grade": band.grade,
                "min_score": (
                    _float(band.min_score)
                    if band.min_score is not None
                    else None
                ),
                "max_score": (
                    _float(band.max_score)
                    if band.max_score is not None
                    else None
                ),
                "grade_point": _float(band.grade_point),
            }
            for band in bands
        ],
    }


# ============================================================================
# Dashboard
# ============================================================================


@router.get("/dashboard")
def dashboard(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Return role-scoped KPIs for the single CampusCore dashboard."""
    role = _role(user)

    student_query = db.query(Student).filter(Student.status.in_(["ACTIVE", "active"]))

    if role == "FACULTY":
        faculty = _faculty_for_user(db, user)
        if faculty is None:
            student_query = student_query.filter(Student.id == -1)
        else:
            assigned_sections = (
                db.query(FacultySubject.section_id)
                .filter(FacultySubject.faculty_id == faculty.id)
                .distinct()
                .subquery()
            )
            student_query = student_query.filter(
                Student.section.in_(db.query(assigned_sections.c.section_id))
            )
    elif role == "STUDENT":
        student_query = student_query.filter(Student.user_id == user.id)

    scoped_students = student_query.all()
    scoped_student_ids = {student.id for student in scoped_students}

    attendance_rows = (
        db.query(Attendance)
        .filter(Attendance.student_id.in_(scoped_student_ids))
        .all()
        if scoped_student_ids
        else []
    )

    fees = (
        db.query(StudentFee)
        .filter(StudentFee.student_id.in_(scoped_student_ids))
        .all()
        if scoped_student_ids
        else []
    )

    results = (
        db.query(StudentResult)
        .filter(StudentResult.student_id.in_(scoped_student_ids))
        .all()
        if scoped_student_ids
        else []
    )

    total_due = sum(_float(f.amount_due) for f in fees)
    total_paid = sum(_float(f.amount_paid) for f in fees)

    passed = sum(
        1
        for result in results
        if _status(result.result_status) not in {"FAIL", "INCOMPLETE"}
    )

    completed_results = [
        result for result in results
        if _status(result.result_status) != "INCOMPLETE"
    ]

    pass_percentage = (
        round(passed / len(completed_results) * 100, 1)
        if completed_results
        else 0.0
    )

    grade_distribution = {
        grade: sum(
            1
            for result in results
            if str(result.grade).upper() == grade
        )
        for grade in ["S", "A", "B", "C", "D", "E", "F"]
    }

    present_count = sum(
        1 for row in attendance_rows if _status(row.status) == "PRESENT"
    )
    attendance_percentage = (
        round(present_count / len(attendance_rows) * 100, 1)
        if attendance_rows
        else 0.0
    )

    # Seven-day attendance trend powers the analytics surface without
    # requiring a second dashboard endpoint.
    trend_by_date: dict[str, dict[str, int]] = {}
    for row in attendance_rows:
        key = row.date.isoformat()
        bucket = trend_by_date.setdefault(key, {"present": 0, "total": 0})
        bucket["total"] += 1
        if _status(row.status) == "PRESENT":
            bucket["present"] += 1

    attendance_trend = []
    for day in sorted(trend_by_date)[-7:]:
        bucket = trend_by_date[day]
        attendance_trend.append({
            "date": day,
            "present": bucket["present"],
            "total": bucket["total"],
            "percentage": round(bucket["present"] / bucket["total"] * 100, 1)
            if bucket["total"]
            else 0.0,
        })

    collection_percentage = (
        round(total_paid / total_due * 100, 1)
        if total_due
        else 0.0
    )

    return {
        "role": role,
        "students": len(scoped_students),
        "attendance_rows": len(attendance_rows),
        "pending_fees": round(max(total_due - total_paid, 0), 2),
        "total_fee_due": round(total_due, 2),
        "total_fee_paid": round(total_paid, 2),
        "fee_collection_percentage": collection_percentage,
        "average_attendance": attendance_percentage,
        "attendance_trend": attendance_trend,
        "pass_percentage": pass_percentage,
        "grade_distribution": grade_distribution,
    }


# ============================================================================
# Faculty
# ============================================================================


@router.get("/faculty")
def faculty_list(
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    rows = (
        db.query(Faculty, User)
        .join(User, User.id == Faculty.user_id)
        .order_by(User.email.asc())
        .all()
    )

    return [
        {
            "id": faculty.id,
            "user_id": faculty.user_id,
            "name": faculty_user.email,
            "email": faculty_user.email,
            "department_id": faculty.department_id,
            "status": faculty_user.status,
        }
        for faculty, faculty_user in rows
    ]


@router.post("/faculty", status_code=status.HTTP_201_CREATED)
def create_faculty(
    request: FacultyCreateIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    target_user = db.get(User, request.user_id)

    if target_user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    if _role(target_user) != "FACULTY":
        raise HTTPException(
            status_code=400,
            detail="User must have FACULTY role",
        )

    existing = (
        db.query(Faculty)
        .filter(Faculty.user_id == request.user_id)
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Faculty profile already exists",
        )

    faculty = Faculty(
        user_id=request.user_id,
        department_id=request.department_id,
    )

    db.add(faculty)
    db.commit()
    db.refresh(faculty)

    return {
        "id": faculty.id,
        "user_id": faculty.user_id,
        "department_id": faculty.department_id,
    }


@router.post("/faculty/assign")
def faculty_assign(
    faculty_id: int,
    subject_id: int,
    section_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    faculty = db.get(Faculty, faculty_id)
    subject = db.get(Subject, subject_id)
    section = db.get(Section, section_id)

    if faculty is None or subject is None or section is None:
        raise HTTPException(
            status_code=404,
            detail="Faculty, subject or section not found",
        )

    existing = (
        db.query(FacultySubject)
        .filter(
            FacultySubject.faculty_id == faculty_id,
            FacultySubject.subject_id == subject_id,
            FacultySubject.section_id == section_id,
        )
        .first()
    )

    if existing:
        return {
            "status": "already_assigned",
            "id": existing.id,
        }

    assignment = FacultySubject(
        faculty_id=faculty_id,
        subject_id=subject_id,
        section_id=section_id,
    )

    db.add(assignment)
    db.commit()
    db.refresh(assignment)

    return {
        "status": "assigned",
        "id": assignment.id,
    }


@router.get("/faculty/{faculty_id}/assignments")
def faculty_assignments(
    faculty_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    if _role(user) == "FACULTY":
        own_faculty = _faculty_for_user(db, user)

        if own_faculty is None or own_faculty.id != faculty_id:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

    rows = (
        db.query(FacultySubject, Subject, Section)
        .join(Subject, Subject.id == FacultySubject.subject_id)
        .join(Section, Section.id == FacultySubject.section_id)
        .filter(FacultySubject.faculty_id == faculty_id)
        .all()
    )

    return [
        {
            "id": assignment.id,
            "subject": {
                "id": subject.id,
                "code": subject.code,
                "name": subject.name,
                "credits": _float(subject.credits),
            },
            "section": {
                "id": section.id,
                "name": section.name,
                "semester": section.semester,
                "academic_year": section.academic_year,
            },
        }
        for assignment, subject, section in rows
    ]


# ============================================================================
# Students
# ============================================================================


@router.get("/students")
def students(
    q: str | None = Query(default=None),
    department_id: int | None = Query(default=None),
    semester: int | None = Query(default=None),
    section: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    query = db.query(Student)

    if q:
        search = f"%{q.strip()}%"
        query = query.filter(
            or_(
                Student.name.ilike(search),
                Student.roll_no.ilike(search),
                Student.email.ilike(search),
            )
        )

    if department_id is not None:
        query = query.filter(
            Student.department_id == department_id
        )

    if semester is not None:
        query = query.filter(
            Student.semester == semester
        )

    if section is not None:
        query = query.filter(
            Student.section == section
        )

    # Faculty gets students belonging to their assigned sections.
    if _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)

        if faculty is None:
            return []

        assigned_sections = (
            db.query(FacultySubject.section_id)
            .filter(FacultySubject.faculty_id == faculty.id)
            .distinct()
            .subquery()
        )

        query = query.filter(
            Student.section.in_(
                db.query(assigned_sections.c.section_id)
            )
        )

    # Student gets only their own record.
    if _role(user) == "STUDENT":
        query = query.filter(
            Student.user_id == user.id
        )

    rows = (
        query
        .order_by(Student.roll_no.asc())
        .all()
    )

    return [
        {
            "id": student.id,
            "user_id": student.user_id,
            "roll_no": student.roll_no,
            "name": student.name,
            "department_id": student.department_id,
            "semester": student.semester,
            "section": student.section,
            "phone": student.phone,
            "email": student.email,
            "status": student.status,
        }
        for student in rows
    ]


@router.post("/students", status_code=status.HTTP_201_CREATED)
def create_student(
    request: StudentIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    roll_no = request.roll_no.strip()
    email = request.email.lower().strip()
    student_status = request.status.upper()

    if student_status not in {"ACTIVE", "INACTIVE"}:
        raise HTTPException(
            status_code=400,
            detail="Student status must be ACTIVE or INACTIVE",
        )

    if (
        db.query(Student)
        .filter(Student.roll_no == roll_no)
        .first()
    ):
        raise HTTPException(
            status_code=409,
            detail="Roll number already exists",
        )

    if (
        db.query(Student)
        .filter(Student.email == email)
        .first()
    ):
        raise HTTPException(
            status_code=409,
            detail="Student email already exists",
        )

    section = db.get(Section, request.section)

    if section is None:
        raise HTTPException(
            status_code=404,
            detail="Section not found",
        )

    department = db.get(
        Department,
        request.department_id,
    )

    if department is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    if section.department_id != request.department_id:
        raise HTTPException(
            status_code=400,
            detail="Section does not belong to selected department",
        )

    if section.semester != request.semester:
        raise HTTPException(
            status_code=400,
            detail="Section semester does not match student semester",
        )

    existing_user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Login email already exists",
        )

    # The students table requires a linked users row.
    # Generate a temporary password which can be replaced later.
    temporary_password = f"PS6@{roll_no}"

    student_user = User(
        email=email,
        password_hash=hash_password(temporary_password),
        role="STUDENT",
        status=student_status,
    )

    db.add(student_user)
    db.flush()

    student = Student(
        user_id=student_user.id,
        roll_no=roll_no,
        name=request.name.strip(),
        department_id=request.department_id,
        semester=request.semester,
        section=request.section,
        phone=request.phone,
        email=email,
        status=student_status,
    )

    db.add(student)

    db.add(
        AuditLog(
            user_id=user.id,
            action="CREATE",
            entity="students",
            entity_id=None,
            old_value=None,
            new_value={
                "roll_no": roll_no,
                "email": email,
                "name": request.name.strip(),
            },
        )
    )

    db.commit()
    db.refresh(student)

    return {
        "id": student.id,
        "user_id": student.user_id,
        "roll_no": student.roll_no,
        "name": student.name,
        "email": student.email,
        "temporary_password": temporary_password,
    }


@router.put("/students/{sid}")
def update_student(
    sid: int,
    request: StudentIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    old_values = {
        "roll_no": student.roll_no,
        "name": student.name,
        "department_id": student.department_id,
        "semester": student.semester,
        "section": student.section,
        "phone": student.phone,
        "email": student.email,
        "status": student.status,
    }

    new_email = request.email.lower().strip()

    duplicate_roll = (
        db.query(Student)
        .filter(
            Student.roll_no == request.roll_no.strip(),
            Student.id != sid,
        )
        .first()
    )

    if duplicate_roll:
        raise HTTPException(
            status_code=409,
            detail="Roll number already exists",
        )

    duplicate_email = (
        db.query(Student)
        .filter(
            Student.email == new_email,
            Student.id != sid,
        )
        .first()
    )

    if duplicate_email:
        raise HTTPException(
            status_code=409,
            detail="Student email already exists",
        )

    section = db.get(Section, request.section)

    if section is None:
        raise HTTPException(
            status_code=404,
            detail="Section not found",
        )

    if (
        section.department_id != request.department_id
        or section.semester != request.semester
    ):
        raise HTTPException(
            status_code=400,
            detail="Section does not match department and semester",
        )

    student.roll_no = request.roll_no.strip()
    student.name = request.name.strip()
    student.department_id = request.department_id
    student.semester = request.semester
    student.section = request.section
    student.phone = request.phone
    student.email = new_email
    student.status = request.status.upper()

    linked_user = db.get(User, student.user_id)

    if linked_user:
        linked_user.email = new_email
        linked_user.status = student.status

    db.add(
        AuditLog(
            user_id=user.id,
            action="UPDATE",
            entity="students",
            entity_id=student.id,
            old_value=old_values,
            new_value={
                "roll_no": student.roll_no,
                "name": student.name,
                "department_id": student.department_id,
                "semester": student.semester,
                "section": student.section,
                "phone": student.phone,
                "email": student.email,
                "status": student.status,
            },
        )
    )

    db.commit()

    return {
        "id": student.id,
        "status": "updated",
    }


@router.get("/students/{sid}")
def student_detail(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT":
        if student.user_id != user.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

    elif _role(user) == "FACULTY":
        subjects = (
            db.query(FacultySubject.subject_id)
            .filter(
                FacultySubject.faculty_id
                == _faculty_for_user(db, user).id
                if _faculty_for_user(db, user)
                else FacultySubject.faculty_id == -1,
                FacultySubject.section_id == student.section,
            )
            .all()
        )

        if not subjects:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

    results = (
        db.query(StudentResult)
        .filter(
            StudentResult.student_id == sid
        )
        .order_by(StudentResult.subject_id.asc())
        .all()
    )

    return {
        "student": {
            "id": student.id,
            "user_id": student.user_id,
            "roll_no": student.roll_no,
            "name": student.name,
            "department_id": student.department_id,
            "semester": student.semester,
            "section": student.section,
            "phone": student.phone,
            "email": student.email,
            "status": student.status,
        },
        "results": [
            {
                "subject_id": result.subject_id,
                "grade": result.grade,
                "grade_point": _float(result.grade_point),
                "score": _float(result.total_score),
                "status": result.result_status,
                "policy_id": result.policy_id,
                "calculated_at": (
                    result.calculated_at.isoformat()
                    if result.calculated_at
                    else None
                ),
            }
            for result in results
        ],
        "cgpa": AcademicEngine.cgpa(
            db,
            sid,
        ),
    }


# ============================================================================
# Departments / Sections / Subjects
# ============================================================================


@router.get("/departments")
def departments(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = (
        db.query(Department)
        .order_by(Department.code.asc())
        .all()
    )

    return [
        {
            "id": department.id,
            "name": department.name,
            "code": department.code,
        }
        for department in rows
    ]


@router.post("/departments", status_code=status.HTTP_201_CREATED)
def create_department(
    name: str,
    code: str,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    name = name.strip()
    code = code.strip().upper()

    if (
        db.query(Department)
        .filter(
            or_(
                Department.name == name,
                Department.code == code,
            )
        )
        .first()
    ):
        raise HTTPException(
            status_code=409,
            detail="Department name or code already exists",
        )

    department = Department(
        name=name,
        code=code,
    )

    db.add(department)
    db.commit()
    db.refresh(department)

    return {
        "id": department.id,
        "name": department.name,
        "code": department.code,
    }


@router.get("/sections")
def sections(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = (
        db.query(Section)
        .order_by(
            Section.semester.asc(),
            Section.name.asc(),
        )
        .all()
    )

    return [
        {
            "id": section.id,
            "name": section.name,
            "semester": section.semester,
            "department_id": section.department_id,
            "academic_year": section.academic_year,
        }
        for section in rows
    ]


@router.post("/sections", status_code=status.HTTP_201_CREATED)
def create_section(
    request: SectionIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    department = db.get(
        Department,
        request.department_id,
    )

    if department is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    existing = (
        db.query(Section)
        .filter(
            Section.name == request.name.strip(),
            Section.semester == request.semester,
            Section.department_id == request.department_id,
            Section.academic_year == request.academic_year.strip(),
        )
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Section already exists",
        )

    section = Section(
        name=request.name.strip(),
        semester=request.semester,
        department_id=request.department_id,
        academic_year=request.academic_year.strip(),
    )

    db.add(section)
    db.commit()
    db.refresh(section)

    return {
        "id": section.id,
    }


@router.get("/subjects")
def subjects(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = (
        db.query(Subject)
        .order_by(
            Subject.semester.asc(),
            Subject.code.asc(),
        )
        .all()
    )

    return [
        {
            "id": subject.id,
            "code": subject.code,
            "name": subject.name,
            "credits": _float(subject.credits),
            "semester": subject.semester,
            "department_id": subject.department_id,
        }
        for subject in rows
    ]


@router.post("/subjects", status_code=status.HTTP_201_CREATED)
def create_subject(
    request: SubjectIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    department = db.get(
        Department,
        request.department_id,
    )

    if department is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    existing = (
        db.query(Subject)
        .filter(Subject.code == request.code.strip().upper())
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Subject code already exists",
        )

    subject = Subject(
        code=request.code.strip().upper(),
        name=request.name.strip(),
        credits=request.credits,
        semester=request.semester,
        department_id=request.department_id,
    )

    db.add(subject)
    db.commit()
    db.refresh(subject)

    return {
        "id": subject.id,
    }


# ============================================================================
# Attendance
# ============================================================================


@router.get("/attendance")
def attendance(
    student_id: int | None = Query(default=None),
    subject_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    query = db.query(Attendance)

    if _role(user) == "STUDENT":
        student = _student_for_user(db, user)

        if student is None:
            return []

        query = query.filter(
            Attendance.student_id == student.id
        )

    elif _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)

        if faculty is None:
            return []

        assigned_subject_ids = (
            db.query(FacultySubject.subject_id)
            .filter(
                FacultySubject.faculty_id == faculty.id
            )
            .subquery()
        )

        query = query.filter(
            Attendance.subject_id.in_(
                db.query(assigned_subject_ids.c.subject_id)
            )
        )

    if student_id is not None:
        query = query.filter(
            Attendance.student_id == student_id
        )

    if subject_id is not None:
        query = query.filter(
            Attendance.subject_id == subject_id
        )

    rows = (
        query
        .order_by(
            Attendance.date.desc(),
            Attendance.id.desc(),
        )
        .all()
    )

    return [
        {
            "id": item.id,
            "student_id": item.student_id,
            "subject_id": item.subject_id,
            "date": item.date.isoformat(),
            "status": item.status,
        }
        for item in rows
    ]


@router.post("/attendance/bulk")
def save_attendance(
    items: list[AttendanceIn],
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    if not items:
        raise HTTPException(
            status_code=400,
            detail="Attendance list cannot be empty",
        )

    saved = 0
    skipped = 0

    for item in items:
        attendance_status = item.status.upper()

        if attendance_status not in {
            "PRESENT",
            "ABSENT",
            "LATE",
        }:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Attendance status must be "
                    "PRESENT, ABSENT or LATE"
                ),
            )

        student = db.get(Student, item.student_id)

        if student is None:
            raise HTTPException(
                status_code=404,
                detail=f"Student {item.student_id} not found",
            )

        if not _faculty_can_student_subject(
            db,
            user,
            student,
            item.subject_id,
        ):
            raise HTTPException(
                status_code=403,
                detail=(
                    "Faculty is not assigned to "
                    "this student's class and subject"
                ),
            )

        existing = (
            db.query(Attendance)
            .filter(
                Attendance.student_id == item.student_id,
                Attendance.subject_id == item.subject_id,
                Attendance.date == item.date,
            )
            .first()
        )

        if existing:
            skipped += 1
            continue

        db.add(
            Attendance(
                student_id=item.student_id,
                subject_id=item.subject_id,
                date=item.date,
                status=attendance_status,
                marked_by=user.id,
            )
        )

        saved += 1

    db.commit()

    return {
        "saved": saved,
        "skipped": skipped,
    }


# ============================================================================
# Fees
# ============================================================================


@router.get("/fee-structures")
def fee_structures(
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    rows = (
        db.query(FeeStructure)
        .order_by(FeeStructure.due_date.asc())
        .all()
    )

    return [
        {
            "id": row.id,
            "semester": row.semester,
            "department_id": row.department_id,
            "amount": _float(row.amount),
            "due_date": row.due_date.isoformat(),
        }
        for row in rows
    ]


@router.post(
    "/fee-structures",
    status_code=status.HTTP_201_CREATED,
)
def create_fee_structure(
    request: FeeStructureIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    if db.get(Department, request.department_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    row = FeeStructure(
        semester=request.semester,
        department_id=request.department_id,
        amount=request.amount,
        due_date=request.due_date,
    )

    db.add(row)
    db.commit()
    db.refresh(row)

    return {
        "id": row.id,
    }


@router.get("/fees/student/{sid}")
def fees(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT" and student.user_id != user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    rows = (
        db.query(StudentFee)
        .filter(StudentFee.student_id == sid)
        .order_by(StudentFee.id.desc())
        .all()
    )

    return [
        {
            "id": fee.id,
            "student_id": fee.student_id,
            "fee_structure_id": fee.fee_structure_id,
            "amount_due": _float(fee.amount_due),
            "amount_paid": _float(fee.amount_paid),
            "balance": round(
                max(
                    _float(fee.amount_due)
                    - _float(fee.amount_paid),
                    0,
                ),
                2,
            ),
            "status": fee.status,
        }
        for fee in rows
    ]


@router.post(
    "/fees",
    status_code=status.HTTP_201_CREATED,
)
def create_student_fee(
    request: StudentFeeIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    if db.get(Student, request.student_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if db.get(FeeStructure, request.fee_structure_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Fee structure not found",
        )

    if request.amount_paid > request.amount_due:
        raise HTTPException(
            status_code=400,
            detail="Amount paid cannot exceed amount due",
        )

    if request.amount_paid >= request.amount_due:
        fee_status = "PAID"
    elif request.amount_paid > 0:
        fee_status = "PARTIAL"
    else:
        fee_status = request.status.upper()

    if fee_status not in {
        "PENDING",
        "PARTIAL",
        "PAID",
        "OVERDUE",
    }:
        fee_status = "PENDING"

    row = StudentFee(
        student_id=request.student_id,
        fee_structure_id=request.fee_structure_id,
        amount_due=request.amount_due,
        amount_paid=request.amount_paid,
        status=fee_status,
    )

    db.add(row)
    db.commit()
    db.refresh(row)

    return {
        "id": row.id,
        "status": row.status,
    }


@router.get("/payments/student/{sid}")
def student_payments(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT" and student.user_id != user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    rows = (
        db.query(Payment, StudentFee)
        .join(
            StudentFee,
            StudentFee.id == Payment.student_fee_id,
        )
        .filter(StudentFee.student_id == sid)
        .order_by(Payment.paid_on.desc(), Payment.id.desc())
        .all()
    )

    return [
        {
            "id": payment.id,
            "student_fee_id": payment.student_fee_id,
            "amount": _float(payment.amount),
            "paid_on": payment.paid_on.isoformat(),
            "reference_no": payment.reference_no,
            "recorded_by": payment.recorded_by,
        }
        for payment, fee in rows
    ]


@router.post("/fees/payment")
def payment(
    request: PaymentIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    fee = db.get(
        StudentFee,
        request.student_fee_id,
    )

    if fee is None:
        raise HTTPException(
            status_code=404,
            detail="Student fee record not found",
        )

    remaining = (
        _float(fee.amount_due)
        - _float(fee.amount_paid)
    )

    if request.amount > remaining:
        raise HTTPException(
            status_code=400,
            detail="Payment exceeds remaining balance",
        )

    existing_reference = (
        db.query(Payment)
        .filter(
            Payment.reference_no == request.reference_no
        )
        .first()
    )

    if existing_reference:
        raise HTTPException(
            status_code=409,
            detail="Payment reference already exists",
        )

    fee.amount_paid = (
        _float(fee.amount_paid)
        + request.amount
    )

    if fee.amount_paid >= fee.amount_due:
        fee.status = "PAID"
    elif fee.amount_paid > 0:
        fee.status = "PARTIAL"
    else:
        fee.status = "PENDING"

    payment_row = Payment(
        student_fee_id=fee.id,
        amount=request.amount,
        paid_on=date.today(),
        reference_no=request.reference_no,
        recorded_by=user.id,
    )

    db.add(payment_row)

    db.add(
        AuditLog(
            user_id=user.id,
            action="PAYMENT",
            entity="student_fees",
            entity_id=fee.id,
            old_value={
                "amount_paid": (
                    _float(fee.amount_paid)
                    - request.amount
                ),
                "status": fee.status,
            },
            new_value={
                "amount_paid": _float(fee.amount_paid),
                "status": fee.status,
                "payment": request.amount,
            },
        )
    )

    db.commit()

    return {
        "status": fee.status,
        "amount_paid": _float(fee.amount_paid),
        "balance": round(
            max(
                _float(fee.amount_due)
                - _float(fee.amount_paid),
                0,
            ),
            2,
        ),
    }


# ============================================================================
# Assessments
# ============================================================================


@router.get("/assessments")
def assessments(
    subject_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    query = db.query(Assessment)

    if subject_id is not None:
        query = query.filter(
            Assessment.subject_id == subject_id
        )

    rows = (
        query
        .order_by(
            Assessment.subject_id.asc(),
            Assessment.sequence.asc(),
            Assessment.id.asc(),
        )
        .all()
    )

    return [
        {
            "id": assessment.id,
            "subject_id": assessment.subject_id,
            "name": assessment.name,
            "max_marks": _float(assessment.max_marks),
            "weightage": _float(assessment.weightage),
            "sequence": assessment.sequence,
        }
        for assessment in rows
    ]


@router.post(
    "/assessments",
    status_code=status.HTTP_201_CREATED,
)
def create_assessment(
    request: AssessmentIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    subject = db.get(
        Subject,
        request.subject_id,
    )

    if subject is None:
        raise HTTPException(
            status_code=404,
            detail="Subject not found",
        )

    existing = (
        db.query(Assessment)
        .filter(
            Assessment.subject_id == request.subject_id,
            Assessment.name == request.name.strip(),
        )
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Assessment already exists",
        )

    assessment = Assessment(
        subject_id=request.subject_id,
        name=request.name.strip(),
        max_marks=request.max_marks,
        weightage=request.weightage,
        sequence=request.sequence,
    )

    db.add(assessment)
    db.commit()
    db.refresh(assessment)

    return {
        "id": assessment.id,
    }


# ============================================================================
# Marks
# ============================================================================


@router.post("/marks/bulk")
def marks(
    items: list[MarksIn],
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    if not items:
        raise HTTPException(
            status_code=400,
            detail="Marks list cannot be empty",
        )

    saved = 0

    for request in items:
        student = db.get(
            Student,
            request.student_id,
        )

        if student is None:
            raise HTTPException(
                status_code=404,
                detail=f"Student {request.student_id} not found",
            )

        if not _faculty_can_student_subject(
            db,
            user,
            student,
            request.subject_id,
        ):
            raise HTTPException(
                status_code=403,
                detail="Faculty is not assigned to this student and subject",
            )

        subject = db.get(
            Subject,
            request.subject_id,
        )

        if subject is None:
            raise HTTPException(
                status_code=404,
                detail="Subject not found",
            )

        assessment = db.get(
            Assessment,
            request.assessment_id,
        )

        if assessment is None:
            raise HTTPException(
                status_code=404,
                detail="Assessment not found",
            )

        if assessment.subject_id != request.subject_id:
            raise HTTPException(
                status_code=400,
                detail="Assessment does not belong to subject",
            )

        if request.marks > _float(assessment.max_marks):
            raise HTTPException(
                status_code=422,
                detail=(
                    f"Marks must be between 0 and "
                    f"{_float(assessment.max_marks)}"
                ),
            )

        existing = (
            db.query(Mark)
            .filter(
                Mark.student_id == request.student_id,
                Mark.assessment_id == request.assessment_id,
            )
            .first()
        )

        if existing and existing.locked:
            raise HTTPException(
                status_code=409,
                detail="Assessment mark is locked",
            )

        if existing is None:
            db.add(
                Mark(
                    student_id=request.student_id,
                    subject_id=request.subject_id,
                    assessment_id=request.assessment_id,
                    marks=request.marks,
                    entered_by=user.id,
                    locked=False,
                )
            )
        else:
            existing.marks = request.marks
            existing.subject_id = request.subject_id
            existing.entered_by = user.id

        saved += 1

    db.commit()

    return {
        "saved": saved,
    }


@router.post("/marks/{mark_id}/lock")
def lock_mark(
    mark_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    mark = db.get(Mark, mark_id)

    if mark is None:
        raise HTTPException(
            status_code=404,
            detail="Mark not found",
        )

    student = db.get(
        Student,
        mark.student_id,
    )

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if not _faculty_can_student_subject(
        db,
        user,
        student,
        mark.subject_id,
    ):
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    mark.locked = True

    db.add(
        AuditLog(
            user_id=user.id,
            action="LOCK",
            entity="marks",
            entity_id=mark.id,
            old_value={"locked": False},
            new_value={"locked": True},
        )
    )

    db.commit()

    return {
        "id": mark.id,
        "locked": True,
    }


# ============================================================================
# Results
# ============================================================================


@router.post("/results/calculate")
def calculate_results(
    subject_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    if not _faculty_can_subject(
        db,
        user,
        subject_id,
    ):
        raise HTTPException(
            status_code=403,
            detail="Faculty is not assigned to this subject",
        )

    try:
        return AcademicEngine.calculate_subject_results(
            db,
            subject_id,
            user.id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=422,
            detail=str(exc),
        ) from exc


@router.get("/results/student/{sid}")
def student_results(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT":
        if student.user_id != user.id:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

    elif _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)

        if faculty is None:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

        has_access = (
            db.query(FacultySubject)
            .filter(
                FacultySubject.faculty_id == faculty.id,
                FacultySubject.section_id == student.section,
            )
            .first()
            is not None
        )

        if not has_access:
            raise HTTPException(
                status_code=403,
                detail="Access denied",
            )

    rows = (
        db.query(StudentResult, Subject)
        .join(
            Subject,
            Subject.id == StudentResult.subject_id,
        )
        .filter(StudentResult.student_id == sid)
        .order_by(
            Subject.semester.asc(),
            Subject.code.asc(),
        )
        .all()
    )

    return [
        {
            "subject_id": result.subject_id,
            "subject_code": subject.code,
            "subject_name": subject.name,
            "credits": _float(subject.credits),
            "semester": subject.semester,
            "score": _float(result.total_score),
            "grade": result.grade,
            "grade_point": _float(result.grade_point),
            "status": result.result_status,
            "policy_id": result.policy_id,
            "calculated_at": (
                result.calculated_at.isoformat()
                if result.calculated_at
                else None
            ),
        }
        for result, subject in rows
    ]


@router.get("/results/class")
def class_results(
    subject_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    if not _faculty_can_subject(
        db,
        user,
        subject_id,
    ):
        raise HTTPException(
            status_code=403,
            detail="Faculty is not assigned to this subject",
        )

    rows = (
        db.query(StudentResult, Student)
        .join(
            Student,
            Student.id == StudentResult.student_id,
        )
        .filter(StudentResult.subject_id == subject_id)
        .all()
    )

    eligible = [
        row for row in rows
        if _status(row[0].result_status) == "ELIGIBLE"
    ]
    failed_or_incomplete = [
        row for row in rows
        if _status(row[0].result_status) != "ELIGIBLE"
    ]

    eligible.sort(
        key=lambda row: (
            -_float(row[0].total_score),
            row[1].roll_no,
        )
    )
    failed_or_incomplete.sort(key=lambda row: row[1].roll_no)

    combined = eligible + failed_or_incomplete

    return [
        {
            "rank": index + 1 if _status(result.result_status) == "ELIGIBLE" else None,
            "student_id": student.id,
            "roll_no": student.roll_no,
            "name": student.name,
            "score": _float(result.total_score),
            "grade": result.grade,
            "grade_point": _float(result.grade_point),
            "status": result.result_status,
            "policy_id": result.policy_id,
        }
        for index, (result, student) in enumerate(combined)
    ]


# ============================================================================
# GPA / CGPA
# ============================================================================


@router.get("/gpa/{sid}")
def gpa(
    sid: int,
    semester: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT" and student.user_id != user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    return AcademicEngine.recalculate_gpa(
        db,
        sid,
        semester,
    )


@router.get("/cgpa/{sid}")
def cgpa(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT" and student.user_id != user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    return {
        "student_id": sid,
        "cgpa": AcademicEngine.cgpa(
            db,
            sid,
        ),
    }


# ============================================================================
# Reports
# ============================================================================


@router.get("/reports/class/excel")
def class_excel(
    subject_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN", "FACULTY")),
):
    rows = class_results(
        subject_id,
        db,
        user,
    )

    workbook = Workbook()
    worksheet = workbook.active
    worksheet.title = "Class Results"

    worksheet.append(
        [
            "Rank",
            "Roll No",
            "Name",
            "Score",
            "Grade",
            "Grade Point",
            "Status",
        ]
    )

    for row in rows:
        worksheet.append(
            [
                row["rank"],
                row["roll_no"],
                row["name"],
                row["score"],
                row["grade"],
                row["grade_point"],
                row["status"],
            ]
        )

    buffer = io.BytesIO()
    workbook.save(buffer)

    filename = "class_results.xlsx"

    return Response(
        buffer.getvalue(),
        media_type=(
            "application/vnd.openxmlformats-officedocument."
            "spreadsheetml.sheet"
        ),
        headers={
            "Content-Disposition": (
                f'attachment; filename="{filename}"'
            )
        },
    )


@router.get("/reports/student/{sid}/pdf")
def student_pdf(
    sid: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    student = db.get(Student, sid)

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    if _role(user) == "STUDENT" and student.user_id != user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied",
        )

    results = student_results(
        sid,
        db,
        user,
    )

    buffer = io.BytesIO()
    pdf = canvas.Canvas(buffer)

    width, height = 595, 842
    y = height - 50

    pdf.setFont("Helvetica-Bold", 18)
    pdf.drawString(
        50,
        y,
        "PS-6 ERP Student Report",
    )

    y -= 30

    pdf.setFont("Helvetica", 10)
    pdf.drawString(
        50,
        y,
        (
            f"Roll No: {student.roll_no}    "
            f"Name: {student.name}"
        ),
    )

    y -= 18

    pdf.drawString(
        50,
        y,
        (
            f"Semester: {student.semester}    "
            f"Section ID: {student.section}"
        ),
    )

    y -= 30

    pdf.setFont("Helvetica-Bold", 10)

    columns = [
        ("Subject", 50),
        ("Score", 260),
        ("Grade", 330),
        ("GP", 390),
        ("Status", 440),
    ]

    for title, x in columns:
        pdf.drawString(x, y, title)

    y -= 18

    pdf.setFont("Helvetica", 9)

    for row in results:
        if y < 80:
            pdf.showPage()
            y = height - 50
            pdf.setFont("Helvetica", 9)

        subject_text = (
            f"{row['subject_code']} "
            f"{row['subject_name']}"
        )

        pdf.drawString(
            50,
            y,
            subject_text[:34],
        )

        pdf.drawString(
            260,
            y,
            f"{row['score']:.2f}",
        )

        pdf.drawString(
            330,
            y,
            str(row["grade"]),
        )

        pdf.drawString(
            390,
            y,
            f"{row['grade_point']:.2f}",
        )

        pdf.drawString(
            440,
            y,
            str(row["status"]),
        )

        y -= 16

    y -= 10

    pdf.setFont("Helvetica-Bold", 11)
    pdf.drawString(
        50,
        y,
        f"CGPA: {AcademicEngine.cgpa(db, sid):.2f}",
    )

    pdf.save()

    filename = f"{student.roll_no}_report.pdf"

    return Response(
        buffer.getvalue(),
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; filename="{filename}"'
            )
        },
    )


def _excel_response(filename: str, headers: list[str], rows: list[list[Any]]) -> Response:
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = "Report"
    sheet.append(headers)
    for row in rows:
        sheet.append(row)

    output = io.BytesIO()
    workbook.save(output)
    return Response(
        content=output.getvalue(),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/reports/attendance/excel")
def attendance_excel(
    student_id: int | None = Query(default=None),
    subject_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = db.query(Attendance, Student, Subject).join(Student, Student.id == Attendance.student_id).join(Subject, Subject.id == Attendance.subject_id).all()

    if _role(user) == "STUDENT":
        own = _student_for_user(db, user)
        rows = [row for row in rows if own and row[0].student_id == own.id]
    elif _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)
        allowed = set()
        if faculty:
            allowed = {(item.subject_id, item.section_id) for item in db.query(FacultySubject).filter(FacultySubject.faculty_id == faculty.id).all()}
        rows = [row for row in rows if (row[0].subject_id, row[1].section) in allowed]

    if student_id is not None:
        rows = [row for row in rows if row[0].student_id == student_id]
    if subject_id is not None:
        rows = [row for row in rows if row[0].subject_id == subject_id]

    return _excel_response(
        "campuscore_attendance.xlsx",
        ["Date", "Roll No", "Student", "Subject", "Status"],
        [[row[0].date.isoformat(), row[1].roll_no, row[1].name, row[2].code, row[0].status] for row in rows],
    )


@router.get("/reports/fees/excel")
def fees_excel(
    student_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = db.query(StudentFee, Student).join(Student, Student.id == StudentFee.student_id).all()

    if _role(user) == "STUDENT":
        own = _student_for_user(db, user)
        rows = [row for row in rows if own and row[0].student_id == own.id]
    elif _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)
        allowed_sections = set()
        if faculty:
            allowed_sections = {item.section_id for item in db.query(FacultySubject).filter(FacultySubject.faculty_id == faculty.id).all()}
        rows = [row for row in rows if row[1].section in allowed_sections]

    if student_id is not None:
        rows = [row for row in rows if row[0].student_id == student_id]

    return _excel_response(
        "campuscore_fees.xlsx",
        ["Roll No", "Student", "Amount Due", "Amount Paid", "Balance", "Status"],
        [[row[1].roll_no, row[1].name, _float(row[0].amount_due), _float(row[0].amount_paid), round(max(_float(row[0].amount_due) - _float(row[0].amount_paid), 0), 2), row[0].status] for row in rows],
    )


@router.get("/reports/results/excel")
def results_excel(
    subject_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = db.query(StudentResult, Student, Subject).join(Student, Student.id == StudentResult.student_id).join(Subject, Subject.id == StudentResult.subject_id).all()

    if _role(user) == "STUDENT":
        own = _student_for_user(db, user)
        rows = [row for row in rows if own and row[0].student_id == own.id]
    elif _role(user) == "FACULTY":
        faculty = _faculty_for_user(db, user)
        allowed = set()
        if faculty:
            allowed = {(item.subject_id, item.section_id) for item in db.query(FacultySubject).filter(FacultySubject.faculty_id == faculty.id).all()}
        rows = [row for row in rows if (row[0].subject_id, row[1].section) in allowed]

    if subject_id is not None:
        rows = [row for row in rows if row[0].subject_id == subject_id]

    return _excel_response(
        "campuscore_results.xlsx",
        ["Roll No", "Student", "Subject", "Score", "Grade", "Grade Point", "Status", "Policy ID"],
        [[row[1].roll_no, row[1].name, row[2].code, _float(row[0].total_score), row[0].grade, _float(row[0].grade_point), row[0].result_status, row[0].policy_id] for row in rows],
    )


# ============================================================================
# Grading policy
# ============================================================================


@router.get("/policies/grading")
def get_policy(
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    policy = (
        db.query(GradePolicy)
        .order_by(
            GradePolicy.version.desc(),
            GradePolicy.id.desc(),
        )
        .first()
    )

    bands = []

    if policy:
        bands = (
            db.query(GradeBand)
            .filter(
                GradeBand.policy_id == policy.id
            )
            .order_by(GradeBand.id.asc())
            .all()
        )

    return _serialize_policy(
        policy,
        bands,
    )


@router.put("/policies/grading")
def update_policy(
    request: PolicyIn,
    db: Session = Depends(get_db),
    user: User = Depends(require_roles("ADMIN")),
):
    old_policy = (
        db.query(GradePolicy)
        .order_by(
            GradePolicy.version.desc(),
            GradePolicy.id.desc(),
        )
        .first()
    )

    new_version = (
        old_policy.version + 1
        if old_policy
        else 1
    )

    policy = GradePolicy(
        name=request.name.strip(),
        pass_tee_min=request.pass_tee_min,
        pass_total_min=request.pass_total_min,
        top_s_count=request.top_s_count,
        qualifying_scale=request.qualifying_scale,
        effective_semester=request.effective_semester,
        version=new_version,
    )

    db.add(policy)
    db.flush()

    # Only create new bands when the request explicitly supplies them.
    if request.bands is not None:
        for band in request.bands:
            grade = band.grade.upper().strip()

            if grade not in {
                "S",
                "A",
                "B",
                "C",
                "D",
                "E",
                "F",
            }:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid grade band: {grade}",
                )

            db.add(
                GradeBand(
                    policy_id=policy.id,
                    grade=grade,
                    min_score=band.min_score,
                    max_score=band.max_score,
                    grade_point=band.grade_point,
                )
            )

    else:
        # Copy existing bands when making a new version.
        if old_policy:
            old_bands = (
                db.query(GradeBand)
                .filter(
                    GradeBand.policy_id == old_policy.id
                )
                .all()
            )

            for old_band in old_bands:
                db.add(
                    GradeBand(
                        policy_id=policy.id,
                        grade=old_band.grade,
                        min_score=old_band.min_score,
                        max_score=old_band.max_score,
                        grade_point=old_band.grade_point,
                    )
                )

    db.add(
        AuditLog(
            user_id=user.id,
            action="UPDATE_POLICY",
            entity="grade_policies",
            entity_id=policy.id,
            old_value=(
                {
                    "policy_id": old_policy.id,
                    "version": old_policy.version,
                }
                if old_policy
                else None
            ),
            new_value={
                "policy_id": policy.id,
                "version": policy.version,
                "pass_tee_min": request.pass_tee_min,
                "pass_total_min": request.pass_total_min,
                "top_s_count": request.top_s_count,
                "qualifying_scale": request.qualifying_scale,
                "effective_semester": request.effective_semester,
            },
        )
    )

    db.commit()
    db.refresh(policy)

    return {
        "id": policy.id,
        "version": policy.version,
        "effective_semester": policy.effective_semester,
    }