from PyQt6.QtWidgets import QMenuBar
from PyQt6.QtGui import QKeySequence, QAction

from utils.utils import resource_path


class MenuWidget(QMenuBar):
    def __init__(
        self,
        parent,
        open_holiday_config_screen,
        open_level_config_screen,
        open_main_data_screen,
        open_result_screen,
        import_data_callback,
        calculate_result_callback,
        export_result_callback,
    ):
        super().__init__(parent)

        # ========== Hệ thống ==========
        system_menu = self.addMenu("Hệ thống")

        theme_action = QAction("Đổi theme", parent)
        theme_action.setShortcut(QKeySequence("Ctrl+T"))
        theme_action.triggered.connect(self.toggle_theme)
        system_menu.addAction(theme_action)

        # ========== Cấu hình ==========
        config_menu = self.addMenu("Cấu hình")

        holiday_action = QAction("Cấu hình ngày nghỉ", parent)
        holiday_action.setShortcut(QKeySequence("Ctrl+1"))
        holiday_action.triggered.connect(open_holiday_config_screen)
        config_menu.addAction(holiday_action)

        level_action = QAction("Cấu hình hạn thanh toán theo từng mức", parent)
        level_action.setShortcut(QKeySequence("Ctrl+2"))
        level_action.triggered.connect(open_level_config_screen)
        config_menu.addAction(level_action)

        # ========== Xử lý dữ liệu ==========
        data_menu = self.addMenu("Xử lý dữ liệu")

        main_data_action = QAction("Quản lý dữ liệu", parent)
        main_data_action.setShortcut(QKeySequence("Ctrl+3"))
        main_data_action.triggered.connect(open_main_data_screen)
        data_menu.addAction(main_data_action)

        self.import_action = QAction("Nhập dữ liệu từ file", parent)
        self.import_action.setShortcut(QKeySequence("Ctrl+I"))
        self.import_action.triggered.connect(import_data_callback)
        data_menu.addAction(self.import_action)

        self.calculate_result_action = QAction("Tính toán kết quả", parent)
        self.calculate_result_action.setShortcut(QKeySequence("Ctrl+C"))
        self.calculate_result_action.triggered.connect(calculate_result_callback)
        data_menu.addAction(self.calculate_result_action)

        # ========== Kết quả ==========
        result_menu = self.addMenu("Kết quả")

        result_action = QAction("Xem kết quả", parent)
        result_action.setShortcut(QKeySequence("Ctrl+4"))
        result_action.triggered.connect(open_result_screen)
        result_menu.addAction(result_action)

        self.export_action = QAction("Xuất dữ liệu", parent)
        self.export_action.setShortcut(QKeySequence("Ctrl+E"))
        self.export_action.triggered.connect(export_result_callback)
        result_menu.addAction(self.export_action)

    def load_stylesheet(self, path):
        with open(resource_path(path), "r", encoding="utf-8") as f:
            return f.read()

    def toggle_theme(self):
        if getattr(self, "_is_dark", False):
            self.parent().setStyleSheet(self.load_stylesheet("themes/light_theme.qss"))
            self._is_dark = False
        else:
            self.parent().setStyleSheet(self.load_stylesheet("themes/dark_theme.qss"))
            self._is_dark = True
