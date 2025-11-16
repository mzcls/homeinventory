from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from .media import MediaResponse
from .category import CategoryResponse # Import CategoryResponse

class ItemBase(BaseModel):
    name: str
    location: Optional[str] = None
    quantity: int = 1
    category_id: Optional[int] = None # Changed from category: str

class ItemCreate(ItemBase):
    warehouse_id: int

class ItemUpdate(ItemBase):
    name: Optional[str] = None
    quantity: Optional[int] = None
    category_id: Optional[int] = None # Allow updating category

class ItemInDB(ItemBase):
    item_id: int
    warehouse_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ItemResponse(ItemBase):
    item_id: int
    warehouse_id: int
    category: Optional[CategoryResponse] = None # Include full category object
    media: List[MediaResponse] = []
    deleted_at: Optional[datetime] = None # Add deleted_at field

    class Config:
        from_attributes = True
