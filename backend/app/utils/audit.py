from __future__ import annotations

import json
from typing import Any

from sqlalchemy.orm import Session

from app.models import AuditLog


def serialize_value(value: Any) -> str | None:
    """
    Convert a Python value into JSON text suitable for audit storage.
    """

    if value is None:
        return None

    try:
        return json.dumps(
            value,
            default=str,
            sort_keys=True,
        )
    except (TypeError, ValueError):
        return str(value)


def create_audit_log(
    db: Session,
    *,
    user_id: int | None,
    action: str,
    entity: str,
    entity_id: int | None = None,
    old_value: Any = None,
    new_value: Any = None,
) -> AuditLog:
    """
    Create an audit log entry.

    The caller is responsible for committing the transaction.
    """

    audit_log = AuditLog(
        user_id=user_id,
        action=action,
        entity=entity,
        entity_id=entity_id,
        old_value=serialize_value(old_value),
        new_value=serialize_value(new_value),
    )

    db.add(audit_log)

    return audit_log