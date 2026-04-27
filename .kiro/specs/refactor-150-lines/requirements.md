# Requirements: Refactor - Giới hạn 150 lines/file

## Mục tiêu

Tách các file Dart vượt quá 150 lines of code thành các file nhỏ hơn, dễ đọc và maintain.

## Quy tắc

- Mỗi file `.dart` (trừ generated `.g.dart`) không quá **150 lines**
- Tách theo **single responsibility**: mỗi file làm 1 việc
- Giữ nguyên logic, không thay đổi behavior
- Public API không đổi (các class/function vẫn accessible như cũ)

## Files cần refactor

| File | Lines hiện tại | Hướng tách |
|------|---------------|------------|
| `calculate_service.dart` | 307 | Tách thành 3: validate+mapping, sort+create results, FIFO calculation |
| `dashboard_screen.dart` | 300 | Tách thành 2-3: step_card widget, dashboard logic, console widget |
| `import_service.dart` | 163 | Tách thành 2: main_data import riêng (có dynamic header), holiday+level chung |

## Ngoài phạm vi

- File generated (`app_database.g.dart`) — không sửa
- File `tables.dart` (83 lines) — OK, không cần tách
- Không thay đổi logic nghiệp vụ
- Không thêm feature mới
