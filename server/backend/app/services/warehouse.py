from sqlalchemy.orm import Session
from typing import List, Optional

from ..models.warehouse import Warehouse
from ..models.user_warehouse import UserWarehouse, UserRole
from ..models.user import User
from ..schemas.warehouse import WarehouseCreate

def create_warehouse(db: Session, warehouse: WarehouseCreate, user_id: int):
    db_warehouse = Warehouse(
        name=warehouse.name,
        description=warehouse.description,
        created_by_user_id=user_id
    )
    db.add(db_warehouse)
    db.commit()
    db.refresh(db_warehouse)

    # Automatically add the creator as an owner of the warehouse
    db_user_warehouse = UserWarehouse(
        user_id=user_id,
        warehouse_id=db_warehouse.warehouse_id,
        role=UserRole.owner
    )
    db.add(db_user_warehouse)
    db.commit()
    db.refresh(db_user_warehouse)

    return db_warehouse

def get_all_warehouses(db: Session) -> List[Warehouse]:
    return db.query(Warehouse).all()

def get_user_warehouses(db: Session, user_id: int) -> List[Warehouse]:
    return (
        db.query(Warehouse)
        .join(UserWarehouse)
        .filter(UserWarehouse.user_id == user_id)
        .all()
    )

def get_user_warehouses_with_roles(db: Session, user_id: int) -> List[tuple[Warehouse, UserRole]]:
    return (
        db.query(Warehouse, UserWarehouse.role)
        .join(UserWarehouse, Warehouse.warehouse_id == UserWarehouse.warehouse_id)
        .filter(UserWarehouse.user_id == user_id)
        .all()
    )

def get_warehouse(db: Session, warehouse_id: int):
    return db.query(Warehouse).filter(Warehouse.warehouse_id == warehouse_id).first()

def get_user_warehouse_role(db: Session, user_id: int, warehouse_id: int) -> Optional[UserRole]:
    user_warehouse = (
        db.query(UserWarehouse)
        .filter(UserWarehouse.user_id == user_id, UserWarehouse.warehouse_id == warehouse_id)
        .first()
    )
    return user_warehouse.role if user_warehouse else None

def add_user_to_warehouse(db: Session, user_id: int, warehouse_id: int, role: UserRole):
    db_user_warehouse = UserWarehouse(
        user_id=user_id,
        warehouse_id=warehouse_id,
        role=role
    )
    db.add(db_user_warehouse)
    db.commit()
    db.refresh(db_user_warehouse)
    return db_user_warehouse

def update_user_warehouse_role(db: Session, user_id: int, warehouse_id: int, new_role: UserRole):
    db_user_warehouse = (
        db.query(UserWarehouse)
        .filter(UserWarehouse.user_id == user_id, UserWarehouse.warehouse_id == warehouse_id)
        .first()
    )
    if db_user_warehouse:
        db_user_warehouse.role = new_role
        db.commit()
        db.refresh(db_user_warehouse)
    return db_user_warehouse

def remove_user_from_warehouse(db: Session, user_id: int, warehouse_id: int):
    db_user_warehouse = (
        db.query(UserWarehouse)
        .filter(UserWarehouse.user_id == user_id, UserWarehouse.warehouse_id == warehouse_id)
        .first()
    )
    if db_user_warehouse:
        db.delete(db_user_warehouse)
        db.commit()
        return True
    return False

def invite_user_to_warehouse(db: Session, warehouse_id: int, invited_user_email: str, inviter_user_id: int):
    # Check if inviter is owner of the warehouse
    inviter_role = get_user_warehouse_role(db, inviter_user_id, warehouse_id)
    if inviter_role != UserRole.owner:
        return None # Or raise an exception for insufficient permissions

    # Find the user to be invited
    invited_user = db.query(User).filter(User.email == invited_user_email).first()
    if not invited_user:
        return None # User not found

    # Check if user is already part of the warehouse
    existing_user_warehouse = (
        db.query(UserWarehouse)
        .filter(UserWarehouse.user_id == invited_user.user_id, UserWarehouse.warehouse_id == warehouse_id)
        .first()
    )
    if existing_user_warehouse:
        return None # User already in warehouse

    # Add user to warehouse as a member
    db_user_warehouse = UserWarehouse(
        user_id=invited_user.user_id,
        warehouse_id=warehouse_id,
        role=UserRole.member
    )
    db.add(db_user_warehouse)
    db.commit()
    db.refresh(db_user_warehouse)
    return db_user_warehouse
