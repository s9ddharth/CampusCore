from __future__ import annotations

import os

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import NullPool

TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL")

if not TEST_DATABASE_URL:
    raise RuntimeError(
        "TEST_DATABASE_URL is not set. "
        "Set it in PowerShell before running pytest."
    )

os.environ["DATABASE_URL"] = TEST_DATABASE_URL

from app.database import Base, get_db
import app.models  # noqa: F401

from fastapi.testclient import TestClient

from app.main import app


engine = create_engine(
    TEST_DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600,
    poolclass=NullPool,
)

TestingSessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


def override_get_db():
    db = TestingSessionLocal()

    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


def pytest_sessionstart(session):
    Base.metadata.create_all(bind=engine)


def pytest_sessionfinish(session, exitstatus):
    Base.metadata.drop_all(bind=engine)


def clean_database(db: Session) -> None:
    for table in reversed(Base.metadata.sorted_tables):
        db.execute(table.delete())

    db.commit()


@pytest.fixture
def db():
    session = TestingSessionLocal()

    try:
        clean_database(session)
        yield session
    finally:
        session.close()


@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client