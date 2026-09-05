from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class FacultySubjectCreate(BaseModel):
    faculty_id: int = Field(gt=0)
    subject_id: int = Field(gt=0)
    section_id: int = Field(gt=0)


class FacultySubjectResponse(FacultySubjectCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime