import uuid
import datetime

from sqlalchemy import (
    Column,
    String,
    Integer,
    Date,
    UniqueConstraint,
)

from models.base import Base


class LevelConfig(Base):
    __tablename__ = "level_config"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    seasonal_code = Column(String, nullable=False)
    sales_method = Column(String, nullable=False)
    payment_period = Column(Integer, nullable=False)
    payment_period_1 = Column(Integer, nullable=False)
    payment_period_2 = Column(Integer, nullable=False)
    payment_period_3 = Column(Integer, nullable=False)
    payment_due_date_1 = Column(Date, nullable=True)
    payment_due_date_2 = Column(Date, nullable=True)
    payment_due_date_3 = Column(Date, nullable=True)

    __table_args__ = (
        UniqueConstraint(
            "seasonal_code", "sales_method", "payment_period", name="uq_level_config"
        ),
    )

    def __repr__(self):
        return (
            f"<LevelConfig(id='{self.id}', seasonal_code='{self.seasonal_code}', "
            f"sales_method='{self.sales_method}', payment_period={self.payment_period}, "
            f"payment_due_date_1={self.payment_period_1}, payment_due_date_2={self.payment_period_2}, "
            f"payment_due_date_1={self.payment_period_3}, "
            f"payment_due_date_1={self.payment_due_date_1}, payment_due_date_2={self.payment_due_date_2}, "
            f"payment_due_date_3={self.payment_due_date_3})>"
        )

    def to_dict(self):
        res = {}
        res["id"] = self.id
        res["seasonal_code"] = self.seasonal_code
        res["sales_method"] = self.sales_method
        res["payment_period"] = self.payment_period
        res["payment_period_1"] = self.payment_period_1
        res["payment_period_2"] = self.payment_period_2
        res["payment_period_3"] = self.payment_period_3
        res["payment_due_date_1"] = self.payment_due_date_1
        res["payment_due_date_2"] = self.payment_due_date_2
        res["payment_due_date_3"] = self.payment_due_date_3

        return res

    @staticmethod
    def empty_dict():
        res = {}
        res["id"] = None
        res["seasonal_code"] = ""
        res["sales_method"] = ""
        res["payment_period"] = 0
        res["payment_period_1"] = 0
        res["payment_period_2"] = 0
        res["payment_period_3"] = 0
        res["payment_due_date_1"] = datetime.date.today()
        res["payment_due_date_2"] = datetime.date.today()
        res["payment_due_date_3"] = datetime.date.today()

        return res
