# Quick Build Guide - Bonus Calculator

Hướng dẫn build ứng dụng thành file thực thi duy nhất (.exe) sử dụng PyInstaller.

## Yêu cầu

- Python 3.8+
- Tất cả dependencies đã được cài đặt từ `requirements.txt`

## Build Steps

### 1. Build với resources (bắt buộc)
```bash
pyinstaller --onefile --windowed --name="BonusCalculator" --add-data="themes;themes" --add-data="assets;assets" --add-data="database.db;." app.py
```

### 2. Build với icon
```bash
pyinstaller --onefile --windowed --name="BonusCalculator" --icon="assets/calculate_icon.png" --add-data="themes;themes" --add-data="assets;assets" --add-data="database.db;." app.py
```

## Build Options

- `--onefile`: Tạo file .exe duy nhất
- `--windowed`: Ẩn console window (GUI app)
- `--name`: Tên file output
- `--icon`: Icon cho file .exe
- `--add-data`: Include thêm folders/files

## Output

File thực thi sẽ được tạo trong thư mục `dist/`:
- `dist/BonusCalculator.exe` (Windows)
- `dist/BonusCalculator` (Linux/macOS)

## Troubleshooting

### Missing modules
Nếu thiếu modules, thêm vào spec file:
```python
hiddenimports=['PyQt6.QtCore', 'PyQt6.QtWidgets', 'SQLAlchemy']
```

### Large file size
Để giảm kích thước:
```bash
pyinstaller --onefile --windowed --exclude-module tkinter --exclude-module matplotlib app.py
```

### Database issues
Đảm bảo database được tạo trước khi chạy:
```bash
python models/init_model.py
```

## Dependencies chính

- **PyQt6**: GUI framework
- **pandas**: Data processing
- **SQLAlchemy**: Database ORM
- **openpyxl**: Excel file handling
- **XlsxWriter**: Excel export formatting
- **qt-material**: Material design themes