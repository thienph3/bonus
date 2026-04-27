# Tasks: DriftIsolate

## 1. Tạo isolate runner helper

- [ ] 1.1 Tạo `core/utils/isolate_runner.dart`
- [ ] 1.2 Helper function nhận: task function + SendPort cho log
- [ ] 1.3 Main thread: tạo ReceivePort, listen log messages, forward tới UI callback

## 2. Refactor Import để chạy trong isolate

- [ ] 2.1 Tách phần đọc Excel + parse thành pure function (không phụ thuộc DB instance)
- [ ] 2.2 Chạy parse trong `Isolate.run()` → return list of companion objects
- [ ] 2.3 Main thread nhận list → batch insert vào DB (DB đã có background isolate)
- [ ] 2.4 Stream log qua SendPort

## 3. Refactor Calculate để chạy trong isolate

- [ ] 3.1 Load data từ DB trên main thread (async, đã background)
- [ ] 3.2 Chạy validate + sort + FIFO trong `Isolate.run()` → return results
- [ ] 3.3 Main thread nhận results → batch update DB
- [ ] 3.4 Stream log qua SendPort

## 4. Refactor Export để chạy trong isolate

- [ ] 4.1 Load data từ DB trên main thread
- [ ] 4.2 Chạy build Excel bytes trong `Isolate.run()` → return bytes
- [ ] 4.3 Main thread nhận bytes → write file
- [ ] 4.4 Stream log qua SendPort

## 5. Update Dashboard

- [ ] 5.1 Dashboard gọi services mới (API không đổi, chỉ internal thay đổi)
- [ ] 5.2 Log callback vẫn hoạt động real-time qua ReceivePort

## 6. Verify

- [ ] 6.1 `dart analyze` pass
- [ ] 6.2 Mỗi file ≤ 150 lines
