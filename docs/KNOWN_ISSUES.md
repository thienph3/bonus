# KNOWN ISSUES (Flutter version)

## Performance (quan trọng)

### 1. FIFO loop update từng row

**File:** `calculate_service.dart` → `_calculateFifo()`

Gọi `await _db.update(...).write(...)` cho mỗi result trong vòng lặp. Với 5000+ records → 5000 DB writes tuần tự, rất chậm.

**Fix:** Gom updates vào list, batch update mỗi 100 rows hoặc cuối vòng lặp.

---

### 2. Import insert từng row

**File:** `import_main_data.dart`, `import_service.dart`

Insert từng record một thay vì batch. Chậm với data lớn.

**Fix:** Gom rows vào list, dùng `batch.insertAll()` mỗi 100 rows (như calculate đã làm ở bước insert results).

---

### 3. Không chạy trong Isolate

**File:** Tất cả services

Import/Calculate/Export chạy trên main thread. Data lớn sẽ block UI (jank, freeze).

**Fix:** Wrap service calls trong `Isolate.run()` hoặc `compute()`. Lưu ý Drift cần setup riêng cho multi-isolate.

---

### 4. readAsBytesSync() block main thread

**File:** `import_service.dart`

`File(filePath).readAsBytesSync()` đọc đồng bộ. File Excel 10MB+ sẽ freeze UI.

**Fix:** Dùng `File(filePath).readAsBytes()` (async).

---

## Logic

### 5. Holiday set DateTime comparison

**File:** `calculate_service.dart`, `parse_utils.dart`

`holidaySet` dùng `DateTime(year, month, day)` (midnight). Nhưng `changeDateByHolidays` cộng `Duration(days: 1)` — nếu input DateTime có time component (VD: 10:30) thì ngày tiếp theo cũng có time → không match với set.

**Fix:** Normalize date trong `changeDateByHolidays`: `DateTime(current.year, current.month, current.day)` trước khi check set.

---

### 6. Không có transaction wrapper

**File:** `calculate_service.dart`

Nếu fail ở bước FIFO, bước insert results đã commit → DB ở trạng thái nửa vời (có results nhưng bonus = 0).

**Fix:** Wrap toàn bộ `calculate()` trong `_db.transaction(() async { ... })`.

---

## UX

### 7. Không có dark theme toggle

App có `darkTheme` config nhưng không có UI button để switch. Luôn dùng light.

### 8. Progress bar indeterminate

`LinearProgressIndicator` chạy không xác định. Không hiển thị % hoàn thành thực tế.
