from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QFont
from .step_widget import StepWidget


class DashboardWidget(QWidget):
    import_requested = pyqtSignal()
    calculate_requested = pyqtSignal()
    export_requested = pyqtSignal()
    reset_requested = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.init_ui()
        self.reset_workflow()

    def init_ui(self):
        layout = QVBoxLayout()

        # Title
        title = QLabel("Quy trình tính thưởng")
        title.setFont(QFont("Arial", 18, QFont.Weight.Bold))
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setStyleSheet("margin: 20px; color: #333;")

        # Steps
        self.step1 = StepWidget(
            1,
            "Nhập dữ liệu",
            "Nhập file Excel (Dữ liệu + Cấu hình)",
            "Nhập dữ liệu chính, cấu hình cấp độ và ngày lễ",
            "Chọn file Excel",
        )

        self.step2 = StepWidget(
            2,
            "Tính toán kết quả",
            "Xử lý tính toán thưởng",
            "Kết hợp dữ liệu với cấu hình để tính thưởng",
            "Tính toán thưởng",
        )

        self.step3 = StepWidget(
            3,
            "Xuất kết quả",
            "Xuất kết quả ra Excel",
            "Tải kết quả đã tính với định dạng",
            "Xuất ra Excel",
        )

        # Reset button
        self.reset_button = QPushButton("🔄 Bắt đầu tính toán mới")
        self.reset_button.setStyleSheet(
            """
            QPushButton {
                background-color: #28a745;
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 6px;
                font-weight: bold;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: #218838;
            }
        """
        )
        self.reset_button.clicked.connect(self.reset_workflow)
        self.reset_button.setVisible(False)

        # Connect signals
        self.step1.button.clicked.connect(self.import_requested.emit)
        self.step2.button.clicked.connect(self.calculate_requested.emit)
        self.step3.button.clicked.connect(self.export_requested.emit)

        layout.addWidget(title)
        layout.addWidget(self.step1)
        layout.addWidget(self.step2)
        layout.addWidget(self.step3)
        layout.addWidget(self.reset_button)
        layout.addStretch()

        self.setLayout(layout)

    def reset_workflow(self):
        """Reset workflow to initial state"""
        self.step1.set_status("ready", "Nhập dữ liệu chính, cấu hình cấp độ và ngày lễ")
        self.step1.set_enabled(True)

        self.step2.set_status("ready", "Kết hợp dữ liệu với cấu hình để tính thưởng")
        self.step2.set_enabled(False)

        self.step3.set_status("ready", "Tải kết quả đã tính với định dạng")
        self.step3.set_enabled(False)

        self.reset_button.setVisible(False)
        self.reset_requested.emit()

    def on_import_started(self):
        self.step1.set_status("processing", "Đang nhập dữ liệu...")
        self.step1.set_enabled(False)

    def on_import_completed(self, stats=None):
        if stats:
            message = f"✅ Đã nhập: {stats.get('records', 0)} bản ghi, {stats.get('levels', 0)} cấp độ, {stats.get('holidays', 0)} ngày lễ"
        else:
            message = "Nhập dữ liệu thành công"
        self.step1.set_status("completed", message)
        self.step2.set_enabled(True)

    def on_import_error(self, error_msg):
        self.step1.set_status("error", f"Nhập dữ liệu thất bại: {error_msg}")
        self.step1.set_enabled(True)

    def on_calculate_started(self):
        self.step2.set_status("processing", "Đang tính toán thưởng...")
        self.step2.set_enabled(False)

    def on_calculate_completed(self, stats=None):
        if stats:
            message = f"✅ Đã tính: {stats.get('total_records', 0)} bản ghi, Tổng thưởng: {stats.get('total_bonus', 0):,.0f} VNĐ"
        else:
            message = "Tính toán hoàn tất thành công"
        self.step2.set_status("completed", message)
        self.step3.set_enabled(True)

    def on_calculate_error(self, error_msg):
        self.step2.set_status("error", f"Tính toán thất bại: {error_msg}")
        self.step2.set_enabled(True)

    def on_export_started(self):
        self.step3.set_status("processing", "Đang xuất dữ liệu...")
        self.step3.set_enabled(False)

    def on_export_completed(self, file_path=None):
        if file_path:
            import os

            filename = os.path.basename(file_path)
            message = f"✅ Đã xuất: {filename}"
        else:
            message = "Xuất dữ liệu thành công"
        self.step3.set_status("completed", message)
        self.reset_button.setVisible(True)

    def on_export_error(self, error_msg):
        self.step3.set_status("error", f"Xuất dữ liệu thất bại: {error_msg}")
        self.step3.set_enabled(True)
