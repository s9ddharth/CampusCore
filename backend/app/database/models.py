from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    JSON,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


def utc_now() -> datetime:
    return datetime.utcnow()


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
    )
    password_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )
    role: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="ACTIVE",
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )


class Department(Base):
    __tablename__ = "departments"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    name: Mapped[str] = mapped_column(
        String(150),
        unique=True,
        nullable=False,
    )
    code: Mapped[str] = mapped_column(
        String(20),
        unique=True,
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )


class Section(Base):
    __tablename__ = "sections"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    name: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )
    semester: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id"),
        nullable=False,
    )
    academic_year: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "name",
            "semester",
            "department_id",
            "academic_year",
            name="uq_section_details",
        ),
    )


class Student(Base):
    __tablename__ = "students"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        unique=True,
        nullable=False,
    )
    roll_no: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )
    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id"),
        nullable=False,
    )
    semester: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    # This is the section ID, matching the SQL schema.
    section: Mapped[int] = mapped_column(
        ForeignKey("sections.id"),
        nullable=False,
    )

    phone: Mapped[str | None] = mapped_column(
        String(20),
        nullable=True,
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="ACTIVE",
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )


class Faculty(Base):
    __tablename__ = "faculty"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        unique=True,
        nullable=False,
    )
    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id"),
        nullable=False,
    )


class Subject(Base):
    __tablename__ = "subjects"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    code: Mapped[str] = mapped_column(
        String(30),
        unique=True,
        nullable=False,
    )
    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )
    credits: Mapped[Decimal] = mapped_column(
        Numeric(4, 2),
        nullable=False,
    )
    semester: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id"),
        nullable=False,
    )


class FacultySubject(Base):
    __tablename__ = "faculty_subjects"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    faculty_id: Mapped[int] = mapped_column(
        ForeignKey("faculty.id"),
        nullable=False,
    )
    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id"),
        nullable=False,
    )
    section_id: Mapped[int] = mapped_column(
        ForeignKey("sections.id"),
        nullable=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "faculty_id",
            "subject_id",
            "section_id",
            name="uq_faculty_subject_section",
        ),
    )


class Attendance(Base):
    __tablename__ = "attendance"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
    )
    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id"),
        nullable=False,
    )
    date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )
    marked_by: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "subject_id",
            "date",
            name="uq_attendance_student_subject_date",
        ),
    )


class FeeStructure(Base):
    __tablename__ = "fee_structures"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    semester: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    department_id: Mapped[int] = mapped_column(
        ForeignKey("departments.id"),
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )
    due_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )


class StudentFee(Base):
    __tablename__ = "student_fees"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
    )
    fee_structure_id: Mapped[int] = mapped_column(
        ForeignKey("fee_structures.id"),
        nullable=False,
    )
    amount_due: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )
    amount_paid: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
        default=Decimal("0.00"),
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="PENDING",
    )


class Payment(Base):
    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_fee_id: Mapped[int] = mapped_column(
        ForeignKey("student_fees.id"),
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(
        Numeric(12, 2),
        nullable=False,
    )
    paid_on: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )
    reference_no: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False,
    )
    recorded_by: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )


class Assessment(Base):
    __tablename__ = "assessments"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )
    max_marks: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )
    weightage: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )
    sequence: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )


class Mark(Base):
    __tablename__ = "marks"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
    )
    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id"),
        nullable=False,
    )
    assessment_id: Mapped[int] = mapped_column(
        ForeignKey("assessments.id"),
        nullable=False,
    )
    marks: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )
    entered_by: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )
    locked: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "assessment_id",
            name="uq_mark_student_assessment",
        ),
    )


class GradePolicy(Base):
    __tablename__ = "grade_policies"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )
    pass_tee_min: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
        default=Decimal("40.00"),
    )
    pass_total_min: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
        default=Decimal("80.00"),
    )
    top_s_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=5,
    )
    qualifying_scale: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
        default=Decimal("200.00"),
    )
    effective_semester: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )
    version: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=1,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )


class GradeBand(Base):
    __tablename__ = "grade_bands"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    policy_id: Mapped[int] = mapped_column(
        ForeignKey("grade_policies.id"),
        nullable=False,
    )
    grade: Mapped[str] = mapped_column(
        String(2),
        nullable=False,
    )
    min_score: Mapped[Decimal | None] = mapped_column(
        Numeric(8, 2),
        nullable=True,
    )
    max_score: Mapped[Decimal | None] = mapped_column(
        Numeric(8, 2),
        nullable=True,
    )
    grade_point: Mapped[Decimal] = mapped_column(
        Numeric(5, 2),
        nullable=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "policy_id",
            "grade",
            name="uq_grade_policy_grade",
        ),
    )


class StudentResult(Base):
    __tablename__ = "student_results"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
    )
    subject_id: Mapped[int] = mapped_column(
        ForeignKey("subjects.id"),
        nullable=False,
    )
    total_score: Mapped[Decimal] = mapped_column(
        Numeric(8, 2),
        nullable=False,
    )
    grade: Mapped[str] = mapped_column(
        String(2),
        nullable=False,
    )
    grade_point: Mapped[Decimal] = mapped_column(
        Numeric(5, 2),
        nullable=False,
    )
    result_status: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )
    policy_id: Mapped[int | None] = mapped_column(
        ForeignKey("grade_policies.id"),
        nullable=True,
    )
    calculated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "subject_id",
            name="uq_student_subject_result",
        ),
    )


class SemesterResult(Base):
    __tablename__ = "semester_results"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
    )
    semester: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    sgpa: Mapped[Decimal] = mapped_column(
        Numeric(5, 2),
        nullable=False,
    )
    total_credits: Mapped[Decimal] = mapped_column(
        Numeric(6, 2),
        nullable=False,
    )

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "semester",
            name="uq_student_semester_result",
        ),
    )


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        autoincrement=True,
    )
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
    )
    action: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )
    entity: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )
    entity_id: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )
    old_value: Mapped[dict | None] = mapped_column(
        JSON,
        nullable=True,
    )
    new_value: Mapped[dict | None] = mapped_column(
        JSON,
        nullable=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=utc_now,
    )