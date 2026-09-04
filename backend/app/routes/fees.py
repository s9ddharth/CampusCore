from __future__ import annotations

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    status,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import FeeStatus, User
from app.schemas.fee import (
    FeeStructureCreate,
    FeeStructureResponse,
    FeeStructureUpdate,
    FeeSummary,
    StudentFeeCreate,
    StudentFeeResponse,
    StudentFeeUpdate,
)
from app.security.permissions import require_admin
from app.services.fee_service import (
    assign_student_fee,
    create_fee_structure,
    delete_fee_structure,
    get_fee_summary,
    get_fee_structure,
    get_student_fee,
    list_fee_structures,
    list_student_fees,
    update_fee_structure,
    update_student_fee,
)


router = APIRouter(
    prefix="/api/fees",
    tags=["Fees"],
)


# ============================================================
# FEE STRUCTURES
# ============================================================

@router.get(
    "/structures",
    response_model=list[FeeStructureResponse],
)
def get_fee_structures(
    department_id: int | None = Query(
        default=None,
        gt=0,
    ),
    semester: int | None = Query(
        default=None,
        ge=1,
        le=12,
    ),
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_fee_structures(
        db,
        department_id=department_id,
        semester=semester,
    )


@router.get(
    "/structures/{fee_structure_id}",
    response_model=FeeStructureResponse,
)
def get_fee_structure_by_id(
    fee_structure_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    fee_structure = get_fee_structure(
        db,
        fee_structure_id,
    )

    if fee_structure is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fee structure not found.",
        )

    return fee_structure


@router.post(
    "/structures",
    response_model=FeeStructureResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_fee_structure_route(
    fee_data: FeeStructureCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return create_fee_structure(
        db,
        fee_data,
        current_user_id=current_user.id,
    )


@router.patch(
    "/structures/{fee_structure_id}",
    response_model=FeeStructureResponse,
)
def update_fee_structure_route(
    fee_structure_id: int,
    fee_data: FeeStructureUpdate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_fee_structure(
        db,
        fee_structure_id,
        fee_data,
        current_user_id=current_user.id,
    )


@router.delete(
    "/structures/{fee_structure_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_fee_structure_route(
    fee_structure_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    delete_fee_structure(
        db,
        fee_structure_id,
        current_user_id=current_user.id,
    )


# ============================================================
# STUDENT FEES
# ============================================================

@router.get(
    "/students",
    response_model=list[StudentFeeResponse],
)
def get_student_fees(
    student_id: int | None = Query(
        default=None,
        gt=0,
    ),
    fee_structure_id: int | None = Query(
        default=None,
        gt=0,
    ),
    fee_status: FeeStatus | None = None,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return list_student_fees(
        db,
        student_id=student_id,
        fee_structure_id=fee_structure_id,
        status_value=fee_status,
    )


@router.get(
    "/students/{student_fee_id}",
    response_model=StudentFeeResponse,
)
def get_student_fee_by_id(
    student_fee_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    student_fee = get_student_fee(
        db,
        student_fee_id,
    )

    if student_fee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student fee not found.",
        )

    return student_fee


@router.post(
    "/students",
    response_model=StudentFeeResponse,
    status_code=status.HTTP_201_CREATED,
)
def assign_student_fee_route(
    fee_data: StudentFeeCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return assign_student_fee(
        db,
        fee_data,
        current_user_id=current_user.id,
    )


@router.patch(
    "/students/{student_fee_id}",
    response_model=StudentFeeResponse,
)
def update_student_fee_route(
    student_fee_id: int,
    fee_data: StudentFeeUpdate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return update_student_fee(
        db,
        student_fee_id,
        fee_data,
        current_user_id=current_user.id,
    )


@router.get(
    "/students/{student_fee_id}/summary",
    response_model=FeeSummary,
)
def get_fee_summary_route(
    student_fee_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return get_fee_summary(
        db,
        student_fee_id,
    )