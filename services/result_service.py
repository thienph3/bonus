from datetime import date, timedelta, datetime
from typing import List

from models.holiday_config_model import HolidayConfig
from models.level_config_model import LevelConfig
from models.main_data_model import MainData
from models.result_model import Result
from repositories.result_repository import ResultRepository
from repositories.holiday_config_repository import HolidayConfigRepository
from repositories.level_config_repository import LevelConfigRepository
from repositories.main_data_repository import MainDataRepository


class ResultService:
    def __init__(self):
        # Khởi tạo repository
        self.repository = ResultRepository()
        self.holiday_config_repo = HolidayConfigRepository()
        self.level_config_repo = LevelConfigRepository()
        self.main_data_repo = MainDataRepository()

    def calculate_result(self, log_func=print, sub_step_func=None):
        log_func("Load toàn bộ holiday_config lên RAM...")
        holidays = self.holiday_config_repo.get_all()
        log_func("Load toàn bộ level_config lên RAM...")
        levels = self.level_config_repo.get_all()
        log_func("Load toàn bộ main_data lên RAM...")
        datas = self.main_data_repo.get_all()
        try:
            log_func("Xóa toàn bộ result đang có trong hệ thống...")
            self.repository.delete_all()

            holiday_set: set = set([holiday.date for holiday in holidays])

            sorted_levels: list[LevelConfig] = sorted(
                levels,
                key=lambda level: (
                    level.seasonal_code,  # asc
                    level.sales_method,  # asc
                    -level.payment_period,  # desc
                ),
            )

            # Create result for ALL main_data records
            data_with_level_dict: dict[str, tuple[str, str, str]] = (
                {}
            )  # data_id -> (level_id, status, message)
            for data in datas:
                level_id = None
                status = "invalid"
                message = ""

                if data.payment_period is None:
                    message = "Payment period is null"
                elif not data.seasonal_code or not data.sales_method:
                    message = "Missing seasonal_code or sales_method"
                else:
                    # Find matching level
                    for level in sorted_levels:
                        if (
                            data.seasonal_code == level.seasonal_code
                            and data.sales_method == level.sales_method
                            and data.payment_period >= level.payment_period
                        ):
                            level_id = level.id
                            status = "valid"
                            message = ""
                            break

                    if not level_id:
                        message = f"No matching level config for seasonal_code={data.seasonal_code}, sales_method={data.sales_method}, payment_period={data.payment_period}"

                data_with_level_dict[data.id] = (level_id, status, message)

            level_dict: dict[str, LevelConfig] = {level.id: level for level in levels}
            data_dict: dict[str, MainData] = {data.id: data for data in datas}

            log_func("Bắt đầu khởi tạo kết quả...")
            if sub_step_func:
                sub_step_func(1)
            idx = 0
            batch = []
            total = 0
            batch_size = 100
            for data_id in data_with_level_dict:
                data: MainData = data_dict[data_id]
                level_id, calc_status, calc_message = data_with_level_dict[data_id]
                level: LevelConfig | None = (
                    level_dict[level_id]
                    if level_id and level_id in level_dict
                    else None
                )

                increase = data.increase or 0
                decrease = data.decrease or 0
                adjust_increase = data.adjust_increase or 0
                adjust_decrease = data.adjust_decrease or 0

                bonus_increase = adjust_increase
                non_bonus_increase = increase - adjust_increase
                bonus_decrease = decrease - adjust_decrease
                non_bonus_decrease = adjust_decrease
                if bonus_decrease > 0 or non_bonus_decrease > 0:
                    type = 0
                elif bonus_increase > 0 or non_bonus_increase > 0:
                    type = 1
                else:
                    type = -1

                payment_due_date = (
                    data.document_date + timedelta(days=data.payment_period or 0)
                    if data.document_date
                    else date(1900, 1, 1)
                )
                if type == 1:
                    payment_due_date_1 = (
                        (
                            level.payment_due_date_1
                            or (
                                (
                                    data.document_date
                                    + timedelta(days=level.payment_period_1 or 0)
                                )
                                if data.document_date
                                else date(1900, 1, 1)
                            )
                        )
                        if level
                        else date(1900, 1, 1)
                    )
                    payment_due_date_2 = (
                        (
                            level.payment_due_date_2
                            or (
                                (
                                    data.document_date
                                    + timedelta(days=level.payment_period_2 or 0)
                                )
                                if data.document_date
                                else date(1900, 1, 1)
                            )
                        )
                        if level
                        else date(1900, 1, 1)
                    )
                    payment_due_date_3 = (
                        (
                            level.payment_due_date_3
                            or (
                                (
                                    data.document_date
                                    + timedelta(days=level.payment_period_3 or 0)
                                )
                                if data.document_date
                                else date(1900, 1, 1)
                            )
                        )
                        if level
                        else date(1900, 1, 1)
                    )

                    payment_due_date_1 = self._change_date_by_holidays(
                        payment_due_date_1, holiday_set
                    )
                    payment_due_date_2 = self._change_date_by_holidays(
                        payment_due_date_2, holiday_set
                    )
                    payment_due_date_3 = self._change_date_by_holidays(
                        payment_due_date_3, holiday_set
                    )
                else:
                    payment_due_date_1 = None
                    payment_due_date_2 = None
                    payment_due_date_3 = None

                result = {
                    "main_data_id": data_id,
                    "level_config_id": level_id,
                    "sorted_idx": 0,  # Will be set later for FIFO calculation
                    "original_idx": idx,  # Keep original input order
                    "type": type,
                    "payment_due_date": payment_due_date,
                    "bonus_decrease": bonus_decrease,
                    "non_bonus_decrease": non_bonus_decrease,
                    "bonus_increase": bonus_increase,
                    "non_bonus_increase": non_bonus_increase,
                    "payment_due_date_1": payment_due_date_1,
                    "payment_due_date_2": payment_due_date_2,
                    "payment_due_date_3": payment_due_date_3,
                    "bonus_1": 0,
                    "bonus_2": 0,
                    "bonus_3": 0,
                    "calculate_status": calc_status,
                    "calculate_message": calc_message,
                }
                batch.append((idx, result))

                if len(batch) >= batch_size:
                    batch_data = [d for (_, d) in batch]
                    error_indexes = self.repository.bulk_create(batch_data)
                    total += len(batch_data) - len(error_indexes)
                    log_func(f"✅ Đã tạo {total} dòng kết quả...")

                    for i in error_indexes:
                        row_num, error_row = batch[i]
                        log_func(f"❌ Insert failed at row {row_num}: {error_row}")

                    batch.clear()
                idx += 1

            # Insert remaining rows
            if batch:
                batch_data = [d for (_, d) in batch]
                error_indexes = self.repository.bulk_create(batch_data)
                total += len(batch_data) - len(error_indexes)
                log_func(f"✅ Đã tạo {total} dòng kết quả...")
                for i in error_indexes:
                    row_num, error_row = batch[i]
                    log_func(f"❌ Insert failed at row {row_num}: {error_row}")

            log_func("Đang sắp xếp kết quả cho tính toán thưởng...")
            if sub_step_func:
                sub_step_func(2)
            # Sort only valid records for bonus calculation and update sorted_idx
            results: list[Result] = self.repository.get_all()
            valid_results = [
                r for r in results if r.calculate_status == "valid" and r.type != -1
            ]
            sorted_valid_results: list[Result] = sorted(
                valid_results,
                key=lambda result: (
                    result.main_data.customer_code,  # asc
                    result.main_data.branch,  # asc
                    result.main_data.seasonal_code,  # asc
                    result.type,  # asc
                    result.payment_due_date,  # asc
                    -result.bonus_decrease,  # desc
                    -result.non_bonus_decrease,  # desc
                    -result.bonus_increase,  # desc
                    -result.non_bonus_increase,  # desc
                ),
            )

            # Update sorted_idx for FIFO calculation
            batch = []
            total = 0
            batch_size = 100
            for index, result in enumerate(sorted_valid_results):
                result2 = {
                    "id": result.id,
                    "sorted_idx": index,
                }
                batch.append((index, result2))

                if len(batch) >= batch_size:
                    batch_data = [d for (_, d) in batch]
                    error_indexes = self.repository.bulk_update(batch_data)
                    total += len(batch_data) - len(error_indexes)
                    log_func(f"✅ Đã sắp xếp {total} dòng kết quả...")
                    batch.clear()

            if batch:
                batch_data = [d for (_, d) in batch]
                error_indexes = self.repository.bulk_update(batch_data)
                total += len(batch_data) - len(error_indexes)
                log_func(f"✅ Đã sắp xếp {total} dòng kết quả...")
                batch.clear()

            # calculate result - use sorted valid results for calculation
            log_func("Bắt đầu tính toán kết quả...")
            if sub_step_func:
                sub_step_func(3)
            sorted_results = sorted_valid_results

            customer_code, branch, seasonal_code, before_remain = "", "", "", []
            batch = []
            total = 0
            batch_size = 100
            for result in sorted_results:
                # Thay doi customer_code, hoac branch, hoac MaVuViec thi phai reset cai list.
                if (
                    customer_code != result.main_data.customer_code
                    or branch != result.main_data.branch
                    or seasonal_code != result.main_data.seasonal_code
                ):
                    customer_code, branch, seasonal_code, before_remain = (
                        result.main_data.customer_code,
                        result.main_data.branch,
                        result.main_data.seasonal_code,
                        [],
                    )

                # Skip empty document numbers
                number = result.main_data.document_number
                if number == "":
                    continue

                (
                    _type,
                    bonus_decrease,
                    non_bonus_decrease,
                    bonus_increase,
                    non_bonus_increase,
                ) = (
                    result.type,
                    result.bonus_decrease,
                    result.non_bonus_decrease,
                    result.bonus_increase,
                    result.non_bonus_increase,
                )

                result.before_remain = str(before_remain)

                if _type == -1:
                    pass
                elif _type == 0:  # decrease
                    if bonus_decrease > 0:  # bonus
                        amount = bonus_decrease
                        item = {
                            "type": "decrease",
                            "sub_type": "bonus",
                            "amount": amount,
                            "date": result.main_data.document_date,
                        }
                        before_remain.append(item)
                    else:  # non_bonus
                        amount = non_bonus_decrease
                        item = {
                            "type": "decrease",
                            "sub_type": "non_bonus",
                            "amount": amount,
                            "date": result.main_data.document_date,
                        }
                        before_remain.append(item)
                else:  # increase
                    if bonus_increase > 0:  # bonus
                        amount = bonus_increase
                        while amount > 0 and len(before_remain) > 0:
                            first_remain = before_remain[0]
                            mi = min(amount, first_remain["amount"])
                            amount -= mi
                            first_remain["amount"] -= mi

                            if first_remain["sub_type"] == "bonus":
                                if first_remain["date"] <= result.payment_due_date_1:
                                    result.bonus_1 += mi
                                elif first_remain["date"] <= result.payment_due_date_2:
                                    result.bonus_2 += mi
                                elif first_remain["date"] <= result.payment_due_date_3:
                                    result.bonus_3 += mi

                            if first_remain["amount"] <= 0:  # == 0
                                before_remain.pop(0)  # remove first item
                    else:  # non_bonus
                        amount = non_bonus_increase
                        while amount > 0 and len(before_remain) > 0:
                            first_remain = before_remain[0]
                            mi = min(amount, first_remain["amount"])
                            amount -= mi
                            first_remain["amount"] -= mi

                            if first_remain["amount"] <= 0:  # == 0
                                before_remain.pop(0)  # remove first item

                result.after_remain = str(before_remain)
                result2 = {
                    "id": result.id,
                    "bonus_1": result.bonus_1,
                    "bonus_2": result.bonus_2,
                    "bonus_3": result.bonus_3,
                    "before_remain": result.before_remain,
                    "after_remain": result.after_remain,
                }
                batch.append((idx, result2))

                if len(batch) >= batch_size:
                    batch_data = [d for (_, d) in batch]
                    error_indexes = self.repository.bulk_update(batch_data)
                    total += len(batch_data) - len(error_indexes)
                    log_func(f"✅ Đã tính toán {total} dòng kết quả...")

                    for i in error_indexes:
                        row_num, error_row = batch[i]
                        log_func(f"❌ Update failed at row {row_num}: {error_row}")

                    batch.clear()

            if batch:
                batch_data = [d for (_, d) in batch]
                error_indexes = self.repository.bulk_update(batch_data)
                total += len(batch_data) - len(error_indexes)
                log_func(f"✅ Đã tính toán {total} dòng kết quả...")

                for i in error_indexes:
                    row_num, error_row = batch[i]
                    log_func(f"❌ Update failed at row {row_num}: {error_row}")

                batch.clear()

            if sub_step_func:
                sub_step_func(4)

        except Exception as e:
            log_func(f"An error occurred: {e}")

    def get_all(self) -> List[Result]:
        return self.repository.get_all()

    def get_page(self, page, page_size, filters, sort):
        items, total = self.repository.get_page(page, page_size)
        return [item.to_dict() for item in items], total

    def get(self, id):
        item = self.repository.get_by_id(id)
        return item.to_dict()

    def add(self, name, date, desc):
        return self.repository.create(name, date, desc)

    def update(self, id, **kwargs):
        return self.repository.update(id, **kwargs)

    def remove(self, id):
        return self.repository.delete(id)

    def _change_date_by_holidays(self, date, holiday_set):
        if not date:
            return None
        if date not in holiday_set:
            return date
        return self._change_date_by_holidays(date + timedelta(days=1), holiday_set)

    def _balance_bonus(remain):
        if remain["bonus"] < 0:
            remain["non_bonus"] += remain["bonus"]
            remain["bonus"] = 0

    def _balance_non_bonus(remain):
        if remain["non_bonus"] < 0:
            remain["bonus"] += remain["non_bonus"]
            remain["non_bonus"] = 0

    def rollback(self):
        return self.repository.rollback()
