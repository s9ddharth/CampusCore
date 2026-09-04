from sqlalchemy import select

from app.database import SessionLocal
from app.models import User, UserRole
from app.security.password import hash_password


EMAIL = "faculty1@campuscore.in"
PASSWORD = "Faculty@12345"


def seed_faculty_user() -> None:
    db = SessionLocal()

    try:
        existing = db.scalar(
            select(User).where(
                User.email == EMAIL
            )
        )

        if existing is not None:
            print(
                f"FACULTY USER ALREADY EXISTS: "
                f"{existing.email}"
            )
            return

        user = User(
            email=EMAIL,
            password_hash=hash_password(PASSWORD),
            role=UserRole.FACULTY,
            is_active=True,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        print(
            f"FACULTY USER CREATED: "
            f"{user.id} - {user.email}"
        )

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_faculty_user()