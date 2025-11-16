from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from .user import UserResponse
from ..models.user_warehouse import UserRole

class WarehouseBase(BaseModel):
    name: str
    description: Optional[str] = None

class WarehouseCreate(WarehouseBase):
    pass

class WarehouseInDB(WarehouseBase):
    warehouse_id: int
    created_by_user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class WarehouseResponse(WarehouseBase):
    warehouse_id: int
    created_by_user_id: int
    creator: UserResponse # To show who created it

    class Config:
        from_attributes = True

class WarehouseWithUserRoleResponse(WarehouseResponse):
    role: UserRole # Add the user's role in this warehouse

    class Config:
        from_attributes = True

class UserWarehouseBase(BaseModel):
    user_id: int
    warehouse_id: int
    role: UserRole

class UserWarehouseInDB(UserWarehouseBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserWarehouseResponse(UserWarehouseBase):
    id: int
    user: UserResponse # To show which user is associated

    class Config:
        from_attributes = True
