# REVIEW — Debt Matching Service

Review date: 2026-05-23 (updated after P1-P3 fixes)

---

## Summary

Desktop tool (Flutter/Windows) tính chiết khấu thanh toán đúng hạn trên TK 131 bằng đối trừ FIFO 3-tier. Feature-complete, P1-P3 improvements applied. Production-ready cho internal use.

---

## Strengths

| # | Strength |
|---|----------|
| 1 | FIFO đối trừ đúng chuẩn VAS, reconciliation + cross-check tự động |
| 2 | Matching Detail audit trail — từng cặp đối trừ |
| 3 | Heavy computation trong Isolate — UI không jank |
| 4 | Batch writes + transaction wrapping + DB indexes |
| 5 | Multi-period isolation (runId) |
| 6 | Pre-validation: duplicate detection, missing field warnings |
| 7 | Collapsible console, progress steps, responsive cards |
| 8 | Export 3 sheets: Summary (by customer) + Result + Matching Detail |
| 9 | Clean separation: data / presentation / core, all files ≤150 LOC |
| 10 | DI-ready (Riverpod Provider for DB) |

---

## Remaining Issues

| # | Issue | Status |
|---|-------|--------|
| 3 | Decrease chỉ push 1 loại (bonus OR non_bonus) | ⏸️ Needs business confirmation |
| 5 | Không skip cuối tuần trong holiday adjustment | ⏸️ Needs recheck |
| 29 | Chunked FIFO per group (for 100k+ rows) | 📋 Designed, not implemented |

Chi tiết → [IMPROVEMENTS.md](IMPROVEMENTS.md)

---

## Business Rules (accepted)

| # | Rule |
|---|------|
| 1 | FIFO gom decrease trước increase (không theo timeline thực) |
| 2 | Decrease chỉ push 1 loại (bonus HOẶC non_bonus) — cần re-confirm |
| 3 | non_bonus increase consume stack không phân biệt |
| 4 | bonus_1/2/3 = số tiền đủ điều kiện, không phải tiền thưởng thực |

---

## Fix History

| Vấn đề | Giải pháp |
|--------|-----------|
| O(n²) writer | Pre-group matchingDetails by resultId |
| Số tiền không format | NumberFormat('#,###') |
| deleteRun không atomic | Transaction wrap |
| Không có DB index | Migration v3: indexes on run_id |
| Không có pre-validation | PreValidationService: missing fields + duplicates |
| Không có progress UI | onSubStep callback + LinearProgressIndicator |
| Error hiển thị raw exception | friendlyError() → Vietnamese messages |
| Không cross-check tổng sổ | Compare sum(decrease) vs totalPushed |
| Import skip rows silently | Count + log skipped rows |
| Không detect trùng chứng từ | Duplicate detection in validateAndMap |
| Console chiếm 40% width | Collapsible bottom panel |
| Load all records cho preview | SQL aggregate + LIMIT 20 |
| Không có Summary sheet | Export grouped by customerCode |
| Stack state dùng toString() | jsonEncode |
| Không có template download | "Tải file mẫu" button |
| Dark mode hardcoded colors | Theme.colorScheme |
| parseNumber truncate | .round() |
| Cards fixed width | LayoutBuilder responsive |
| Không loading khi switch run | setState processing |
| DB không testable | Riverpod Provider + forTesting constructor |
