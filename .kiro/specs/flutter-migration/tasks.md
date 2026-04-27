# Tasks: Flutter Migration

## Phase 1: Project Setup

- [ ] 1.1 Tạo Flutter project mới (`flutter create --platforms=windows debt_matching`)
- [ ] 1.2 Thêm dependencies vào pubspec.yaml (drift, riverpod, excel, file_picker, uuid)
- [ ] 1.3 Setup project structure (core, data, domain, presentation)
- [ ] 1.4 Setup theme (Light/Dark, Material 3)

## Phase 2: Database Layer

- [ ] 2.1 Định nghĩa Drift tables (4 bảng)
- [ ] 2.2 Tạo DAOs (CRUD + bulk operations)
- [ ] 2.3 Generate code (`dart run build_runner build`)
- [ ] 2.4 Test database operations

## Phase 3: Core Utils

- [ ] 3.1 Implement `parseDate()` — hỗ trợ Excel serial, dd/mm/yyyy, yyyy-mm-dd, etc.
- [ ] 3.2 Implement `parseNumber()` — String/double → int?
- [ ] 3.3 Implement `changeDateByHolidays()` — while loop (không recursive)

## Phase 4: Import Service

- [ ] 4.1 Implement Excel reader với dynamic header detection
- [ ] 4.2 Import holiday_config (đọc cột date)
- [ ] 4.3 Import level_config (9 cột)
- [ ] 4.4 Import main_data (17 cột, batch insert)
- [ ] 4.5 Chạy trong Isolate + progress callback
- [ ] 4.6 Test với file data/input.xlsx

## Phase 5: Calculate Service

- [ ] 5.1 Validate & mapping main_data với level_config
- [ ] 5.2 Tạo result records (phân loại type, tính payment_due_date)
- [ ] 5.3 Sort valid results
- [ ] 5.4 FIFO stack processing + bonus calculation
- [ ] 5.5 Batch update results
- [ ] 5.6 Chạy trong Isolate + progress callback
- [ ] 5.7 Test kết quả khớp với output Python cũ (dùng data/result.xlsx làm baseline)

## Phase 6: Export Service

- [ ] 6.1 Load results, sort theo originalIdx
- [ ] 6.2 Ghi Excel với date serial + formatting
- [ ] 6.3 Auto-resize columns
- [ ] 6.4 Chạy trong Isolate
- [ ] 6.5 Test output format

## Phase 7: UI - Dashboard

- [ ] 7.1 App shell (AppBar, NavigationRail, Console panel)
- [ ] 7.2 Dashboard screen với 3 step cards
- [ ] 7.3 Step widget (status: ready/processing/completed/error + animation)
- [ ] 7.4 File picker integration (import/export)
- [ ] 7.5 Connect services → UI state (Riverpod)

## Phase 8: UI - Data Views

- [ ] 8.1 Holiday config list + CRUD
- [ ] 8.2 Level config list + CRUD
- [ ] 8.3 Main data paginated table
- [ ] 8.4 Result paginated table

## Phase 9: Polish

- [ ] 9.1 Error handling toàn app (snackbar, dialog)
- [ ] 9.2 Console log widget (scrollable, timestamped)
- [ ] 9.3 Theme toggle (persist preference)
- [ ] 9.4 Window title, icon, minimum size

## Phase 10: Cleanup & Deploy

- [ ] 10.1 Xóa toàn bộ code Python cũ (components/, models/, repositories/, services/, workers/, utils/, themes/, env/)
- [ ] 10.2 Cập nhật README.md
- [ ] 10.3 Cập nhật docs/ cho Flutter version
- [ ] 10.4 Build exe (`flutter build windows`)
- [ ] 10.5 Test end-to-end
