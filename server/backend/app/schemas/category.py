from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CategoryBase(BaseModel):
    name: str

class CategoryCreate(CategoryBase):
    warehouse_id: int

class CategoryInDB(CategoryBase):
    category_id: int
    warehouse_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class CategoryResponse(CategoryBase):
    category_id: Optional[int] = None
    warehouse_id: Optional[int] = None

    class Config:
        from_attributes = True
