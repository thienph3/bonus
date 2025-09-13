import datetime
import pandas as pd
from PyQt6.QtCore import QObject, pyqtSignal
from models.result_model import Result
from services.result_service import ResultService


class ExportResultWorker(QObject):
    finished = pyqtSignal()
    error = pyqtSignal(str)
    log_signal = pyqtSignal(str)

    def __init__(self, file_path):
        super().__init__()
        self.file_path = file_path
        self.result_service = ResultService()

    def run(self):
        try:
            self.log_signal.emit("📤 Đang lấy dữ liệu kết quả...")
            results: list[Result] = self.result_service.get_all()
            results = sorted(
                results, key=lambda result: (result.original_idx)
            )  # Keep original input order
            results = [result.to_dict() for result in results]

            self.log_signal.emit("📤 Đang tạo DataFrame...")
            df = pd.DataFrame(results)
            df["document_date"] = df["document_date"].apply(self.to_excel_serial)
            df["payment_due_date"] = df["payment_due_date"].apply(self.to_excel_serial)
            df["payment_due_date_1"] = df["payment_due_date_1"].apply(
                self.to_excel_serial
            )
            df["payment_due_date_2"] = df["payment_due_date_2"].apply(
                self.to_excel_serial
            )
            df["payment_due_date_3"] = df["payment_due_date_3"].apply(
                self.to_excel_serial
            )

            self.log_signal.emit("📤 Đang ghi file Excel...")
            with pd.ExcelWriter(self.file_path, engine="xlsxwriter") as writer:
                df.to_excel(writer, index=False)

                workbook = writer.book
                worksheet = writer.sheets["Sheet1"]
                date_format = workbook.add_format({"num_format": "dd/mm/yyyy"})
                vnd_accounting_format = workbook.add_format({"num_format": "#,##0"})

                for idx, col in enumerate(df.columns):
                    max_len = max(df[col].astype(str).map(len).max(), len(str(col)))
                    max_len += 2

                    if col in [
                        "document_date",
                        "payment_due_date",
                        "payment_due_date_1",
                        "payment_due_date_2",
                        "payment_due_date_3",
                    ]:
                        worksheet.set_column(idx, idx, max_len, date_format)
                    elif col in [
                        "increase",
                        "decrease",
                        "adjust_increase",
                        "adjust_decrease",
                        "bonus_increase",
                        "non_bonus_increase",
                        "bonus_decrease",
                        "non_bonus_decrease",
                        "bonus_1",
                        "bonus_2",
                        "bonus_3",
                    ]:
                        worksheet.set_column(idx, idx, max_len, vnd_accounting_format)
                    else:
                        worksheet.set_column(idx, idx, max_len)

            self.finished.emit()
        except Exception as e:
            self.error.emit(str(e))

    def to_excel_serial(self, d):
        if pd.isna(d):
            return None
        excel_start_date = datetime.date(1899, 12, 30)
        return (d - excel_start_date).days
