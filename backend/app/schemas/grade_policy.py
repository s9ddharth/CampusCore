from __future__ import annotations

from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class GradeBandCreate(BaseModel):
    grade: str = Field(min_length=1, max_length=5)
    minimum_score: Decimal = Field(ge=0)
    maximum_score: Decimal = Field(ge=0)
    grade_point: Decimal = Field(ge=0)


class GradeBandResponse(GradeBandCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    policy_id: int


class GradePolicyCreate(BaseModel):
    version: str = Field(min_length=1, max_length=50)
    name: str = Field(min_length=1, max_length=150)

    qualifying_threshold: Decimal = Field(ge=0)
    total_scale: Decimal = Field(gt=0)
    tee_pass_mark: Decimal = Field(ge=0)

    top_s_count: int = Field(ge=0)

    active: bool = True

    bands: list[GradeBandCreate] = Field(default_factory=list)


class GradePolicyResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    version: str
    name: str

    qualifying_threshold: Decimal
    total_scale: Decimal
    tee_pass_mark: Decimal

    top_s_count: int
    active: bool

    bands: list[GradeBandResponse] = Field(
        default_factory=list
    )