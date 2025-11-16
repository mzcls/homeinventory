from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.user_warehouse import UserRole

class UserWarehouseBase(BaseModel):
    user_id: int
    warehouse_id: int
    role: UserRole

class UserWarehouseCreate(UserWarehouseBase):
    pass

class UserWarehouseResponse(UserWarehouseBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
