import uuid

from sqlalchemy import (
    Column,
    String,
    Integer,
    Date,
    ForeignKey,
)
from sqlalchemy.orm import relationship

from models.base import Base


class Result(Base):
    __tablename__ = "result"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    main_data_id = Column(String, ForeignKey("main_data.id"), nullable=False)
    level_config_id = Column(String, ForeignKey("level_config.id"), nullable=True)
    bonus_increase = Column(Integer, nullable=False, default=0)
    non_bonus_increase = Column(Integer, nullable=False, default=0)
    bonus_decrease = Column(Integer, nullable=False, default=0)
    non_bonus_decrease = Column(Integer, nullable=False, default=0)
    type = Column(Integer, nullable=False, default=0)
    payment_due_date = Column(Date, nullable=True, default=None)
    sorted_idx = Column(Integer, nullable=False, default=0)
    bonus_1 = Column(Integer, nullable=False, default=0)
    bonus_2 = Column(Integer, nullable=False, default=0)
    bonus_3 = Column(Integer, nullable=False, default=0)
    before_remain = Column(String, nullable=False, default="")
    after_remain = Column(String, nullable=False, default="")
    payment_due_date_1 = Column(Date, nullable=True, default=None)
    payment_due_date_2 = Column(Date, nullable=True, default=None)
    payment_due_date_3 = Column(Date, nullable=True, default=None)

    main_data = relationship("MainData")
    level_config = relationship("LevelConfig")

    def to_dict(self):
        res = self.main_data.to_dict() if self.main_data else {}
        res["id"] = self.id
        res["main_data_id"] = self.main_data_id
        res["level_config_id"] = self.level_config_id
        res["sorted_idx"] = self.sorted_idx
        res["type"] = self.type
        res["payment_due_date"] = self.payment_due_date
        res["bonus_decrease"] = self.bonus_decrease
        res["non_bonus_decrease"] = self.non_bonus_decrease
        res["bonus_increase"] = self.bonus_increase
        res["non_bonus_increase"] = self.non_bonus_increase
        res["payment_due_date_1"] = self.payment_due_date_1
        res["payment_due_date_2"] = self.payment_due_date_2
        res["payment_due_date_3"] = self.payment_due_date_3
        res["bonus_1"] = self.bonus_1
        res["bonus_2"] = self.bonus_2
        res["bonus_3"] = self.bonus_3
        res["before_remain"] = self.before_remain
        res["after_remain"] = self.after_remain
        return res
