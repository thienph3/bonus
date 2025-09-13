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
from workers.export_result_worker import ExportResultWorker


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
            (r.bonus_1 or 0) + (r.bonus_2 or 0) + (r.bonus_3 or 0) for r in results
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
        file_path, _ = QFileDialog.getSaveFileName(
            self,
            "Export Result to Excel",
            "result.xlsx",
            "Excel Files (*.xlsx);;All Files (*)",
        )

        if file_path:
            if self.menu.export_result_action:
                self.menu.export_result_action.setEnabled(False)
            self.central_widget.dashboard_widget.on_export_started()
            self.right_console.log_with_time("📤 Bắt đầu xuất kết quả...")

            self.export_result_thread = QThread()
            self.export_result_worker = ExportResultWorker(file_path)
            self.export_result_worker.moveToThread(self.export_result_thread)

            self.export_result_worker.log_signal.connect(
                self.right_console.log_with_time
            )
            self.export_result_worker.finished.connect(self._on_export_result_finished)
            self.export_result_worker.error.connect(self._on_export_result_error)

            self.export_result_thread.started.connect(self.export_result_worker.run)
            self.export_result_worker.finished.connect(self.export_result_thread.quit)
            self.export_result_worker.error.connect(self.export_result_thread.quit)
            self.export_result_worker.finished.connect(
                self.export_result_worker.deleteLater
            )
            self.export_result_thread.finished.connect(
                self.export_result_thread.deleteLater
            )

            self.export_result_thread.start()

    def _on_export_result_finished(self):
        self.right_console.log_with_time("🎉 Xuất kết quả hoàn tất.")
        self.central_widget.dashboard_widget.on_export_completed(
            self.export_result_worker.file_path
        )
        if self.menu.export_result_action:
            self.menu.export_result_action.setEnabled(True)

    def _on_export_result_error(self, msg):
        self.right_console.log_with_time(f"❌ Xuất kết quả gặp lỗi: {msg}")
        self.central_widget.dashboard_widget.on_export_error(msg)
        if self.menu.export_result_action:
            self.menu.export_result_action.setEnabled(True)


# === Chạy ứng dụng Qt6 ===
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = App()
    app.setStyleSheet(window.menu.load_stylesheet("themes/light_theme.qss"))
    window.show()
    sys.exit(app.exec())
