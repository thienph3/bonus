from PyQt6.QtWidgets import QStackedWidget

from components.holiday_config_widget import HolidayConfigWidget
from components.level_config_widget import LevelConfigWidget
from components.main_data_widget import MainDataWidget
from components.result_widget import ResultWidget
from components.dashboard_widget import DashboardWidget

from services.holiday_config_service import HolidayConfigService
from services.level_config_service import LevelConfigService
from services.main_data_service import MainDataService
from services.result_service import ResultService


class CentralWidget(QStackedWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.holiday_config_service: HolidayConfigService = HolidayConfigService()
        self.level_config_service: LevelConfigService = LevelConfigService()
        self.main_data_service: MainDataService = MainDataService()
        self.result_service: ResultService = ResultService()

        self.dashboard_widget = DashboardWidget(parent=self)
        self.holiday_config_widget = HolidayConfigWidget(self.holiday_config_service)
        self.level_config_widget = LevelConfigWidget(self.level_config_service)
        self.main_data_widget = MainDataWidget(self.main_data_service)
        self.result_widget = ResultWidget(self.result_service)

        self.addWidget(self.dashboard_widget)
        self.addWidget(self.holiday_config_widget)
        self.addWidget(self.level_config_widget)
        self.addWidget(self.main_data_widget)
        self.addWidget(self.result_widget)

        # Show dashboard by default
        self.show_dashboard()

    def show_holiday_config(self):
        self.setCurrentWidget(self.holiday_config_widget)

    def show_level_config(self):
        self.setCurrentWidget(self.level_config_widget)

    def show_main_data(self):
        self.setCurrentWidget(self.main_data_widget)

    def show_dashboard(self):
        self.setCurrentWidget(self.dashboard_widget)

    def show_result(self):
        self.setCurrentWidget(self.result_widget)
