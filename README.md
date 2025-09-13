# Ứng dụng Tính Toán Thưởng (Bonus Calculator)

Ứng dụng desktop được xây dựng bằng PyQt6 để tính toán thưởng dựa trên dữ liệu bán hàng và các cấu hình liên quan.

## Tính năng chính

- **Dashboard với workflow 3 bước**: Giao diện trực quan với animation và status tracking
- **Import đa luồng**: Nhập dữ liệu song song từ 3 sheet Excel (Data, level_config, holiday_config)
- **Tính toán thưởng phức tạp**: Logic nghiệp vụ với FIFO stack và 3-tier bonus system
- **Export có định dạng**: Xuất Excel với auto-resize, date format và number format
- **Background processing**: Tất cả tác vụ nặng chạy trong worker threads
- **Real-time status**: Icon xoay và text animation hiển thị tiến trình

## Cấu trúc dự án

```
bonus/
├── components/          # UI widgets và custom components
│   ├── dashboard_widget.py    # Dashboard chính với 3 steps
│   ├── step_widget.py         # Widget cho từng bước
│   ├── rotating_label.py      # Custom label với animation xoay
│   └── ...
├── models/             # SQLAlchemy database models
├── repositories/       # Data access layer
├── services/          # Business logic layer
├── workers/           # Background worker threads
│   ├── import_*_worker.py     # Import workers
│   ├── calculate_result_worker.py
│   └── export_result_worker.py
├── themes/            # Light/Dark theme CSS
├── data/              # Sample Excel files
├── assets/            # Icons và resources
└── utils/             # Utility functions
```

## Yêu cầu hệ thống

- Python 3.8+
- PyQt6
- pandas
- SQLAlchemy
- openpyxl
- xlsxwriter

## Cài đặt nhanh

```bash
# Clone repository
git clone <repository-url>
cd bonus

# Tạo virtual environment
python -m venv env
source env/bin/activate  # Linux/macOS
# env\Scripts\activate   # Windows

# Cài đặt dependencies
pip install -r requirements.txt

# Tạo database
python models/init_model.py

# Chạy ứng dụng
python app.py
```

## Workflow sử dụng

### 🔄 Dashboard 3 bước:
1. **📥 Nhập dữ liệu**: Chọn file Excel → Import song song 3 sheet
2. **⚙️ Tính toán kết quả**: Xử lý logic nghiệp vụ phức tạp
3. **📤 Xuất kết quả**: Export Excel với định dạng chuyên nghiệp

### ✨ Tính năng nổi bật:
- **Real-time status**: Icon xoay + text animation với dots (1-100)
- **Non-blocking UI**: Tất cả operations chạy background
- **Error handling**: Graceful error recovery với detailed logging
- **Progress tracking**: Console log chi tiết từng bước

## Kiến trúc kỹ thuật

### 🏗️ Architecture Pattern:
- **MVC Pattern**: Models, Services, Components tách biệt
- **Repository Pattern**: Abstraction layer cho database access
- **Worker Pattern**: Background threads cho heavy operations
- **Observer Pattern**: Signal/slot communication

### 🚀 Performance Optimizations:
- **Batch processing**: Insert/update theo batch 100 records
- **Memory management**: Load data vào RAM cho tốc độ
- **Parallel import**: 3 worker threads đồng thời
- **Lazy loading**: UI components load on demand

### 📊 Business Logic Highlights:
- **FIFO Stack Algorithm**: Xử lý decrease/increase theo thứ tự
- **Holiday Adjustment**: Tự động điều chỉnh ngày đáo hạn
- **3-Tier Bonus System**: bonus_1, bonus_2, bonus_3 theo timeline
- **Group Processing**: Tính toán theo (customer, branch, seasonal)

## Tài liệu kỹ thuật

- [QUICK_START.md](QUICK_START.md) - Hướng dẫn cài đặt nhanh
- [LOGIC.md](LOGIC.md) - Luồng xử lý Import/Calculate/Export
- [LOGIC_CALCULATE.md](LOGIC_CALCULATE.md) - Chi tiết thuật toán tính toán
- [GUIDELINE.md](GUIDELINE.md) - Điều kiện JOIN giữa các bảng

## Tác giả

Phát triển bởi team bonus calculator với focus on UX và performance.