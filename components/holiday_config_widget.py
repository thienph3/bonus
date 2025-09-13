from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel
from PyQt6.QtGui import QFont

from components.list_widget import ListWidget
from components.view_widget import ViewWidget
from components.edit_widget import EditWidget
from models.holiday_config_model import HolidayConfig


class HolidayConfigWidget(QWidget):
    def __init__(
        self,
        service,
        columns=[
            ("id", "Mã"),
            ("date", "Ngày lễ"),
            ("name", "Tên lễ"),
            ("desc", "Mô tả"),
        ],
    ):
        super().__init__()
        self.service = service
        self.columns = columns
        self.id_field = "id"

        # Main layout
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(5, 5, 5, 5)

        # Title label
        title = QLabel("Cấu hình ngày nghỉ")
        title.setFont(QFont("Arial", 12, weight=QFont.Weight.Bold))
        self.layout.addWidget(title)

        # Stack layout for dynamic widgets (list/view/edit)
        self.stack = QVBoxLayout()
        self.layout.addLayout(self.stack)
        self.show_list()

    def clear_stack(self):
        for i in reversed(range(self.stack.count())):
            widget = self.stack.itemAt(i).widget()
            if widget:
                widget.setParent(None)

    def show_list(self):
        self.clear_stack()
        widget = ListWidget(
            self.service,
            self.columns,
            self.id_field,
            on_add=self.show_new,
            on_view=self.show_view,
            on_edit=self.show_edit,
        )
        self.stack.addWidget(widget)

    def show_view(self, item_id):
        record = self.service.get(item_id)
        self.clear_stack()
        self.stack.addWidget(ViewWidget(record, self.columns, on_back=self.show_list))

    def show_edit(self, item_id):
        record = self.service.get(item_id)
        self.clear_stack()
        self.stack.addWidget(
            EditWidget(
                self.columns,
                self.service,
                record,
                on_saved=self.show_list,
                on_cancel=self.show_list,
            )
        )

    def show_new(self):
        self.clear_stack()
        self.stack.addWidget(
            EditWidget(
                self.columns,
                self.service,
                HolidayConfig.empty_dict(),
                on_saved=self.show_list,
                on_cancel=self.show_list,
            )
        )
