# DATABASE SCHEMA - Cấu trúc cơ sở dữ liệu

## Tổng quan

SQLite database (`database.db`), sử dụng SQLAlchemy ORM.
4 bảng chính, tất cả dùng UUID string làm primary key.

---

## Bảng: holiday_config

Danh sách ngày nghỉ lễ, dùng để điều chỉnh payment_due_date.

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|--------|
| id | String (UUID) | PK | |
| date | Date | UNIQUE, NOT NULL | Ngày nghỉ lễ |
| name | String | nullable | Tên ngày lễ (chưa sử dụng) |
| desc | String | nullable | Mô tả (chưa sử dụng) |

---

## Bảng: level_config

Cấu hình cấp độ thưởng theo mã vụ việc + phương thức bán hàng + kỳ hạn.

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|--------|
| id | String (UUID) | PK | |
| seasonal_code | String | NOT NULL | Mã vụ việc |
| sales_method | String | NOT NULL | Phương thức bán hàng |
| payment_period | Integer | NOT NULL | Kỳ hạn thanh toán (ngày) - dùng để match |
| payment_period_1 | Integer | NOT NULL | Số ngày tính bonus tier 1 |
| payment_period_2 | Integer | NOT NULL | Số ngày tính bonus tier 2 |
| payment_period_3 | Integer | NOT NULL | Số ngày tính bonus tier 3 |
| payment_due_date_1 | Date | nullable | Ngày đáo hạn cố định tier 1 (ưu tiên) |
| payment_due_date_2 | Date | nullable | Ngày đáo hạn cố định tier 2 (ưu tiên) |
| payment_due_date_3 | Date | nullable | Ngày đáo hạn cố định tier 3 (ưu tiên) |

**Unique constraint:** `(seasonal_code, sales_method, payment_period)`

---

## Bảng: main_data

Dữ liệu bán hàng chính, import từ sheet "Data".

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|--------|
| id | String (UUID) | PK | |
| idx | Integer | nullable | Số thứ tự trong Excel |
| document_date | Date | nullable | Ngày chứng từ |
| document_number | String | nullable | Số chứng từ |
| description | String | nullable | Diễn giải (không dùng trong tính toán) |
| corresponding_account | String | nullable | Tài khoản đối ứng |
| increase | Integer | nullable | Phát sinh tăng |
| decrease | Integer | nullable | Phát sinh giảm |
| adjust_increase | Integer | nullable | Điều chỉnh tăng |
| adjust_decrease | Integer | nullable | Điều chỉnh giảm |
| end_amount | Integer | nullable | Số dư cuối kỳ (không dùng trong tính toán) |
| seasonal_code | String | NOT NULL | Mã vụ việc |
| payment_period | Integer | nullable | Kỳ hạn thanh toán (ngày) |
| customer_code | String | NOT NULL | Mã khách hàng |
| customer_name | String | nullable | Tên khách hàng (không dùng trong tính toán) |
| branch | String | NOT NULL | Chi nhánh |
| code | String | nullable | Mã |
| sales_method | String | NOT NULL | Phương thức bán hàng |

---

## Bảng: result

Kết quả tính toán thưởng, liên kết với main_data và level_config.

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|--------|
| id | String (UUID) | PK | |
| main_data_id | String | FK → main_data.id, NOT NULL | |
| level_config_id | String | FK → level_config.id, nullable | NULL nếu không match được level |
| sorted_idx | Integer | NOT NULL, default 0 | Thứ tự sau khi sort (dùng cho FIFO) |
| original_idx | Integer | NOT NULL, default 0 | Thứ tự gốc khi import |
| type | Integer | NOT NULL, default 0 | -1=invalid, 0=decrease, 1=increase |
| payment_due_date | Date | nullable | Ngày đáo hạn chung |
| bonus_increase | Integer | NOT NULL, default 0 | Phần tăng có thưởng |
| non_bonus_increase | Integer | NOT NULL, default 0 | Phần tăng không thưởng |
| bonus_decrease | Integer | NOT NULL, default 0 | Phần giảm có thưởng |
| non_bonus_decrease | Integer | NOT NULL, default 0 | Phần giảm không thưởng |
| payment_due_date_1 | Date | nullable | Mốc đáo hạn tier 1 |
| payment_due_date_2 | Date | nullable | Mốc đáo hạn tier 2 |
| payment_due_date_3 | Date | nullable | Mốc đáo hạn tier 3 |
| bonus_1 | Integer | NOT NULL, default 0 | Thưởng tier 1 |
| bonus_2 | Integer | NOT NULL, default 0 | Thưởng tier 2 |
| bonus_3 | Integer | NOT NULL, default 0 | Thưởng tier 3 |
| before_remain | String | NOT NULL, default "" | Stack trước khi xử lý (debug) |
| after_remain | String | NOT NULL, default "" | Stack sau khi xử lý (debug) |
| calculate_status | String | NOT NULL, default "valid" | "valid" hoặc "invalid" |
| calculate_message | String | NOT NULL, default "" | Lý do invalid |

---

## Relationships

```
main_data (1) ←── (N) result
level_config (1) ←── (N) result
holiday_config: không có FK, dùng như lookup set
```

---

## Repository Pattern

Tất cả repositories dùng chung pattern:
- Mỗi repository tạo riêng `engine` và `SessionFactory` (không share session)
- `bulk_create()`: Binary split retry khi batch fail → isolate row lỗi
- `bulk_update()`: Tương tự binary split retry
- `delete_all()`: Xóa toàn bộ trước khi import mới
- `rollback()`: Rollback session khi có lỗi
