# IMPROVEMENTS — Prioritized Action Items

Sorted by priority (impact × likelihood / effort). Issue context → [REVIEW.md](REVIEW.md)

---

## P1 — Fix Now (~45 min)

| # | Fix | Where | Status |
|---|-----|-------|--------|
| 1 | `NumberFormat('#,###')` cho số tiền | `preview_panel.dart` | ✅ Done |
| 2 | Pre-group matchingDetails by resultId (fix O(n²)) | `calculate_writer.dart` | ✅ Done |
| 3 | Push 2 items khi cả bonusDec & nonBonusDec > 0 | `calculate_fifo.dart` | ⏸️ Needs confirmation |
| 4 | Wrap `deleteRun` trong `_db.transaction()` | `export_service.dart` | ✅ Done |

> **#3 Note:** Cần confirm với nghiệp vụ — có thể là intentional rule (chỉ push 1 loại).

---

## P2 — Next Sprint (~5 hours)

| # | Fix | Where | Effort |
|---|-----|-------|--------|
| 5 | Thêm `weekday == 6 \|\| 7` check vào holiday loop | `parse_utils.dart` | 5 min |
| 6 | `CREATE INDEX idx_*_run_id ON *(run_id)` + bump schema | `app_database.dart` migration | 10 min |
| 7 | Pre-validation state: show invalid/duplicate/missing trước calculate | `dashboard_screen.dart` | 2-3 hrs |
| 8 | Wire `onSubStep` callback → UI progress "Bước X/4" | `dashboard_screen.dart` | 20 min |
| 9 | Map exceptions → Vietnamese messages + expandable detail | `dashboard_screen.dart` catch | 30 min |
| 10 | Compare `sum(bonusDec+nonBonusDec)` vs `totalPushed`, log warning | `calculate_service.dart` | 15 min |
| 11 | Count + return skipped rows, show warning | `import_parser.dart` | 15 min |
| 12 | Detect duplicate `documentNumber` per group, add warning | `calculate_result_builder.dart` | 30 min |

---

## P3 — Backlog (~6 hours)

| # | Fix | Where | Effort |
|---|-----|-------|--------|
| 13 | Console → collapsible bottom panel | `dashboard_screen.dart` | 1-2 hrs |
| 14 | Aggregate queries (COUNT, LIMIT 20) thay load all | `preview_loader.dart` | 30 min |
| 15 | Thêm sheet "Summary" group by customerCode | `export_builder.dart` | 1 hr |
| 16 | `jsonEncode(stack)` thay `stack.toString()` | `calculate_fifo.dart` | 10 min |
| 17 | Nút "Tải template" ở initial state | `dashboard_state_views.dart` | 30 min |
| 18 | `Theme.of(context).colorScheme.errorContainer` thay hardcoded | `preview_panel.dart` | 5 min |
| 19 | `.toInt()` → `.round()` | `parse_utils.dart` | 2 min |
| 20 | `LayoutBuilder` + adaptive card width | `preview_panel.dart` | 20 min |
| 21 | Show loading khi `_selectRun` | `dashboard_screen.dart` | 5 min |
| 22 | Riverpod Provider cho DB, inject vào services | All services | 1-2 hrs |

---

## P4 — Future (v1.2+)

| # | Feature | Effort |
|---|---------|--------|
| 23 | So sánh giữa các kỳ | 2 days |
| 24 | Config UI cho level/holiday trong app | 3 days |
| 25 | Optional % input → tính tiền thưởng cuối | 1 day |
| 26 | Edit/override kết quả individual | 2 days |
| 27 | Retry/cleanup cho stuck runs | 1 hour |
| 28 | Keyboard shortcuts (Ctrl+O, Ctrl+E) | 30 min |
