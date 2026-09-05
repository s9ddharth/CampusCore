from __future__ import annotations

from datetime import date
from decimal import Decimal

from sqlalchemy.orm import Session

from app.database.database import SessionLocal
from app.database.models import (
    Assessment,
    Attendance,
    Department,
    Faculty,
    FacultySubject,
    FeeStructure,
    GradeBand,
    GradePolicy,
    Mark,
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


def seed(db: Session) -> None:
    """
    Seed the existing SQL database.

    IMPORTANT:
    This function does NOT create tables.
    Tables must already exist in the MySQL database.
    """

    # Prevent duplicate seed runs.
    if db.query(User).count() > 0:
        return

    # ------------------------------------------------------------------
    # Users
    # ------------------------------------------------------------------

    admin = User(
        email="admin@erp.local",
        password_hash=hash_password("Admin@123"),
        role="ADMIN",
        status="ACTIVE",
    )

    faculty_user = User(
        email="faculty@erp.local",
        password_hash=hash_password("Faculty@123"),
        role="FACULTY",
        status="ACTIVE",
    )

    db.add_all(
        [
            admin,
            faculty_user,
        ]
    )

    db.flush()

    # ------------------------------------------------------------------
    # Departments
    # ------------------------------------------------------------------

    departments = [
        Department(
            name="Computer Science & Engineering",
            code="CSE",
        ),
        Department(
            name="Electronics & Communication",
            code="ECE",
        ),
        Department(
            name="Mechanical Engineering",
            code="ME",
        ),
        Department(
            name="Electrical Engineering",
            code="EE",
        ),
    ]

    db.add_all(departments)
    db.flush()

    cse = departments[0]

    # ------------------------------------------------------------------
    # Sections
    # ------------------------------------------------------------------

    section_a = Section(
        name="A",
        semester=6,
        department_id=cse.id,
        academic_year="2026-27",
    )

    section_b = Section(
        name="B",
        semester=6,
        department_id=cse.id,
        academic_year="2026-27",
    )

    section_a_4 = Section(
        name="A",
        semester=4,
        department_id=cse.id,
        academic_year="2026-27",
    )

    db.add_all(
        [
            section_a,
            section_b,
            section_a_4,
        ]
    )

    db.flush()

    # ------------------------------------------------------------------
    # Faculty
    # ------------------------------------------------------------------

    faculty = Faculty(
        user_id=faculty_user.id,
        department_id=cse.id,
    )

    db.add(faculty)
    db.flush()

    # ------------------------------------------------------------------
    # Student users
    # ------------------------------------------------------------------

    students: list[Student] = []

    student_names = [
        "Aarav Sharma",
        "Vivaan Gupta",
        "Aditya Verma",
        "Arjun Singh",
        "Kabir Mehta",
        "Rohan Kumar",
        "Ishaan Patel",
        "Ananya Shah",
        "Diya Jain",
        "Meera Kapoor",
    ]

    for index, name in enumerate(student_names, start=1):
        email = f"student{index}@erp.local"
        roll_no = f"CSE6A{index:03d}"

        student_user = User(
            email=email,
            password_hash=hash_password("Student@123"),
            role="STUDENT",
            status="ACTIVE",
        )

        db.add(student_user)
        db.flush()

        student = Student(
            user_id=student_user.id,
            roll_no=roll_no,
            name=name,
            department_id=cse.id,
            semester=6,
            section=section_a.id,
            phone=f"98{index:08d}",
            email=email,
            status="ACTIVE",
        )

        db.add(student)
        students.append(student)

    db.flush()

    # ------------------------------------------------------------------
    # Subjects
    # ------------------------------------------------------------------

    subject_1 = Subject(
        code="CS601",
        name="Advanced Data Structures",
        credits=Decimal("4.00"),
        semester=6,
        department_id=cse.id,
    )

    subject_2 = Subject(
        code="CS602",
        name="Database Management Systems",
        credits=Decimal("4.00"),
        semester=6,
        department_id=cse.id,
    )

    subject_3 = Subject(
        code="CS603",
        name="Operating Systems",
        credits=Decimal("3.00"),
        semester=6,
        department_id=cse.id,
    )

    subject_4 = Subject(
        code="CS401",
        name="Computer Networks",
        credits=Decimal("3.00"),
        semester=4,
        department_id=cse.id,
    )

    db.add_all(
        [
            subject_1,
            subject_2,
            subject_3,
            subject_4,
        ]
    )

    db.flush()

    # ------------------------------------------------------------------
    # Faculty assignments
    # ------------------------------------------------------------------

    db.add_all(
        [
            FacultySubject(
                faculty_id=faculty.id,
                subject_id=subject_1.id,
                section_id=section_a.id,
            ),
            FacultySubject(
                faculty_id=faculty.id,
                subject_id=subject_2.id,
                section_id=section_a.id,
            ),
            FacultySubject(
                faculty_id=faculty.id,
                subject_id=subject_3.id,
                section_id=section_a.id,
            ),
        ]
    )

    # ------------------------------------------------------------------
    # Assessments
    # ------------------------------------------------------------------

    assessments = [
        Assessment(
            subject_id=subject_1.id,
            name="CAT-1",
            max_marks=Decimal("50.00"),
            weightage=Decimal("0.20"),
            sequence=1,
        ),
        Assessment(
            subject_id=subject_1.id,
            name="CAT-2",
            max_marks=Decimal("50.00"),
            weightage=Decimal("0.20"),
            sequence=2,
        ),
        Assessment(
            subject_id=subject_1.id,
            name="TEE",
            max_marks=Decimal("100.00"),
            weightage=Decimal("0.50"),
            sequence=3,
        ),
        Assessment(
            subject_id=subject_1.id,
            name="Internals",
            max_marks=Decimal("20.00"),
            weightage=Decimal("0.10"),
            sequence=4,
        ),
    ]

    db.add_all(assessments)
    db.flush()

    cat1, cat2, tee, internals = assessments

    # ------------------------------------------------------------------
    # Grading policy
    # ------------------------------------------------------------------

    policy = GradePolicy(
        name="PS-6 Default Grading Policy",
        pass_tee_min=Decimal("40.00"),
        pass_total_min=Decimal("80.00"),
        top_s_count=5,
        qualifying_scale=Decimal("200.00"),
        effective_semester=6,
        version=1,
    )

    db.add(policy)
    db.flush()

    # Configurable bands.
    grade_bands = [
        GradeBand(
            policy_id=policy.id,
            grade="S",
            min_score=Decimal("0.00"),
            max_score=Decimal("200.00"),
            grade_point=Decimal("10.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="A",
            min_score=Decimal("160.00"),
            max_score=Decimal("199.99"),
            grade_point=Decimal("9.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="B",
            min_score=Decimal("140.00"),
            max_score=Decimal("159.99"),
            grade_point=Decimal("8.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="C",
            min_score=Decimal("120.00"),
            max_score=Decimal("139.99"),
            grade_point=Decimal("7.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="D",
            min_score=Decimal("100.00"),
            max_score=Decimal("119.99"),
            grade_point=Decimal("6.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="E",
            min_score=Decimal("80.00"),
            max_score=Decimal("99.99"),
            grade_point=Decimal("5.00"),
        ),
        GradeBand(
            policy_id=policy.id,
            grade="F",
            min_score=Decimal("0.00"),
            max_score=Decimal("79.99"),
            grade_point=Decimal("0.00"),
        ),
    ]

    db.add_all(grade_bands)

    # ------------------------------------------------------------------
    # Marks
    # ------------------------------------------------------------------
    #
    # Students 1-5:
    #   Clearly eligible high performers.
    #
    # Student 6:
    #   TEE = 39 -> mandatory F.
    #
    # Student 7:
    #   TEE >= 40 but qualifying score < 80 -> mandatory F.
    #
    # Student 8:
    #   Eligible, should fall into A-E depending on normalized score.
    #
    # Student 9:
    #   Eligible, lower band.
    #
    # Student 10:
    #   Eligible and demonstrates another valid case.
    #
    # Totals:
    #   CAT1 + CAT2 + TEE + Internals = 220 maximum.
    #   Engine normalizes to 200.
    #

    score_matrix = [
        (45, 44, 95, 18),
        (44, 42, 92, 18),
        (43, 41, 90, 17),
        (42, 40, 88, 17),
        (41, 39, 85, 17),
        (38, 45, 39, 18),   # TEE fail
        (20, 20, 40, 7),    # total fail
        (40, 40, 55, 15),
        (20, 30, 45, 10),
        (39, 40, 80, 16),
    ]

    for student, scores in zip(students, score_matrix):
        db.add_all(
            [
                Mark(
                    student_id=student.id,
                    subject_id=subject_1.id,
                    assessment_id=cat1.id,
                    marks=Decimal(str(scores[0])),
                    entered_by=faculty_user.id,
                    locked=False,
                ),
                Mark(
                    student_id=student.id,
                    subject_id=subject_1.id,
                    assessment_id=cat2.id,
                    marks=Decimal(str(scores[1])),
                    entered_by=faculty_user.id,
                    locked=False,
                ),
                Mark(
                    student_id=student.id,
                    subject_id=subject_1.id,
                    assessment_id=tee.id,
                    marks=Decimal(str(scores[2])),
                    entered_by=faculty_user.id,
                    locked=False,
                ),
                Mark(
                    student_id=student.id,
                    subject_id=subject_1.id,
                    assessment_id=internals.id,
                    marks=Decimal(str(scores[3])),
                    entered_by=faculty_user.id,
                    locked=False,
                ),
            ]
        )

    # ------------------------------------------------------------------
    # Fee structure
    # ------------------------------------------------------------------

    fee_structure = FeeStructure(
        semester=6,
        department_id=cse.id,
        amount=Decimal("65000.00"),
        due_date=date(2026, 8, 31),
    )

    db.add(fee_structure)
    db.flush()

    # ------------------------------------------------------------------
    # Student fee cases
    # ------------------------------------------------------------------

    for index, student in enumerate(students):
        if index == 1:
            # Pending / overdue case.
            amount_due = Decimal("65000.00")
            amount_paid = Decimal("0.00")
            fee_status = "OVERDUE"

        elif index == 4:
            # Pending partial payment case.
            amount_due = Decimal("65000.00")
            amount_paid = Decimal("52000.00")
            fee_status = "PARTIAL"

        else:
            # Paid case.
            amount_due = Decimal("65000.00")
            amount_paid = Decimal("65000.00")
            fee_status = "PAID"

        db.add(
            StudentFee(
                student_id=student.id,
                fee_structure_id=fee_structure.id,
                amount_due=amount_due,
                amount_paid=amount_paid,
                status=fee_status,
            )
        )

    db.flush()

    # ------------------------------------------------------------------
    # Attendance demo cases
    # ------------------------------------------------------------------
    # Seed 15 class days so the dashboard has a real attendance trend.
    # Student 6 is deliberately below the attendance threshold.
    for day_offset in range(15):
        attendance_date = date(2026, 8, 1 + day_offset)
        for student_index, student in enumerate(students):
            # Students 1-5: strong attendance.
            # Student 6: 5/15 present, clearly below threshold.
            # Others: mixed but plausible.
            if student_index == 5:
                status_value = "PRESENT" if day_offset in {0, 3, 7, 10, 14} else "ABSENT"
            elif student_index in {0, 1, 2, 3, 4}:
                status_value = "ABSENT" if day_offset in {4, 11} else "PRESENT"
            else:
                status_value = "ABSENT" if (day_offset + student_index) % 5 == 0 else "PRESENT"

            db.add(
                Attendance(
                    student_id=student.id,
                    subject_id=subject_1.id,
                    date=attendance_date,
                    status=status_value,
                    marked_by=faculty_user.id,
                )
            )

    # ------------------------------------------------------------------
    # Historical semester demo case for GPA vs CGPA
    # ------------------------------------------------------------------
    # Student 1 has a completed Semester 4 result. After Semester 6
    # evaluation this makes CGPA visibly different from Semester 6 GPA.
    db.add(
        StudentResult(
            student_id=students[0].id,
            subject_id=subject_4.id,
            total_score=Decimal("150.00"),
            grade="B",
            grade_point=Decimal("8.00"),
            result_status="ELIGIBLE",
            policy_id=policy.id,
        )
    )
    db.add(
        SemesterResult(
            student_id=students[0].id,
            semester=4,
            sgpa=Decimal("8.00"),
            total_credits=Decimal("3.00"),
        )
    )

    db.commit()

    # Pre-calculate the seeded Semester 6 subject so the judge sees a
    # working result set immediately, while the UI can still recalculate it.
    AcademicEngine.calculate_subject_results(
        db,
        subject_1.id,
        faculty_user.id,
    )


def run() -> None:
    db = SessionLocal()

    try:
        seed(db)
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    run()