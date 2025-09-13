from PyQt6.QtWidgets import QLabel
from PyQt6.QtCore import pyqtProperty
from PyQt6.QtGui import QPainter
from PyQt6.QtCore import Qt


class RotatingLabel(QLabel):
    def __init__(self, text=""):
        super().__init__(text)
        self._rotation = 0
        self.setFixedSize(16, 16)
        self.setAlignment(Qt.AlignmentFlag.AlignCenter)

    @pyqtProperty(float)
    def rotation(self):
        return self._rotation

    @rotation.setter
    def rotation(self, value):
        self._rotation = value
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        # Get exact center
        center_x = self.width() / 2
        center_y = self.height() / 2

        # Apply rotation around center
        painter.translate(center_x, center_y)
        painter.rotate(self._rotation)
        painter.translate(-center_x, -center_y)

        # Draw the text
        painter.drawText(self.rect(), Qt.AlignmentFlag.AlignCenter, self.text())
