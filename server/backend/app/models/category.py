from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base

class Category(Base):
    __tablename__ = "category"

    category_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    warehouse_id = Column(Integer, ForeignKey("warehouse.warehouse_id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    warehouse = relationship("Warehouse", back_populates="categories")
    items = relationship("Item", back_populates="category")
