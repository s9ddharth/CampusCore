# PS-6 ERP Backend

FastAPI + SQLAlchemy backend aligned to the PS-6 ERP blueprint.

## Run
```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
python -m app.seed
python -m uvicorn app.main:app --reload --port 8000
```

The seed creates the canonical tables and judge-friendly demo cases.

Demo users:
- Admin: `admin@erp.local` / `Admin@123`
- Faculty: `faculty@erp.local` / `Faculty@123`
- Student: `student1@erp.local` / `Student@123`
