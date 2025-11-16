from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas.media import MediaResponse
from ..schemas.response import ResponseModel # Import ResponseModel
from ..services import media as media_service
from ..services import item as item_service
from ..services import warehouse as warehouse_service
from ..routes.auth import get_current_user
from ..models.user import User
from ..models.item_media import FileType
# Removed: from ..utils.media import save_upload_file, delete_upload_file # These are now handled by media_service

router = APIRouter()

@router.post("/upload/{item_id}", response_model=ResponseModel[MediaResponse]) # Use ResponseModel
async def upload_item_media(
    item_id: int,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_item = item_service.get_item(db, item_id)
    if not db_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")

    # Check if user has access to the item's warehouse
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_item.warehouse_id)
    if user_role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this item's warehouse."
        )

    # Determine file type
    content_type = file.content_type
    if content_type.startswith("image/"):
        file_type = FileType.image
    elif content_type.startswith("video/"):
        file_type = FileType.video
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported file type")

    # Read file content
    file_content = await file.read()

    # Save the file using the service function
    file_url, thumbnail_url = media_service.save_upload_file(file_content, file.filename, content_type)

    media_create = {
        "item_id": item_id,
        "file_url": file_url,
        "thumbnail_url": thumbnail_url,
        "file_type": file_type
    }
    created_media = media_service.create_item_media(db, media_create)
    return ResponseModel(data=created_media, message="Media uploaded successfully") # Wrap response

@router.delete("/{media_id}", response_model=ResponseModel)
async def delete_media(
    media_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_media = media_service.get_media_by_id(db, media_id)
    if not db_media:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Media not found")

    # Check if user has access to the item's warehouse
    user_role = warehouse_service.get_user_warehouse_role(db, current_user.user_id, db_media.item.warehouse_id)
    if user_role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this item's warehouse."
        )

    # Delete the file and the database record using the service function
    deleted = media_service.delete_media_by_id(db, media_id) # No delete_file_callback needed
    if not deleted:
        # This case should ideally not be hit if the initial check passes
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Media not found during deletion")

    return ResponseModel(message="Media deleted successfully")