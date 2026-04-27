# Tasks: UX Option B

## 1. Refactor Dashboard states

- [ ] 1.1 Đổi state machine: initial → processing → preview → exported
- [ ] 1.2 Xóa 3 step cards, thay bằng single content area thay đổi theo state
- [ ] 1.3 Giữ console panel bên phải

## 2. State: Initial

- [ ] 2.1 Hiển thị nút lớn "Chọn file Excel" ở giữa
- [ ] 2.2 Text hướng dẫn ngắn bên dưới (file cần 3 sheet: Data, level_config, holiday_config)

## 3. State: Processing

- [ ] 3.1 Khi user chọn file → chuyển sang state processing
- [ ] 3.2 Hiển thị progress indicator (indeterminate)
- [ ] 3.3 Gọi importFromExcel → calculate tuần tự
- [ ] 3.4 Nếu error → hiển thị error message + nút "Thử lại"

## 4. State: Preview

- [ ] 4.1 Tạo widget `preview_panel.dart` hiển thị:
  - Summary cards (records, valid/invalid, bonus totals, reconciliation)
  - Warnings list (invalid records, mismatch)
  - Preview table (top 20 records có bonus > 0)
- [ ] 4.2 Nút "Xuất kết quả" (primary) và "Chọn file khác" (secondary)

## 5. State: Exported

- [ ] 5.1 Hiển thị success message + file path
- [ ] 5.2 Nút "Bắt đầu lại"

## 6. Cleanup

- [ ] 6.1 Xóa step_card.dart (không còn dùng)
- [ ] 6.2 `dart analyze` pass
- [ ] 6.3 Mỗi file ≤ 150 lines
