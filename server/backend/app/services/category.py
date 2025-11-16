from sqlalchemy.orm import Session
from ..models.category import Category
from ..models.item import Item # Import Item model
from ..schemas.category import CategoryCreate

def create_category(db: Session, category: CategoryCreate):
    db_category = Category(name=category.name, warehouse_id=category.warehouse_id)
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

def get_category(db: Session, category_id: int):
    return db.query(Category).filter(Category.category_id == category_id).first()

def get_category_by_name_and_warehouse(db: Session, name: str, warehouse_id: int):
    return db.query(Category).filter(Category.name == name, Category.warehouse_id == warehouse_id).first()

def get_categories_by_warehouse(db: Session, warehouse_id: int):
    return db.query(Category).filter(Category.warehouse_id == warehouse_id).all()

def delete_category(db: Session, category_id: int) -> dict:
    db_category = db.query(Category).filter(Category.category_id == category_id).first()
    if not db_category:
        return {"success": False, "message": "Category not found"}
    
    # Check if any active items are using this category
    associated_items_count = db.query(Item).filter(Item.category_id == category_id, Item.deleted_at == None).count()
    if associated_items_count > 0:
        return {"success": False, "message": "Category is in use by active items and cannot be deleted"}

    db.delete(db_category)
    db.commit()
    return {"success": True, "message": "Category deleted successfully"}
