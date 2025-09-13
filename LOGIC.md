# LOGIC - Luồng xử lý Import, Calculate & Export

## 1. IMPORT - Nhập dữ liệu

### Luồng xử lý:
1. **Chọn file Excel** → QFileDialog
2. **Chạy song song 3 worker threads:**
   - ImportHolidayConfigWorker (sheet: "holiday_config")
   - ImportLevelConfigWorker (sheet: "level_config") 
   - ImportMainDataWorker (sheet: "Data", skip 13-14 rows)

### Chi tiết từng worker:
- **HolidayConfig**: Đọc cột "date" → parse_date() → bulk insert
- **LevelConfig**: Đọc 9 cột → parse_date/parse_number → insert từng row
- **MainData**: Đọc 17 cột → parse_date/parse_number → batch insert (100 rows/lần)

### Xử lý lỗi:
- Parse error: Skip row, log warning, rollback transaction
- Batch error: Log failed rows, continue với batch tiếp theo
- Fatal error: Stop worker, show error message

## 2. CALCULATE - Tính toán kết quả

### Luồng xử lý:
1. **Load toàn bộ dữ liệu vào RAM:**
   - holidays → set(date) để tra cứu nhanh
   - levels → sort theo (seasonal_code ASC, sales_method ASC, payment_period DESC)
   - datas → dict(id: MainData)

2. **Mapping main_data với level_config:**
   - Tìm level phù hợp nhất cho mỗi main_data
   - Điều kiện: seasonal_code = level.seasonal_code AND sales_method = level.sales_method AND payment_period >= level.payment_period

3. **Tạo result records:**
   - Tính bonus_increase, non_bonus_increase, bonus_decrease, non_bonus_decrease
   - Xác định type: -1 (invalid), 0 (decrease), 1 (increase)
   - Tính payment_due_date + điều chỉnh theo holiday_set
   - Batch insert 100 rows/lần

4. **Sắp xếp kết quả:**
   - Sort theo: customer_code, branch, seasonal_code, type, payment_due_date, amounts
   - Update sorted_idx cho tất cả records

5. **Tính toán bonus:**
   - Group theo (customer_code, branch, seasonal_code)
   - Xử lý từng group theo thứ tự sorted_idx
   - Maintain before_remain stack cho mỗi group
   - Tính bonus_1, bonus_2, bonus_3 dựa trên payment_due_date_1/2/3

## 3. EXPORT - Xuất kết quả

### Luồng xử lý:
1. **Load tất cả Result records** → sort theo sorted_idx
2. **Convert to DataFrame:**
   - result.to_dict() → merge main_data fields
   - Convert date fields to Excel serial format
3. **Export to Excel:**
   - Auto-resize columns
   - Apply date format (dd/mm/yyyy)
   - Apply number format (#,##0) cho amount fields
4. **Show success/error message**

## Ưu điểm

### ✅ ƯU ĐIỂM:

**Import:**
- Song song 3 threads → tăng tốc độ import
- Batch processing → giảm memory usage
- Error handling linh hoạt → không crash khi có lỗi data
- Dynamic header detection → tương thích nhiều format Excel

**Calculate:**
- Load toàn bộ vào RAM → tốc độ xử lý nhanh
- Business logic rõ ràng → dễ maintain
- Batch update → hiệu suất cao
- Holiday adjustment → logic nghiệp vụ chính xác

**Export:**
- Format Excel chuyên nghiệp → dễ đọc
- Auto-resize columns → UX tốt
- Date/number formatting → chuẩn định dạng

## Khuyết điểm

### ❌ KHUYẾT ĐIỂM:

**Import:**
- Không validate dữ liệu trước khi import → có thể import sai
- Xóa toàn bộ data cũ → mất dữ liệu nếu import fail
- Không có progress bar → user không biết tiến độ
- Hard-coded sheet names → không flexible

**Calculate:**
- Load toàn bộ vào RAM → crash nếu data quá lớn
- Không có checkpoint → phải chạy lại từ đầu nếu fail
- Logic phức tạp trong 1 function → khó debug
- Không có validation kết quả → có thể tính sai

**Export:**
- Không có template → format cố định
- Load toàn bộ result → memory issue với data lớn
- Không có filter/pagination → export tất cả

**Tổng thể:**
- Không có transaction rollback toàn bộ
- Thiếu logging chi tiết cho debug
- Không có unit test → khó đảm bảo chất lượng
- UI freeze khi export data lớn