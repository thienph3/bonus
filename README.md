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

Chi tiết thuật toán xem [docs/LOGIC_CALCULATE.md](docs/LOGIC_CALCULATE.md).

## Workflow

1. **Nhập dữ liệu** — File Excel gồm 3 sheet: `Data`, `level_config`, `holiday_config`
2. **Tính toán** — Validate, mapping level, sort, đối trừ FIFO, tính bonus
3. **Xuất kết quả** — Export Excel có format

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
| [docs/LOGIC_CALCULATE.md](docs/LOGIC_CALCULATE.md) | Thuật toán tính toán (FIFO, 3-tier bonus) |
| [docs/LOGIC_IMPORT.md](docs/LOGIC_IMPORT.md) | Logic import dữ liệu |
| [docs/LOGIC_EXPORT.md](docs/LOGIC_EXPORT.md) | Logic export kết quả |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | Schema database |
| [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Known issues (đã fix trong Flutter version) |
