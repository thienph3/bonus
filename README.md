# Debt Matching - Tính chiết khấu thanh toán đúng hạn

Ứng dụng desktop (Flutter/Windows) hỗ trợ kế toán tính **chiết khấu thanh toán đúng hạn** trên TK 131 (Phải thu khách hàng), dựa trên đối trừ công nợ FIFO.

## Nghiệp vụ

Dữ liệu đầu vào là sổ chi tiết TK 131:
- **Phát sinh tăng (increase)** = bán hàng (Nợ TK 131)
- **Phát sinh giảm (decrease)** = khách thanh toán (Có TK 131)

Hệ thống gom toàn bộ khoản thanh toán vào stack FIFO theo nhóm (khách hàng, chi nhánh, mã vụ việc), sau đó đối trừ với các khoản mua hàng. Khi đối trừ, so sánh **ngày thanh toán** với **ngày mua hàng + kỳ hạn** để xác định mức thưởng:

| Điều kiện | Kết quả |
|-----------|---------|
| Ngày thanh toán ≤ Ngày mua + period_1 (VD: 30 ngày) | bonus_1 |
| Ngày thanh toán ≤ Ngày mua + period_2 (VD: 45 ngày) | bonus_2 |
| Ngày thanh toán ≤ Ngày mua + period_3 (VD: 60 ngày) | bonus_3 |
| Vượt quá tất cả | Không thưởng |

> **Lưu ý:** bonus_1/2/3 = **số tiền đủ điều kiện thưởng** ở mỗi tier, không phải tiền thưởng thực tế. Bộ phận chính sách sẽ nhân % chiết khấu tương ứng để ra số tiền thưởng cuối cùng.

## Workflow

1. **Chọn file Excel** → App tự động import + calculate
2. **Preview kết quả** → Xem summary, warnings, top records có bonus, reconciliation
3. **Xuất kết quả** → Export Excel gồm 3 sheet: Summary + Result + Matching Detail

Hỗ trợ **nhiều kỳ**: mỗi lần import tạo 1 kỳ mới, data cũ được giữ lại. Chọn kỳ cũ từ dropdown để xem lại hoặc export lại.

## Tính năng

- Đối trừ FIFO với chi tiết matching (khoản nào match khoản nào)
- Pre-validation: kiểm tra dữ liệu trước khi tính (thiếu field, trùng chứng từ)
- Reconciliation check (tổng pushed = consumed + remaining) + cross-check tổng sổ
- Multi-period: lưu lịch sử các kỳ, xem/export/xóa từng kỳ
- Export: Summary theo khách hàng + Result + Matching Detail
- Heavy computation chạy trong Isolate (UI không jank)
- Collapsible console với real-time log
- Light/Dark theme
- Audit trail (RunHistories)

## Cài đặt & Chạy

```bash
cd debt_matching
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

### Build exe
```bash
flutter build windows
# Output: build/windows/x64/runner/Release/
```

Yêu cầu: Flutter SDK (stable), Windows

## Tài liệu

| File | Nội dung |
|------|----------|
| [docs/RUN_GUIDE.md](docs/RUN_GUIDE.md) | Hướng dẫn chạy app + test với file Excel |
| [docs/LOGIC_CALCULATE.md](docs/LOGIC_CALCULATE.md) | Thuật toán tính toán (FIFO, 3-tier bonus) |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | Schema database |
| [docs/REVIEW.md](docs/REVIEW.md) | Review tổng hợp + business rules + fix history |
| [docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md) | Danh sách cải thiện theo priority |
| [docs/TESTING.md](docs/TESTING.md) | Hướng dẫn chạy test (129 tests) |

## Assets

| File | Mô tả | Kích thước |
|------|--------|-----------|
| `debt_matching/windows/runner/resources/app_icon.ico` | App icon (taskbar, title bar) | Multi-res: 16/32/48/256 |
| `debt_matching/assets/initial_state.png` | Illustration màn hình chờ import | 240x200 |
| `debt_matching/assets/export_success.png` | Illustration xuất file thành công | 200x160 |
| `debt_matching/assets/error_state.png` | Illustration lỗi | 200x160 |
| `debt_matching/assets/template.xlsx` | File mẫu Excel | — |

Prompts để generate images: [prompts/](prompts/)

## Tool Scripts

```bash
cd debt_matching

# Compress illustration PNGs
dart run tool/compress_images.dart

# Generate app_icon.ico from assets/app_icon.png
dart run tool/generate_ico.dart
```
