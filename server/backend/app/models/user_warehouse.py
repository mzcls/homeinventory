from sqlalchemy import Column, Integer, ForeignKey, Enum, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base
import enum

class UserRole(str, enum.Enum):
    owner = "owner"
    member = "member"

class UserWarehouse(Base):
    __tablename__ = "user_warehouse"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.user_id"), nullable=False)
    warehouse_id = Column(Integer, ForeignKey("warehouse.warehouse_id"), nullable=False)
    role = Column(Enum(UserRole), nullable=False, default=UserRole.member)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="user_warehouses")
    warehouse = relationship("Warehouse", back_populates="user_warehouses")

    __table_args__ = (UniqueConstraint("user_id", "warehouse_id", name="_user_warehouse_uc"),)
