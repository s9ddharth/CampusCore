from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas.audit import AuditLogResponse
from app.security.permissions import require_admin
from app.services.audit_service import list_audit_logs


router = APIRouter(
    prefix="/api/audit-logs",
    tags=["Audit Logs"],
)


@router.get(
    "",
    response_model=list[AuditLogResponse],
)
def get_audit_logs(
    entity: str | None = None,
    entity_id: int | None = Query(
        default=None,
        gt=0,
    ),
    user_id: int | None = Query(
        default=None,
        gt=0,
    ),
    limit: int = Query(
        default=100,
        ge=1,
        le=500,
    ),
    _: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_audit_logs(
        db,
        entity=entity,
        entity_id=entity_id,
        user_id=user_id,
        limit=limit,
    )