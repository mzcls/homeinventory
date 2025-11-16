from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas.category import CategoryCreate, CategoryResponse
from ..schemas.response import ResponseModel
from ..services import category as category_service
from ..services import warehouse as warehouse_service
from ..routes.auth import get_current_user
from ..models.user import User
from ..models.user_warehouse import UserRole

router = APIRouter()

async def check_warehouse_access_for_category(
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

@router.post("/", response_model=ResponseModel[CategoryResponse], status_code=status.HTTP_201_CREATED)
async def create_category_route(
    category: CategoryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure user has access to the warehouse
    await check_warehouse_access_for_category(category.warehouse_id, current_user, db)
    
    # Check if category name already exists for this warehouse
    existing_category = category_service.get_category_by_name_and_warehouse(db, category.name, category.warehouse_id)
    if existing_category:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Category with this name already exists in this warehouse.")

    created_category = category_service.create_category(db=db, category=category)
    return ResponseModel(data=created_category, message="Category created successfully")

@router.get("/warehouse/{warehouse_id}", response_model=ResponseModel[List[CategoryResponse]])
async def get_categories_in_warehouse(
    warehouse_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure user has access to the warehouse
    await check_warehouse_access_for_category(warehouse_id, current_user, db)
    categories = category_service.get_categories_by_warehouse(db=db, warehouse_id=warehouse_id)
    return ResponseModel(data=categories, message="Categories retrieved successfully")

@router.delete("/{category_id}", response_model=ResponseModel)
async def delete_category_route(
    category_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_category = category_service.get_category(db, category_id)
    if not db_category:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")

    # Ensure user has access to the warehouse of the category
    await check_warehouse_access_for_category(db_category.warehouse_id, current_user, db)

    # Only owner can delete categories
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_category.warehouse_id)
    if user_role != UserRole.owner:
         raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only owners can delete categories from this warehouse."
        )

    deleted = category_service.delete_category(db, category_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found for deletion")
    return ResponseModel(message="Category deleted successfully")
