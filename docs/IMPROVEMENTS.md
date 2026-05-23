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
| 30 | Isolate.run() capture unsendable DB object | 10 min | ✅ Done |
| 31 | Template download "not found" (rootBundle) | 15 min | ✅ Done |
| 32 | parseDate miss ISO 8601 T format | 5 min | ✅ Done |
| 33 | Column guide dialog + date format reference | 30 min | ✅ Done |
| 34 | Custom illustrations + image compression | 30 min | ✅ Done |
| 35 | App rename: CKTT - Đối trừ công nợ | 10 min | ✅ Done |

---

## P5 — UX Polish (v1.2)

| # | Issue | Severity | Suggestion |
|---|-------|----------|------------|
| 36 | Import phase shows only spinner (25s no feedback) | Medium | Show "Importing X/31965 dòng..." in progress label |
| 37 | Console expand icon inverted | Low | Use `expand_more` when collapsed, `expand_less` when expanded |
| 38 | Export success button "Bắt đầu lại" misleading | Low | Rename to "Quay lại" (goes back to preview) |
| 39 | Run selector status in English | Low | `(importing)` → `(lỗi)`, `(imported)` → `(chờ tính)`, `(completed)` → `(hoàn tất)` |
| 40 | No drag-and-drop file import | Low | Desktop users expect drag .xlsx onto window |
| 41 | Error text can overflow | Low | Wrap error message in SingleChildScrollView |
| 42 | No "Mở file" button after export | Low | Open exported file directly from success screen |
| 43 | Bonus rates dialog no validation feedback | Low | Show inline error when input is not a number |

---

## P6 — Responsive Layout (multi-resolution support)

Target: app phải hoạt động tốt từ 1024x768 đến 3840x2160 (4K).

| # | Issue | Resolution affected | Fix |
|---|-------|-------------------|-----|
| 44 | Preview action buttons overflow | < 900px width | Wrap buttons in `Wrap` widget thay vì `Row` |
| 45 | Main content quá sparse trên ultrawide | > 1920px | Thêm `ConstrainedBox(maxWidth: 900)` cho main content |
| 46 | Column guide dialog tràn viền | < 750px | `maxWidth: min(700, MediaQuery.width - 48)` |
| 47 | Compare/Override dialog tràn viền | < 750px | Tương tự #46 |
| 48 | Initial state illustration quá nhỏ trên 4K | > 2560px | Scale illustration theo `MediaQuery.size` |
| 49 | Console panel fixed 150px height | Tất cả | Dùng `MediaQuery.size.height * 0.2` (20% screen) |
| 50 | DataTable font quá nhỏ trên 4K | > 2560px | Scale font theo `MediaQuery.textScaleFactor` (Flutter tự handle nếu không hardcode) |
| 51 | Card width clamp(120, 180) quá nhỏ trên 4K | > 2560px | Dùng `MediaQuery` để scale clamp values |

### Nguyên tắc responsive

1. **Không hardcode pixel values** — dùng relative sizing hoặc `MediaQuery`
2. **Wrap thay Row** cho action buttons
3. **ConstrainedBox(maxWidth)** cho content area — tránh quá rộng
4. **Dialog dùng `MediaQuery.of(context).size`** để tính maxWidth/maxHeight
5. **Test ở 3 breakpoints**: 1024x768, 1920x1080, 3840x2160

---

## P7 — Visual Style (professional desktop density)

Giữ Material 3 nhưng điều chỉnh cho phù hợp user kế toán + data-heavy UI.

| # | Change | Current | Target |
|---|--------|---------|--------|
| 52 | Giảm padding | 24px | 16px — hiển thị nhiều data hơn |
| 53 | Mute color seed | `Colors.blue` (vibrant) | `Colors.indigo` hoặc `Colors.blueGrey` — corporate |
| 54 | Card style | Elevated + rounded | Outlined/flat — ít playful hơn |
| 55 | Table row colors | Trắng đều | Alternating row colors (zebra striping) |
| 56 | Body text size | 14px (M3 default) | 13px cho data areas |
| 57 | Icon colors in cards | Colorful per-card | Monochrome (primary only) — ít visual noise |
| 58 | DataTable row height | 48px (M3 default) | 36-40px — denser |

### Nguyên tắc style

- **Modern framework, classical density** — M3 components nhưng spacing/sizing của desktop app
- **Trust > delight** — Accountants cần tin tưởng kết quả, không cần animation fancy
- **Data first** — Minimize chrome, maximize data visibility
- **Monochrome + 1 accent** — Dùng 1 màu chủ đạo, còn lại neutral

---

## P8 — Package Upgrades (all to latest)

Mục tiêu: upgrade toàn bộ dependencies lên latest. Chạy full test suite sau mỗi bước.

### Bước 1: Safe upgrades (no breaking changes)

```yaml
# dev_dependencies
build_runner: ^2.15.0      # 2.14.1 → 2.15.0
image: ^4.9.0              # 4.3.0 → 4.9.0 (tool script only)
```

### Bước 2: Drift + SQLite3 migration (medium risk)

```yaml
# Remove:
sqlite3_flutter_libs: ^0.5.28  # ← XÓA (EOL, không cần nữa)

# Upgrade:
drift: ^2.33.0             # 2.32.1 → 2.33.0
drift_dev: ^2.33.0         # 2.32.1 → 2.33.0
```

- `sqlite3` 3.x tự bundle binaries qua Dart hooks
- Xóa `sqlite3_flutter_libs` khỏi pubspec
- Kiểm tra `NativeDatabase` setup trong `app_database.dart`
- Test: DB open, import, calculate, export

### Bước 3: intl upgrade (minor breaking)

```yaml
intl: ^0.20.2              # 0.19.0 → 0.20.2
```

- Kiểm tra `DateFormat`, `NumberFormat` API changes
- Test: parse_utils_test, export_builder_test

### Bước 4: file_picker major upgrade (breaking API)

```yaml
file_picker: ^11.0.2       # 8.3.7 → 11.0.2
```

- Check API changes: `pickFiles()`, `saveFile()` signatures
- Update `dashboard_screen.dart`, `template_service.dart`
- Test: manual import/export flow

### Bước 5: flutter_riverpod major upgrade (breaking, largest effort)

```yaml
flutter_riverpod: ^3.3.1   # 2.6.1 → 3.3.1
riverpod: ^3.2.1           # 2.6.1 → 3.2.1
```

- Riverpod 3.x có breaking changes (Provider → Notifier pattern)
- Update `app_database.dart` provider setup
- Update tất cả test files dùng `ProviderScope`
- Effort: ~2-3 hours

### Verification

Sau mỗi bước:
```cmd
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter test test/isolate_import_test.dart  # real Isolate
```

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
