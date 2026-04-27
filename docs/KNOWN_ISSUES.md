# KNOWN ISSUES

## Thiết kế nghiệp vụ

### 1. ~~FIFO mù — không phản ánh thứ tự thời gian thực~~ [BIZ RULE]

### 2. ~~Không phân biệt thanh toán cho khoản nợ nào~~ [FIXED]

### 3. ~~bonus_1/2/3 là số tiền đủ điều kiện~~ [CLARIFIED]

### 4. ~~Decrease chỉ push 1 loại~~ [ACCEPTED]

### 5. ~~non_bonus increase consume stack không phân biệt~~ [ACCEPTED]

---

## Đã fix ✅

| Issue | Fix |
|-------|-----|
| FIFO batch update từng row | Batch 100 rows |
| Import insert từng row | Batch insertAll |
| readAsBytesSync block UI | Async readAsBytes |
| Holiday DateTime normalize | Normalize trong parseDate + changeDateByHolidays |
| Không có transaction | Wrap calculate trong db.transaction() |
| Không có audit trail | Bảng RunHistories |
| Không export chi tiết đối trừ | Bảng MatchingDetails + sheet "Matching Detail" |
| Không validate tổng | Reconciliation check sau FIFO |
| Dark theme toggle | IconButton trên AppBar |
| Flow 3 bước thừa | Gộp thành: Chọn file → Preview → Export |
| Không có preview | Preview panel với summary, warnings, top 20 records |
| Không chạy trong Isolate | Excel parse, FIFO compute, Excel build chạy trong Isolate.run() |
| Không hỗ trợ nhiều kỳ | runId gắn vào mọi record, run selector UI, xem/export/xóa từng kỳ |

---

## Còn tồn tại

Không có issues tồn tại.
