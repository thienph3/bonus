# Requirements: DriftIsolate — Background DB Processing

## Mục tiêu

Chuyển database operations sang background isolate để UI không bị jank với data lớn (> 2000 rows).

## Phương án

Sử dụng `NativeDatabase.createInBackground()` — API chính thức của Drift. Drift tự tạo background isolate để host database, main thread giao tiếp qua message passing. Không cần tự quản lý Isolate/SendPort.

Tham khảo: https://drift.simonbinder.eu/platforms/vm/

## Yêu cầu

### FR-1: Đổi DB connection sang background isolate

Thay `NativeDatabase.createInBackground(file)` (đã dùng) — thực ra app hiện tại **đã dùng** `createInBackground` trong `app_database.dart`. Tức là DB đã chạy trên background isolate rồi.

Vấn đề thực sự: các service methods (import, calculate, export) chạy logic Dart nặng (for loops, sort, map) trên main thread. DB queries đã async nhưng logic xung quanh vẫn block.

### FR-2: Chuyển heavy Dart logic sang isolate

- Import: parse Excel + build companion objects → chạy trong `Isolate.run()`
- Calculate: validate + sort + FIFO loop → chạy trong `Isolate.run()`
- Export: build Excel bytes → chạy trong `Isolate.run()`

### FR-3: Log streaming từ isolate

- Dùng `SendPort`/`ReceivePort` để stream log messages từ isolate về main thread
- Dashboard nhận log stream và update UI real-time

## Ràng buộc

- DB connection giữ nguyên `createInBackground` (đã có)
- Mỗi file ≤ 150 lines
- `dart analyze` pass
- Giữ nguyên logic nghiệp vụ
