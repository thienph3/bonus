# KNOWN ISSUES

## Bugs (cần fix)

### 1. Biến `idx` stale ở bước 5 calculate

**File:** `services/result_service.py`

Trong vòng lặp tính bonus (bước 5), `batch.append((idx, result2))` dùng biến `idx` còn giữ giá trị cuối cùng từ bước 3 (tạo result). Khi log error sẽ hiển thị sai row number.

**Fix:** Thay bằng biến đếm riêng cho vòng lặp bước 5.

---

### 2. Exception bị nuốt

**File:** `services/result_service.py`

```python
except Exception as e:
    log_func(f"An error occurred: {e}")
```

Chỉ log mà không raise. Worker sẽ emit `finished` (thành công) thay vì `error` → UI báo hoàn tất dù thực tế fail.

**Fix:** Thêm `raise` sau log, hoặc emit error signal.

---

### 3. Null document_date crash ở bước 5

**File:** `services/result_service.py`

Nếu record decrease có `document_date = None`, push vào stack với `"date": None`. Khi increase consume stack, so sánh `None <= payment_due_date_1` → `TypeError`.

**Fix:** Skip record có document_date = None, hoặc validate trước khi push.

---

## Rủi ro nghiệp vụ (nên cải thiện)

### 4. Decrease chỉ push 1 loại (bonus HOẶC non_bonus)

Nếu record có cả `bonus_decrease > 0` VÀ `non_bonus_decrease > 0`, chỉ phần bonus được push vào stack. Phần non_bonus bị bỏ qua.

Theo công thức: `bonus_decrease = decrease - adjust_decrease`, `non_bonus_decrease = adjust_decrease`. Nếu cả 2 > 0 thì tổng tiền vào stack < tổng decrease thực tế.

---

### 5. non_bonus increase consume stack không phân biệt

Khi increase loại non_bonus consume stack, nó trừ bất kỳ item nào (cả bonus lẫn non_bonus). Có thể "ăn" hết khoản thanh toán bonus → increase bonus sau không còn gì để đối trừ → mất thưởng.

---

### 6. Không có chi tiết đối trừ (reconciliation)

Không export được thông tin "khoản mua hàng X đối trừ với khoản thanh toán Y bao nhiêu tiền". Chỉ có tổng bonus_1/2/3. Khó giải trình cho kiểm toán.

---

## Kỹ thuật (nice to have)

### 7. Monolithic function

`calculate_result()` có 350+ lines, không thể unit test từng bước riêng biệt.

### 8. Load lại từ DB không cần thiết

Bước 4 gọi `self.repository.get_all()` sau khi bước 3 vừa insert xong. Data đã có sẵn trong memory.

### 9. Recursive holiday adjustment không có giới hạn

`_change_date_by_holidays()` đệ quy không giới hạn. Nếu holiday_set chứa nhiều ngày liên tiếp (>1000) → stack overflow.

### 10. Không share transaction giữa các repository

Mỗi repository tạo riêng engine/session. Không thể rollback toàn bộ nếu fail giữa chừng → DB ở trạng thái nửa vời.
