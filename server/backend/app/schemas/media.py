from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.item_media import FileType

class MediaBase(BaseModel):
    file_url: str
    file_type: FileType

class MediaCreate(MediaBase):
    item_id: int

class MediaInDB(MediaBase):
    id: int
    item_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class MediaResponse(MediaBase):
    id: int
    thumbnail_url: Optional[str] = None

    class Config:
        from_attributes = True
