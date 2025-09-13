from PyQt6.QtWidgets import (
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QFrame,
)
from PyQt6.QtCore import Qt, QPropertyAnimation, QEasingCurve
from PyQt6.QtGui import QFont
from .rotating_label import RotatingLabel


class StepWidget(QFrame):
    def __init__(self, step_number, title, description, sub_info, button_text):
        super().__init__()
        self.step_number = step_number
        self.spin_animation = None
        self.spin_icon = None
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

        self.status_label = QLabel("Sẵn sàng")
        self.status_label.setStyleSheet("color: #666; font-size: 12px;")

        # Create status icon labels
        self.status_icon = QLabel("⏳")
        self.status_icon.setStyleSheet("font-size: 12px; border: none;")
        self.status_icon.setAlignment(Qt.AlignmentFlag.AlignCenter)

        self.spin_icon = RotatingLabel("⚙")
        self.spin_icon.setStyleSheet("font-size: 14px; font-weight: bold;")
        self.spin_icon.setVisible(False)

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

        # Status layout with icons
        status_layout = QHBoxLayout()
        status_layout.addWidget(self.status_icon)
        status_layout.addWidget(self.spin_icon)
        status_layout.addWidget(self.status_label)
        status_layout.setSpacing(5)

        action_layout.addLayout(status_layout)
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

        status_text = {
            "ready": "Sẵn sàng",
            "processing": "Đang xử lý",
            "completed": "Hoàn tất",
            "error": "Lỗi",
        }

        # Handle status icons
        if status == "processing":
            self._start_spin_animation()
            self.status_icon.setVisible(False)
            self.spin_icon.setVisible(True)
        else:
            self._stop_spin_animation()
            self.status_icon.setText(status_icons.get(status, ""))
            self.status_icon.setVisible(True)
            self.spin_icon.setVisible(False)

        self.status_label.setText(status_text.get(status, status))
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

    def _start_spin_animation(self):
        if not self.spin_animation:
            self.spin_animation = QPropertyAnimation(self.spin_icon, b"rotation")
            self.spin_animation.setDuration(1000)
            self.spin_animation.setStartValue(0)
            self.spin_animation.setEndValue(360)
            self.spin_animation.setLoopCount(-1)
            self.spin_animation.setEasingCurve(QEasingCurve.Type.Linear)
        self.spin_animation.start()

    def _stop_spin_animation(self):
        if self.spin_animation:
            self.spin_animation.stop()
            self.spin_icon.rotation = 0
