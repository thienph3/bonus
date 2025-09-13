import uuid
import datetime

from sqlalchemy import (
    Column,
    String,
    Integer,
    Date,
)

from models.base import Base


class MainData(Base):
    __tablename__ = "main_data"
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    idx = Column(Integer, nullable=True)
    document_date = Column(Date, nullable=True)
    document_number = Column(String, nullable=True)
    description = Column(String, nullable=True)  # Không sử dụng nhưng vẫn lưu
    corresponding_account = Column(String, nullable=True)
    increase = Column(Integer, nullable=True)
    decrease = Column(Integer, nullable=True)
    adjust_increase = Column(Integer, nullable=True)
    adjust_decrease = Column(Integer, nullable=True)
    end_amount = Column(Integer, nullable=True)  # Không sử dụng nhưng vẫn lưu
    seasonal_code = Column(String, nullable=False)
    payment_period = Column(Integer, nullable=True)
    customer_code = Column(String, nullable=False)
    customer_name = Column(String, nullable=True)  # Không sử dụng nhưng vẫn lưu
    branch = Column(String, nullable=False)
    code = Column(String, nullable=True)
    sales_method = Column(String, nullable=False)

    def __repr__(self):
        return (
            f"<MainData(id={self.id!r}, document_date={self.document_date}, "
            f"document_number={self.document_number!r}, corresponding_account={self.corresponding_account!r}, "
            f"increase={self.increase}, decrease={self.decrease}, "
            f"adjust_increase={self.adjust_increase}, adjust_decrease={self.adjust_decrease}, "
            f"end_amount={self.end_amount}, seasonal_code={self.seasonal_code!r}, "
            f"payment_period={self.payment_period}, customer_code={self.customer_code!r}, "
            f"branch={self.branch!r}, sales_method={self.sales_method!r})>"
        )

    def to_dict(self):
        res = {}
        res["id"] = self.id
        res["idx"] = self.idx
        res["document_date"] = self.document_date
        res["document_number"] = self.document_number
        res["description"] = self.description
        res["corresponding_account"] = self.corresponding_account
        res["increase"] = self.increase
        res["decrease"] = self.decrease
        res["adjust_increase"] = self.adjust_increase
        res["adjust_decrease"] = self.adjust_decrease
        res["end_amount"] = self.end_amount
        res["seasonal_code"] = self.seasonal_code
        res["payment_period"] = self.payment_period
        res["customer_code"] = self.customer_code
        res["customer_name"] = self.customer_name
        res["branch"] = self.branch
        res["code"] = self.code
        res["sales_method"] = self.sales_method

        return res

    @staticmethod
    def empty_dict():
        res = {}
        res["id"] = None
        res["idx"] = 0
        res["document_date"] = datetime.date.today()
        res["document_number"] = ""
        res["description"] = ""
        res["corresponding_account"] = ""
        res["increase"] = 0
        res["decrease"] = 0
        res["adjust_increase"] = 0
        res["adjust_decrease"] = 0
        res["end_amount"] = 0
        res["seasonal_code"] = ""
        res["payment_period"] = 0
        res["customer_code"] = ""
        res["customer_name"] = ""
        res["branch"] = ""
        res["code"] = ""
        res["sales_method"] = ""

        return res
