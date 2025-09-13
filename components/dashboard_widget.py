from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QFrame,
    QProgressBar,
)
from PyQt6.QtCore import Qt, pyqtSignal, QTimer
from PyQt6.QtGui import QFont, QPixmap


class StepWidget(QFrame):
    def __init__(self, step_number, title, description, sub_info, button_text):
        super().__init__()
        self.step_number = step_number
        self.setFrameStyle(QFrame.Shape.Box)
        self.setStyleSheet(
            "QFrame { border: 2px solid #ddd; border-radius: 8px; padding: 10px; }"
        )

        layout = QVBoxLayout()

        # Header với step number và title
        header_layout = QHBoxLayout()

        # Step circle
        step_label = QLabel(str(step_number))
        step_label.setStyleSheet(
            """
            QLabel {
                background-color: #e0e0e0;
                border-radius: 20px;
                width: 40px;
                height: 40px;
                font-size: 18px;
                font-weight: bold;
                color: #666;
            }
        """
        )
        step_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        step_label.setFixedSize(40, 40)

        # Title và description
        text_layout = QVBoxLayout()
        self.title_label = QLabel(title)
        self.title_label.setFont(QFont("Arial", 14, QFont.Weight.Bold))

        self.desc_label = QLabel(description)
        self.desc_label.setStyleSheet("color: #666;")

        self.sub_info_label = QLabel(sub_info)
        self.sub_info_label.setStyleSheet("color: #999; font-size: 11px;")

        text_layout.addWidget(self.title_label)
        text_layout.addWidget(self.desc_label)
        text_layout.addWidget(self.sub_info_label)

        header_layout.addWidget(step_label)
        header_layout.addLayout(text_layout)
        header_layout.addStretch()

        # Status và button
        action_layout = QHBoxLayout()

        self.status_label = QLabel("Ready")
        self.status_label.setStyleSheet("color: #666; font-size: 12px;")

        self.button = QPushButton(button_text)
        self.button.setStyleSheet(
            """
            QPushButton {
                background-color: #007acc;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #005a9e;
            }
            QPushButton:disabled {
                background-color: #ccc;
                color: #666;
            }
        """
        )

        action_layout.addWidget(self.status_label)
        action_layout.addStretch()
        action_layout.addWidget(self.button)

        layout.addLayout(header_layout)
        layout.addLayout(action_layout)
        self.setLayout(layout)

    def set_status(self, status, message=""):
        """Set step status: 'ready', 'processing', 'completed', 'error'"""
        status_colors = {
            "ready": "#666",
            "processing": "#ff9800",
            "completed": "#4caf50",
            "error": "#f44336",
        }

        status_icons = {
            "ready": "⏳",
            "processing": "⚙️",
            "completed": "✅",
            "error": "❌",
        }

        self.status_label.setText(f"{status_icons.get(status, '')} {status.title()}")
        self.status_label.setStyleSheet(
            f"color: {status_colors.get(status, '#666')}; font-size: 12px;"
        )

        if message:
            self.sub_info_label.setText(message)

        # Update step circle color
        circle_colors = {
            "ready": "#e0e0e0",
            "processing": "#ff9800",
            "completed": "#4caf50",
            "error": "#f44336",
        }

        step_circle = self.findChild(QLabel)
        if step_circle:
            step_circle.setStyleSheet(
                f"""
                QLabel {{
                    background-color: {circle_colors.get(status, '#e0e0e0')};
                    border-radius: 20px;
                    width: 40px;
                    height: 40px;
                    font-size: 18px;
                    font-weight: bold;
                    color: white;
                }}
            """
            )

    def set_enabled(self, enabled):
        self.button.setEnabled(enabled)
        if not enabled:
            self.setStyleSheet(
                "QFrame { border: 2px solid #ddd; border-radius: 8px; padding: 10px; opacity: 0.6; }"
            )
        else:
            self.setStyleSheet(
                "QFrame { border: 2px solid #ddd; border-radius: 8px; padding: 10px; }"
            )


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
        self.step1.set_status("ready")
        self.step1.set_enabled(True)

        self.step2.set_status("ready")
        self.step2.set_enabled(False)

        self.step3.set_status("ready")
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
