from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base

class Warehouse(Base):
    __tablename__ = "warehouse"

    warehouse_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    created_by_user_id = Column(Integer, ForeignKey("user.user_id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    creator = relationship("User", back_populates="warehouses_created")
    user_warehouses = relationship("UserWarehouse", back_populates="warehouse")
    items = relationship("Item", back_populates="warehouse")
    categories = relationship("Category", back_populates="warehouse") # New relationship
