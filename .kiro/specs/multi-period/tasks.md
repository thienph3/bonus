# Tasks: Multi-period

## 1. Database migration

- [ ] 1.1 Thêm cột `runId` (text, nullable) vào: MainDatas, LevelConfigs, HolidayConfigs, Results, MatchingDetails
- [ ] 1.2 Tăng schemaVersion → 2
- [ ] 1.3 Viết migration: ALTER TABLE ADD COLUMN runId TEXT
- [ ] 1.4 Regenerate (`dart run build_runner build`)

## 2. Import — gắn run_id

- [ ] 2.1 Import service: tạo RunHistory trước, lấy run_id
- [ ] 2.2 Truyền run_id vào import_parser (thêm vào mỗi row Map)
- [ ] 2.3 Bỏ logic xóa data cũ — chỉ insert mới
- [ ] 2.4 Batch insert với run_id

## 3. Calculate — filter by run_id

- [ ] 3.1 Calculate service nhận run_id parameter
- [ ] 3.2 Load data filter by run_id
- [ ] 3.3 Xóa results/matching_details CỦA RUN ĐÓ trước khi tính lại (không xóa run khác)
- [ ] 3.4 Insert results/matching_details với run_id

## 4. Export — filter by run_id

- [ ] 4.1 Export service nhận run_id parameter
- [ ] 4.2 Load results/matching_details filter by run_id
- [ ] 4.3 File name gợi ý có timestamp

## 5. UI — Run selector

- [ ] 5.1 Tạo widget `run_selector.dart`: dropdown hiển thị danh sách runs
- [ ] 5.2 Mỗi item: timestamp + file name + status (imported/completed)
- [ ] 5.3 Đặt trên AppBar hoặc phía trên main content
- [ ] 5.4 Khi chọn run → load preview của run đó
- [ ] 5.5 Run mới nhất auto-select

## 6. UI — Xóa run

- [ ] 6.1 Thêm nút xóa (icon delete) bên cạnh mỗi run trong selector
- [ ] 6.2 Confirm dialog: "Xóa kỳ này? Toàn bộ data sẽ bị xóa."
- [ ] 6.3 Cascade delete: main_data, level_config, holiday_config, result, matching_detail WHERE runId = X
- [ ] 6.4 Xóa RunHistory record
- [ ] 6.5 Sau xóa: auto-select run gần nhất còn lại

## 7. Dashboard flow update

- [ ] 7.1 State initial: hiển thị run selector (nếu có runs cũ) + nút "Import mới"
- [ ] 7.2 Khi chọn run cũ → hiển thị preview + nút export
- [ ] 7.3 Khi import mới → tạo run mới → auto process → preview
- [ ] 7.4 Nút "Import mới" luôn visible (không cần reset)

## 8. Verify

- [ ] 8.1 `dart analyze` pass
- [ ] 8.2 Mỗi file ≤ 150 lines
