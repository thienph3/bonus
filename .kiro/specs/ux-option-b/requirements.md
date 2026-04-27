# Requirements: UX Option B — Import + Preview + Export

## Mục tiêu

Đổi flow từ 3 bước (Import → Calculate → Export) sang 2 bước có preview:
1. Chọn file → import + calculate tự động (gộp)
2. Preview kết quả → xác nhận → export

## Yêu cầu chức năng

### FR-1: Gộp Import + Calculate thành 1 bước
- User chọn file Excel
- App tự động: import → calculate → hiển thị preview
- Console log vẫn hiển thị chi tiết từng sub-step
- Nếu lỗi ở bất kỳ đâu → hiển thị error, cho chọn lại file

### FR-2: Preview screen sau khi tính toán xong
- Summary cards:
  - Tổng records imported
  - Tổng records valid / invalid
  - Tổng bonus_1, bonus_2, bonus_3
  - Reconciliation status (OK / mismatch)
- Warnings nếu có:
  - Số records invalid > 0 → hiển thị danh sách lý do
  - Reconciliation mismatch
- Preview table: top 20 records có bonus > 0 (sortable)
- Nút "Xuất kết quả" và "Chọn file khác"

### FR-3: Export
- User nhấn "Xuất kết quả" → chọn save path → export
- Sau export: hiển thị success message + path file
- Nút "Bắt đầu lại" để reset

### FR-4: Layout mới
```
┌─────────────────────────────────────────────┐
│ AppBar (title + theme toggle)               │
├────────────────────────┬────────────────────┤
│                        │                    │
│   Main Area            │   Console Log      │
│   (Step 1 hoặc        │                    │
│    Preview screen)     │                    │
│                        │                    │
└────────────────────────┴────────────────────┘
```

- State 1 (initial): Nút "Chọn file Excel" lớn ở giữa + hướng dẫn ngắn
- State 2 (processing): Progress indicator + console log
- State 3 (preview): Summary + table + action buttons
- State 4 (exported): Success message + reset button

## Ràng buộc

- Giữ nguyên logic nghiệp vụ (services không đổi)
- Chỉ thay đổi presentation layer
- Mỗi file ≤ 150 lines
- Console log vẫn hoạt động real-time
