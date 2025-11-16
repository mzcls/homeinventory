from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base

class Item(Base):
    __tablename__ = "item"

    item_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    location = Column(String(255))
    quantity = Column(Integer, default=1, nullable=False)
    warehouse_id = Column(Integer, ForeignKey("warehouse.warehouse_id"), nullable=False)
    category_id = Column(Integer, ForeignKey("category.category_id"), nullable=True) # New category_id field
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime, nullable=True) # Soft delete column

    warehouse = relationship("Warehouse", back_populates="items")
    category = relationship("Category", back_populates="items") # New relationship
    media = relationship("ItemMedia", back_populates="item")
