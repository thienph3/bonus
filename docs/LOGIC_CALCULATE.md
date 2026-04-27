# LOGIC CALCULATE - Chi tiết luồng tính toán thưởng

## Tổng quan

Function `calculate_result()` trong `services/result_service.py` thực hiện 6 bước tuần tự để tính toán thưởng.
Chỉ các record có `calculate_status = "valid"` và `type != -1` mới được tham gia tính toán bonus.

---

## Bước 1: Load dữ liệu vào RAM

```python
holidays = self.holiday_config_repo.get_all()
levels = self.level_config_repo.get_all()
datas = self.main_data_repo.get_all()
```

Xóa toàn bộ result cũ trước khi tính toán lại.

---

## Bước 2: Validate & Mapping main_data với level_config

### 2.1 Validate từng record

Mỗi main_data record được validate trước khi tìm level:

| Điều kiện lỗi | Message |
|---|---|
| `document_number` rỗng hoặc null | "Document number is empty" |
| `payment_period` is None | "Payment period is null" |
| `payment_period < 0` | "Payment period must be >= 0" |
| `seasonal_code` rỗng hoặc null | "Missing seasonal_code" |
| `sales_method` rỗng hoặc null | "Missing sales_method" |

Nếu có bất kỳ lỗi nào → `calculate_status = "invalid"`, không tìm level.

### 2.2 Sort levels

```python
sorted_levels = sorted(levels, key=lambda level: (
    level.seasonal_code,   # ASC
    level.sales_method,    # ASC
    -level.payment_period, # DESC - ưu tiên period cao hơn
))
```

### 2.3 Tìm level phù hợp

```python
for level in sorted_levels:
    if (data.seasonal_code.lower() == level.seasonal_code.lower()
        and data.sales_method.lower() == level.sales_method.lower()
        and data.payment_period >= level.payment_period):
        # Lấy level đầu tiên thỏa mãn → break
```

**Lưu ý quan trọng:** So sánh **case-insensitive** (`.lower()`).

Logic: Vì levels đã sort payment_period DESC, level đầu tiên match chính là level có payment_period cao nhất mà `<= data.payment_period`.

Nếu không tìm được level → `calculate_status = "invalid"`, message ghi rõ lý do.

---

## Bước 3: Tạo result records

### 3.1 Tính các giá trị cơ bản

```python
increase = data.increase or 0
decrease = data.decrease or 0
adjust_increase = data.adjust_increase or 0
adjust_decrease = data.adjust_decrease or 0

bonus_increase = adjust_increase
non_bonus_increase = increase - adjust_increase
bonus_decrease = decrease - adjust_decrease
non_bonus_decrease = adjust_decrease
```

### 3.2 Xác định type

```python
if bonus_decrease > 0 or non_bonus_decrease > 0:
    type = 0   # decrease
elif bonus_increase > 0 or non_bonus_increase > 0:
    type = 1   # increase
else:
    type = -1  # invalid (không tham gia tính toán)
```

### 3.3 Tính payment_due_date

```python
payment_due_date = document_date + timedelta(days=payment_period)
```

### 3.4 Tính payment_due_date_1/2/3 (CHỈ cho type == 1)

Nếu `type != 1` → tất cả payment_due_date_1/2/3 = None.

Nếu `type == 1`:

```python
# Ưu tiên dùng ngày cố định từ level_config
# Nếu level.payment_due_date_X là None → tính từ document_date + level.payment_period_X
payment_due_date_1 = level.payment_due_date_1 or (document_date + timedelta(days=level.payment_period_1))
payment_due_date_2 = level.payment_due_date_2 or (document_date + timedelta(days=level.payment_period_2))
payment_due_date_3 = level.payment_due_date_3 or (document_date + timedelta(days=level.payment_period_3))

# Điều chỉnh tránh ngày lễ (recursive: nếu rơi vào holiday → +1 ngày, check lại)
payment_due_date_1 = _change_date_by_holidays(payment_due_date_1, holiday_set)
payment_due_date_2 = _change_date_by_holidays(payment_due_date_2, holiday_set)
payment_due_date_3 = _change_date_by_holidays(payment_due_date_3, holiday_set)
```

**Fallback:** Nếu `document_date` is None hoặc không có level → dùng `date(1900, 1, 1)`.

### 3.5 Batch insert

Insert theo batch 100 records/lần. Lưu cả `original_idx` (thứ tự gốc) và `sorted_idx` (sẽ cập nhật sau).

---

## Bước 4: Sắp xếp kết quả

### Filter

Chỉ lấy records thỏa: `calculate_status == "valid" AND type != -1`

### Sort key

```python
sorted_valid_results = sorted(valid_results, key=lambda result: (
    result.main_data.customer_code,  # ASC
    result.main_data.branch,         # ASC
    result.main_data.seasonal_code,  # ASC
    result.type,                     # ASC → decrease (0) trước, increase (1) sau
    result.payment_due_date,         # ASC → đáo hạn sớm trước
    -result.bonus_decrease,          # DESC → số tiền lớn trước
    -result.non_bonus_decrease,      # DESC
    -result.bonus_increase,          # DESC
    -result.non_bonus_increase,      # DESC
))
```

**Ý nghĩa:** Trong cùng 1 group, decrease phải được xử lý trước increase (vì decrease push vào stack, increase lấy ra từ stack).

Update `sorted_idx` cho từng record theo batch 100.

---

## Bước 5: Tính toán bonus (CORE LOGIC)

### 5.1 Group processing

