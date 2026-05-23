# REVIEW — Debt Matching Service

Review date: 2026-05-23

---

## Summary

Desktop tool (Flutter/Windows) tính chiết khấu thanh toán đúng hạn trên TK 131 bằng đối trừ FIFO 3-tier. Feature-complete theo spec, production-ready cho scope hiện tại (internal, single-user, <10k rows).

---

## Strengths

| # | Strength |
|---|----------|
| 1 | FIFO đối trừ đúng chuẩn VAS, reconciliation check tự động |
| 2 | Matching Detail audit trail — từng cặp đối trừ |
| 3 | Heavy computation trong Isolate — UI không jank |
| 4 | Batch writes + transaction wrapping |
| 5 | Multi-period isolation (runId) |
| 6 | Single-screen state machine, console real-time feedback |
| 7 | Clean separation: data / presentation / core |

---

## Issues Summary

28 issues found. Chi tiết fix → [IMPROVEMENTS.md](IMPROVEMENTS.md)

| Severity | Count | Key items |
|----------|-------|-----------|
| High | 4 | O(n²) writer, decrease mất non_bonus, số tiền không format, thiếu pre-validation |
| Medium | 12 | No weekend skip, no DB index, no cross-check tổng, no progress UI |
| Low | 12 | Truncate vs round, dark mode colors, responsive cards, etc. |

### Top risks

| Risk | Likelihood | Impact |
|------|-----------|--------|
| Sai bonus do mất non_bonus decrease (B2) | Medium | High |
| Performance timeout dataset lớn (P1) | High | Medium |
| User import file sai không biết (G1) | High | Medium |
| Data corruption khi delete crash (P2) | Low | High |

---

## Business Rules (accepted)

Các behavior đã confirm là intentional:

| # | Rule |
|---|------|
| 1 | FIFO gom decrease trước increase (không theo timeline thực) |
| 2 | Decrease chỉ push 1 loại (bonus HOẶC non_bonus) — cần re-confirm |
| 3 | non_bonus increase consume stack không phân biệt |
| 4 | bonus_1/2/3 = số tiền đủ điều kiện, không phải tiền thưởng thực |

---

## Fix History

Các vấn đề đã được giải quyết trong quá trình phát triển:

| Vấn đề ban đầu | Giải pháp |
|-----------------|-----------|
| FIFO/Import insert từng row | Batch 100 rows |
| readAsBytesSync block UI | Isolate.run() cho Excel parse, FIFO, Excel build |
| Holiday DateTime không normalize | Normalize trong parseDate + changeDateByHolidays |
| Không có transaction | db.transaction() wrapper |
| Không có audit trail | Bảng RunHistories + MatchingDetails |
| Không validate tổng | Reconciliation check |
| Flow 3 bước thừa | Gộp: Chọn file → Preview → Export |
| Không hỗ trợ nhiều kỳ | runId trên mọi record, run selector |
