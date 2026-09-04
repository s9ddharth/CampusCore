from __future__ import annotations

from bcrypt import checkpw, gensalt, hashpw


def hash_password(password: str) -> str:
    """
    Hash a plaintext password using bcrypt.
    """
    if not password:
        raise ValueError("Password cannot be empty.")

    hashed = hashpw(
        password.encode("utf-8"),
        gensalt(),
    )

    return hashed.decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    """
    Verify a plaintext password against a bcrypt hash.
    """
    if not password or not password_hash:
        return False

    try:
        return checkpw(
            password.encode("utf-8"),
            password_hash.encode("utf-8"),
        )
    except (ValueError, TypeError):
        return False