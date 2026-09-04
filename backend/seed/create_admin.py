from __future__ import annotations

from sqlalchemy import select

from app.database import SessionLocal
from app.models import User, UserRole
from app.security.password import hash_password


ADMIN_EMAIL = "admin@campuscore.in"
ADMIN_PASSWORD = "Admin@12345"


def create_admin() -> None:
    db = SessionLocal()

    try:
        existing_user = db.scalar(
            select(User).where(User.email == ADMIN_EMAIL)
        )

        if existing_user is not None:
            print(f"Admin already exists: {ADMIN_EMAIL}")
            return

        admin = User(
            email=ADMIN_EMAIL,
            password_hash=hash_password(ADMIN_PASSWORD),
            role=UserRole.ADMIN,
            is_active=True,
        )

        db.add(admin)
        db.commit()
        db.refresh(admin)

        print("Admin created successfully.")
        print(f"Email: {ADMIN_EMAIL}")
        print(f"Password: {ADMIN_PASSWORD}")
        print(f"User ID: {admin.id}")

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    create_admin()