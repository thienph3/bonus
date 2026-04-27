# Tasks: Fix Remaining Issues

## 1. Clarify bonus meaning (Issue #3)

- [ ] 1.1 Cập nhật README: ghi rõ bonus_1/2/3 = số tiền đủ điều kiện, không phải tiền thưởng thực
- [ ] 1.2 Cập nhật docs/LOGIC_CALCULATE.md: thêm note giải thích ý nghĩa output

## 2. Audit trail (Issue #6)

- [ ] 2.1 Thêm table `RunHistories` trong tables.dart (id, timestamp, filePath, recordCount, levelCount, holidayCount, totalBonus, status)
- [ ] 2.2 Regenerate database (`dart run build_runner build`)
- [ ] 2.3 Import service: tạo run_history record khi bắt đầu, update khi hoàn tất
- [ ] 2.4 Calculate service: update run_history với totalBonus
- [ ] 2.5 UI: thêm tab/section hiển thị lịch sử chạy (đơn giản, list view)

## 3. Export chi tiết đối trừ (Issue #7)

- [ ] 3.1 Thêm table `MatchingDetails` (id, resultId, decreaseDocNumber, decreaseDate, amountMatched, bonusTier)
- [ ] 3.2 Regenerate database
- [ ] 3.3 Trong calculate_fifo.dart: khi consume stack, lưu matching detail (document_number từ decrease, amount, tier)
- [ ] 3.4 Export service: thêm sheet "Matching Detail" với columns: increase_doc, decrease_doc, decrease_date, amount, tier

## 4. Reconciliation check (Issue #8)

- [ ] 4.1 Sau FIFO loop: tính tổng decrease pushed, tổng consumed, tổng remaining
- [ ] 4.2 Verify: total_decrease_pushed = total_consumed + total_remaining
- [ ] 4.3 Log kết quả reconciliation
- [ ] 4.4 Return reconciliation stats trong calculate result
- [ ] 4.5 Dashboard hiển thị reconciliation summary sau calculate

## 5. Isolate (Issue #10)

- [ ] 5.1 Tạo helper để mở DB connection trong isolate
- [ ] 5.2 Wrap importFromExcel trong compute/Isolate
- [ ] 5.3 Wrap calculate trong compute/Isolate
- [ ] 5.4 Wrap exportToExcel trong compute/Isolate
- [ ] 5.5 Stream log messages từ isolate về main thread (SendPort/ReceivePort)
- [ ] 5.6 Dashboard nhận log stream và update UI

## 6. Verify

- [ ] 6.1 `dart analyze` pass
- [ ] 6.2 Mỗi file ≤ 150 lines
