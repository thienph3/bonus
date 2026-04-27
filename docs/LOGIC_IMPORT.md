# LOGIC IMPORT - Chi tiết luồng nhập dữ liệu

## Tổng quan

Import chạy song song 3 worker threads, mỗi worker xử lý 1 sheet từ cùng 1 file Excel:

| Worker | Sheet name | Service | Thư viện |
|--------|-----------|---------|----------|
| ImportMainDataWorker | "Data" | MainDataService | openpyxl (.xlsx) / xlrd (.xls) |
| ImportLevelConfigWorker | "level_config" | LevelConfigService | pandas |
| ImportHolidayConfigWorker | "holiday_config" | HolidayConfigService | pandas |

Tất cả worker đều **xóa toàn bộ dữ liệu cũ** trước khi import mới (không merge/upsert).

---

## 1. Import Main Data

### 1.1 Dynamic Header Detection

Không hard-code skip rows. Thay vào đó, scan tối đa 30 dòng đầu để tìm dòng header:

```python
# Tìm dòng đầu tiên có >= 17 cột non-empty → đó là header row
for i, row in enumerate(sheet.iter_rows(min_row=1, max_row=30)):
    values = [cell.value for cell in row]
    if sum(1 for v in values if v not in (None, "", " ")) >= 17:
        data_start_row = i  # Header found
        break

data_start_row += 1  # Data bắt đầu từ dòng tiếp theo sau header
```

### 1.2 Hỗ trợ cả .xlsx và .xls

| Format | Thư viện | Ghi chú |
|--------|----------|---------|
| .xlsx | openpyxl (read_only=True, data_only=True) | Nhanh, ít RAM |
| .xls | xlrd | Legacy format |

Với .xls, logic tương tự nhưng dùng `sheet.row_values()` thay vì `iter_rows`.

### 1.3 Column mapping (17 cột, theo thứ tự A→Q)

```python
headers = [
    "idx",                    # A - Số thứ tự
    "document_date",          # B - Ngày chứng từ
    "document_number",        # C - Số chứng từ
    "description",            # D - Diễn giải (không dùng trong tính toán)
    "corresponding_account",  # E - Tài khoản đối ứng
    "increase",               # F - Phát sinh tăng
    "decrease",               # G - Phát sinh giảm
    "adjust_increase",        # H - Điều chỉnh tăng
    "adjust_decrease",        # I - Điều chỉnh giảm
    "end_amount",             # J - Số dư cuối kỳ (không dùng trong tính toán)
    "seasonal_code",          # K - Mã vụ việc
    "payment_period",         # L - Kỳ hạn thanh toán (ngày)
    "customer_code",          # M - Mã khách hàng
    "customer_name",          # N - Tên khách hàng (không dùng trong tính toán)
    "branch",                 # O - Chi nhánh
    "code",                   # P - Mã
    "sales_method",           # Q - Phương thức bán hàng
]
```

### 1.4 Parse rules

| Field | Parse function | Ghi chú |
|-------|---------------|---------|
| idx | `parse_number()` | int hoặc None |
| document_date | `parse_date()` | Hỗ trợ nhiều format (xem bên dưới) |
| increase, decrease, adjust_* | `parse_number()` | int hoặc None |
| payment_period | `parse_number()` | int hoặc None |
| seasonal_code, customer_code, branch, sales_method | Raw string | Bắt buộc (NOT NULL trong DB) |

### 1.5 Điều kiện dừng

```python
# Dừng khi gặp dòng hoàn toàn trống
if all(cell is None or (isinstance(cell, str) and cell.strip() == "") for cell in row):
    break
```

### 1.6 Batch insert

- Batch size: 100 rows/lần
- Nếu batch fail → chia đôi (binary split) và retry từng nửa
- Nếu 1 row fail → log error, tiếp tục các row khác
- Parse error → rollback transaction cho row đó, skip, tiếp tục

---

## 2. Import Level Config

### 2.1 Đọc bằng pandas

```python
df = pd.read_excel(file_path, sheet_name="level_config")
```

Không cần dynamic header detection (pandas tự detect header row đầu tiên).

### 2.2 Columns (9 cột)

| Column | Type | Ghi chú |
|--------|------|---------|
| seasonal_code | String | Mã vụ việc |
| sales_method | String | Phương thức bán hàng |
| payment_period | Integer | Kỳ hạn thanh toán (ngày) - dùng để match với main_data |
| payment_period_1 | Integer | Kỳ hạn tính bonus tier 1 (ngày) |
| payment_period_2 | Integer | Kỳ hạn tính bonus tier 2 (ngày) |
| payment_period_3 | Integer | Kỳ hạn tính bonus tier 3 (ngày) |
| payment_due_date_1 | Date (nullable) | Ngày đáo hạn cố định tier 1 |
| payment_due_date_2 | Date (nullable) | Ngày đáo hạn cố định tier 2 |
| payment_due_date_3 | Date (nullable) | Ngày đáo hạn cố định tier 3 |

### 2.3 Unique constraint

```
UNIQUE(seasonal_code, sales_method, payment_period)
```

### 2.4 Insert strategy

Insert từng row một (không batch). Nếu row lỗi → rollback + skip + log warning.

### 2.5 Ý nghĩa payment_due_date vs payment_period

- `payment_due_date_X`: Ngày cố định (ưu tiên dùng nếu có giá trị)
- `payment_period_X`: Số ngày cộng thêm vào document_date (dùng khi payment_due_date_X = NULL)

---

## 3. Import Holiday Config

### 3.1 Đọc bằng pandas

```python
df = pd.read_excel(file_path, sheet_name="holiday_config")
```

### 3.2 Columns

| Column | Type | Ghi chú |
|--------|------|---------|
| date | Date (unique) | Ngày nghỉ lễ |

Model còn có `name` và `desc` nhưng hiện tại import chỉ đọc cột `date`.

### 3.3 Insert strategy

Insert từng row một. Nếu row lỗi → rollback + skip.

---

## 4. Utility Functions

### parse_date()

Hỗ trợ nhiều input types:

| Input type | Xử lý |
|-----------|--------|
| `pd.Timestamp` | `.date()` |
| `datetime` | `.date()` |
| `float/int` (Excel serial) | Convert từ epoch 1899-12-30, xử lý bug Excel leap year 1900 |
| String | Thử lần lượt: `dd/mm/yyyy`, `yyyy-mm-dd`, `yyyy-mm-dd HH:MM:SS`, `dd-mm-yyyy`, `mm/dd/yyyy` |
| None / empty | Return None |

### parse_number()

```python
def parse_number(number_str):
    if number_str is None or number_str == "" or pd.isna(number_str):
        return None
    return int(number_str)
```

---

## 5. Error Handling

| Loại lỗi | Xử lý |
|-----------|--------|
| Sheet không tồn tại | Exception → worker emit error signal |
| Sheet rỗng | Log warning, return (không crash) |
| Parse error (1 row) | Rollback row đó, skip, tiếp tục |
| Insert error (batch) | Binary split retry → isolate row lỗi |
| Fatal error | Raise exception → worker emit error signal → UI hiển thị |