Mỗi nhóm `(customer_code, branch, seasonal_code)` có 1 stack `before_remain` riêng.
Khi đổi group → reset stack về `[]`.

### 5.2 Skip condition

```python
if document_number == "":
    continue  # Bỏ qua record không có số chứng từ
```

### 5.3 Lưu before_remain

Trước khi xử lý, lưu trạng thái stack hiện tại: `result.before_remain = str(before_remain)`

### 5.4 Xử lý TYPE = 0 (Decrease) → Push vào stack

Mỗi record decrease chỉ push **MỘT item** vào stack:

```python
if bonus_decrease > 0:
    # Push item loại bonus
    item = {
        "type": "decrease",
        "sub_type": "bonus",
        "amount": bonus_decrease,
        "date": document_date
    }
    before_remain.append(item)
else:
    # Push item loại non_bonus
    item = {
        "type": "decrease",
        "sub_type": "non_bonus",
        "amount": non_bonus_decrease,
        "date": document_date
    }
    before_remain.append(item)
```

**Lưu ý:** Nếu `bonus_decrease > 0` thì push bonus, **ELSE** push non_bonus. Không push cả hai.

### 5.5 Xử lý TYPE = 1 (Increase) → Lấy từ stack (FIFO)

#### Nhánh A: bonus_increase > 0

```python
amount = bonus_increase
while amount > 0 and len(before_remain) > 0:
    first_remain = before_remain[0]  # FIFO - lấy từ đầu
    mi = min(amount, first_remain["amount"])
    amount -= mi
    first_remain["amount"] -= mi

    # CHỈ tính bonus nếu item trong stack có sub_type == "bonus"
    if first_remain["sub_type"] == "bonus":
        if first_remain["date"] <= payment_due_date_1:
            result.bonus_1 += mi
        elif first_remain["date"] <= payment_due_date_2:
            result.bonus_2 += mi
        elif first_remain["date"] <= payment_due_date_3:
            result.bonus_3 += mi
        # Nếu date > payment_due_date_3 → không được bonus nào

    if first_remain["amount"] <= 0:
        before_remain.pop(0)  # Xóa item đã hết
```

**Logic bonus 3-tier:**
- `document_date` của decrease <= `payment_due_date_1` → bonus_1
- `document_date` của decrease <= `payment_due_date_2` → bonus_2
- `document_date` của decrease <= `payment_due_date_3` → bonus_3
- Vượt quá cả 3 mốc → không thưởng

#### Nhánh B: non_bonus_increase (else)

```python
amount = non_bonus_increase
while amount > 0 and len(before_remain) > 0:
    first_remain = before_remain[0]
    mi = min(amount, first_remain["amount"])
    amount -= mi
    first_remain["amount"] -= mi

    # KHÔNG tính bonus - chỉ trừ amount từ stack
    if first_remain["amount"] <= 0:
        before_remain.pop(0)
```

**Khác biệt quan trọng:** non_bonus increase vẫn consume stack nhưng KHÔNG sinh bonus.

### 5.6 Lưu after_remain

Sau khi xử lý: `result.after_remain = str(before_remain)`

### 5.7 Batch update

Update `bonus_1, bonus_2, bonus_3, before_remain, after_remain` theo batch 100 records.

---

## Bước 6: Hoàn tất

Emit `sub_step_func(4)` báo hiệu hoàn thành.

---

## Ví dụ minh họa

### Giả sử group (KH001, CN01, VU01):

| # | Type | bonus_decrease | non_bonus_decrease | bonus_increase | non_bonus_increase | document_date |
|---|------|------|------|------|------|------|
| 1 | 0 (decrease) | 500 | 0 | 0 | 0 | 2024-01-10 |
| 2 | 0 (decrease) | 0 | 300 | 0 | 0 | 2024-01-15 |
| 3 | 1 (increase) | 0 | 0 | 400 | 0 | 2024-02-01 |

**Giả sử payment_due_date_1 = 2024-02-28**

**Xử lý:**
1. Record #1: Push `{sub_type: "bonus", amount: 500, date: 2024-01-10}`
2. Record #2: Push `{sub_type: "non_bonus", amount: 300, date: 2024-01-15}`
3. Record #3 (increase 400, bonus):
   - Lấy item đầu stack: `{bonus, 500, 2024-01-10}`
   - `mi = min(400, 500) = 400`
   - sub_type == "bonus" AND date(2024-01-10) <= payment_due_date_1(2024-02-28) → `bonus_1 += 400`
   - Stack còn: `[{bonus, 100, 2024-01-10}, {non_bonus, 300, 2024-01-15}]`

**Kết quả Record #3:** bonus_1 = 400, bonus_2 = 0, bonus_3 = 0

---

## Holiday Adjustment

```python
def _change_date_by_holidays(self, date, holiday_set):
    if not date:
        return None
    if date not in holiday_set:
        return date
    return self._change_date_by_holidays(date + timedelta(days=1), holiday_set)
```

Recursive: nếu ngày rơi vào holiday → cộng 1 ngày, check lại cho đến khi không còn trùng.

---

## Độ phức tạp

| Bước | Complexity | Ghi chú |
|------|-----------|---------|
| 1 - Load | O(n) | n = tổng records |
| 2 - Validate & Map | O(n × m) | m = số levels |
| 3 - Create results | O(n) | Batch insert |
| 4 - Sort | O(n log n) | Python timsort |
| 5 - Calculate bonus | O(n × k) | k = max stack size trong 1 group |
| 6 - Update | O(n) | Batch update |

Worst case tổng thể: O(n²) nếu 1 group có nhiều decrease rồi 1 increase lớn consume hết.
