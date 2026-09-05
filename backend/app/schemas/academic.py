from __future__ import annotations

from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


# =========================================================
# SUBJECT RESULTS
# =========================================================

class CalculateSubjectRequest(BaseModel):
    subject_id: int = Field(gt=0)
    section_id: int = Field(gt=0)
    semester: int = Field(ge=1)
    academic_year: str = Field(min_length=1, max_length=20)
    policy_id: int | None = Field(default=None, gt=0)


class SubjectResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    subject_id: int
    policy_id: int

    semester: int
    academic_year: str

    normalized_score: Decimal
    raw_total: Decimal
    tee_score: Decimal

    grade: str
    grade_point: Decimal
    rank: int | None

    status: str


# =========================================================
# STUDENT RESULT FILTER
# =========================================================

class StudentResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    subject_id: int
    policy_id: int

    semester: int
    academic_year: str

    normalized_score: Decimal
    raw_total: Decimal
    tee_score: Decimal

    grade: str
    grade_point: Decimal
    rank: int | None

    status: str


# =========================================================
# GPA
# =========================================================

class CalculateGPARequest(BaseModel):
    student_id: int = Field(gt=0)
    semester: int = Field(ge=1)
    academic_year: str = Field(min_length=1, max_length=20)


class SemesterResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    semester: int
    academic_year: str

    gpa: Decimal
    total_credits: Decimal
    status: str


# =========================================================
# CGPA
# =========================================================

class StudentCGPAResponse(BaseModel):
    student_id: int
    cgpa: Decimal
    total_credits: Decimal
    semesters_completed: int