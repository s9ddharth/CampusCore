from sqlalchemy import text

from app.database import engine


def main():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))

            print("✅ Database connection successful")
            print("✅ MySQL response:", result.scalar())

    except Exception as exc:
        print("❌ Database connection failed")
        print(exc)


if __name__ == "__main__":
    main()