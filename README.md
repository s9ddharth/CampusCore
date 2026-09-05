# CampusCore PS-6 ERP

CampusCore is the PS-6 ERP-based integrated student management system described in the supplied blueprint: one trusted student record powers admissions/student profiles, attendance, fees, exams/marks, academic evaluation, GPA/CGPA, reports and analytics.

## Current implementation

- Frontend: Flutter (web-first responsive UI)
- Backend: FastAPI + SQLAlchemy
- Database: SQLite by default, with PostgreSQL/MySQL-style relational modeling supported by SQLAlchemy
- Authentication: JWT + hashed passwords + role-based access
- Validation: Pydantic
- Reports: server-side PDF/XLSX generation
- Academic engine: configurable fail rules, relative ranking, top-5 S grades, A-E bands, credit-weighted GPA/CGPA
- Audit trail: `audit_logs` for sensitive changes

The blueprint lists React + Node.js + Express as the target stack, while this supplied repository was already implemented as Flutter + FastAPI. The implementation has been aligned to the blueprint's module surface, role rules, academic engine, seed cases, dashboard analytics and report outputs without replacing the existing Flutter application with a different frontend stack.

## Run

### Backend

```bash
cd backend
python -m venv .venv
# Windows
.venv\\Scripts\\activate
# macOS/Linux
# source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The backend creates `backend/erp_ps6.db` and seeds the demo data automatically on first startup.

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Set `apiBaseUrl` in `frontend/lib/main.dart` when the backend is hosted somewhere other than `http://127.0.0.1:8000`.

## Demo accounts

- Admin: `admin@erp.local` / `Admin@123`
- Faculty: `faculty@erp.local` / `Faculty@123`
- Student: `student1@erp.local` / `Student@123`

## Blueprint demo cases seeded

The demo database includes five eligible top performers for S-grade ranking, a TEE < 40 failure, a qualifying-total < 80 failure, pending/overdue fees, low attendance, an A-E grade spread, and a historical Semester 4 result so GPA and CGPA visibly differ.
