from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.database import get_db
from app.models import (
    GradeBand,
    GradePolicy,
    User,
)
from app.schemas.grade_policy import (
    GradePolicyCreate,
    GradePolicyResponse,
)
from app.security.permissions import (
    get_current_user,
)


router = APIRouter(
    prefix="/api/academic/policies",
    tags=["Academic Policies"],
)


# =========================================================
# HELPERS
# =========================================================

def role_name(user: User) -> str:
    role = user.role

    if hasattr(role, "value"):
        return str(role.value).upper()

    value = str(role).upper()

    if "." in value:
        value = value.split(".")[-1]

    return value


def require_admin(
    user: User,
) -> User:

    if role_name(user) != "ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Only admin can manage "
                "grade policies."
            ),
        )

    return user


def validate_bands(
    payload: GradePolicyCreate,
) -> None:

    if not payload.bands:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "At least one grade band "
                "must be configured."
            ),
        )

    for band in payload.bands:

        if band.maximum_score < band.minimum_score:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Invalid range for "
                    f"grade {band.grade}."
                ),
            )

        if (
            band.maximum_score
            > payload.total_scale
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Maximum score for "
                    f"grade {band.grade} exceeds "
                    f"the policy scale."
                ),
            )

    grades = [
        band.grade.upper()
        for band in payload.bands
    ]

    if "S" not in grades:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Grade policy must contain "
                "an S grade band."
            ),
        )


# =========================================================
# CREATE POLICY
# =========================================================

@router.post(
    "",
    response_model=GradePolicyResponse,
)
def create_policy(
    payload: GradePolicyCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    require_admin(current_user)

    if (
        payload.qualifying_threshold
        > payload.total_scale
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "Qualifying threshold cannot "
                "exceed total scale."
            ),
        )

    if (
        payload.tee_pass_mark
        > 100
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "TEE pass mark cannot exceed 100."
            ),
        )

    validate_bands(payload)

    existing = db.scalar(
        select(GradePolicy).where(
            GradePolicy.version
            == payload.version
        )
    )

    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Grade policy version "
                "already exists."
            ),
        )

    # Only one active policy.
    if payload.active:
        active_policies = db.scalars(
            select(GradePolicy).where(
                GradePolicy.active.is_(True)
            )
        ).all()

        for active_policy in active_policies:
            active_policy.active = False

    policy = GradePolicy(
        version=payload.version,
        name=payload.name,
        qualifying_threshold=(
            payload.qualifying_threshold
        ),
        total_scale=payload.total_scale,
        tee_pass_mark=payload.tee_pass_mark,
        top_s_count=payload.top_s_count,
        active=payload.active,
    )

    db.add(policy)
    db.flush()

    for band in payload.bands:
        db.add(
            GradeBand(
                policy_id=policy.id,
                grade=band.grade.upper(),
                minimum_score=band.minimum_score,
                maximum_score=band.maximum_score,
                grade_point=band.grade_point,
            )
        )

    db.commit()

    result = db.scalar(
        select(GradePolicy)
        .options(
            selectinload(
                GradePolicy.grade_bands
            )
        )
        .where(
            GradePolicy.id == policy.id
        )
    )

    return result


# =========================================================
# LIST POLICIES
# =========================================================

@router.get(
    "",
    response_model=list[GradePolicyResponse],
)
def list_policies(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    if role_name(current_user) not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "You do not have permission "
                "to view policies."
            ),
        )

    return list(
        db.scalars(
            select(GradePolicy)
            .options(
                selectinload(
                    GradePolicy.grade_bands
                )
            )
            .order_by(
                GradePolicy.id.desc()
            )
        ).all()
    )


# =========================================================
# ACTIVE POLICY
# =========================================================

@router.get(
    "/active",
    response_model=GradePolicyResponse,
)
def get_active_policy(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    if role_name(current_user) not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "You do not have permission."
            ),
        )

    policy = db.scalar(
        select(GradePolicy)
        .options(
            selectinload(
                GradePolicy.grade_bands
            )
        )
        .where(
            GradePolicy.active.is_(True)
        )
        .order_by(
            GradePolicy.id.desc()
        )
    )

    if policy is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "No active grade policy found."
            ),
        )

    return policy


# =========================================================
# GET POLICY BY ID
# =========================================================

@router.get(
    "/{policy_id}",
    response_model=GradePolicyResponse,
)
def get_policy(
    policy_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    if role_name(current_user) not in {
        "ADMIN",
        "FACULTY",
    }:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden.",
        )

    policy = db.scalar(
        select(GradePolicy)
        .options(
            selectinload(
                GradePolicy.grade_bands
            )
        )
        .where(
            GradePolicy.id == policy_id
        )
    )

    if policy is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Grade policy not found."
            ),
        )

    return policy


# =========================================================
# ACTIVATE POLICY
# =========================================================

@router.post(
    "/{policy_id}/activate",
    response_model=GradePolicyResponse,
)
def activate_policy(
    policy_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):

    require_admin(current_user)

    policy = db.scalar(
        select(GradePolicy).where(
            GradePolicy.id == policy_id
        )
    )

    if policy is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Grade policy not found."
            ),
        )

    active_policies = db.scalars(
        select(GradePolicy).where(
            GradePolicy.active.is_(True),
            GradePolicy.id != policy_id,
        )
    ).all()

    for active_policy in active_policies:
        active_policy.active = False

    policy.active = True

    db.commit()

    return db.scalar(
        select(GradePolicy)
        .options(
            selectinload(
                GradePolicy.grade_bands
            )
        )
        .where(
            GradePolicy.id == policy_id
        )
    )