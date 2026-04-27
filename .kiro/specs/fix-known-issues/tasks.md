# Tasks: Fix Known Issues

## 1. Batch update trong FIFO (Issue #1)

- [ ] 1.1 Gom bonus results vào list trong vòng lặp
- [ ] 1.2 Batch update mỗi 100 rows bằng `_db.batch()`
- [ ] 1.3 Flush remaining batch cuối vòng lặp

## 2. Batch insert cho Import (Issue #2)

- [ ] 2.1 `import_main_data.dart`: gom rows, `batch.insertAll()` mỗi 100
- [ ] 2.2 `import_service.dart` holiday: gom rows, batch insert
- [ ] 2.3 `import_service.dart` level: gom rows, batch insert

## 3. Async file read (Issue #4)

- [ ] 3.1 Đổi `readAsBytesSync()` → `await File(...).readAsBytes()`

## 4. Holiday DateTime normalize (Issue #5)

- [ ] 4.1 Trong `changeDateByHolidays()`: normalize `current` thành midnight trước khi check set
- [ ] 4.2 Đảm bảo `holidaySet` cũng dùng midnight (đã OK)

## 5. Transaction wrapper (Issue #6)

- [ ] 5.1 Wrap toàn bộ body `calculate()` trong `_db.transaction(() async { ... })`
- [ ] 5.2 Nếu exception → auto rollback

## 6. Isolate cho services (Issue #3)

- [ ] 6.1 Tạo helper `runInIsolate()` hoặc dùng `compute()`
- [ ] 6.2 Lưu ý: Drift cần `NativeDatabase` mở riêng trong isolate, hoặc dùng `DriftIsolate`
- [ ] 6.3 Wrap `importFromExcel` trong isolate
- [ ] 6.4 Wrap `calculate` trong isolate
- [ ] 6.5 Wrap `exportToExcel` trong isolate
- [ ] 6.6 Thay callback `onLog` bằng `SendPort` hoặc stream

## 7. Dark theme toggle (Issue #7)

- [ ] 7.1 Thêm `ThemeMode` state vào app (Riverpod provider hoặc ValueNotifier)
- [ ] 7.2 Thêm IconButton toggle trên AppBar
- [ ] 7.3 Persist preference (shared_preferences hoặc drift)

## 8. Progress bar % (Issue #8)

- [ ] 8.1 Thêm callback `onProgress(int current, int total)` vào services
- [ ] 8.2 Dashboard nhận progress → tính % → update LinearProgressIndicator value
- [ ] 8.3 Hiển thị text "X/Y" bên cạnh progress bar

## 9. Verify

- [ ] 9.1 `dart analyze` pass
- [ ] 9.2 Mỗi file ≤ 150 lines
- [ ] 9.3 Chạy app trên Windows, test với data mẫu
