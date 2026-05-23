# REVIEW — Debt Matching Service

Review date: 2026-05-23
Reviewed from: Accounting, Backend Engineering, UX/UI Design, Product Management

---

## Summary

Debt Matching là desktop tool (Flutter/Windows) tính chiết khấu thanh toán đúng hạn trên TK 131 bằng đối trừ FIFO 3-tier. App đã feature-complete theo spec, deliver value rõ ràng (từ vài giờ Excel → vài giây), có audit trail và reconciliation check.

**Overall assessment:** Production-ready cho scope hiện tại (internal tool, single-user, dataset <10k rows). Có tech debt và UX gaps cần address cho long-term maintainability và user adoption.

---

## Strengths

| # | Strength | Category |
|---|----------|----------|
| 1 | FIFO đối trừ đúng chuẩn VAS, reconciliation check tự động | Business Logic |
| 2 | Matching Detail lưu chi tiết từng cặp đối trừ — đáp ứng audit | Business Logic |
| 3 | Heavy computation trong Isolate — UI không jank | Performance |
| 4 | Batch writes (100 rows) + transaction wrapping | Reliability |
| 5 | Multi-period với runId isolation — không lẫn data | Architecture |
| 6 | Single-screen workflow, state machine rõ ràng | UX |
| 7 | Console panel real-time feedback | UX |
| 8 | Light/Dark theme, Material 3 | UI |
| 9 | Clean code separation (data/presentation/core) | Maintainability |
| 10 | Feature completeness 100% theo spec | Product |

---

## Issues Found

### Business Logic

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| B1 | Chỉ skip ngày lễ, không skip cuối tuần | Medium | `changeDateByHolidays` không check Saturday/Sunday. Ngày đáo hạn có thể rơi vào cuối tuần → sai tier |
| B2 | Decrease chỉ push 1 loại vào stack | High | Nếu chứng từ có cả `bonusDecrease > 0` VÀ `nonBonusDecrease > 0`, phần non_bonus bị mất — không tham gia đối trừ |
| B3 | Không cross-check tổng sổ | Medium | Chỉ reconcile stack (pushed=consumed+remaining). Không verify tổng decrease trên sổ = tổng pushed |
| B4 | `parseNumber` truncate thay vì round | Low | `double.toInt()` cắt phần thập phân, sai lệch nhỏ tích lũy |
| B5 | Không validate trùng chứng từ | Medium | Duplicate `documentNumber` trong file → bonus tính gấp đôi |
| B6 | Decrease trước increase trong cùng group (FIFO gom) | Accepted | Thanh toán ngày 15/3 có thể đối trừ với hóa đơn ngày 20/3. Đã ghi nhận là business rule |
| B7 | Level matching lấy paymentPeriod lớn nhất match | Low | Cần confirm đúng ý đồ nghiệp vụ |

### Performance & Reliability

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| P1 | O(n²) trong `CalculateWriter.writeFifoResults` | High | Mỗi chunk scan toàn bộ matchingDetails. 10k results → 5M comparisons |
| P2 | `deleteRun` không có transaction | Medium | Crash giữa chừng → orphan data |
| P3 | Không có DB index trên `runId` | Medium | Full table scan trên mọi query filter by runId |
| P4 | `previewLoader` load ALL records vào memory | Medium | Chỉ cần top 20 + counts, nhưng load toàn bộ |
| P5 | Import parser silent `catch (_) {}` | Medium | Rows parse lỗi bị skip không warning |
| P6 | `beforeRemain`/`afterRemain` lưu `toString()` | Low | Không parse lại được, nên dùng JSON |
| P7 | Singleton DB không testable | Low | Không inject mock cho unit test |
| P8 | Không có retry/idempotency cho calculate | Low | Run stuck ở status 'importing' nếu crash |

### UX/UI

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| U1 | Số tiền không format (raw integer) | High | "1234567890" thay vì "1,234,567,890" — unreadable cho kế toán |
| U2 | Không có progress steps trong processing | Medium | Chỉ spinner + "Đang xử lý...", không biết đang ở bước nào |
| U3 | Console chiếm 40% width | Medium | Secondary info chiếm quá nhiều space, ép main content |
| U4 | Error hiển thị raw exception | Medium | Kế toán không đọc được technical error |
| U5 | Dark mode — warning card hardcoded `Colors.orange[50]` | Low | Chói trong dark mode |
| U6 | Summary cards fixed 150px, không responsive | Low | Wrap xấu trên màn hình nhỏ |
| U7 | Không có loading state khi chuyển kỳ | Low | UI freeze vài giây không feedback |
| U8 | Run selector label quá dài, khó scan | Low | Thiếu tên file, visual differentiation |
| U9 | DataTable không alternating row colors | Low | Khó đọc nhiều rows |

### Product Gaps

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| G1 | Không có validation report trước calculate | High | User chỉ biết file sai SAU KHI chạy xong |
| G2 | Không có summary theo khách hàng | Medium | Kế toán cần tổng bonus/KH để đối chiếu, gửi thông báo |
| G3 | Không có onboarding/help | Medium | Kế toán mới không biết bắt đầu từ đâu, metric nghĩa gì |
| G4 | Template file không accessible từ app | Low | `data/template.xlsx` tồn tại nhưng user phải tự tìm |
| G5 | Không edit/override kết quả | Low | Case ngoại lệ phải sửa file gốc rồi re-import |
| G6 | Không so sánh giữa các kỳ | Low | Không biết bonus tăng/giảm so với kỳ trước |
| G7 | Không tính tiền thưởng cuối cùng (chỉ số tiền đủ điều kiện) | Low | Bộ phận chính sách phải nhân % riêng |
| G8 | Không có config UI cho level/holiday | Low | Phải sửa file Excel để thay đổi config |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Tính sai bonus do B2 (mất non_bonus decrease) | Medium | High | Fix logic push 2 items |
| Performance degradation với dataset lớn (P1) | High | Medium | Fix O(n²) → O(n) |
| User import file sai, không biết (G1) | High | Medium | Pre-validation report |
| Kế toán đọc sai số vì không format (U1) | Certain | Medium | NumberFormat |
| Data corruption khi delete crash (P2) | Low | High | Transaction wrap |
