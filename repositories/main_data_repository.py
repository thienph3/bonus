from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import create_engine
from models.main_data_model import MainData

from utils.utils import resource_path

# Usage
db_path = resource_path("database.db")
engine = create_engine(f"sqlite:///{db_path}", echo=False)

# Tạo kết nối đến SQLite
# engine = create_engine('sqlite:///database.db', echo=False)

# Tạo Session
SessionFactory = sessionmaker(bind=engine)


class MainDataRepository:
    def __init__(self):
        self.session = SessionFactory()

    def create(
        self,
        idx,
        document_date,
        document_number,
        description,
        corresponding_account,
        increase,
        decrease,
        adjust_increase,
        adjust_decrease,
        end_amount,
        seasonal_code,
        payment_period,
        customer_code,
        customer_name,
        branch,
        code,
        sales_method,
    ):
        try:
            main_data = MainData(
                idx=idx,
                document_date=document_date,
                document_number=document_number,
                description=description,
                corresponding_account=corresponding_account,
                increase=increase,
                decrease=decrease,
                adjust_increase=adjust_increase,
                adjust_decrease=adjust_decrease,
                end_amount=end_amount,
                seasonal_code=seasonal_code,
                payment_period=payment_period,
                customer_code=customer_code,
                customer_name=customer_name,
                branch=branch,
                code=code,
                sales_method=sales_method,
            )
            self.session.add(main_data)
            self.session.commit()
            return main_data
        except IntegrityError:
            self.session.rollback()
            raise

    def bulk_create(self, data_list: dict, start=0, end=100) -> list[int]:
        batch = data_list[start:end]
        try:
            self.session.bulk_save_objects([MainData(**data) for data in batch])
            self.session.commit()
            return []
        except Exception as e:
            self.session.rollback()
            if len(batch) == 1:
                return [start]
            mid = (start + end) // 2
            return self.bulk_create(data_list, start, mid) + self.bulk_create(
                data_list, mid, end
            )

    def get_by_id(self, id):
        return self.session.query(MainData).filter_by(id=id).first()

    def get_page(self, page: int, page_size: int):
        offset = (page - 1) * page_size

        query = self.session.query(MainData)
        total = query.count()

        datas = query.order_by(MainData.idx).offset(offset).limit(page_size).all()

        return datas, total

    def get_all(self):
        return self.session.query(MainData).all()

    def update(self, id, **kwargs):
        main_data = self.session.query(MainData).filter_by(id=id).first()
        if main_data:
            for key, value in kwargs.items():
                setattr(main_data, key, value)
            self.session.commit()
            return main_data
        return None

    def create(self, **kwargs):
        holiday_config = MainData(**kwargs)
        self.session.add(holiday_config)
        self.session.commit()
        return holiday_config

    def delete(self, id):
        main_data = self.session.query(MainData).filter_by(id=id).first()
        if main_data:
            self.session.delete(main_data)
            self.session.commit()
            return True
        return False

    def delete_all(self):
        """Xóa tất cả dữ liệu trong bảng HolidayConfig"""
        try:
            self.session.query(MainData).delete()
            self.session.commit()
        except Exception as e:
            self.session.rollback()  # Rollback nếu có lỗi
            print(f"An error occurred while deleting data: {e}")

    def rollback(self):
        self.session.rollback()
