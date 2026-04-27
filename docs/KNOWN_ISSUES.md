# KNOWN ISSUES

## Business rules (accepted)

| # | Issue | Status |
|---|-------|--------|
| 1 | FIFO gom decrease trước increase (không theo thứ tự thời gian thực) | BIZ RULE |
| 2 | Decrease chỉ push 1 loại (bonus HOẶC non_bonus) | ACCEPTED |
| 3 | non_bonus increase consume stack không phân biệt | ACCEPTED |
| 4 | bonus_1/2/3 = số tiền đủ điều kiện, không phải tiền thưởng thực | CLARIFIED |

## Đã fix ✅

| Issue | Fix |
|-------|-----|
| FIFO update từng row | Batch 100 rows |
| Import insert từng row | Batch insertAll |
| readAsBytesSync block UI | Async readAsBytes |
| Holiday DateTime normalize | Normalize trong parseDate + changeDateByHolidays |
| Không có transaction | db.transaction() wrapper |
| Không có audit trail | Bảng RunHistories |
| Không export chi tiết đối trừ | Bảng MatchingDetails + sheet "Matching Detail" |
| Không validate tổng | Reconciliation check (pushed = consumed + remaining) |
| Dark theme | Toggle trên AppBar |
| Flow 3 bước thừa | Gộp: Chọn file → Preview → Export |
| Không có preview | Preview panel (summary, warnings, top 20) |
| Không chạy trong Isolate | Excel parse, FIFO, Excel build trong Isolate.run() |
| Không hỗ trợ nhiều kỳ | runId trên mọi record, run selector, xem/export/xóa từng kỳ |
| Không phân biệt thanh toán cho khoản nào | MatchingDetails lưu chi tiết từng cặp đối trừ |

## Còn tồn tại

Không có.
