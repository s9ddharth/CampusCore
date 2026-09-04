from __future__ import annotations

from app.models import User, UserRole
from app.security.password import hash_password


def create_test_user(
    db,
    *,
    email: str,
    password: str,
    role: UserRole = UserRole.ADMIN,
    is_active: bool = True,
) -> User:
    user = User(
        email=email,
        password_hash=hash_password(password),
        role=role,
        is_active=is_active,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


def test_login_success(client, db):
    create_test_user(
        db,
        email="admin@test.com",
        password="Admin@12345",
        role=UserRole.ADMIN,
    )

    response = client.post(
        "/api/auth/login",
        json={
            "email": "admin@test.com",
            "password": "Admin@12345",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] == 7200


def test_login_invalid_password(client, db):
    create_test_user(
        db,
        email="wrongpass@test.com",
        password="Correct@12345",
        role=UserRole.ADMIN,
    )

    response = client.post(
        "/api/auth/login",
        json={
            "email": "wrongpass@test.com",
            "password": "Wrong@12345",
        },
    )

    assert response.status_code == 401

    assert response.json()["detail"] == (
        "Invalid email or password."
    )


def test_login_unknown_user(client):
    response = client.post(
        "/api/auth/login",
        json={
            "email": "doesnotexist@test.com",
            "password": "Password@123",
        },
    )

    assert response.status_code == 401


def test_login_inactive_user(client, db):
    create_test_user(
        db,
        email="inactive@test.com",
        password="Password@123",
        role=UserRole.ADMIN,
        is_active=False,
    )

    response = client.post(
        "/api/auth/login",
        json={
            "email": "inactive@test.com",
            "password": "Password@123",
        },
    )

    assert response.status_code == 403

    assert response.json()["detail"] == (
        "User account is inactive."
    )


def test_auth_me(client, db):
    user = create_test_user(
        db,
        email="me@test.com",
        password="Password@123",
        role=UserRole.ADMIN,
    )

    login_response = client.post(
        "/api/auth/login",
        json={
            "email": "me@test.com",
            "password": "Password@123",
        },
    )

    assert login_response.status_code == 200

    token = login_response.json()["access_token"]

    response = client.get(
        "/api/auth/me",
        headers={
            "Authorization": f"Bearer {token}",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert data["id"] == user.id
    assert data["email"] == "me@test.com"
    assert data["role"] == "ADMIN"
    assert data["is_active"] is True


def test_auth_me_without_token(client):
    response = client.get(
        "/api/auth/me"
    )

    assert response.status_code == 401


def test_auth_me_invalid_token(client):
    response = client.get(
        "/api/auth/me",
        headers={
            "Authorization": "Bearer invalid-token",
        },
    )

    assert response.status_code == 401