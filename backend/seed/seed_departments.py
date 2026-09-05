from sqlalchemy import select

from app.database import SessionLocal
from app.models import Department


def seed_departments() -> None:
    db = SessionLocal()

    try:
        existing = db.scalar(
            select(Department).where(
                Department.code == "CSE"
            )
        )

        if existing:
            print("CSE DEPARTMENT ALREADY EXISTS")
            return

        department = Department(
            code="CSE",
            name="Computer Science & Engineering",
        )

        db.add(department)
        db.commit()
        db.refresh(department)

        print(
            f"DEPARTMENT CREATED: "
            f"{department.id} - {department.code}"
        )

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_departments()