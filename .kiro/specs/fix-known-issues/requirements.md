# Requirements: Fix Known Issues

## Mục tiêu

Fix 8 issues trong `docs/KNOWN_ISSUES.md` để app hoạt động ổn định với data lớn (5000+ rows) và UX tốt hơn.

## Yêu cầu

### Performance

- FR-1: FIFO calculation batch update mỗi 100 rows thay vì update từng row
- FR-2: Import dùng batch insert (100 rows/lần) cho cả 3 loại data
- FR-3: Services chạy trong Isolate (không block UI)
- FR-4: Đọc file Excel async (`readAsBytes()`)

### Logic

- FR-5: Normalize DateTime trong `changeDateByHolidays` trước khi check holiday set
- FR-6: Wrap toàn bộ `calculate()` trong transaction

### UX

- FR-7: Thêm dark theme toggle button trên AppBar
- FR-8: Progress bar hiển thị % thực tế (truyền current/total từ service)

## Ràng buộc

- Giữ nguyên logic nghiệp vụ (kết quả tính toán không đổi)
- Mỗi file vẫn ≤ 150 lines
- `dart analyze` pass, 0 errors

## Tham chiếu

- #[[file:docs/KNOWN_ISSUES.md]]
