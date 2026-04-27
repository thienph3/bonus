# LOGIC EXPORT - Chi tiết luồng xuất kết quả

## Tổng quan

Export chạy trong `ExportResultWorker` (background thread), xuất toàn bộ result ra file Excel với formatting chuyên nghiệp.

---

## Luồng xử lý

### Bước 1: Load & Sort

```python
results = result_service.get_all()
results = sorted(results, key=lambda result: result.original_idx)  # Giữ thứ tự gốc
results = [result.to_dict() for result in results]
```

**Lưu ý:** Export sort theo `original_idx` (thứ tự nhập liệu ban đầu), KHÔNG phải `sorted_idx` (thứ tự dùng khi calculate bonus).

### Bước 2: Chuyển đổi Date → Excel Serial Number

```python
def to_excel_serial(d):
    if pd.isna(d):
        return None
    excel_start_date = datetime.date(1899, 12, 30)
    return (d - excel_start_date).days
```

Các cột date được convert: `document_date`, `payment_due_date`, `payment_due_date_1/2/3`

**Lý do:** Lưu dưới dạng số để Excel có thể áp dụng date format (dd/mm/yyyy) chính xác.

### Bước 3: Ghi file Excel

Engine: `xlsxwriter` (qua pandas ExcelWriter)

---

## Column Formatting

### Date columns (format: dd/mm/yyyy)

- document_date
- payment_due_date
- payment_due_date_1
- payment_due_date_2
- payment_due_date_3

### Number columns (format: #,##0 - VND accounting)

- increase
- decrease
- adjust_increase
- adjust_decrease
- bonus_increase
- non_bonus_increase
- bonus_decrease
- non_bonus_decrease
- bonus_1
- bonus_2
- bonus_3

### Auto-resize

Tất cả columns được auto-resize dựa trên:
```python
max_len = max(df[col].astype(str).map(len).max(), len(str(col))) + 2
```

---

## Output columns (từ Result.to_dict())

Export bao gồm TẤT CẢ fields từ cả MainData và Result:

**Từ MainData:**
- id, idx, document_date, document_number, description, corresponding_account
- increase, decrease, adjust_increase, adjust_decrease, end_amount
- seasonal_code, payment_period, customer_code, customer_name, branch, code, sales_method

**Từ Result:**
- id, main_data_id, level_config_id, sorted_idx, original_idx
- type, payment_due_date
- bonus_decrease, non_bonus_decrease, bonus_increase, non_bonus_increase
- payment_due_date_1, payment_due_date_2, payment_due_date_3
- bonus_1, bonus_2, bonus_3
- before_remain, after_remain
- calculate_status, calculate_message

---

## Error Handling

| Lỗi | Xử lý |
|------|--------|
| Không có quyền ghi file | Exception → emit error signal → UI hiển thị |
| File đang mở bởi app khác | Exception → emit error signal |
| Bất kỳ exception nào | Catch → emit error signal với message |
