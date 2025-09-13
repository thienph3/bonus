import pandas as pd

from typing import List

from models.level_config_model import LevelConfig
from repositories.level_config_repository import LevelConfigRepository
from utils.utils import parse_date, parse_number


class LevelConfigService:
    def __init__(self):
        self.repository = LevelConfigRepository()

    def import_data(self, file_path, log_func=print):
        try:
            df = pd.read_excel(file_path, sheet_name="level_config")

            if df.empty:
                log_func("⚠️ Sheet 'level_config' is empty.")
                return

            self.repository.delete_all()
            log_func("🗑️ Đã xóa dữ liệu cũ trong level_config.")

            count = 0
            for index, row in df.iterrows():
                seasonal_code = row["seasonal_code"]
                sales_method = row["sales_method"]
                payment_period = row["payment_period"]
                payment_period_1 = row["payment_period_1"]
                payment_period_2 = row["payment_period_2"]
                payment_period_3 = row["payment_period_3"]
                payment_due_date_1 = (
                    None
                    if pd.isna(row["payment_due_date_1"])
                    else row["payment_due_date_1"]
                )
                payment_due_date_2 = (
                    None
                    if pd.isna(row["payment_due_date_2"])
                    else row["payment_due_date_2"]
                )
                payment_due_date_3 = (
                    None
                    if pd.isna(row["payment_due_date_3"])
                    else row["payment_due_date_3"]
                )

                try:
                    payment_period = parse_number(payment_period)
                    payment_period_1 = parse_number(payment_period_1)
                    payment_period_2 = parse_number(payment_period_2)
                    payment_period_3 = parse_number(payment_period_3)
                    payment_due_date_1 = parse_date(payment_due_date_1)
                    payment_due_date_2 = parse_date(payment_due_date_2)
                    payment_due_date_3 = parse_date(payment_due_date_3)

                    self.repository.create(
                        **{
                            "seasonal_code": seasonal_code,
                            "sales_method": sales_method,
                            "payment_period": payment_period,
                            "payment_period_1": payment_period_1,
                            "payment_period_2": payment_period_2,
                            "payment_period_3": payment_period_3,
                            "payment_due_date_1": payment_due_date_1,
                            "payment_due_date_2": payment_due_date_2,
                            "payment_due_date_3": payment_due_date_3,
                        }
                    )
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

            log_func(f"✅ Đã nhập {count}/{len(df)} dòng dữ liệu vào level_config.")

        except Exception as e:
            log_func(f"❌ An error occurred while importing level_config: {e}")
            raise

    def get_all(self) -> List[LevelConfig]:
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
