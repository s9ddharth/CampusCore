from __future__ import annotations

from datetime import date

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import (
    Attendance,
    AttendanceStatus,
    Faculty,
    FacultySubject,
    Section,
    Student,
    Subject,
    User,
)
from app.schemas.attendance import (
    AttendanceCreate,
    AttendanceUpdate,
    BulkAttendanceCreate,
)
from app.utils.audit import create_audit_log


def get_attendance(
    db: Session,
    attendance_id: int,
) -> Attendance | None:
    return db.get(Attendance, attendance_id)


def get_faculty_for_user(
    db: Session,
    user_id: int,
) -> Faculty:
    statement = select(Faculty).where(
        Faculty.user_id == user_id
    )

    faculty = db.scalar(statement)

    if faculty is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty profile not found.",
        )

    return faculty


def validate_student(
    db: Session,
    student_id: int,
) -> Student:
    student = db.get(Student, student_id)

    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found.",
        )

    if student.status != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Attendance cannot be marked for an inactive student."
            ),
        )

    return student


def validate_subject(
    db: Session,
    subject_id: int,
) -> Subject:
    subject = db.get(Subject, subject_id)

    if subject is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subject not found.",
        )

    return subject


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


def validate_faculty_assignment(
    db: Session,
    faculty_id: int,
    subject_id: int,
    section_id: int,
) -> FacultySubject:
    statement = select(FacultySubject).where(
        FacultySubject.faculty_id == faculty_id,
        FacultySubject.subject_id == subject_id,
        FacultySubject.section_id == section_id,
    )

    assignment = db.scalar(statement)

    if assignment is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Faculty is not assigned to this "
                "subject and section."
            ),
        )

    return assignment


def validate_student_section(
    student: Student,
    section: Section,
) -> None:
    if student.section_id != section.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Student does not belong to the selected section."
            ),
        )


def validate_subject_section(
    subject: Subject,
    section: Section,
) -> None:
    if subject.department_id != section.department_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Subject and section belong to "
                "different departments."
            ),
        )

    if subject.semester != section.semester:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Subject semester must match the section semester."
            ),
        )


def check_duplicate_attendance(
    db: Session,
    student_id: int,
    subject_id: int,
    attendance_date: date,
    exclude_id: int | None = None,
) -> bool:
    statement = select(Attendance).where(
        Attendance.student_id == student_id,
        Attendance.subject_id == subject_id,
        Attendance.date == attendance_date,
    )

    if exclude_id is not None:
        statement = statement.where(
            Attendance.id != exclude_id
        )

    return db.scalar(statement) is not None


def mark_attendance(
    db: Session,
    current_user: User,
    attendance_data: AttendanceCreate,
) -> Attendance:
    faculty = get_faculty_for_user(
        db,
        current_user.id,
    )

    student = validate_student(
        db,
        attendance_data.student_id,
    )

    subject = validate_subject(
        db,
        attendance_data.subject_id,
    )

    section = validate_section(
        db,
        student.section_id,
    )

    validate_student_section(
        student,
        section,
    )

    validate_subject_section(
        subject,
        section,
    )

    validate_faculty_assignment(
        db,
        faculty_id=faculty.id,
        subject_id=subject.id,
        section_id=section.id,
    )

    if check_duplicate_attendance(
        db,
        student_id=student.id,
        subject_id=subject.id,
        attendance_date=attendance_data.date,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Attendance already exists for this "
                "student, subject, and date."
            ),
        )

    attendance = Attendance(
        student_id=student.id,
        subject_id=subject.id,
        date=attendance_data.date,
        status=attendance_data.status,
        marked_by=faculty.id,
    )

    db.add(attendance)
    db.flush()

    create_audit_log(
        db,
        user_id=current_user.id,
        action="CREATE",
        entity="ATTENDANCE",
        entity_id=attendance.id,
        new_value={
            "student_id": attendance.student_id,
            "subject_id": attendance.subject_id,
            "date": str(attendance.date),
            "status": attendance.status.value,
            "marked_by": attendance.marked_by,
        },
    )

    db.commit()
    db.refresh(attendance)

    return attendance


