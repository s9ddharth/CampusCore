from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import AuditLog


def list_audit_logs(
    db: Session,
    entity: str | None = None,
    entity_id: int | None = None,
    user_id: int | None = None,
    limit: int = 100,
) -> list[AuditLog]:
    statement = select(AuditLog)

    if entity is not None:
        statement = statement.where(
            AuditLog.entity == entity
        )

    if entity_id is not None:
        statement = statement.where(
            AuditLog.entity_id == entity_id
        )

    if user_id is not None:
        statement = statement.where(
            AuditLog.user_id == user_id
        )

    statement = (
        statement
        .order_by(AuditLog.created_at.desc())
        .limit(limit)
    )

    return list(db.scalars(statement).all())