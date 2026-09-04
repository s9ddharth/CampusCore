from fastapi import FastAPI

from app.config import settings
from app.routes.auth import router as auth_router
from app.routes.departments import router as departments_router
from app.routes.faculty import router as faculty_router
from app.routes.sections import router as sections_router
from app.routes.subjects import router as subjects_router
from app.routes.users import router as users_router
from app.routes.faculty_subjects import router as faculty_subjects_router
from app.routes.students import router as students_router
from app.routes.attendance import router as attendance_router
from app.routes.fees import router as fees_router
from app.routes.payments import router as payments_router
from app.routes.audit_logs import router as audit_logs_router
from app.routes.academic import router as academic_router
from app.routes.academic import router as academic_router
from app.routes.grade_policy import router as grade_policy_router
from app.routes.reports import router as reports_router
from app.routes.dashboard import router as dashboard_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "message": "CampusCore API",
        "version": settings.app_version,
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "healthy",
    }


app.include_router(auth_router)
app.include_router(users_router)
app.include_router(departments_router)
app.include_router(sections_router)
app.include_router(subjects_router)
app.include_router(faculty_router)
app.include_router(faculty_subjects_router)
app.include_router(students_router)
app.include_router(attendance_router)
app.include_router(fees_router)
app.include_router(payments_router)
app.include_router(audit_logs_router)
app.include_router(academic_router)
app.include_router(academic_router)
app.include_router(grade_policy_router)
app.include_router(reports_router)
app.include_router(dashboard_router)