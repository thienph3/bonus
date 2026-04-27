# Requirements: Chuyển đổi Bonus Calculator sang Flutter Desktop

## Mục tiêu

Viết lại toàn bộ ứng dụng Bonus Calculator từ Python/PyQt6 sang Flutter Desktop App (Windows/Linux/macOS), giữ nguyên logic nghiệp vụ, xóa toàn bộ code Python cũ.

## Yêu cầu chức năng

### FR-1: Import dữ liệu từ Excel
- Đọc file Excel (.xlsx, .xls) chứa 3 sheet: `Data`, `level_config`, `holiday_config`
- Dynamic header detection cho sheet Data (scan tìm row có >= 17 cột non-empty)
- Parse date (nhiều format), parse number
- Xóa dữ liệu cũ trước khi import mới
- Hiển thị progress và log chi tiết

### FR-2: Tính toán thưởng (Core logic)
- Validate main_data records (document_number, payment_period, seasonal_code, sales_method)
- Mapping main_data với level_config (case-insensitive, payment_period >= level.payment_period)
- Sort levels theo (seasonal_code ASC, sales_method ASC, payment_period DESC)
- Phân loại giao dịch: type 0 (decrease/thanh toán), type 1 (increase/mua hàng), type -1 (invalid)
- Tính payment_due_date_1/2/3 (ưu tiên ngày cố định, fallback = document_date + period)
- Holiday adjustment (dời ngày nếu trùng ngày lễ)
- Sort valid results theo (customer_code, branch, seasonal_code, type, payment_due_date, amounts)
- FIFO stack processing theo group (customer_code, branch, seasonal_code)
- Decrease push vào stack, Increase consume từ stack
- Tính bonus_1/2/3 dựa trên so sánh ngày thanh toán với mốc đáo hạn
- non_bonus increase consume stack nhưng không sinh bonus

### FR-3: Export kết quả
- Xuất file Excel (.xlsx) với formatting
- Date format: dd/mm/yyyy
- Number format: #,##0 (VND accounting)
- Auto-resize columns
- Sort theo original_idx (thứ tự gốc)

### FR-4: Giao diện
- Dashboard workflow 3 bước (Import → Calculate → Export)
- Real-time progress/status cho mỗi bước
- Console log panel
- Xem/sửa dữ liệu (holiday_config, level_config, main_data, result)
- Light/Dark theme
- Responsive layout

### FR-5: Database
- SQLite local (file database.db)
- 4 bảng: holiday_config, level_config, main_data, result
- Schema giữ nguyên như hiện tại

## Yêu cầu phi chức năng

### NFR-1: Performance
- Import/Calculate/Export chạy background (không block UI)
- Batch processing cho insert/update

### NFR-2: Platform
- Target: Windows only
- Single executable hoặc installer

### NFR-3: UX
- UI modern, clean (Material Design 3)
- Animation mượt cho status/progress
- Error handling rõ ràng với message chi tiết

## Tham chiếu

- Logic tính toán chi tiết: #[[file:docs/LOGIC_CALCULATE.md]]
- Logic import: #[[file:docs/LOGIC_IMPORT.md]]
- Logic export: #[[file:docs/LOGIC_EXPORT.md]]
- Database schema: #[[file:docs/DATABASE_SCHEMA.md]]
- Known issues cần fix khi rewrite: #[[file:docs/KNOWN_ISSUES.md]]
