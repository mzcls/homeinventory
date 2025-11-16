from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas.user import UserResponse
from ..schemas.warehouse import WarehouseResponse
from ..schemas.user_warehouse import UserWarehouseCreate, UserWarehouseResponse
from ..schemas.response import ResponseModel
from ..services import user as user_service
from ..services import warehouse as warehouse_service
from ..routes.auth import get_current_admin_user
from ..models.user import User
from ..models.user_warehouse import UserRole

router = APIRouter(prefix="/admin", tags=["admin"])

@router.get("/users", response_model=ResponseModel[List[UserResponse]])
async def get_all_users_route(
    current_admin_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    users = user_service.get_all_users(db)
    return ResponseModel(data=users, message="All users retrieved successfully")

@router.get("/warehouses", response_model=ResponseModel[List[WarehouseResponse]])
async def get_all_warehouses_route(
    current_admin_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    warehouses = warehouse_service.get_all_warehouses(db)
    return ResponseModel(data=warehouses, message="All warehouses retrieved successfully")

@router.post("/assign_warehouse", response_model=ResponseModel[UserWarehouseResponse])
async def assign_warehouse_to_user_route(
    user_warehouse_data: UserWarehouseCreate,
    current_admin_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    # Check if user and warehouse exist
    user = user_service.get_user_by_id(db, user_warehouse_data.user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    warehouse = warehouse_service.get_warehouse(db, user_warehouse_data.warehouse_id)
    if not warehouse:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Warehouse not found")

    # Check if assignment already exists
    existing_assignment = warehouse_service.get_user_warehouse_role(
        db, user_warehouse_data.user_id, user_warehouse_data.warehouse_id
    )
    if existing_assignment:
        # Update existing assignment
        updated_assignment = warehouse_service.update_user_warehouse_role(
            db, user_warehouse_data.user_id, user_warehouse_data.warehouse_id, user_warehouse_data.role
        )
        return ResponseModel(data=updated_assignment, message="User warehouse role updated successfully")
    else:
        # Create new assignment
        new_assignment = warehouse_service.add_user_to_warehouse(
            db, user_warehouse_data.user_id, user_warehouse_data.warehouse_id, user_warehouse_data.role
        )
        return ResponseModel(data=new_assignment, message="User assigned to warehouse successfully")

@router.delete("/remove_warehouse_assignment", response_model=ResponseModel)
async def remove_warehouse_assignment_route(
    user_id: int,
    warehouse_id: int,
    current_admin_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    success = warehouse_service.remove_user_from_warehouse(db, user_id, warehouse_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")
    return ResponseModel(message="User removed from warehouse successfully")

@router.put("/users/{user_id}/reset-password", response_model=ResponseModel)
async def reset_user_password_route(
    user_id: int,
    current_admin_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    updated_user = user_service.reset_user_password(db, user_id, "123456")
    if not updated_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return ResponseModel(message="User password reset to '123456' successfully")
