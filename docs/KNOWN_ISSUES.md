# KNOWN ISSUES

## Thiết kế nghiệp vụ

### 1. FIFO mù — không phản ánh thứ tự thời gian thực

Code gom toàn bộ decrease (thanh toán) trước increase (mua hàng) trong cùng group. Mọi khoản thanh toán (bất kể ngày nào) đều vào stack trước khi bất kỳ khoản mua hàng nào được đối trừ.

Hệ quả: Khoản thanh toán ngày 15/01 có thể đối trừ cho khoản mua hàng ngày 01/02 (phát sinh sau). Trong kế toán thực tế, thanh toán chỉ nên đối trừ cho nợ đã phát sinh trước đó.

---

### 2. Không phân biệt thanh toán cho khoản nợ nào

Thực tế khi khách thanh toán thường có số chứng từ tham chiếu (reference) chỉ rõ trả cho hóa đơn nào. App đối trừ FIFO mù — không biết khách trả cho khoản nào, chỉ trừ theo thứ tự trong stack.

---

### 3. bonus_1/2/3 là "số tiền đủ điều kiện", không phải tiền thưởng thực

App ghi `bonus_1 += mi` (mi = số tiền đối trừ). Tức bonus = toàn bộ số tiền thanh toán đúng hạn, không phải % chiết khấu. Thực tế chiết khấu thường là % trên giá trị (VD: 2% nếu trả trong 30 ngày).

Nếu đây là ý đồ (ghi nhận số tiền đủ điều kiện, bộ phận khác nhân % sau) thì OK. Cần ghi rõ trong doc.

---

### 4. Decrease chỉ push 1 loại (bonus HOẶC non_bonus)

Nếu `bonus_decrease > 0` → push bonus, else push non_bonus. Nếu 1 giao dịch có cả 2 phần → phần non_bonus bị mất, không vào stack.

---

### 5. non_bonus increase consume stack không phân biệt

Khi increase loại non_bonus consume stack, nó trừ bất kỳ item nào (cả bonus lẫn non_bonus). Có thể "ăn" hết khoản thanh toán bonus → increase bonus sau không còn gì để đối trừ.

---

## Thiếu sót cho production

### 6. Không có audit trail

Không ghi nhận ai chạy, lúc nào, input file gì. Mỗi lần chạy xóa sạch dữ liệu cũ.

### 7. Không export chi tiết đối trừ

Không biết "khoản mua hàng X đối trừ với khoản thanh toán Y bao nhiêu tiền". Chỉ có tổng bonus_1/2/3. Khó giải trình cho kiểm toán.

### 8. Không validate tổng (reconciliation)

Không kiểm tra tổng increase/decrease trước và sau đối trừ có khớp không. Kết quả có thể sai mà không phát hiện.

### 9. Không hỗ trợ nhiều kỳ

Mỗi lần import xóa hết, không lưu lịch sử. Không so sánh được kết quả giữa các kỳ.

---

## Kỹ thuật

### 10. Không chạy trong Isolate

Services chạy trên main thread. Data > 2000 rows có thể gây jank UI. Drift cần setup riêng cho multi-isolate (DriftIsolate).
