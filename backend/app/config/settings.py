from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "PS-6 ERP Student Management System"
    app_version: str = "1.0.0"

    # Database connection is loaded from backend/.env
    database_url: str

    jwt_secret_key: str = "change-this-secret-in-production"
    access_token_expire_minutes: int = 1440

    cors_origins: str = "*"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def cors_origin_list(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_origins.split(",")
            if origin.strip()
        ] or ["*"]


settings = Settings()