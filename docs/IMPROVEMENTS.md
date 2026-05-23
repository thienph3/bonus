# IMPROVEMENTS

Danh sách cải thiện theo priority. Context → [REVIEW.md](REVIEW.md)

---

## Tổng quan

| Phase | Mô tả | Status |
|-------|--------|--------|
| P1 | Critical fixes | ✅ Done (trừ #3 chờ confirm) |
| P2 | Performance + validation | ✅ Done (trừ #5 chờ recheck) |
| P3 | UX improvements | ✅ Done |
| P4 | Features + bug fixes | ✅ Done |
| P5 | UX polish | 📋 Planned |
| P6 | Responsive layout | 📋 Planned |
| P7 | Visual style | 📋 Planned |
| P8 | Package upgrades | ✅ Done |

---

## ✅ Completed (P1–P4, P8)

<details>
<summary>P1 — Critical Fixes</summary>

| # | Fix | Status |
|---|-----|--------|
| 1 | NumberFormat cho số tiền | ✅ |
| 2 | Pre-group matchingDetails (fix O(n²)) | ✅ |
| 3 | Push 2 items khi cả bonusDec & nonBonusDec > 0 | ⏸️ Needs business confirmation |
| 4 | deleteRun trong transaction | ✅ |

</details>

<details>
<summary>P2 — Performance + Validation</summary>

| # | Fix | Status |
|---|-----|--------|
| 5 | Weekend check trong holiday loop | ⏸️ Needs recheck |
| 6 | DB indexes on run_id | ✅ |
| 7 | Pre-validation service | ✅ |
| 8 | Progress UI (onSubStep) | ✅ |
| 9 | Vietnamese error messages | ✅ |
| 10 | Cross-check tổng sổ | ✅ |
| 11 | Count skipped rows | ✅ |
| 12 | Duplicate document detection | ✅ |

</details>

<details>
<summary>P3 — UX Improvements</summary>

| # | Fix | Status |
|---|-----|--------|
| 13 | Collapsible console | ✅ |
| 14 | Aggregate queries (LIMIT 20) | ✅ |
| 15 | Summary sheet in export | ✅ |
| 16 | jsonEncode for stack state | ✅ |
| 17 | Template download button | ✅ |
| 18 | Theme.colorScheme | ✅ |
| 19 | parseNumber .round() | ✅ |
| 20 | LayoutBuilder responsive cards | ✅ |
| 21 | Loading on switch run | ✅ |
| 22 | Riverpod Provider for DB | ✅ |

</details>

<details>
<summary>P4 — Features + Bug Fixes</summary>

| # | Feature | Status |
|---|---------|--------|
| 23 | So sánh giữa các kỳ | ✅ |
| 24 | Config UI (level/holiday) | ✅ |
| 25 | Optional % → final bonus | ✅ |
| 26 | Edit/override individual | ✅ |
| 27 | Retry stuck runs | ✅ |
| 28 | Keyboard shortcuts | ✅ |
| 29 | Chunked FIFO (100k+ rows) | ✅ |
| 30 | Isolate unsendable DB fix | ✅ |
| 31 | Template rootBundle fix | ✅ |
| 32 | parseDate ISO 8601 fix | ✅ |
| 33 | Column guide dialog | ✅ |
| 34 | Custom illustrations | ✅ |
| 35 | App rename (CKTT) | ✅ |

</details>

<details>
<summary>P8 — Package Upgrades ✅</summary>

| Package | Before | After |
|---------|--------|-------|
| drift | 2.32.1 | 2.33.0 |
| drift_dev | 2.32.1 | 2.33.0 |
| sqlite3_flutter_libs | 0.5.42 | ❌ Removed (EOL) |
| file_picker | 8.3.7 | 11.0.2 |
| flutter_riverpod | 2.6.1 | 3.3.1 |
| intl | 0.19.0 | 0.20.2 |
| build_runner | 2.14.1 | 2.15.0 |

</details>

---

## 📋 Planned

### P5 — UX Polish

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 36 | Import: no progress during 25s | Medium | Show row count in progress label |
| 37 | Console expand icon inverted | Low | Swap expand_more/expand_less |
| 38 | "Bắt đầu lại" misleading after export | Low | Rename to "Quay lại" |
| 39 | Run status in English | Low | Translate to Vietnamese |
| 40 | No drag-and-drop | Low | Add DropTarget widget |
| 41 | Error text overflow | Low | Wrap in ScrollView |
| 42 | No "Mở file" after export | Low | Add open-file button |
| 43 | Bonus rates: no validation | Low | Inline error on invalid input |
| 59 | **Sample Verification** | High | See design below |

### P6 — Responsive Layout

Target: 1024x768 → 3840x2160

| # | Issue | Fix |
|---|-------|-----|
| 44 | Buttons overflow < 900px | `Wrap` thay `Row` |
| 45 | Content sparse > 1920px | `ConstrainedBox(maxWidth: 900)` |
| 46 | Dialog tràn < 750px | Dynamic maxWidth via MediaQuery |
| 47 | Compare/Override dialog tràn | Tương tự #46 |
| 48 | Illustration nhỏ trên 4K | Scale theo screen size |
| 49 | Console fixed 150px | 20% screen height |
| 50 | Font nhỏ trên 4K | Respect textScaleFactor |
| 51 | Card clamp quá nhỏ trên 4K | Scale clamp values |

### P7 — Visual Style

Nguyên tắc: Modern framework, classical density.

| # | Change | Current → Target |
|---|--------|-----------------|
| 52 | Padding | 24px → 16px |
| 53 | Color seed | blue → indigo/blueGrey |
| 54 | Card style | Elevated → Outlined/flat |
| 55 | Table rows | White → Zebra striping |
| 56 | Body text | 14px → 13px (data areas) |
| 57 | Icon colors | Colorful → Monochrome |
| 58 | Row height | 48px → 36-40px |

---

## 📐 Designs

### #59 — Sample Verification ("Kiểm tra mẫu")

**Mục đích**: Kế toán spot-check kết quả bằng mẫu ngẫu nhiên với giải thích chi tiết.

**UI**: Button "Kiểm tra mẫu" → Dialog hiển thị 1 KH ngẫu nhiên (có bonus) → "Mẫu khác" để xem KH tiếp.

**Nội dung**:
- Danh sách thanh toán (stack FIFO)
- Từng cặp đối trừ với giải thích tier
- Tổng kết bonus

**Giải thích mỗi matching**:
- `bonus_1`: "Ngày TT ≤ Hạn tier1 → Đủ ĐK Bonus 1"
- `bonus_2`: "Ngày TT ≤ Hạn tier2 → Đủ ĐK Bonus 2"
- `bonus_3`: "Ngày TT ≤ Hạn tier3 → Đủ ĐK Bonus 3"
- `none`: "Ngày TT > Hạn tier3 → Không thưởng"

**Data**: Có sẵn trong `results` + `matching_details` + `main_datas`.

**Effort**: ~2-3 hours.

---

### #29 — Chunked FIFO (100k+ rows)

**Problem**: 1 transaction cho toàn bộ FIFO → RAM cao, DB lock lâu, crash = redo all.

**Solution**: 3-phase processing:
1. **Prepare** — Build results, extract groups
2. **FIFO per group** — Small transactions, crash-recoverable
3. **Finalize** — Reconciliation, update status

**Performance**:
| Metric | Before | After |
|--------|--------|-------|
| Peak RAM | 200-500MB | 20-50MB |
| DB lock | 120s continuous | 200ms/group |
| Crash cost | Redo all | Redo 1 group |
| Progress | Spinner | Live per-group |

---

## ⏸️ Pending Business Confirmation

| # | Issue | Question |
|---|-------|----------|
| 3 | Decrease push logic | Push 1 loại hay 2 loại khi cả bonus & non-bonus > 0? |
| 5 | Holiday adjustment | Có skip cuối tuần (T7/CN) không? |
