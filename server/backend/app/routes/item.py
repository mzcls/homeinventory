from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from ..database import get_db
from ..schemas.item import ItemCreate, ItemResponse, ItemUpdate
from ..schemas.response import ResponseModel
from ..services import item as item_service
from ..services import warehouse as warehouse_service
from ..services import category as category_service # Import category_service
from ..routes.auth import get_current_user
from ..models.user import User
from ..models.user_warehouse import UserRole
from ..models.item import Item

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

async def check_item_access(
    item_id: int,
    include_deleted: bool = False, # Add parameter
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_item = item_service.get_item(db, item_id, include_deleted=include_deleted) # Pass to service
    if not db_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_item.warehouse_id)
    if user_role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this item's warehouse."
        )
    return db_item

@router.post("/", response_model=ResponseModel[ItemResponse], status_code=status.HTTP_201_CREATED)
async def create_item_route(
    item: ItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure current user has access to the warehouse
    await check_warehouse_access(item.warehouse_id, current_user, db)
    
    # Validate category_id
    if item.category_id is not None:
        db_category = category_service.get_category(db, item.category_id)
        if not db_category or db_category.warehouse_id != item.warehouse_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid category_id for this warehouse")

    created_item = item_service.create_item(db=db, item=item)
    return ResponseModel(data=created_item, message="Item created successfully")

@router.get("/warehouse/{warehouse_id}", response_model=ResponseModel[List[ItemResponse]])
async def get_items_in_warehouse(
    warehouse_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure current user has access to the warehouse
    await check_warehouse_access(warehouse_id, current_user, db)
    items = item_service.get_items_by_warehouse(db=db, warehouse_id=warehouse_id)
    return ResponseModel(data=items, message="Items retrieved successfully")

@router.get("/warehouse/{warehouse_id}/deleted", response_model=ResponseModel[List[ItemResponse]])
async def get_deleted_items_in_warehouse(
    warehouse_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure current user has access to the warehouse
    await check_warehouse_access(warehouse_id, current_user, db)
    items = item_service.get_deleted_items_by_warehouse(db=db, warehouse_id=warehouse_id)
    return ResponseModel(data=items, message="Deleted items retrieved successfully")

@router.get("/search", response_model=ResponseModel[List[ItemResponse]])
async def search_items_globally(
    query: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Searches for items across all warehouses accessible by the current user.
    """
    items = item_service.search_all_items(db, current_user.user_id, query)
    return ResponseModel(data=items, message="Items found successfully")

@router.get("/{item_id}", response_model=ResponseModel[ItemResponse])
async def get_item_detail(
    item_id: int,
    include_deleted: bool = False, # Add query parameter
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Manually call the dependency with the parameter
    db_item = await check_item_access(item_id, include_deleted, current_user, db)
    return ResponseModel(data=db_item, message="Item details retrieved successfully")

@router.put("/{item_id}", response_model=ResponseModel[ItemResponse])
async def update_item_route(
    item_id: int,
    item_update: ItemUpdate,
    db_item: Item = Depends(check_item_access),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Only owner or member can update item
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_item.warehouse_id)
    if user_role not in [UserRole.owner, UserRole.member]:
         raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to update items in this warehouse."
        )
    
    # Validate category_id if it's being updated
    if item_update.category_id is not None:
        db_category = category_service.get_category(db, item_update.category_id)
        if not db_category or db_category.warehouse_id != db_item.warehouse_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid category_id for this warehouse")

    updated_item = item_service.update_item(db, item_id, item_update)
    if not updated_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found after update attempt")
    return ResponseModel(data=updated_item, message="Item updated successfully")


@router.delete("/{item_id}", response_model=ResponseModel, status_code=status.HTTP_200_OK)
async def delete_item_route(
    item_id: int,
    db_item: Item = Depends(check_item_access),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Only owner can delete items
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_item.warehouse_id)
    if user_role != UserRole.owner:
         raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only owners can delete items from this warehouse."
        )
    
    deleted_item = item_service.delete_item(db, item_id)
    if not deleted_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found for deletion")
    return ResponseModel(message="Item deleted successfully")

@router.post("/restore/{item_id}", response_model=ResponseModel[ItemResponse], status_code=status.HTTP_200_OK)
async def restore_item_route(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # We need to fetch the item including deleted ones to restore it
    db_item = item_service.get_item(db, item_id, include_deleted=True)
    if not db_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")

    # Only owner can restore items
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_item.warehouse_id)
    if user_role != UserRole.owner:
         raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only owners can restore items from this warehouse."
        )
    
    restored_item = item_service.restore_item(db, item_id)
    if not restored_item:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to restore item")
    return ResponseModel(data=restored_item, message="Item restored successfully")