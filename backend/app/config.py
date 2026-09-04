from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "CampusCore"
    app_version: str = "1.0.0"

    database_url: str

    jwt_secret: str
    access_token_expire_minutes: int = 120

    server_host: str = "127.0.0.1"
    server_port: int = 8000

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()