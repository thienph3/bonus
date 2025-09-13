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

### 🏠 Dashboard chính:
- **3 bước tuần tự**: Nhập dữ liệu → Tính toán → Xuất kết quả
- **Real-time status**: Icon xoay + text animation khi đang xử lý
- **Progress tracking**: Hiển thị số lượng records, thời gian hoàn thành

### 📥 Bước 1 - Import Data:
- Chọn file Excel chứa 3 sheet: Data, level_config, holiday_config
- Import song song 3 worker threads
- Hiển thị thống kê: X bản ghi, Y cấp độ, Z ngày lễ

### ⚙️ Bước 2 - Calculate:
- Xử lý logic FIFO stack phức tạp
- Tính toán 3-tier bonus system
- Hiển thị tổng thưởng và số records

### 📤 Bước 3 - Export:
- Chọn đường dẫn lưu file
- Export background thread
- Format Excel chuyên nghiệp với auto-resize

## Cấu trúc file Excel input
- **Sheet "Data":** Dữ liệu bán hàng (17 cột, skip 13-14 rows đầu)
- **Sheet "level_config":** Cấu hình cấp độ thưởng
- **Sheet "holiday_config":** Danh sách ngày lễ

## Troubleshooting

### 🚫 Lỗi thường gặp:
- **Import fail:** Kiểm tra tên sheet (Data, level_config, holiday_config)
- **Calculate không hoạt động:** Đảm bảo đã import đủ 3 loại dữ liệu
- **Export bị treo:** Kiểm tra quyền ghi file và đường dẫn
- **UI freeze:** Tất cả operations đã chuyển sang background threads

### 🔍 Debug tips:
- Kiểm tra Console log ở panel bên phải
- Status animation dừng = có lỗi xảy ra
- Database file: `database.db` trong thư mục gốc
- Log files: Tự động ghi vào console widget

## Tính năng nâng cao

### 🎨 Themes:
- Light theme (mặc định)
- Dark theme
- Switch qua menu hoặc phím tắt

### 📊 Console Logging:
- Real-time progress tracking
- Chi tiết từng bước xử lý
- Error messages với stack trace
- Import/Calculate/Export banners

### 🔄 Animation Features:
- Rotating gear icon khi processing
- Text dots animation (1-100 dots)
- Status color coding (ready/processing/completed/error)
- Smooth transitions giữa các trạng thái

## Phím tắt
- Menu shortcuts theo chuẩn (Alt + underlined letter)
- Dashboard workflow: Click từng bước theo thứ tự
- Reset workflow: Nút "Bắt đầu tính toán mới"