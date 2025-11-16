from sqlalchemy.orm import Session
from ..models.item_media import ItemMedia
from ..schemas.media import MediaCreate
from typing import Callable, Optional
import os
import shutil
from PIL import Image # For thumbnail generation
import io # Import io module
from ..utils.settings import settings # Import settings

# Define upload directories based on settings
UPLOAD_DIR = os.path.join(settings.upload_dir, "original")
THUMBNAIL_DIR = os.path.join(settings.upload_dir, "thumbnails")

# Ensure directories exist
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(THUMBNAIL_DIR, exist_ok=True)

def create_item_media(db: Session, media: dict):
    db_media = ItemMedia(**media)
    db.add(db_media)
    db.commit()
    db.refresh(db_media)
    return db_media

def get_media_by_id(db: Session, media_id: int):
    return db.query(ItemMedia).filter(ItemMedia.id == media_id).first()

def save_upload_file(upload_file_content: bytes, filename: str, file_type: str) -> tuple[str, Optional[str]]:
    """Saves the uploaded file and generates a thumbnail if it's an image, with compression."""
    file_extension = os.path.splitext(filename)[1].lower()
    unique_filename = f"{os.urandom(16).hex()}{file_extension}"
    
    original_filepath = os.path.join(UPLOAD_DIR, unique_filename)
    thumbnail_filepath = os.path.join(THUMBNAIL_DIR, unique_filename)

    file_url = f"/uploads/original/{unique_filename}"
    thumbnail_url: Optional[str] = None

    if file_type.startswith("image/"):
        try:
            # Open image from bytes
            img = Image.open(io.BytesIO(upload_file_content))

            # Save compressed original image
            if file_extension in ['.jpg', '.jpeg']:
                img.save(original_filepath, quality=80) # Compress JPEG
            elif file_extension == '.png':
                img.save(original_filepath, optimize=True) # Optimize PNG
            else:
                # For other image types, save without specific compression
                img.save(original_filepath)

            # Generate thumbnail
            img.thumbnail((128, 128)) # Generate a 128x128 thumbnail
            img.save(thumbnail_filepath)
            thumbnail_url = f"/uploads/thumbnails/{unique_filename}"

        except Exception as e:
            print(f"Error processing image {filename}: {e}")
            # Fallback: save original content if image processing fails
            with open(original_filepath, "wb") as buffer:
                buffer.write(upload_file_content)
    else:
        # For non-image files, save original content directly
        with open(original_filepath, "wb") as buffer:
            buffer.write(upload_file_content)
    
    return file_url, thumbnail_url # Return both original and thumbnail URLs

def delete_file(file_url: str):
    """Deletes the original and thumbnail files associated with a file_url."""
    if file_url.startswith("/uploads/original/"):
        filename = os.path.basename(file_url)
        original_filepath = os.path.join(UPLOAD_DIR, filename)
        thumbnail_filepath = os.path.join(THUMBNAIL_DIR, filename)

        if os.path.exists(original_filepath):
            os.remove(original_filepath)
        if os.path.exists(thumbnail_filepath):
            os.remove(thumbnail_filepath)

def delete_media_by_id(db: Session, media_id: int) -> bool:
    db_media = get_media_by_id(db, media_id)
    if db_media:
        file_url = db_media.file_url
        db.delete(db_media)
        db.commit()
        # After successfully deleting from DB, delete the file
        delete_file(file_url)
        return True
    return False
