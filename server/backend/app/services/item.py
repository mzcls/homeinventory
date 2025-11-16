from sqlalchemy.orm import Session, joinedload
from sqlalchemy.sql import func
from typing import List, Optional

from ..models.item import Item
from ..models.user_warehouse import UserWarehouse, UserRole
from ..models.category import Category # Import Category model
from ..schemas.item import ItemCreate, ItemUpdate

def create_item(db: Session, item: ItemCreate):
    db_item = Item(**item.dict())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def get_item(db: Session, item_id: int, include_deleted: bool = False):
    query = db.query(Item).filter(Item.item_id == item_id)
    if not include_deleted:
        query = query.filter(Item.deleted_at == None)
    return query.first()

def get_items_by_warehouse(db: Session, warehouse_id: int) -> List[Item]:
    # Only return active (not soft-deleted) items
    return db.query(Item).filter(Item.warehouse_id == warehouse_id, Item.deleted_at == None).all()

def get_deleted_items_by_warehouse(db: Session, warehouse_id: int) -> List[Item]:
    # Return only soft-deleted items
    return db.query(Item).filter(Item.warehouse_id == warehouse_id, Item.deleted_at != None).all()

def search_all_items(db: Session, user_id: int, query: str) -> List[Item]:
    """
    Searches for items across all warehouses accessible by the user.
    Filters by item name, category name, and location.
    Excludes soft-deleted items.
    """
    search_pattern = f"%{query.lower()}%"
    
    return (
        db.query(Item)
        .join(UserWarehouse, Item.warehouse_id == UserWarehouse.warehouse_id)
        .outerjoin(Category, Item.category_id == Category.category_id) # Outerjoin to include items without category
        .filter(
            UserWarehouse.user_id == user_id,
            Item.deleted_at == None, # Exclude soft-deleted items
            (
                func.lower(Item.name).like(search_pattern) |
                func.lower(Item.location).like(search_pattern) |
                func.lower(func.coalesce(Category.name, '')).like(search_pattern) # Search by category name, handle None
            )
        )
        # .options(joinedload(Item.category)) # Eager load category for response - Removed for debugging 
        .all()
    )

def update_item(db: Session, item_id: int, item_update: ItemUpdate):
    db_item = get_item(db, item_id)
    if not db_item:
        return None
    
    update_data = item_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_item, key, value)
        
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def delete_item(db: Session, item_id: int):
    """
    Soft deletes an item by setting its deleted_at timestamp.
    """
    db_item = get_item(db, item_id)
    if not db_item:
        return None
    db_item.deleted_at = func.now()
    db.commit()
    db.refresh(db_item)
    return db_item

def restore_item(db: Session, item_id: int):
    """
    Restores a soft-deleted item by setting its deleted_at timestamp to None.
    """
    db_item = db.query(Item).filter(Item.item_id == item_id).first()
    if not db_item:
        return None
    db_item.deleted_at = None
    db.commit()
    db.refresh(db_item)
    return db_item
