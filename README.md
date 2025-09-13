# Ứng dụng Tính Toán Thưởng (Bonus Calculator)

Ứng dụng desktop được xây dựng bằng PyQt6 để tính toán thưởng dựa trên dữ liệu bán hàng và các cấu hình liên quan.

## Tính năng chính

- **Quản lý dữ liệu chính**: Import và quản lý dữ liệu bán hàng từ file Excel
- **Cấu hình ngày lễ**: Thiết lập các ngày nghỉ lễ ảnh hưởng đến việc tính toán
- **Cấu hình cấp độ**: Thiết lập các mức thưởng theo từng cấp độ
- **Tính toán thưởng**: Tự động tính toán thưởng dựa trên các quy tắc được định nghĩa
- **Xuất kết quả**: Export kết quả ra file Excel với định dạng phù hợp

## Cấu trúc dự án

```
bonus/
├── components/          # Các widget giao diện
├── models/             # Định nghĩa database models
├── repositories/       # Tầng truy cập dữ liệu
├── services/          # Logic nghiệp vụ
├── workers/           # Background workers cho các tác vụ nặng
├── themes/            # Giao diện theme
├── data/              # Dữ liệu mẫu
└── assets/            # Icons và tài nguyên
```

## Yêu cầu hệ thống

- Python 3.8+
- PyQt6
- pandas
- SQLAlchemy
- openpyxl

## Cài đặt

1. Clone repository
2. Cài đặt dependencies:
```bash
pip install -r requirements.txt
```

## Chạy ứng dụng

```bash
python app.py
```

## Cách sử dụng

1. **Import dữ liệu**: Sử dụng menu Import để tải dữ liệu từ file Excel
2. **Cấu hình**: Thiết lập ngày lễ và cấp độ thưởng
3. **Tính toán**: Nhấn Calculate để tính toán kết quả
4. **Xuất kết quả**: Export kết quả ra file Excel

## Tác giả

Phát triển bởi team bonus calculator