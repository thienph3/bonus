# Requirements: Fix Remaining Issues

## Mục tiêu

Fix 6 issues còn lại từ `docs/KNOWN_ISSUES.md`: #2, #3 (clarify doc), #6, #7, #8, #10.

## Yêu cầu

### FR-1: Clarify bonus meaning (Issue #3)
- Ghi rõ trong README và docs rằng bonus_1/2/3 = "số tiền đủ điều kiện thưởng ở mỗi tier", không phải tiền thưởng thực tế
- Bộ phận khác sẽ nhân % để ra tiền thưởng

### FR-2: Audit trail (Issue #6)
- Lưu lịch sử mỗi lần chạy: timestamp, file input, số records, kết quả tổng
- Bảng `run_history` trong DB
- Hiển thị lịch sử trên UI (danh sách các lần chạy)

### FR-3: Export chi tiết đối trừ (Issue #7)
- Thêm bảng `matching_detail` lưu từng cặp đối trừ: result_id, decrease_document_number, amount_matched, bonus_tier
- Export thêm sheet "Matching Detail" trong file Excel kết quả

### FR-4: Reconciliation check (Issue #8)
- Sau khi calculate xong, kiểm tra:
  - Tổng decrease trong stack = tổng bonus_1 + bonus_2 + bonus_3 + unmatched
  - Tổng increase consumed = tổng matched amount
- Log warning nếu không khớp
- Hiển thị tổng hợp trên dashboard sau calculate

### FR-5: Isolate (Issue #10)
- Import/Calculate/Export chạy trong Isolate
- UI không bị jank với data lớn
- Log vẫn stream real-time về main thread

## Ràng buộc

- Giữ nguyên logic FIFO (biz rule #1 không đổi)
- Mỗi file ≤ 150 lines
- `dart analyze` pass

## Tham chiếu

- #[[file:docs/KNOWN_ISSUES.md]]
- #[[file:docs/LOGIC_CALCULATE.md]]
