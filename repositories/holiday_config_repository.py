from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import create_engine
from models.holiday_config_model import HolidayConfig
from utils.utils import resource_path

db_path = resource_path("database.db")
engine = create_engine(f"sqlite:///{db_path}", echo=False)

SessionFactory = sessionmaker(bind=engine)


class HolidayConfigRepository:
    def __init__(self):
        self.session = SessionFactory()

    def get_by_id(self, id):
        return self.session.query(HolidayConfig).filter_by(id=id).first()

    def get_page(self, page: int, page_size: int):
        offset = (page - 1) * page_size

        query = self.session.query(HolidayConfig)
        total = query.count()

        holidays = (
            query.order_by(HolidayConfig.date).offset(offset).limit(page_size).all()
        )

        return holidays, total

    def get_all(self):
        return self.session.query(HolidayConfig).order_by(HolidayConfig.date).all()

    # def create(self, date, name=None, desc=None):
    #     try:
    #         holiday_config = HolidayConfig(date=date)
    #         self.session.add(holiday_config)
    #         self.session.commit()
    #         return holiday_config
    #     except IntegrityError:
    #         self.session.rollback()
    #         raise

    def update(self, id, **kwargs):
        holiday_config = self.session.query(HolidayConfig).filter_by(id=id).first()
        if holiday_config:
            for key, value in kwargs.items():
                setattr(holiday_config, key, value)
            self.session.commit()
            return holiday_config
        return None

    def create(self, **kwargs):
        holiday_config = HolidayConfig(**kwargs)
        self.session.add(holiday_config)
        self.session.commit()
        return holiday_config

    def delete(self, id):
        holiday_config = self.session.query(HolidayConfig).filter_by(id=id).first()
        if holiday_config:
            self.session.delete(holiday_config)
            self.session.commit()
            return True
        return False

    def delete_all(self):
        """Xóa tất cả dữ liệu trong bảng HolidayConfig"""
        try:
            self.session.query(HolidayConfig).delete()
            self.session.commit()
        except Exception as e:
            self.session.rollback()  # Rollback nếu có lỗi
            print(f"An error occurred while deleting data: {e}")

    def rollback(self):
        self.session.rollback()
