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

        # ========== Quy trình ==========
        workflow_menu = self.addMenu("Quy trình")

        dashboard_action = QAction("📊 Màn hình chính", parent)
        dashboard_action.setShortcut(QKeySequence("Ctrl+0"))
        dashboard_action.triggered.connect(parent.central_widget.show_dashboard)
        workflow_menu.addAction(dashboard_action)

        # Keep references for enabling/disabling from app.py
        self.import_action = None
        self.calculate_result_action = None
        self.export_action = None

        # ========== Xem dữ liệu ==========
        view_menu = self.addMenu("Xem dữ liệu")

        main_data_action = QAction("📋 Dữ liệu chính", parent)
        main_data_action.setShortcut(QKeySequence("Ctrl+1"))
        main_data_action.triggered.connect(open_main_data_screen)
        view_menu.addAction(main_data_action)

        result_action = QAction("📈 Kết quả tính toán", parent)
        result_action.setShortcut(QKeySequence("Ctrl+2"))
        result_action.triggered.connect(open_result_screen)
        view_menu.addAction(result_action)

        # ========== Cấu hình ==========
        config_menu = self.addMenu("Cấu hình")

        holiday_action = QAction("🗓️ Ngày nghỉ lễ", parent)
        holiday_action.setShortcut(QKeySequence("Ctrl+3"))
        holiday_action.triggered.connect(open_holiday_config_screen)
        config_menu.addAction(holiday_action)

        level_action = QAction("📊 Cấp độ thưởng", parent)
        level_action.setShortcut(QKeySequence("Ctrl+4"))
        level_action.triggered.connect(open_level_config_screen)
        config_menu.addAction(level_action)

        # ========== Hệ thống ==========
        system_menu = self.addMenu("Hệ thống")

        theme_action = QAction("🎨 Đổi theme", parent)
        theme_action.setShortcut(QKeySequence("Ctrl+T"))
        theme_action.triggered.connect(self.toggle_theme)
        system_menu.addAction(theme_action)

        # Connect dashboard workflow signals
        parent.central_widget.dashboard_widget.import_requested.connect(
            import_data_callback
        )
        parent.central_widget.dashboard_widget.calculate_requested.connect(
            calculate_result_callback
        )
        parent.central_widget.dashboard_widget.export_requested.connect(
            export_result_callback
        )

        # Connect reset signal
        parent.central_widget.dashboard_widget.reset_requested.connect(
            lambda: parent.central_widget.show_dashboard()
        )

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
