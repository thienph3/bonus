# GUIDELINE - Điều kiện JOIN giữa các bảng

## Điều kiện JOIN giữa main-data và level-config

**Điều kiện JOIN:**
```sql
main_data.seasonal_code = level_config.seasonal_code 
AND main_data.sales_method = level_config.sales_method
AND main_data.payment_period >= level_config.payment_period
```

**Logic áp dụng:**
- Sắp xếp level_config theo thứ tự: seasonal_code ASC, sales_method ASC, payment_period DESC
- Với mỗi main_data, tìm level_config đầu tiên thỏa mãn điều kiện trên
- Nếu main_data.payment_period = NULL thì không JOIN với level_config nào

## Điều kiện JOIN giữa main-data và holiday-config

**Không có JOIN trực tiếp**

Holiday-config được sử dụng để:
- Tạo một SET chứa tất cả ngày nghỉ lễ
- Điều chỉnh payment_due_date_1, payment_due_date_2, payment_due_date_3 trong result
- Nếu ngày đáo hạn trùng với ngày lễ, tự động chuyển sang ngày tiếp theo (không phải lễ)

## Bảng Result - Kết nối tất cả

**Foreign Keys:**
- `result.main_data_id` → `main_data.id`
- `result.level_config_id` → `level_config.id` (nullable)

**Relationships:**
```python
main_data = relationship("MainData")
level_config = relationship("LevelConfig")
```

## Tóm tắt luồng xử lý

1. **Load dữ liệu:** Tất cả 3 bảng được load vào RAM
2. **Tạo holiday_set:** Chuyển holiday_config thành set để tra cứu nhanh
3. **JOIN main_data + level_config:** Theo điều kiện trên, tạo mapping data_id → level_id
4. **Tính toán result:** Sử dụng holiday_set để điều chỉnh ngày đáo hạn
5. **Lưu kết quả:** Vào bảng result với foreign key tới cả 2 bảng