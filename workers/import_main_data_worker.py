from PyQt6.QtCore import QObject, pyqtSignal
from services.main_data_service import MainDataService


class ImportMainDataWorker(QObject):
    log_signal = pyqtSignal(str)
    finished = pyqtSignal()
    error = pyqtSignal(str)

    def __init__(self, file_path):
        super().__init__()
        self.file_path = file_path
        self.service = MainDataService()

    def run(self):
        try:
            self.service.import_data(self.file_path, log_func=self.log_signal.emit)
            self.finished.emit()
        except Exception as e:
            self.error.emit(str(e))
