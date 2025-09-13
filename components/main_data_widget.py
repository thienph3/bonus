from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel
from PyQt6.QtGui import QFont

from components.list_widget import ListWidget
from components.view_widget import ViewWidget
from components.edit_widget import EditWidget
from models.main_data_model import MainData


class MainDataWidget(QWidget):
    def __init__(
        self,
        service,
        columns=[
            ("id", "Mã"),
            ("document_date", "Ngày phát sinh"),
            ("document_number", "Mã phát sinh"),
            ("description", "Mô tả"),
            ("corresponding_account", "Tài khoản đối ứng"),
            ("increase", "Tăng"),
            ("decrease", "Giảm"),
            ("adjust_increase", "Tăng điều chỉnh"),
            ("adjust_decrease", "Giảm điều chỉnh"),
            ("end_amount", "Số dư cuối kì"),
            ("seasonal_code", "Mã mùa vụ"),
            ("payment_period", "Mức"),
            ("customer_code", "Mã khách hàng"),
            ("customer_name", "Tên khách hàng"),
            ("branch", "Cơ sở"),
            ("code", "code"),
            ("sales_method", "Kênh bán"),
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
        title = QLabel("Quản lý dữ liệu")
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
                MainData.empty_dict(),
                on_saved=self.show_list,
                on_cancel=self.show_list,
            )
        )