def bulk_mark_attendance(
    db: Session,
    current_user: User,
    attendance_data: BulkAttendanceCreate,
) -> list[Attendance]:
    faculty = get_faculty_for_user(
        db,
        current_user.id,
    )

    subject = validate_subject(
        db,
        attendance_data.subject_id,
    )

    section = validate_section(
        db,
        attendance_data.section_id,
    )

    validate_subject_section(
        subject,
        section,
    )

    validate_faculty_assignment(
        db,
        faculty_id=faculty.id,
        subject_id=subject.id,
        section_id=section.id,
    )

    student_ids = [
        record.student_id
        for record in attendance_data.records
    ]

    if len(student_ids) != len(set(student_ids)):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "The same student cannot appear more than once "
                "in a bulk attendance request."
            ),
        )

    statement = select(Student).where(
        Student.id.in_(student_ids)
    )

    students = {
        student.id: student
        for student in db.scalars(statement).all()
    }

    if len(students) != len(student_ids):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="One or more students were not found.",
        )

    results: list[Attendance] = []

    for record in attendance_data.records:
        student = students[record.student_id]

        if student.status != "ACTIVE":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Attendance cannot be marked for inactive "
                    f"student {student.roll_no}."
                ),
            )

        validate_student_section(
            student,
            section,
        )

        if check_duplicate_attendance(
            db,
            student_id=student.id,
            subject_id=subject.id,
            attendance_date=attendance_data.date,
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    f"Attendance already exists for student "
                    f"{student.roll_no} on "
                    f"{attendance_data.date}."
                ),
            )

        attendance = Attendance(
            student_id=student.id,
            subject_id=subject.id,
            date=attendance_data.date,
            status=record.status,
            marked_by=faculty.id,
        )

        db.add(attendance)
        db.flush()

        create_audit_log(
            db,
            user_id=current_user.id,
            action="CREATE",
            entity="ATTENDANCE",
            entity_id=attendance.id,
            new_value={
                "student_id": attendance.student_id,
                "subject_id": attendance.subject_id,
                "date": str(attendance.date),
                "status": attendance.status.value,
                "marked_by": attendance.marked_by,
            },
        )

        results.append(attendance)

    db.commit()

    for attendance in results:
        db.refresh(attendance)

    return results


def update_attendance(
    db: Session,
    current_user: User,
    attendance_id: int,
    attendance_data: AttendanceUpdate,
) -> Attendance:
    attendance = get_attendance(
        db,
        attendance_id,
    )

    if attendance is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance record not found.",
        )

    faculty = get_faculty_for_user(
        db,
        current_user.id,
    )

    student = validate_student(
        db,
        attendance.student_id,
    )

    validate_faculty_assignment(
        db,
        faculty_id=faculty.id,
        subject_id=attendance.subject_id,
        section_id=student.section_id,
    )

    old_value = {
        "status": attendance.status.value,
    }

    attendance.status = attendance_data.status

    create_audit_log(
        db,
        user_id=current_user.id,
        action="UPDATE",
        entity="ATTENDANCE",
        entity_id=attendance.id,
        old_value=old_value,
        new_value={
            "status": attendance.status.value,
        },
    )

    db.commit()
    db.refresh(attendance)

    return attendance


def list_attendance(
    db: Session,
    student_id: int | None = None,
    subject_id: int | None = None,
    section_id: int | None = None,
    attendance_date: date | None = None,
) -> list[Attendance]:
    statement = select(Attendance)

    if student_id is not None:
        statement = statement.where(
            Attendance.student_id == student_id
        )

    if subject_id is not None:
        statement = statement.where(
            Attendance.subject_id == subject_id
        )

    if section_id is not None:
        statement = (
            statement
            .join(
                Student,
                Attendance.student_id == Student.id,
            )
            .where(
                Student.section_id == section_id
            )
        )

    if attendance_date is not None:
        statement = statement.where(
            Attendance.date == attendance_date
        )

    statement = statement.order_by(
        Attendance.date.desc(),
        Attendance.student_id,
    )

    return list(db.scalars(statement).all())


def get_student_attendance_summary(
    db: Session,
    student_id: int,
) -> list[dict[str, object]]:
    validate_student(db, student_id)

    statement = (
        select(
            Attendance.subject_id,
            func.count(Attendance.id).label(
                "total_classes"
            ),
            func.sum(
                Attendance.status == AttendanceStatus.PRESENT
            ).label(
                "present_classes"
            ),
        )
        .where(
            Attendance.student_id == student_id
        )
        .group_by(
            Attendance.subject_id
        )
    )

    rows = db.execute(statement).all()

    return [
        {
            "subject_id": row.subject_id,
            "total_classes": int(row.total_classes),
            "present_classes": int(
                row.present_classes or 0
            ),
            "attendance_percentage": (
                round(
                    (
                        int(row.present_classes or 0)
                        / int(row.total_classes)
                    ) * 100,
                    2,
                )
                if row.total_classes
                else 0.0
            ),
        }
        for row in rows
    ]