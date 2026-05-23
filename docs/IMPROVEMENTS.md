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

| # | Fix | Where | Status |
|---|-----|-------|--------|
| 5 | Thêm `weekday == 6 \|\| 7` check vào holiday loop | `parse_utils.dart` | ⏸️ Needs recheck |
| 6 | `CREATE INDEX idx_*_run_id ON *(run_id)` + bump schema | `app_database.dart` migration | ✅ Done |
| 7 | Pre-validation state: show invalid/duplicate/missing trước calculate | `pre_validation_service.dart` | ✅ Done |
| 8 | Wire `onSubStep` callback → UI progress "Bước X/4" | `dashboard_screen.dart` | ✅ Done |
| 9 | Map exceptions → Vietnamese messages + expandable detail | `dashboard_screen.dart` catch | ✅ Done |
| 10 | Compare `sum(bonusDec+nonBonusDec)` vs `totalPushed`, log warning | `calculate_service.dart` | ✅ Done |
| 11 | Count + return skipped rows, show warning | `import_parser.dart` | ✅ Done |
| 12 | Detect duplicate `documentNumber` per group, add warning | `calculate_result_builder.dart` | ✅ Done |

---

## P3 — Backlog (~6 hours)

| # | Fix | Where | Status |
|---|-----|-------|--------|
| 13 | Console → collapsible bottom panel | `console_panel.dart` | ✅ Done |
| 14 | Aggregate queries (COUNT, LIMIT 20) thay load all | `preview_loader.dart` | ✅ Done |
| 15 | Thêm sheet "Summary" group by customerCode | `export_builder.dart` | ✅ Done |
| 16 | `jsonEncode(stack)` thay `stack.toString()` | `calculate_fifo.dart` | ✅ Done |
| 17 | Nút "Tải template" ở initial state | `dashboard_state_views.dart` | ✅ Done |
| 18 | `Theme.of(context).colorScheme.errorContainer` thay hardcoded | `preview_panel.dart` | ✅ Done |
| 19 | `.toInt()` → `.round()` | `parse_utils.dart` | ✅ Done |
| 20 | `LayoutBuilder` + adaptive card width | `preview_panel.dart` | ✅ Done |
| 21 | Show loading khi `_selectRun` | `dashboard_screen.dart` | ✅ Done |
| 22 | Riverpod Provider cho DB, inject vào services | `app_database.dart` | ✅ Done |

---

## P4 — Future (v1.2+)

| # | Feature | Effort | Status |
|---|---------|--------|--------|
| 23 | So sánh giữa các kỳ | 2 days | ✅ Done |
| 24 | Config UI cho level/holiday trong app | 3 days | ✅ Done |
| 25 | Optional % input → tính tiền thưởng cuối | 1 day | ✅ Done |
| 26 | Edit/override kết quả individual | 2 days | ✅ Done |
| 27 | Retry/cleanup cho stuck runs | 1 hour | ✅ Done |
| 28 | Keyboard shortcuts (Ctrl+O, Ctrl+E) | 30 min | ✅ Done |
| 29 | **Chunked FIFO per group (100k+ rows)** | 2-3 hours | ✅ Done |

---

## #29 — Chunked FIFO Design (for 100k+ rows)

### Problem

Current approach: 1 transaction wraps entire FIFO for all groups. With 100k+ rows:
- Peak RAM 200-500MB (all results in memory)
- DB locked 60-120s continuously
- 1 crash = redo everything

### Solution: 3-phase chunked processing

```
Phase 1: Prepare (1 transaction)
  - Delete old results, build + insert result rows, sort, extract distinct groups
  - Save group list to fifo_progress table
  - Status: 'calculating'

Phase 2: FIFO per group (N small transactions)
  - For each group (customer, branch, seasonal):
    - Compute FIFO (in-memory, <200 records per group)
    - Write bonus + matchings in 1 transaction
    - Mark group 'done' in fifo_progress
    - Report progress: "150/500 nhóm (30%)"
  - Batch 50 groups per Isolate call to amortize overhead

Phase 3: Finalize (1 transaction)
  - Reconciliation check (aggregate across groups)
  - Update run status → 'completed'
  - Clean up fifo_progress entries
```

### Schema addition

```sql
CREATE TABLE fifo_progress (
  run_id TEXT,
  group_key TEXT,  -- "customerCode|branch|seasonalCode"
  status TEXT DEFAULT 'pending',  -- pending → done
  PRIMARY KEY (run_id, group_key)
);
```

### Crash recovery

| Crash at | Recovery |
|----------|----------|
| Phase 1 | Transaction rollback → re-run from scratch |
| Phase 2 (group 300/500) | Resume from group 301 (skip 'done' groups) |
| Phase 3 | All groups done → just finalize |

### Performance (100k rows, 500 groups)

| Metric | Current | Chunked |
|--------|---------|---------|
| Peak RAM | 200-500MB | 20-50MB |
| Crash cost | Redo 120s | Redo <1s (1 group) |
| DB lock | 120s continuous | 200ms per group |
| UI progress | Spinner only | Live per-group progress |

### Resume logic

```dart
final pending = await getGroupsWithStatus(runId, 'pending');
if (pending.isEmpty) { finalize(); return; }
// Continue from first pending group
```
