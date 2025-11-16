from sqlalchemy.orm import Session
from ..models.user import User
from ..schemas.user import UserCreate
from ..utils.security import get_password_hash
from typing import Optional, List

def get_user_by_email(db: Session, email: Optional[str]):
    if email is None:
        return None
    return db.query(User).filter(User.email == email).first()

def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.user_id == user_id).first()

def create_user(db: Session, user: UserCreate):
    hashed_password = get_password_hash(user.password)
    
    # Check if this is the first user being registered
    is_first_user = db.query(User).count() == 0
    
    db_user = User(username=user.username, password_hash=hashed_password, is_admin=is_first_user)
    if user.email: # Only set email if provided
        db_user.email = user.email
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user_password(db: Session, user_id: int, new_password: str):
    db_user = get_user_by_id(db, user_id)
    if db_user:
        db_user.password_hash = get_password_hash(new_password)
        db.commit()
        db.refresh(db_user)
    return db_user

def reset_user_password(db: Session, user_id: int, default_password: str):
    db_user = get_user_by_id(db, user_id)
    if db_user:
        db_user.password_hash = get_password_hash(default_password)
        db.commit()
        db.refresh(db_user)
    return db_user

def get_all_users(db: Session) -> List[User]:
    return db.query(User).all()
