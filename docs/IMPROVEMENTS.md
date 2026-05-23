# IMPROVEMENTS — Prioritized Action Items

Consolidated from REVIEW.md. Sorted by priority (impact × likelihood / effort).

---

## Priority 1 — Fix Now (correctness & usability blockers)

### 1. Format số tiền hiển thị
- **Issue:** U1 — Raw integer "1234567890" không đọc được
- **Impact:** Mọi user bị ảnh hưởng, mọi lần dùng
- **Fix:** Dùng `NumberFormat('#,###')` từ package `intl` (đã có dependency)
- **Where:** `preview_panel.dart` — `_card()`, `_buildPreviewTable()`
- **Effort:** 15 min

### 2. Fix O(n²) trong CalculateWriter
- **Issue:** P1 — `matchingDetails.where((m) => chunk.any(...))` scan toàn bộ list mỗi chunk
- **Impact:** 10k rows → 5M comparisons, 50k rows → timeout
- **Fix:** Pre-group matchingDetails vào `Map<String, List<Map>>` by `resultId` trước vòng lặp
- **Where:** `calculate_writer.dart` → `writeFifoResults()`
- **Effort:** 10 min

### 3. Fix decrease chỉ push 1 loại vào stack
- **Issue:** B2 — Nếu chứng từ có cả bonusDecrease VÀ nonBonusDecrease, phần non_bonus bị mất
- **Impact:** Tổng đối trừ < tổng thanh toán thực tế, sai kết quả
- **Fix:** Push 2 items vào stack khi cả 2 > 0
- **Where:** `calculate_fifo.dart` → block `if (type == 0)`
- **Effort:** 15 min
- **Note:** Cần confirm với nghiệp vụ trước khi fix — có thể là intentional business rule

### 4. Wrap deleteRun trong transaction
- **Issue:** P2 — 6 deletes không atomic, crash → orphan data
- **Fix:** `_db.transaction(() async { ... })`
- **Where:** `export_service.dart` → `deleteRun()`
- **Effort:** 2 min

---

## Priority 2 — Next Sprint (reliability & UX)

### 5. Thêm weekend skip vào holiday adjustment
- **Issue:** B1 — Ngày đáo hạn rơi vào Thứ 7/CN không được dời
- **Fix:** Thêm `current.weekday == DateTime.saturday || current.weekday == DateTime.sunday` vào while loop
- **Where:** `parse_utils.dart` → `changeDateByHolidays()`
- **Effort:** 5 min

### 6. Thêm DB indexes trên runId
- **Issue:** P3 — Full table scan trên mọi query
- **Fix:** Thêm `@TableIndex` annotation hoặc `customStatement('CREATE INDEX...')` trong migration
- **Where:** `tables.dart` hoặc `app_database.dart` migration
- **Effort:** 10 min (+ bump schema version)

### 7. Pre-validation report trước calculate
- **Issue:** G1 — User chỉ biết file sai sau khi chạy xong
- **Fix:** Sau import, show validation summary (missing columns, invalid rows, duplicate docs) với option "Tiếp tục" hoặc "Hủy"
- **Where:** `dashboard_screen.dart` → `_processFile()`, thêm state `AppState.validated`
- **Effort:** 2-3 hours

### 8. Progress steps trong processing
- **Issue:** U2 — Chỉ spinner, không biết đang ở bước nào
- **Fix:** Dùng `onSubStep` callback (đã có) để update UI: "Bước 1/4: Validate...", "Bước 2/4: Sort..."
- **Where:** `dashboard_screen.dart` + `dashboard_state_views.dart`
- **Effort:** 20 min

### 9. User-friendly error messages
- **Issue:** U4 — Raw exception hiển thị cho kế toán
- **Fix:** Map known exceptions → Vietnamese messages. Unknown → "Lỗi không xác định, vui lòng liên hệ IT" + expandable detail
- **Where:** `dashboard_screen.dart` → catch blocks
- **Effort:** 30 min

### 10. Cross-check tổng sổ
- **Issue:** B3 — Không verify tổng decrease = tổng pushed
- **Fix:** Sau FIFO, compare `sum(bonusDecrease + nonBonusDecrease)` vs `totalPushed`. Log warning nếu mismatch
- **Where:** `calculate_service.dart` → sau `_runFifoInIsolate()`
- **Effort:** 15 min

