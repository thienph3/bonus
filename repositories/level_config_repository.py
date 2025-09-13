from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import create_engine
from models.level_config_model import LevelConfig

from utils.utils import resource_path

# Usage
db_path = resource_path("database.db")
engine = create_engine(f"sqlite:///{db_path}", echo=False)

# Tạo kết nối đến SQLite
# engine = create_engine('sqlite:///database.db', echo=False)

# Tạo Session
SessionFactory = sessionmaker(bind=engine)


class LevelConfigRepository:
    def __init__(self):
        self.session = SessionFactory()

    def create(
        self,
        seasonal_code,
        sales_method,
        payment_period,
        payment_period_1,
        payment_period_2,
        payment_period_3,
        payment_due_date_1,
        payment_due_date_2,
        payment_due_date_3,
    ):
        try:
            level_config = LevelConfig(
                seasonal_code=seasonal_code,
                sales_method=sales_method,
                payment_period=payment_period,
                payment_period_1=payment_period_1,
                payment_period_2=payment_period_2,
                payment_period_3=payment_period_3,
                payment_due_date_1=payment_due_date_1,
                payment_due_date_2=payment_due_date_2,
                payment_due_date_3=payment_due_date_3,
            )
            self.session.add(level_config)
            self.session.commit()
            return level_config
        except IntegrityError:
            self.session.rollback()
            raise

    def get_by_id(self, id):
        return self.session.query(LevelConfig).filter_by(id=id).first()

    def get_page(self, page: int, page_size: int):
        offset = (page - 1) * page_size

        query = self.session.query(LevelConfig)
        total = query.count()

        levels = (
            query.order_by(
                LevelConfig.seasonal_code,
                LevelConfig.sales_method,
                LevelConfig.payment_period,
            )
            .offset(offset)
            .limit(page_size)
            .all()
        )

        return levels, total

    def get_all(self):
        return self.session.query(LevelConfig).all()

    def update(self, id, **kwargs):
        level_config = self.session.query(LevelConfig).filter_by(id=id).first()
        if level_config:
            for key, value in kwargs.items():
                setattr(level_config, key, value)
            self.session.commit()
            return level_config
        return None

    def create(self, **kwargs):
        holiday_config = LevelConfig(**kwargs)
        self.session.add(holiday_config)
        self.session.commit()
        return holiday_config

    def delete(self, id):
        level_config = self.session.query(LevelConfig).filter_by(id=id).first()
        if level_config:
            self.session.delete(level_config)
            self.session.commit()
            return True
        return False

    def delete_all(self):
        """Xóa tất cả dữ liệu trong bảng HolidayConfig"""
        try:
            self.session.query(LevelConfig).delete()
            self.session.commit()
        except Exception as e:
            self.session.rollback()  # Rollback nếu có lỗi
            print(f"An error occurred while deleting data: {e}")

    def rollback(self):
        self.session.rollback()
