# LOGIC CALCULATE - Chi tiết luồng tính toán

## Tổng quan
Function `calculate_result()` có 350+ lines code thực hiện 6 bước chính để tính toán thưởng.

## Bước 1: Load dữ liệu vào RAM
```python
holidays = self.holiday_config_repo.get_all()  # Tất cả ngày lễ
levels = self.level_config_repo.get_all()      # Tất cả cấu hình level
datas = self.main_data_repo.get_all()          # Tất cả dữ liệu chính
```
**Mục đích:** Load toàn bộ để xử lý nhanh, tránh query DB nhiều lần

## Bước 2: Mapping main_data với level_config
```python
# Tạo holiday_set để tra cứu O(1)
holiday_set = set([holiday.date for holiday in holidays])

# Sort levels theo priority
sorted_levels = sorted(levels, key=lambda level: (
    level.seasonal_code,    # ASC
    level.sales_method,     # ASC  
    -level.payment_period   # DESC - ưu tiên period cao hơn
))

# Mapping data với level phù hợp nhất
data_with_level_dict = {}
for data in datas:
    for level in sorted_levels:
        if (data.seasonal_code == level.seasonal_code and 
            data.sales_method == level.sales_method):
            if data.payment_period >= level.payment_period:
                data_with_level_dict[data.id] = level.id
                break  # Lấy level đầu tiên thỏa mãn
```
**Logic:** Tìm level có payment_period cao nhất mà <= data.payment_period

## Bước 3: Tạo result records
```python
for data_id in data_with_level_dict:
    # Tính toán các giá trị
    bonus_increase = adjust_increase
    non_bonus_increase = increase - adjust_increase  
    bonus_decrease = decrease - adjust_decrease
    non_bonus_decrease = adjust_decrease
    
    # Xác định type
    if bonus_decrease > 0 or non_bonus_decrease > 0:
        type = 0  # decrease
    elif bonus_increase > 0 or non_bonus_increase > 0:
        type = 1  # increase
    else:
        type = -1 # invalid
    
    # Tính payment_due_date với holiday adjustment
    payment_due_date_1 = _change_date_by_holidays(calculated_date_1, holiday_set)
    # ... tương tự cho date_2, date_3
```
**Logic nghiệp vụ:** 
- Type 0 = giảm tiền, Type 1 = tăng tiền
- Điều chỉnh ngày đáo hạn tránh ngày lễ (recursive)

## Bước 4: Sắp xếp kết quả
```python
sorted_results = sorted(results, key=lambda result: (
    result.main_data.customer_code,  # ASC
    result.main_data.branch,         # ASC  
    result.main_data.seasonal_code,  # ASC
    result.type,                     # ASC - decrease trước, increase sau
    result.payment_due_date,         # ASC - đáo hạn sớm trước
    -result.bonus_decrease,          # DESC - số tiền lớn trước
    -result.non_bonus_decrease,      # DESC
    -result.bonus_increase,          # DESC
    -result.non_bonus_increase       # DESC
))
```
**Mục đích:** Đảm bảo thứ tự xử lý đúng cho bước 5

## Bước 5: Tính toán bonus (Logic phức tạp nhất)
```python
customer_code, branch, seasonal_code, before_remain = "", "", "", []

for result in sorted_results:
    # Reset remain khi đổi group
    if (customer_code != result.main_data.customer_code or 
        branch != result.main_data.branch or 
        seasonal_code != result.main_data.seasonal_code):
        before_remain = []  # Reset stack
    
    if result.type == 0:  # decrease - thêm vào stack
        item = {
            "type": "decrease",
            "sub_type": "bonus" if bonus_decrease > 0 else "non_bonus", 
            "amount": amount,
            "date": document_date
        }
        before_remain.append(item)
        
    elif result.type == 1:  # increase - trừ từ stack
        amount = bonus_increase or non_bonus_increase
        while amount > 0 and len(before_remain) > 0:
            first_remain = before_remain[0]  # FIFO
            mi = min(amount, first_remain["amount"])
            amount -= mi
            first_remain["amount"] -= mi
            
            # Tính bonus dựa trên ngày và sub_type
            if first_remain["sub_type"] == "bonus":
                if first_remain["date"] <= payment_due_date_1:
                    result.bonus_1 += mi
                elif first_remain["date"] <= payment_due_date_2:
                    result.bonus_2 += mi  
                elif first_remain["date"] <= payment_due_date_3:
                    result.bonus_3 += mi
            
            if first_remain["amount"] <= 0:
                before_remain.pop(0)  # Remove depleted item
```

**Logic nghiệp vụ phức tạp:**
- **Group processing:** Mỗi (customer_code, branch, seasonal_code) có stack riêng
- **FIFO stack:** Decrease vào cuối, increase lấy từ đầu
- **Bonus calculation:** Chỉ tính bonus cho sub_type="bonus" dựa trên ngày đáo hạn
- **3-tier bonus:** bonus_1 (sớm nhất), bonus_2, bonus_3 (muộn nhất)

## Bước 6: Batch update kết quả
```python
# Update bonus_1, bonus_2, bonus_3, before_remain, after_remain
batch_data = [{"id": result.id, "bonus_1": result.bonus_1, ...}]
self.repository.bulk_update(batch_data)
```

## Phân tích độ phức tạp

### Độ phức tạp thuật toán:
- **Bước 1-2:** O(n) - linear scan
- **Bước 3:** O(n) - tạo records  
- **Bước 4:** O(n log n) - sorting
- **Bước 5:** O(n²) - worst case với nested while loop
- **Tổng:** O(n²) trong trường hợp xấu nhất

### Độ phức tạp logic nghiệp vụ:
- **6 bước tuần tự** phụ thuộc lẫn nhau
- **State management** phức tạp (before_remain stack)
- **Multiple conditions** cho bonus calculation
- **Holiday adjustment** với recursive function
- **Group-based processing** với reset logic

### Memory usage:
- Load toàn bộ 3 bảng vào RAM
- Tạo multiple dictionaries cho mapping
- Maintain before_remain stack cho mỗi group

## Điểm yếu chính:
1. **Monolithic function** - 350+ lines không thể test riêng biệt
2. **Complex state** - before_remain stack khó debug
3. **Memory intensive** - load toàn bộ data
4. **No rollback** - fail ở bước 5 mất hết công sức bước 1-4
5. **Hard to optimize** - không thể parallel processing