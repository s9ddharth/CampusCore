from decimal import Decimal
from datetime import date

from sqlalchemy import select

from app.database import SessionLocal
from app.models import (
    Assessment,
    AssessmentStatus,
    AssessmentType,
    Department,
    Faculty,
    FacultySubject,
    GradeBand,
    GradePolicy,
    Mark,
    Section,
    Student,
    Subject,
    User,
    UserRole,
)


def get_or_create(db, model, defaults=None, **filters):
    instance = db.scalar(
        select(model).filter_by(**filters)
    )

    if instance:
        return instance, False

    instance = model(
        **filters,
        **(defaults or {}),
    )

    db.add(instance)
    db.flush()

    return instance, True


def main():
    db = SessionLocal()

    try:
        # -------------------------------------------------
        # Department
        # -------------------------------------------------

        department, _ = get_or_create(
            db,
            Department,
            name="Computer Science & Engineering",
            code="CSE",
        )

        # -------------------------------------------------
        # Section
        # -------------------------------------------------

        section, _ = get_or_create(
    db,
    Section,
    name="CSE-A",
    semester="3",
    academic_year="2026-27",
    department_id=department.id,
)

        # -------------------------------------------------
        # Faculty user
        # -------------------------------------------------

        faculty_user = db.scalar(
            select(User).where(
                User.email == "faculty1@campuscore.in"
            )
        )

        if faculty_user is None:
            raise RuntimeError(
                "faculty1@campuscore.in not found. "
                "Run the faculty seed first."
            )

        # -------------------------------------------------
        # Faculty
        # -------------------------------------------------

        faculty, _ = get_or_create(
    db,
    Faculty,
    user_id=faculty_user.id,
    employee_id="FAC001",
    defaults={
        "name": "Dr. Demo Faculty",
        "phone": "9876543210",
        "department_id": department.id,
    },
)

        # -------------------------------------------------
        # Subject
        # -------------------------------------------------

        subject, _ = get_or_create(
    db,
    Subject,
    code="CS301",
    semester="3",
    defaults={
        "name": "Data Structures",
        "credits": Decimal("4"),
        "department_id": department.id,
    },
)

        # -------------------------------------------------
        # Faculty-subject assignment
        # -------------------------------------------------

        get_or_create(
            db,
            FacultySubject,
            faculty_id=faculty.id,
            subject_id=subject.id,
            section_id=section.id,
        )

                # -------------------------------------------------
        # Student users + student records
        # -------------------------------------------------

        student_data = [
            ("STU001", "Aarav Sharma", "aarav@campuscore.in"),
            ("STU002", "Diya Verma", "diya@campuscore.in"),
            ("STU003", "Kabir Singh", "kabir@campuscore.in"),
            ("STU004", "Anaya Gupta", "anaya@campuscore.in"),
            ("STU005", "Arjun Mehta", "arjun@campuscore.in"),
            ("STU006", "Ishita Jain", "ishita@campuscore.in"),
            ("STU007", "Rohan Kapoor", "rohan@campuscore.in"),
            ("STU008", "Sara Khan", "sara@campuscore.in"),
        ]

        students = []

        for roll_no, name, email in student_data:

            # Create/login user for the student
            student_user = db.scalar(
                select(User).where(
                    User.email == email
                )
            )

            if student_user is None:
                student_user = User(
                    email=email,
                    password_hash=faculty_user.password_hash,
                    role=UserRole.STUDENT,
                    is_active=True,
                )

                db.add(student_user)
                db.flush()

            elif student_user.role != UserRole.STUDENT:
                raise RuntimeError(
                    f"User {email} already exists with role "
                    f"{student_user.role.value}"
                )

            # Create student record
            student = db.scalar(
                select(Student).where(
                    Student.roll_no == roll_no
                )
            )

            if student is None:
                student = Student(
                    user_id=student_user.id,
                    roll_no=roll_no,
                    name=name,
                    email=email,
                    semester=3,
                    department_id=department.id,
                    section_id=section.id,
                    status="ACTIVE",
                )

                db.add(student)
                db.flush()

            else:
                student.name = name
                student.email = email
                student.semester = 3
                student.department_id = department.id
                student.section_id = section.id
                student.status = "ACTIVE"

            students.append(student)

        # -------------------------------------------------
        # Grade policy
        # -------------------------------------------------

        policy = db.scalar(
            select(GradePolicy).where(
                GradePolicy.version == "2026-V1"
            )
        )

        if policy is None:
            policy = GradePolicy(
                version="2026-V1",
                name="CampusCore Relative Grading 2026",
                qualifying_threshold=Decimal("80"),
                total_scale=Decimal("200"),
                tee_pass_mark=Decimal("40"),
                top_s_count=5,
                active=True,
            )

            db.add(policy)
            db.flush()

        # -------------------------------------------------
        # Grade bands
        #
        # S is handled by Top-N relative grading.
        # A-E are absolute bands after S is assigned.
        # -------------------------------------------------

        bands = [
            ("S", Decimal("190"), Decimal("200"), Decimal("10")),
            ("A", Decimal("170"), Decimal("189.99"), Decimal("9")),
            ("B", Decimal("150"), Decimal("169.99"), Decimal("8")),
            ("C", Decimal("130"), Decimal("149.99"), Decimal("7")),
            ("D", Decimal("110"), Decimal("129.99"), Decimal("6")),
            ("E", Decimal("80"), Decimal("109.99"), Decimal("5")),
        ]

        for grade, minimum, maximum, point in bands:
            existing = db.scalar(
                select(GradeBand).where(
                    GradeBand.policy_id == policy.id,
                    GradeBand.grade == grade,
                )
            )

            if existing is None:
                db.add(
                    GradeBand(
                        policy_id=policy.id,
                        grade=grade,
                        minimum_score=minimum,
                        maximum_score=maximum,
                        grade_point=point,
                    )
                )

        db.flush()

        # -------------------------------------------------
        # Assessments
        #
        # Raw scale:
        # CAT1     50
        # CAT2     50
        # TEE     100
        # INTERNAL 20
        # ----------------
        # TOTAL   220
        # -------------------------------------------------

        assessments_config = [
            (
                "CAT1",
                AssessmentType.CAT1,
                Decimal("50"),
                date(2026, 8, 10),
            ),
            (
                "CAT2",
                AssessmentType.CAT2,
                Decimal("50"),
                date(2026, 8, 20),
            ),
            (
                "TEE",
                AssessmentType.TEE,
                Decimal("100"),
                date(2026, 8, 30),
            ),
            (
                "Internal",
                AssessmentType.INTERNAL,
                Decimal("20"),
                date(2026, 8, 25),
            ),
        ]

        assessments = []

        for name, assessment_type, max_marks, assessment_date in assessments_config:
            assessment = db.scalar(
                select(Assessment).where(
                    Assessment.subject_id == subject.id,
                    Assessment.section_id == section.id,
                    Assessment.name == name,
                    Assessment.semester == "3",
                    Assessment.academic_year == "2026-27",
                )
            )

            if assessment is None:
                assessment = Assessment(
                    subject_id=subject.id,
                    section_id=section.id,
                    name=name,
                    assessment_type=assessment_type,
                    max_marks=max_marks,
                    assessment_date=assessment_date,
                    semester="3",
                    academic_year="2026-27",
                    status=AssessmentStatus.FINALIZED,
                )

                db.add(assessment)
                db.flush()

            assessments.append(assessment)

        # -------------------------------------------------
        # Marks
        #
        # Designed so there are:
        # - 5 strongest students eligible for S
        # - 1 student with a normal A/B/C range
        # - 1 student below qualifying threshold
        # - 1 student failing TEE
        # -------------------------------------------------

        marks = {
            "STU001": [48, 47, 96, 19],
            "STU002": [47, 46, 94, 19],
            "STU003": [46, 45, 92, 18],
            "STU004": [45, 44, 90, 18],
            "STU005": [44, 43, 88, 18],
            "STU006": [40, 39, 80, 16],
            "STU007": [30, 30, 70, 15],
            "STU008": [45, 42, 38, 15],
        }

        for student in students:
            student_marks = marks[student.roll_number]

            for assessment, mark_value in zip(
                assessments,
                student_marks,
            ):
                existing = db.scalar(
                    select(Mark).where(
                        Mark.assessment_id == assessment.id,
                        Mark.student_id == student.id,
                    )
                )

                if existing is None:
                    db.add(
                        Mark(
                            assessment_id=assessment.id,
                            student_id=student.id,
                            marks=Decimal(str(mark_value)),
                            entered_by=faculty_user.id,
                        )
                    )

        db.commit()

        print("ACADEMIC DEMO DATA CREATED")
        print(f"Department : {department.name}")
        print(f"Section    : {section.name}")
        print(f"Subject    : {subject.code} - {subject.name}")
        print(f"Students   : {len(students)}")
        print(f"Assessments: {len(assessments)}")
        print(f"Policy     : {policy.version}")

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    main()