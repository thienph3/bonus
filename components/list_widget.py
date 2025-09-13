import datetime

from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QTableWidget,
    QTableWidgetItem,
    QHeaderView,
    QPushButton,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QMessageBox,
    QAbstractItemView,
    QAbstractScrollArea,
)
from PyQt6.QtCore import Qt


class ListWidget(QWidget):
    def __init__(
        self,
        service,
        columns,
        id_field="id",
        page_size=10,
        on_add=None,
        on_view=None,
        on_edit=None,
    ):
        super().__init__()
        self.service = service
        self.columns = columns
        self.id_field = id_field
        self.page_size = page_size
        self.current_page = 1
        self.total_records = 0
        self.total_pages = 1
        self.sort_field = None
        self.sort_order = None
        self.filters = {}
        self.on_add = on_add
        self.on_view = on_view
        self.on_edit = on_edit

        self._init_ui()
        self.load_data()

    def _init_ui(self):
        layout = QVBoxLayout()

        # Search bar
        search_layout = QHBoxLayout()
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Tìm kiếm...")
        self.search_input.returnPressed.connect(self.on_search)
        search_layout.addWidget(QLabel("Tìm kiếm:"))
        search_layout.addWidget(self.search_input)
        # layout.addLayout(search_layout)

        # Table
        self.table = QTableWidget()
        self.table.setColumnCount(len(self.columns) + 1)  # +1 for actions
        self.table.setHorizontalHeaderLabels(
            [label for _, label in self.columns] + [""]
        )
        self.table.horizontalHeader().sectionClicked.connect(self.on_sort)
        self.table.horizontalHeader().setSectionResizeMode(
            QHeaderView.ResizeMode.Stretch
        )
        layout.addWidget(self.table)

        # Pagination + Add button
        nav_layout = QHBoxLayout()
        self.page_label = QLabel()
        nav_layout.addWidget(self.page_label)

        self.prev_btn = QPushButton("Trước")
        self.prev_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        self.prev_btn.clicked.connect(self.prev_page)
        nav_layout.addWidget(self.prev_btn)

        self.next_btn = QPushButton("Sau")
        self.next_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        self.next_btn.clicked.connect(self.next_page)
        nav_layout.addWidget(self.next_btn)

        nav_layout.addStretch()

        self.add_btn = QPushButton("Thêm mới")
        self.add_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        self.add_btn.clicked.connect(self.on_add)
        nav_layout.addWidget(self.add_btn)

        layout.addLayout(nav_layout)
        self.setLayout(layout)

    def load_data(self):
        records, total = self.service.get_page(
            self.current_page,
            self.page_size,
            filters=self.filters,
            sort=(self.sort_field, self.sort_order) if self.sort_field else None,
        )
        self.total_records = total
        self.total_pages = max(1, -(-total // self.page_size))  # ceil

        self.page_label.setText(
            f"Trang {self.current_page}/{self.total_pages} — Tổng: {total}"
        )
        self.populate_table(records)

    def populate_table(self, records):
        self.table.setRowCount(len(records))
        for row, record in enumerate(records):
            for col, (key, _) in enumerate(self.columns):
                value = record.get(key, "")
                if isinstance(value, (datetime.date, datetime.datetime)):
                    item_value = value.strftime("%d/%m/%Y")
                else:
                    item_value = str(value) if value is not None else ""
                item = QTableWidgetItem(item_value)

                # ID column clickable
                if key == self.id_field:
                    item.setForeground(Qt.GlobalColor.blue)
                    item.setFlags(Qt.ItemFlag.ItemIsEnabled)
                    item.setToolTip("Bấm để xem")
                    self.table.setItem(row, col, item)
                    self.table.itemClicked.connect(self.handle_item_click)
                else:
                    item.setFlags(
                        Qt.ItemFlag.ItemIsSelectable | Qt.ItemFlag.ItemIsEnabled
                    )
                    self.table.setItem(row, col, item)

            # Action buttons
            btn_layout = QHBoxLayout()
            edit_btn = QPushButton("Sửa")
            edit_btn.setCursor(Qt.CursorShape.PointingHandCursor)
            delete_btn = QPushButton("Xóa")
            delete_btn.setCursor(Qt.CursorShape.PointingHandCursor)

            item_id = record[self.id_field]

            edit_btn.clicked.connect(lambda _, i=item_id: self.on_edit(i))
            delete_btn.clicked.connect(lambda _, i=item_id: self.confirm_delete(i))

            btn_container = QWidget()
            btn_layout.addWidget(edit_btn)
            btn_layout.addWidget(delete_btn)
            btn_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
            btn_container.setLayout(btn_layout)
            self.table.setCellWidget(row, len(self.columns), btn_container)
            self.table.setRowHeight(row, 50)

        self.table.setHorizontalScrollMode(QAbstractItemView.ScrollMode.ScrollPerPixel)
        self.table.setSizeAdjustPolicy(
            QAbstractScrollArea.SizeAdjustPolicy.AdjustToContents
        )
        self.table.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)

        header = self.table.horizontalHeader()
        header.setSectionResizeMode(QHeaderView.ResizeMode.ResizeToContents)

    def handle_item_click(self, item):
        col = item.column()
        key, _ = self.columns[col]
        if key == self.id_field:
            item_id = item.text()
            self.on_view(item_id)

    def on_search(self):
        keyword = self.search_input.text().strip()
        self.filters["keyword"] = keyword
        self.current_page = 1
        self.load_data()

    def on_sort(self, index):
        if index >= len(self.columns):
            return
        key, _ = self.columns[index]
        if self.sort_field == key:
            # Toggle order
            self.sort_order = "desc" if self.sort_order == "asc" else "asc"
        else:
            self.sort_field = key
            self.sort_order = "asc"
        self.load_data()

    def prev_page(self):
        if self.current_page > 1:
            self.current_page -= 1
            self.load_data()

    def next_page(self):
        if self.current_page < self.total_pages:
            self.current_page += 1
            self.load_data()

    def confirm_delete(self, item_id):
        reply = QMessageBox.question(
            self,
            "Xác nhận xóa",
            f"Bạn có chắc muốn xóa item với id `{item_id}`?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
        )
        if reply == QMessageBox.StandardButton.Yes:
            self.service.remove(item_id)
            self.load_data()
