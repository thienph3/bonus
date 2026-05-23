# HƯỚNG DẪN CHẠY ỨNG DỤNG

## Yêu cầu

- Flutter SDK (stable channel)
- Windows 10/11
- Developer Mode bật (Settings → Developer → Developer Mode ON)

## Cài đặt

```cmd
cd debt_matching
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Chạy ứng dụng

```cmd
flutter run -d windows
```

## Build exe (release)

```cmd
flutter build windows
```

Output: `build/windows/x64/runner/Release/debt_matching.exe`

---

## Hướng dẫn sử dụng

### Bước 1: Chuẩn bị file Excel

File Excel cần có **3 sheet**:

| Sheet | Nội dung |
|-------|----------|
| `Data` | Sổ chi tiết TK 131 (phát sinh tăng/giảm) |
| `level_config` | Cấu hình kỳ hạn + mức thưởng theo vụ việc |
| `holiday_config` | Danh sách ngày nghỉ lễ |

Bấm **"Tải file mẫu"** trong app để lấy template.

### Bước 2: Import & Tính toán

1. Bấm **"Chọn file Excel"** (hoặc `Ctrl+O`)
2. App tự động: Import → Validate → Tính FIFO → Hiển thị kết quả
3. Xem console (bấm thanh Console ở dưới) để theo dõi tiến trình

### Bước 3: Xem kết quả

- **Cards**: Tổng records, tổng thưởng, số lỗi
- **Top results**: 20 khoản có bonus cao nhất
- **Warnings**: Nếu có dữ liệu lỗi hoặc reconciliation mismatch

### Bước 4: Xuất kết quả

1. Bấm **"Xuất Excel"** (hoặc `Ctrl+E`)
2. Chọn nơi lưu file
3. File output gồm 3 sheet: Summary, Result, Matching Detail

### Tùy chọn

- **Nhập % chiết khấu**: Khi export, app hỏi % cho 3 tier → tính final_bonus
- **So sánh kỳ**: Chọn 2 kỳ từ dropdown → xem thay đổi theo khách hàng
- **Xóa kỳ**: Bấm icon thùng rác bên cạnh dropdown

---

## Kiểm tra với file Excel mẫu

### Test nhanh (dùng test fixtures)

Các file test có sẵn trong `test/fixtures/`:

| File | Mô tả |
|------|--------|
| `normal.xlsx` | 2 khách hàng, 6 dòng, 2 levels, 2 holidays — kết quả có bonus |
| `edge_cases.xlsx` | Dữ liệu thiếu field, trùng chứng từ, số 0 |
| `empty.xlsx` | Chỉ có header, không có data |

Chạy app rồi import từng file để verify:

```
1. normal.xlsx      → Phải có kết quả, status "completed", bonus > 0
2. edge_cases.xlsx  → Phải có warnings, nhưng không crash
3. empty.xlsx       → Phải hiện "0 records", không crash
```

### Test với dữ liệu thật

Dùng file `data/input.xlsx` (10MB, dữ liệu thực):

```
1. Import → Kiểm tra số records khớp với file gốc
2. Xem warnings (nếu có trùng chứng từ, thiếu field)
3. Export → Mở file output, kiểm tra:
   - Sheet Summary: tổng theo khách hàng
   - Sheet Result: đủ cột, số tiền format đúng
   - Sheet Matching Detail: từng cặp đối trừ
```

---

## Chạy automated tests

```cmd
cd debt_matching

:: Tất cả tests (114 tests)
flutter test

:: Chỉ E2E pipeline (import→calculate→export)
flutter test test/e2e_test.dart

:: Chỉ robustness (Isolate + file errors)
flutter test test/robustness_test.dart

:: Integration test (mở app thật trên Windows)
flutter test integration_test/ -d windows
```

### Kết quả mong đợi

```
✅ flutter test → "All 114 tests passed!"
✅ Không có test nào fail
⚠️ WARNING (drift) về multiple databases → bỏ qua (chỉ hiện ở debug)
```

---

## Troubleshooting

| Lỗi | Giải pháp |
|-----|-----------|
| "Building with plugins requires symlink support" | Bật Developer Mode |
| "Không tìm thấy file" | Kiểm tra đường dẫn file Excel |
| "File không đúng format" | Cần đủ 3 sheet: Data, level_config, holiday_config |
| "Không có quyền truy cập" | Đóng file Excel đang mở, hoặc chạy app với quyền admin |
| App treo khi import file lớn | Bình thường — FIFO chạy trong Isolate, đợi progress bar |
