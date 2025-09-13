from PyQt6.QtCore import QObject, pyqtSignal
from services.result_service import ResultService


class CalculateResultWorker(QObject):
    log_signal = pyqtSignal(str)
    sub_step_signal = pyqtSignal(int)
    finished = pyqtSignal()
    error = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.service = ResultService()

    def run(self):
        try:
            self.service.calculate_result(
                log_func=self.log_signal.emit, sub_step_func=self.sub_step_signal.emit
            )
            self.finished.emit()
        except Exception as e:
            self.error.emit(str(e))
