import datetime
import pandas as pd
import sys

from PyQt6.QtCore import QThread
from PyQt6.QtWidgets import (
    QApplication,
    QWidget,
    QHBoxLayout,
    QFileDialog,
    QMessageBox,
)

from components.menu_widget import MenuWidget
from components.central_widget import CentralWidget
from components.right_console import RightConsole

from models.result_model import Result

from workers.import_holiday_config_worker import ImportHolidayConfigWorker
from workers.import_level_config_worker import ImportLevelConfigWorker
from workers.import_main_data_worker import ImportMainDataWorker
from workers.calculate_result_worker import CalculateResultWorker


class App(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Calculate The Bonus")
        self.setGeometry(100, 100, 800, 600)

        self.central_widget = CentralWidget(parent=self)
        self.right_console = RightConsole(parent=self)
        self.menu = MenuWidget(
            parent=self,
            open_holiday_config_screen=self.central_widget.show_holiday_config,
            open_level_config_screen=self.central_widget.show_level_config,
            open_main_data_screen=self.central_widget.show_main_data,
            open_result_screen=self.central_widget.show_result,
            import_data_callback=self.import_data,
            calculate_result_callback=self.calculate_result,
            export_result_callback=self.export_result,
        )

        self.main_layout = QHBoxLayout()
        self.main_layout.setMenuBar(self.menu)
        self.main_layout.addWidget(self.central_widget, 3)
        self.main_layout.addWidget(self.right_console, 2)

        self.setLayout(self.main_layout)

    def import_data(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self, "Open Excel File", "", "Excel Files (*.xlsx *.xls)"
        )
        if file_path:
            if self.menu.import_action:
                self.menu.import_action.setEnabled(False)
            self.central_widget.dashboard_widget.on_import_started()
            self.right_console.log_import_banner()
            self.right_console.log_with_time("📥 Bắt đầu nhập dữ liệu vào...")
            self.running_import_threads = 3

            self._start_import_holiday_config(file_path)
            self._start_import_level_config(file_path)
            self._start_import_main_data(file_path)

    def _import_thread_finished_handler(self):
        self.running_import_threads -= 1
        if self.running_import_threads == 0:
            if self.menu.import_action:
                self.menu.import_action.setEnabled(True)

            # Get stats for dashboard
            records_count = len(self.central_widget.main_data_service.get_all())
            levels_count = len(self.central_widget.level_config_service.get_all())
            holidays_count = len(self.central_widget.holiday_config_service.get_all())

            stats = {
                "records": records_count,
                "levels": levels_count,
                "holidays": holidays_count,
            }

            self.central_widget.dashboard_widget.on_import_completed(stats)
            self.right_console.log_with_time("🎉 Nhập dữ liệu vào hoàn tất.")
            self.central_widget.holiday_config_widget.show_list()
            self.central_widget.holiday_config_widget.stack.itemAt(
                0
            ).widget().load_data()
            self.central_widget.level_config_widget.show_list()
            self.central_widget.level_config_widget.stack.itemAt(0).widget().load_data()
            self.central_widget.main_data_widget.show_list()
            self.central_widget.main_data_widget.stack.itemAt(0).widget().load_data()

    def _start_import_holiday_config(self, file_path: str):
        self.right_console.log_with_time(
            "📥 Bắt đầu nhập dữ liệu vào holiday-config..."
        )

        self.holiday_config_thread = QThread()
        self.holiday_config_worker = ImportHolidayConfigWorker(file_path)
        self.holiday_config_worker.moveToThread(self.holiday_config_thread)

        self.holiday_config_worker.log_signal.connect(self.right_console.log_with_time)
        self.holiday_config_worker.finished.connect(
            self._on_import_holiday_config_finished
        )
        self.holiday_config_worker.error.connect(self._on_import_holiday_config_error)

        self.holiday_config_thread.started.connect(self.holiday_config_worker.run)
        self.holiday_config_worker.finished.connect(self.holiday_config_thread.quit)
        self.holiday_config_worker.error.connect(self.holiday_config_thread.quit)
        self.holiday_config_worker.finished.connect(
            self.holiday_config_worker.deleteLater
        )
        self.holiday_config_thread.finished.connect(
            self.holiday_config_thread.deleteLater
        )

        self.holiday_config_thread.start()

    def _on_import_holiday_config_finished(self):
        self.right_console.log_with_time("🎉 Nhập dữ liệu vào holiday-config hoàn tất.")
        self._import_thread_finished_handler()

    def _on_import_holiday_config_error(self, msg):
        self.right_console.log_with_time(
            f"❌ Nhập dữ liệu vào holiday-config gặp lỗi: {msg}"
        )
        self.central_widget.dashboard_widget.on_import_error(msg)
        self._import_thread_finished_handler()

    def _start_import_level_config(self, file_path: str):
        self.right_console.log_with_time("📥 Bắt đầu nhập dữ liệu vào level-config...")

        self.level_config_thread = QThread()
        self.level_config_worker = ImportLevelConfigWorker(file_path)
        self.level_config_worker.moveToThread(self.level_config_thread)

        self.level_config_worker.log_signal.connect(self.right_console.log_with_time)
        self.level_config_worker.finished.connect(self._on_import_level_config_finished)
        self.level_config_worker.error.connect(self._on_import_level_config_error)

        self.level_config_thread.started.connect(self.level_config_worker.run)
        self.level_config_worker.finished.connect(self.level_config_thread.quit)
        self.level_config_worker.error.connect(self.level_config_thread.quit)
        self.level_config_worker.finished.connect(self.level_config_worker.deleteLater)
        self.level_config_thread.finished.connect(self.level_config_thread.deleteLater)

        self.level_config_thread.start()

    def _on_import_level_config_finished(self):
        self.right_console.log_with_time("🎉 Nhập dữ liệu vào level-config hoàn tất.")
        self._import_thread_finished_handler()

    def _on_import_level_config_error(self, msg):
        self.right_console.log_with_time(
            f"❌ Nhập dữ liệu vào level-config gặp lỗi: {msg}"
        )
        self._import_thread_finished_handler()

    def _start_import_main_data(self, file_path: str):
        self.right_console.log_with_time("📥 Bắt đầu nhập dữ liệu vào main-data...")

        self.main_data_thread = QThread()
        self.main_data_worker = ImportMainDataWorker(file_path)
        self.main_data_worker.moveToThread(self.main_data_thread)

        self.main_data_worker.log_signal.connect(self.right_console.log_with_time)
        self.main_data_worker.finished.connect(self._on_import_main_data_finished)
        self.main_data_worker.error.connect(self._on_import_main_data_error)

        self.main_data_thread.started.connect(self.main_data_worker.run)
        self.main_data_worker.finished.connect(self.main_data_thread.quit)
        self.main_data_worker.error.connect(self.main_data_thread.quit)
        self.main_data_worker.finished.connect(self.main_data_worker.deleteLater)
        self.main_data_thread.finished.connect(self.main_data_thread.deleteLater)

        self.main_data_thread.start()

    def _on_import_main_data_finished(self):
        self.right_console.log_with_time("🎉 Nhập dữ liệu vào main-data hoàn tất.")
        self._import_thread_finished_handler()

    def _on_import_main_data_error(self, msg):
        self.right_console.log_with_time(
            f"❌ Nhập dữ liệu vào main-data gặp lỗi: {msg}"
        )
        self._import_thread_finished_handler()

    def calculate_result(self):
        if self.menu.calculate_result_action:
            self.menu.calculate_result_action.setEnabled(False)
        self.central_widget.dashboard_widget.on_calculate_started()
        self.right_console.log_calculate_banner()
        self.right_console.log_with_time("📥 Bắt đầu tính toán kết quả...")

        self.calculate_result_thread = QThread()
        self.calculate_result_worker = CalculateResultWorker()
        self.calculate_result_worker.moveToThread(self.calculate_result_thread)

        self.calculate_result_worker.log_signal.connect(
            self.right_console.log_with_time
        )
        self.calculate_result_worker.finished.connect(
            self._on_calculate_result_finished
        )
        self.calculate_result_worker.error.connect(self._on_calculate_result_error)

        self.calculate_result_thread.started.connect(self.calculate_result_worker.run)
        self.calculate_result_worker.finished.connect(self.calculate_result_thread.quit)
        self.calculate_result_worker.error.connect(self.calculate_result_thread.quit)
        self.calculate_result_worker.finished.connect(
            self.calculate_result_worker.deleteLater
        )
        self.calculate_result_thread.finished.connect(
            self.calculate_result_thread.deleteLater
        )

        self.calculate_result_thread.start()

    def _on_calculate_result_finished(self):
        self.right_console.log_with_time("🎉 Tính toán kết quả hoàn tất.")

        # Get stats for dashboard
        results = self.central_widget.result_service.get_all()
        total_records = len(results)
        total_bonus = sum(
            r.bonus_1 + r.bonus_2 + r.bonus_3
            for r in results
            if r.bonus_1 and r.bonus_2 and r.bonus_3
        )

        stats = {"total_records": total_records, "total_bonus": total_bonus}

        self.central_widget.dashboard_widget.on_calculate_completed(stats)
        if self.menu.calculate_result_action:
            self.menu.calculate_result_action.setEnabled(True)

    def _on_calculate_result_error(self, msg):
        self.right_console.log_with_time(f"❌ Tính toán kết quả gặp lỗi: {msg}")
        self.central_widget.dashboard_widget.on_calculate_error(msg)
        if self.menu.calculate_result_action:
            self.menu.calculate_result_action.setEnabled(True)

    def export_result(self):
        """Function run when user click Export button."""
        # Prompt the user to choose a file location
        file_path, _ = QFileDialog.getSaveFileName(
            self,
            "Export Result to Excel",
            "result.xlsx",
            "Excel Files (*.xlsx);;All Files (*)",
        )

        if file_path:
            try:
                results: list[Result] = self.central_widget.result_service.get_all()
                results = sorted(results, key=lambda result: (result.sorted_idx))
                results = [result.to_dict() for result in results]

                df = pd.DataFrame(results)
                df["document_date"] = df["document_date"].apply(self.to_excel_serial)
                df["payment_due_date"] = df["payment_due_date"].apply(
                    self.to_excel_serial
                )
                df["payment_due_date_1"] = df["payment_due_date_1"].apply(
                    self.to_excel_serial
                )
                df["payment_due_date_2"] = df["payment_due_date_2"].apply(
                    self.to_excel_serial
                )
                df["payment_due_date_3"] = df["payment_due_date_3"].apply(
                    self.to_excel_serial
                )
                with pd.ExcelWriter(file_path, engine="xlsxwriter") as writer:
                    df.to_excel(writer, index=False)

                    workbook = writer.book
                    worksheet = writer.sheets["Sheet1"]
                    date_format = workbook.add_format({"num_format": "dd/mm/yyyy"})
                    vnd_accounting_format = workbook.add_format({"num_format": "#,##0"})

                    for idx, col in enumerate(df.columns):
                        # Get max length of column header and column values as strings
                        max_len = max(df[col].astype(str).map(len).max(), len(str(col)))
                        # Add some padding
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
                            worksheet.set_column(
                                idx, idx, max_len, vnd_accounting_format
                            )
                        else:
                            worksheet.set_column(idx, idx, max_len)

                self.central_widget.dashboard_widget.on_export_completed(file_path)
            except Exception as e:
                self.central_widget.dashboard_widget.on_export_error(str(e))

    def to_excel_serial(eslf, d):
        if pd.isna(d):
            return None
        excel_start_date = datetime.date(1899, 12, 30)
        return (d - excel_start_date).days


# === Chạy ứng dụng Qt6 ===
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = App()
    app.setStyleSheet(window.menu.load_stylesheet("themes/light_theme.qss"))
    window.show()
    sys.exit(app.exec())
