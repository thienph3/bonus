from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPlainTextEdit
from PyQt6.QtGui import QFont, QFontDatabase
from datetime import datetime


class RightConsole(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(5, 5, 5, 5)

        title = QLabel("Nhật ký hệ thống")
        title.setFont(QFont("Arial", 12, weight=QFont.Weight.Bold))
        layout.addWidget(title)

        self.console = QPlainTextEdit()
        self.console.setReadOnly(True)

        # Use system fixed font
        self.console.setFont(QFont("Courier New", 10))

        self.console.setStyleSheet("background-color: black; color: lightgreen;")
        layout.addWidget(self.console)

    def log_with_time(self, message: str):
        now = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        self.console.appendPlainText(f"[{now}] {message}")

    def log_import_banner(self):
        banner = r"""


    ██╗███╗   ███╗██████╗  ██████╗ ██████╗ ████████╗
    ██║████╗ ████║██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝
    ██║██╔████╔██║██████╔╝██║   ██║██████╔╝   ██║   
    ██║██║╚██╔╝██║██╔═══╝ ██║   ██║██╔═══╝    ██║   
    ██║██║ ╚═╝ ██║██║     ╚██████╔╝██║        ██║   
    ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝        ╚═╝   
        """
        self.log_with_time(banner)

    def log_calculate_banner(self):
        banner = r"""


    ██████╗  █████╗ ██████╗ ██╗   ██╗██╗      █████╗ ████████╗███████╗
    ██╔═══╝ ██╔══██╗██╔═══╝ ██║   ██║██║     ██╔══██╗╚══██╔══╝██╔════╝
    ██║     ███████║██║     ██║   ██║██║     ███████║   ██║   █████╗  
    ██║     ██╔══██║██║     ██║   ██║██║     ██╔══██║   ██║   ██╔══╝  
    ╚██████╗██║  ██║╚██████╗╚██████╔╝███████╗██║  ██║   ██║   ███████╗
     ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
        """
        self.log_with_time(banner)

    def log_export_banner(self):
        banner = r"""


    ███████╗██╗  ██╗██████╗  ██████╗ ██████╗ ████████╗
    ██╔════╝╚██╗██╔╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝
    █████╗   ╚███╔╝ ██████╔╝██║   ██║██████╔╝   ██║   
    ██╔══╝   ██╔██╗ ██╔═══╝ ██║   ██║██╔═══╝    ██║   
    ███████╗██╔╝╚██╗██║     ╚██████╔╝██║        ██║   
    ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝        ╚═╝   
        """
        self.log_with_time(banner)