### 11. Log skipped rows trong import parser
- **Issue:** P5 — Silent `catch (_) {}` swallow errors
- **Fix:** Count skipped rows, return count trong parsed result, show warning
- **Where:** `import_parser.dart` → `_parseLevels()`, `_parseMainData()`
- **Effort:** 15 min

### 12. Validate trùng chứng từ
- **Issue:** B5 — Duplicate documentNumber → bonus gấp đôi
- **Fix:** After import, detect duplicates within same (customerCode, branch, seasonalCode). Add warning, không block
- **Where:** `calculate_result_builder.dart` hoặc validation step mới
- **Effort:** 30 min

---

## Priority 3 — Backlog (polish & nice-to-have)

### 13. Console → collapsible bottom panel
- **Issue:** U3 — Chiếm 40% width
- **Fix:** Chuyển console xuống bottom, collapsible (3 lines visible mặc định)
- **Effort:** 1-2 hours

### 14. Optimize previewLoader với aggregate queries
- **Issue:** P4 — Load all records chỉ để count + top 20
- **Fix:** `SELECT COUNT(*)`, `SELECT ... ORDER BY bonus DESC LIMIT 20`
- **Effort:** 30 min

### 15. Summary theo khách hàng trong export
- **Issue:** G2 — Kế toán cần tổng bonus/KH
- **Fix:** Thêm sheet "Summary" trong export: group by customerCode, sum bonus_1/2/3
- **Effort:** 1 hour

### 16. JSON serialize stack state
- **Issue:** P6 — `toString()` không parse lại được
- **Fix:** `jsonEncode(stack)` thay `stack.toString()`
- **Effort:** 10 min

### 17. Download template từ app
- **Issue:** G4 — Template file không accessible
- **Fix:** Nút "📋 Tải template" ở initial state, copy bundled template ra folder user chọn
- **Effort:** 30 min

### 18. Dark mode color fix
- **Issue:** U5 — `Colors.orange[50]` hardcoded
- **Fix:** Dùng `Theme.of(context).colorScheme.errorContainer`
- **Effort:** 5 min

### 19. `parseNumber` dùng round thay truncate
- **Issue:** B4
- **Fix:** `.toInt()` → `.round()`
- **Where:** `parse_utils.dart`
- **Effort:** 2 min

### 20. Responsive summary cards
- **Issue:** U6 — Fixed 150px width
- **Fix:** `LayoutBuilder` + adaptive width hoặc `GridView`
- **Effort:** 20 min

### 21. Loading state khi chuyển kỳ
- **Issue:** U7
- **Fix:** Set `_state = AppState.processing` trước load, revert sau
- **Effort:** 5 min

### 22. DI cho AppDatabase (testability)
- **Issue:** P7 — Singleton không mockable
- **Fix:** Riverpod Provider cho DB instance, inject vào services
- **Effort:** 1-2 hours (refactor all services)

---

## Priority 4 — Future (v1.2+)

| # | Feature | Effort | Value |
|---|---------|--------|-------|
| 23 | So sánh giữa các kỳ | 2 days | Reporting |
| 24 | Config UI cho level/holiday trong app | 3 days | Reduce file dependency |
| 25 | Optional % input → tính tiền thưởng cuối | 1 day | End-to-end workflow |
| 26 | Edit/override kết quả individual | 2 days | Flexibility |
| 27 | Retry/cleanup cho stuck runs | 1 hour | Reliability |
| 28 | Keyboard shortcuts (Ctrl+O, Ctrl+E) | 30 min | Power user |

---

## Quick Reference

| Priority | Items | Total Effort |
|----------|-------|-------------|
| P1 — Fix Now | #1-4 | ~45 min |
| P2 — Next Sprint | #5-12 | ~5 hours |
| P3 — Backlog | #13-22 | ~6 hours |
| P4 — Future | #23-28 | ~9 days |

**Recommendation:** Ship P1 fixes immediately (under 1 hour). Plan P2 for next iteration. P3/P4 as capacity allows.
