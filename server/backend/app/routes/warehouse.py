from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas.warehouse import WarehouseCreate, WarehouseResponse, UserWarehouseResponse, WarehouseWithUserRoleResponse
from ..schemas.user import UserResponse # Import UserResponse
from ..schemas.response import ResponseModel # Import ResponseModel
from ..services import warehouse as warehouse_service
from ..routes.auth import get_current_user, get_current_admin_user
from ..models.user import User
from ..models.user_warehouse import UserRole

router = APIRouter()

async def check_warehouse_access(
    warehouse_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, warehouse_id)
    if user_role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this warehouse."
        )
    return user_role

@router.post("/", response_model=ResponseModel[WarehouseResponse], status_code=status.HTTP_201_CREATED) # Use ResponseModel
def create_new_warehouse(
    warehouse: WarehouseCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    created_warehouse = warehouse_service.create_warehouse(db=db, warehouse=warehouse, user_id=current_user.user_id)
    return ResponseModel(data=created_warehouse, message="Warehouse created successfully") # Wrap response

@router.get("/", response_model=ResponseModel[List[WarehouseResponse]]) # Use ResponseModel
def get_warehouses_for_user(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    warehouses = warehouse_service.get_user_warehouses(db=db, user_id=current_user.user_id) # Call the new service function
    return ResponseModel(data=warehouses, message="Warehouses retrieved successfully") # Wrap response

@router.get("/user/{user_id}", response_model=ResponseModel[List[WarehouseWithUserRoleResponse]])
def get_user_warehouses_route(
    user_id: int,
    current_admin_user: User = Depends(get_current_admin_user), # Corrected dependency
    db: Session = Depends(get_db)
):
    warehouses_with_roles = warehouse_service.get_user_warehouses_with_roles(db=db, user_id=user_id) # Call the new service function
    # Map the results to the new schema
    response_data = []
    for warehouse, role in warehouses_with_roles:
        response_data.append(WarehouseWithUserRoleResponse(
            warehouse_id=warehouse.warehouse_id,
            name=warehouse.name,
            description=warehouse.description,
            created_by_user_id=warehouse.created_by_user_id,
            creator=UserResponse(user_id=warehouse.creator.user_id, username=warehouse.creator.username, is_admin=warehouse.creator.is_admin), # Manually create UserResponse
            role=role
        ))
    return ResponseModel(data=response_data, message="User's warehouses retrieved successfully")

@router.post("/{warehouse_id}/invite", response_model=ResponseModel[UserWarehouseResponse]) # Use ResponseModel
def invite_user_to_warehouse_route(
    warehouse_id: int,
    invited_user_email: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Check if current_user is owner of the warehouse
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, warehouse_id)
    if user_role != UserRole.owner:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only warehouse owners can invite users."
        )

    invited_user_warehouse = warehouse_service.invite_user_to_warehouse(
        db, warehouse_id, invited_user_email, current_user.user_id
    )
    if invited_user_warehouse is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User not found, or already a member, or inviter is not owner."
        )
    return ResponseModel(data=invited_user_warehouse, message="User invited to warehouse successfully")