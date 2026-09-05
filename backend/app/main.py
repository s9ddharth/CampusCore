from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config.settings import settings
from app.api.auth import router as auth_router
from app.api.erp import router as erp_router
from app.database.database import SessionLocal, engine
from app.database.models import Base, User
from app.seed import seed


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth_router)
app.include_router(erp_router)


@app.on_event("startup")
def initialize_database() -> None:
    """Create the lightweight hackathon database and seed it once."""
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.query(User).count() == 0:
            seed(db)
    finally:
        db.close()


@app.get("/")
def root():
    return {
        "message": f"Welcome to {settings.app_name}",
        "version": settings.app_version,
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": settings.app_version,
    }