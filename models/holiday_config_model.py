import uuid
import datetime

from sqlalchemy import (
    Column,
    String,
    Date,
)


from models.base import Base


class HolidayConfig(Base):
    __tablename__ = "holiday_config"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    date = Column(Date, unique=True, nullable=False)
    name = Column(String, nullable=True)
    desc = Column(String, nullable=True)

    def __repr__(self):
        return f"<HolidayConfig(id='{self.id}', date='{self.date}', name='{self.name}', desc='{self.desc}')>"

    def to_dict(self):
        res = {}
        res["id"] = self.id
        res["date"] = self.date
        res["name"] = self.name
        res["desc"] = self.desc

        return res

    @staticmethod
    def empty_dict():
        res = {}
        res["id"] = None
        res["date"] = datetime.date.today()
        res["name"] = ""
        res["desc"] = ""

        return res
