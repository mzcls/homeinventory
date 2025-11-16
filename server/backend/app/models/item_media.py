from sqlalchemy import Column, Integer, String, ForeignKey, Enum, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base
import enum

class FileType(str, enum.Enum):
    image = "image"
    video = "video"

class ItemMedia(Base):
    __tablename__ = "item_media"

    id = Column(Integer, primary_key=True, index=True)
    item_id = Column(Integer, ForeignKey("item.item_id"), nullable=False)
    file_url = Column(String(2048), nullable=False)
    thumbnail_url = Column(String(2048))
    file_type = Column(Enum(FileType), nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    item = relationship("Item", back_populates="media")
