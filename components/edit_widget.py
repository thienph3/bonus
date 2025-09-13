import datetime
from sqlalchemy.exc import IntegrityError, StatementError

from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QPushButton,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QDateEdit,
    QMessageBox,
    QScrollArea,
)
from PyQt6.QtCore import QDate


class EditWidget(QWidget):
    def __init__(self, columns, service, record=None, on_saved=None, on_cancel=None):
        super().__init__()
        self.service = service
        self.columns = columns
        self.record = record or {}
        self.on_saved = on_saved
        self.on_cancel = on_cancel

        # layout = QVBoxLayout()
        # self.inputs = {}
        # for key, label in columns:
        #     if key == "id":
        #         continue  # không cho chỉnh ID
        #     layout.addWidget(QLabel(label))

        #     value = self.record.get(key, "")

        #     if isinstance(value, (datetime.date, datetime.datetime)):
        #         date_edit = QDateEdit()
        #         date_edit.setCalendarPopup(True)
        #         date_edit.setDisplayFormat("dd/MM/yyyy")
        #         if isinstance(value, datetime.datetime):
        #             value = value.date()  # chỉ lấy phần ngày
        #         date_edit.setDate(QDate(value.year, value.month, value.day))
        #         self.inputs[key] = date_edit
        #         layout.addWidget(date_edit)
        #     else:
        #         line = QLineEdit()
        #         line.setText(str(value) if value else "")
        #         self.inputs[key] = line
        #         layout.addWidget(line)

        # btn_layout = QHBoxLayout()
        # save_btn = QPushButton("Lưu")
        # save_btn.clicked.connect(self.save)
        # cancel_btn = QPushButton("Hủy")
        # cancel_btn.clicked.connect(self.on_cancel)
        # btn_layout.addWidget(save_btn)
        # btn_layout.addWidget(cancel_btn)
        # layout.addLayout(btn_layout)

        # self.setLayout(layout)
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)

        container = QWidget()
        form_layout = QVBoxLayout(container)
        self.inputs = {}

        for key, label in columns:
            if key == "id":
                continue

            value = self.record.get(key, "")

            # Tạo một layout ngang cho từng dòng
            row_layout = QHBoxLayout()

            lbl = QLabel(label)
            lbl.setFixedWidth(200)  # để nhãn cùng chiều rộng
            row_layout.addWidget(lbl)

            if isinstance(value, (datetime.date, datetime.datetime)):
                date_edit = QDateEdit()
                date_edit.setCalendarPopup(True)
                date_edit.setDisplayFormat("dd/MM/yyyy")
                if isinstance(value, datetime.datetime):
                    value = value.date()
                date_edit.setDate(QDate(value.year, value.month, value.day))
                self.inputs[key] = date_edit
                row_layout.addWidget(date_edit)
            else:
                line = QLineEdit()
                line.setText(str(value) if value else "")
                self.inputs[key] = line
                row_layout.addWidget(line)

            form_layout.addLayout(row_layout)

        # Nút lưu/hủy
        btn_layout = QHBoxLayout()
        save_btn = QPushButton("Lưu")
        save_btn.clicked.connect(self.save)
        cancel_btn = QPushButton("Hủy")
        cancel_btn.clicked.connect(self.on_cancel)
        btn_layout.addWidget(save_btn)
        btn_layout.addWidget(cancel_btn)
        form_layout.addLayout(btn_layout)
        form_layout.addStretch()

        # Gắn container vào scroll area
        scroll_area.setWidget(container)

        # Đặt scroll_area vào layout chính
        main_layout = QVBoxLayout()
        main_layout.addWidget(scroll_area)
        self.setLayout(main_layout)

    # def save(self):
    #     data = {k: v.text().strip() for k, v in self.inputs.items()}
    #     if self.record.get("id"):
    #         self.service.update(self.record["id"], **data)
    #     else:
    #         self.service.create(data)
    #     if self.on_saved:
    #         self.on_saved()

    def save(self):
        result = {}
        for key, widget in self.inputs.items():
            if isinstance(widget, QDateEdit):
                qdate = widget.date()
                if not qdate.isValid():
                    result[key] = None  # Không set nếu ngày không hợp lệ
                else:
                    pydate = datetime.date(qdate.year(), qdate.month(), qdate.day())
                    result[key] = pydate
            elif isinstance(widget, QLineEdit):
                text = widget.text()
                # Optional: convert to int/float/bool if needed here
                result[key] = text
            else:
                # fallback nếu có widget lạ
                result[key] = widget.text() if hasattr(widget, "text") else None

        try:
            if self.record.get("id"):
                self.service.update(self.record["id"], **result)
            else:
                self.service.create(**result)

            if self.on_saved:
                self.on_saved()

        except TypeError as e:
            self.service.rollback()
            QMessageBox.warning(
                self,
                "Lỗi kiểu dữ liệu",
                f"Kiểu dữ liệu không hợp lệ: {str(e)}",
                QMessageBox.StandardButton.Ok,
            )

        except (IntegrityError, StatementError) as e:
            self.service.rollback()
            if "UNIQUE constraint failed" in str(e.orig):
                QMessageBox.warning(
                    self,
                    "Lỗi trùng dữ liệu",
                    "Dữ liệu tương tự đã tồn tại trong hệ thống. Vui lòng chọn dữ liệu khác.",
                    QMessageBox.StandardButton.Ok,
                )
            else:
                QMessageBox.critical(
                    self,
                    "Lỗi cơ sở dữ liệu",
                    f"Lỗi ràng buộc: {str(e.orig)}",
                    QMessageBox.StandardButton.Ok,
                )

        except Exception as e:
            self.service.rollback()
            QMessageBox.critical(
                self,
                "Lỗi khi lưu dữ liệu",
                f"Đã xảy ra lỗi không xác định: {str(e)}",
                QMessageBox.StandardButton.Ok,
            )
