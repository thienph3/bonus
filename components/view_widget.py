from PyQt6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel


class ViewWidget(QWidget):
    def __init__(self, record, columns, on_back=None):
        super().__init__()
        layout = QVBoxLayout()
        for key, label in columns:
            value = str(record.get(key, ""))
            layout.addWidget(QLabel(f"{label}: {value}"))
        back_btn = QPushButton("Back")
        if on_back:
            back_btn.clicked.connect(on_back)
        layout.addWidget(back_btn)
        self.setLayout(layout)
