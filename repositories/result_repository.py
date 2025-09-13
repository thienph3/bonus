from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import create_engine
from models.result_model import Result

from utils.utils import resource_path

# Usage
db_path = resource_path("database.db")
engine = create_engine(f"sqlite:///{db_path}", echo=False)

# Tạo kết nối đến SQLite
# engine = create_engine('sqlite:///database.db', echo=False)

# Tạo Session
SessionFactory = sessionmaker(bind=engine)


class ResultRepository:
    def __init__(self):
        self.session = SessionFactory()

    def create(
        self,
        main_data_id,
        level_config_id,
        bonus_increase,
        non_bonus_increase,
        bonus_decrease,
        non_bonus_decrease,
        type,
        payment_due_date,
        payment_due_date_1,
        payment_due_date_2,
        payment_due_date_3,
    ):
        try:
            result = Result(
                main_data_id=main_data_id,
                level_config_id=level_config_id,
                bonus_increase=bonus_increase,
                non_bonus_increase=non_bonus_increase,
                bonus_decrease=bonus_decrease,
                non_bonus_decrease=non_bonus_decrease,
                type=type,
                payment_due_date=payment_due_date,
                payment_due_date_1=payment_due_date_1,
                payment_due_date_2=payment_due_date_2,
                payment_due_date_3=payment_due_date_3,
            )
            self.session.add(result)
            self.session.commit()
            return result
        except IntegrityError:
            self.session.rollback()
            raise

    def bulk_create(self, data_list: dict, start=0, end=100) -> list[int]:
        batch = data_list[start:end]
        try:
            self.session.bulk_save_objects([Result(**data) for data in batch])
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
        return self.session.query(Result).filter_by(id=id).first()

    def get_page(self, page: int, page_size: int):
        offset = (page - 1) * page_size

        query = self.session.query(Result)
        total = query.count()

        results = (
            query.order_by(Result.sorted_idx).offset(offset).limit(page_size).all()
        )

        return results, total

    def get_all(self):
        return self.session.query(Result).all()

    def update(self, id, **kwargs):
        result = self.session.query(Result).filter_by(id=id).first()
        if result:
            for key, value in kwargs.items():
                setattr(result, key, value)
            self.session.commit()
            return result
        return None

    def bulk_update(self, data_list: list[dict], start=0, end=100) -> list[int]:
        batch = data_list[start:end]

        try:
            for data in batch:
                id_ = data.get("id")
                if not id_:
                    continue

                obj = self.session.query(Result).filter_by(id=id_).first()
                if not obj:
                    continue

                for key, value in data.items():
                    if key != "id":
                        setattr(obj, key, value)

            self.session.commit()
            return []
        except Exception as e:
            self.session.rollback()
            if len(batch) == 1:
                return [start]
            mid = (start + end) // 2
            return self.bulk_update(data_list, start, mid) + self.bulk_update(
                data_list, mid, end
            )

    def delete(self, id):
        result = self.session.query(Result).filter_by(id=id).first()
        if result:
            self.session.delete(result)
            self.session.commit()
            return True
        return False

    def delete_all(self):
        """Xóa tất cả dữ liệu trong bảng HolidayConfig"""
        try:
            self.session.query(Result).delete()
            self.session.commit()
        except Exception as e:
            self.session.rollback()  # Rollback nếu có lỗi
            print(f"An error occurred while deleting data: {e}")

    def rollback(self):
        self.session.rollback()
