# QUICK START - Hướng dẫn cài đặt nhanh

## Yêu cầu hệ thống
- Python 3.8+
- Git

## Bước 1: Clone project
```bash
git clone https://github.com/thienph3/bonus.git
cd bonus
```

## Bước 2: Tạo virtual environment
```bash
python -m venv env
```

## Bước 3: Kích hoạt virtual environment
```bash
# Linux/macOS
. env/bin/activate

# Windows
env\Scripts\activate
```

## Bước 4: Cài đặt dependencies
```bash
pip install -r requirements.txt
```

## Bước 5: Tạo database
```bash
python models/init_model.py
```

**Kết quả:** Tạo file `database.db` với 4 tables:
- `holiday_config` - Cấu hình ngày lễ
- `level_config` - Cấu hình cấp độ thưởng
- `main_data` - Dữ liệu bán hàng chính
- `result` - Kết quả tính toán thưởng

## Bước 6: Chạy ứng dụng
```bash
python app.py
```

## Workflow sử dụng
1. **Import Data:** Chọn file Excel chứa dữ liệu
2. **Calculate:** Tính toán thưởng dựa trên cấu hình
3. **Export:** Xuất kết quả ra file Excel

## Cấu trúc file Excel input
- **Sheet "Data":** Dữ liệu bán hàng (17 cột, skip 13-14 rows đầu)
- **Sheet "level_config":** Cấu hình cấp độ thưởng
- **Sheet "holiday_config":** Danh sách ngày lễ

## Troubleshooting
- **Lỗi import:** Kiểm tra format Excel và tên sheet
- **Lỗi calculate:** Đảm bảo đã import đủ dữ liệu
- **UI không hiển thị:** Kiểm tra PyQt6 đã cài đặt đúng

## Phím tắt
- `Ctrl+0` - Màn hình chính
- `Ctrl+I` - Import dữ liệu
- `Ctrl+C` - Tính toán
- `Ctrl+E` - Export kết quả
- `Ctrl+T` - Đổi theme