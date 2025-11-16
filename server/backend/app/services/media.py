from sqlalchemy.orm import Session
from ..models.item_media import ItemMedia
from ..schemas.media import MediaCreate
from typing import Callable

def create_item_media(db: Session, media: dict):
    db_media = ItemMedia(**media)
    db.add(db_media)
    db.commit()
    db.refresh(db_media)
    return db_media

def get_media_by_id(db: Session, media_id: int):
    return db.query(ItemMedia).filter(ItemMedia.id == media_id).first()

def delete_media_by_id(db: Session, media_id: int, delete_file_callback: Callable[[str], None]) -> bool:
    db_media = get_media_by_id(db, media_id)
    if db_media:
        file_url = db_media.file_url
        db.delete(db_media)
        db.commit()
        # After successfully deleting from DB, delete the file
        delete_file_callback(file_url)
        return True
    return False
