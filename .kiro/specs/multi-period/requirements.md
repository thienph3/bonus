# Requirements: Hỗ trợ nhiều kỳ (Multi-period)

## Mục tiêu

Giữ lại data và kết quả của các lần chạy trước. User có thể xem lại, so sánh, và export lại bất kỳ kỳ nào.

## Thiết kế

Mỗi lần import + calculate = 1 "run" (kỳ). Thay vì xóa data cũ, gắn `run_id` vào mọi record để phân biệt kỳ nào.

### FR-1: Gắn run_id vào data

- Thêm cột `runId` vào bảng: main_data, level_config, holiday_config, result, matching_detail
- Mỗi lần import tạo 1 run mới trong RunHistories, dùng run_id đó cho toàn bộ data
- KHÔNG xóa data cũ khi import mới

### FR-2: Calculate theo run

- Calculate chỉ xử lý data của run hiện tại (filter by run_id)
- Results và matching_details gắn cùng run_id

### FR-3: UI — Chọn kỳ

- Thêm dropdown/selector trên AppBar hoặc sidebar: danh sách các runs (timestamp + file name + status)
- Khi chọn 1 run → preview hiển thị kết quả của run đó
- Run mới nhất được chọn mặc định

### FR-4: Export theo run

- Export chỉ xuất data của run đang chọn
- File name gợi ý: `result_<timestamp>.xlsx`

### FR-5: Xóa run cũ

- User có thể xóa 1 run (cascade delete: main_data, level_config, holiday_config, result, matching_detail của run đó)
- Confirm dialog trước khi xóa

## Ràng buộc

- Migration: schemaVersion tăng lên 2, thêm cột runId (nullable cho data cũ)
- Mỗi file ≤ 150 lines
- `dart analyze` pass

## Tham chiếu

- #[[file:docs/KNOWN_ISSUES.md]]
- #[[file:debt_matching/lib/data/database/tables.dart]]
