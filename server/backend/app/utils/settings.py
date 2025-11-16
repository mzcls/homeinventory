# server/backend/app/utils/settings.py
from pydantic_settings import BaseSettings, SettingsConfigDict
import os

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Default upload directory relative to the project root
    # Can be overridden by UPLOAD_DIR environment variable or .env file
    upload_dir: str = "uploads"
    
    # FastAPI app settings
    app_name: str = "Home Inventory API"
    secret_key: str = "YOUR_SUPER_SECRET_KEY" # TODO: Change this in production
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

# Ensure the upload directory is absolute
settings = Settings()
if not os.path.isabs(settings.upload_dir):
    settings.upload_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), settings.upload_dir)
