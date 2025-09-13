import pandas as pd

from typing import List

from models.holiday_config_model import HolidayConfig
from repositories.holiday_config_repository import HolidayConfigRepository
from utils.utils import parse_date


class HolidayConfigService:
    def __init__(self):
        self.repository = HolidayConfigRepository()

    def import_data(self, file_path, log_func=print):
        try:
            df = pd.read_excel(file_path, sheet_name="holiday_config")
            if df.empty:
                log_func("Sheet 'holiday_config' is empty.")
                return

            self.repository.delete_all()
            log_func("🗑️ Đã xóa dữ liệu cũ trong holiday_config.")

            count = 0
            for index, row in df.iterrows():
                date = row["date"]
                try:
                    date = parse_date(date)
                    self.repository.create(**{"date": date})
                    count += 1
                    if count % 100 == 0:
                        log_func(f"Đã nhập row {count}/{len(df)}")

                except ValueError as ve:
                    log_func(
                        f"⚠️ ValueError in row {index + 1}: {ve}. Skipping. Row error: {row.to_dict()}"
                    )
                    self.repository.rollback()
                    continue
                except Exception as e:
                    log_func(
                        f"❌ Exception in row {index + 1}: {e}. Skipping. Row error: {row.to_dict()}"
                    )
                    self.repository.rollback()
                    continue

            log_func(f"✅ Đã nhập {count}/{len(df)} dòng dữ liệu vào holiday_config.")
        except Exception as e:
            log_func(f"❌ Error occurred: {e}")
            raise

    def get_all(self) -> List[HolidayConfig]:
        return self.repository.get_all()

    def get_page(self, page, page_size, filters, sort):
        items, total = self.repository.get_page(page, page_size)
        return [item.to_dict() for item in items], total

    def get(self, id):
        item = self.repository.get_by_id(id)
        return item.to_dict()

    # def add(self, name, date, desc):
    #     return self.repository.create(name, date, desc)

    def update(self, id, **kwargs):
        return self.repository.update(id, **kwargs)

    def create(self, **kwargs):
        return self.repository.create(**kwargs)

    def remove(self, id):
        return self.repository.delete(id)

    def rollback(self):
        return self.repository.rollback()
