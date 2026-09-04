from __future__ import annotations

from decimal import Decimal

from pydantic import BaseModel, Field


class AdminDashboardResponse(BaseModel):
    total_users: int
    total_students: int
    total_faculty: int
    total_departments: int
    total_sections: int
    total_subjects: int


class FacultyDashboardResponse(BaseModel):
    faculty_id: int
    assigned_subjects: int
    assigned_sections: int
    total_students: int


class StudentDashboardResponse(BaseModel):
    student_id: int
    roll_no: str
    name: str
    semester: int
    department_id: int
    section_id: int

    total_results: int
    latest_gpa: Decimal | None
    cgpa: Decimal
    total_credits: Decimal


class DashboardResponse(BaseModel):
    role: str
    data: dict = Field(default_factory=dict)