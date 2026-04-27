# KNOWN ISSUES

## Thiết kế nghiệp vụ

### 1. ~~FIFO mù — không phản ánh thứ tự thời gian thực~~ [BIZ RULE]

Đây là business rule: gom toàn bộ decrease trước increase trong cùng group. Không phải bug.

### 2. ~~Không phân biệt thanh toán cho khoản nợ nào~~ [FIXED]

Đã fix: bảng MatchingDetails lưu chi tiết từng cặp đối trừ (increase_doc ↔ decrease_doc, amount, tier). Export thêm sheet "Matching Detail".

### 3. ~~bonus_1/2/3 là số tiền đủ điều kiện~~ [CLARIFIED]

Đã ghi rõ trong README: bonus = số tiền đủ điều kiện thưởng, không phải tiền thưởng thực.

### 4. ~~Decrease chỉ push 1 loại~~ [ACCEPTED]

Tạm bỏ qua theo yêu cầu.

### 5. ~~non_bonus increase consume stack không phân biệt~~ [ACCEPTED]

Tạm bỏ qua theo yêu cầu.

---

## Đã fix ✅

| Issue | Fix |
|-------|-----|
| FIFO batch update từng row | ✅ Batch 100 rows (`calculate_fifo.dart`) |
| Import insert từng row | ✅ Batch insertAll |
| readAsBytesSync block UI | ✅ Async readAsBytes |
| Holiday DateTime normalize | ✅ Normalize trong parseDate + changeDateByHolidays |
| Không có transaction | ✅ Wrap calculate trong db.transaction() |
| Không có audit trail | ✅ Bảng RunHistories |
| Không export chi tiết đối trừ | ✅ Bảng MatchingDetails + sheet "Matching Detail" |
| Không validate tổng | ✅ Reconciliation check sau FIFO |
| Dark theme toggle | ✅ IconButton trên AppBar |

---

## Còn tồn tại

### 6. Không hỗ trợ nhiều kỳ

Mỗi lần import xóa toàn bộ data cũ (main_data, level_config, holiday_config, results, matching_details). Không giữ được data/result của kỳ trước để so sánh. RunHistories chỉ lưu metadata, không lưu data thực.

### 7. Không chạy trong Isolate

Services chạy trên main thread. Data > 2000 rows có thể gây jank UI. Batch operations đã giúp giảm nhưng chưa triệt để.

### 8. Flow 3 bước thừa bước Calculate

User luôn chạy Import → Calculate → Export tuần tự. Calculate là implementation detail. Cần gộp thành: Chọn file → Preview → Export.

### 9. Không có preview trước khi export

User không biết kết quả đúng/sai cho đến khi mở file Excel. Cần hiển thị preview trước khi export.
