# LOGIC CALCULATE - Thuật toán tính toán thưởng

## Tổng quan

```
import_service.dart → pre_validation_service.dart → calculate_service.dart
                                                      ├── calculate_validator.dart
                                                      ├── calculate_result_builder.dart
                                                      ├── calculate_fifo.dart
                                                      └── calculate_writer.dart
```

Chạy trong `db.transaction()`. FIFO computation chạy trong `Isolate.run()`.
Chỉ xử lý data của 1 run (filter by `runId`).

---

## Bước 0: Pre-validation (sau import, trước calculate)

File: `pre_validation_service.dart` → `validate()`

Kiểm tra dữ liệu đã import, log warnings:
- Đếm dòng thiếu documentNumber, paymentPeriod, seasonalCode, salesMethod
- Detect duplicate documentNumber trong cùng group (customer|branch|seasonal)
- Không block — chỉ warning, calculate vẫn chạy

---

## Bước 1: Validate & Mapping level_config

File: `calculate_validator.dart` → `validateAndMap()`

Mỗi main_data record được validate:

| Lỗi | Message |
|-----|---------|
| document_number rỗng/null | "Document number is empty" |
| payment_period null | "Payment period is null" |
| payment_period < 0 | "Payment period must be >= 0" |
| seasonal_code rỗng | "Missing seasonal_code" |
| sales_method rỗng | "Missing sales_method" |

Nếu valid → tìm level phù hợp (case-insensitive, payment_period DESC → lấy level đầu tiên match).
Nếu valid + documentNumber trùng trong group → append warning vào message (không block).

---

## Bước 2: Tạo result records

File: `calculate_result_builder.dart` → `buildResultRows()`

```
bonusIncrease    = adjustIncrease
nonBonusIncrease = increase - adjustIncrease
bonusDecrease    = decrease - adjustDecrease
nonBonusDecrease = adjustDecrease

type = 0 (decrease) | 1 (increase) | -1 (invalid)
```

payment_due_date_1/2/3 chỉ tính cho type == 1:
- Ưu tiên ngày cố định từ level_config
- Fallback: document_date + payment_period_X
- Holiday adjustment: dời sang ngày làm việc (iterative, max 1000 lần)

---

## Bước 3: Sort

File: `calculate_service.dart` → `_getSortedValidResults()`

Filter: `calculateStatus == 'valid' AND type != -1`

Sort key: customer_code → branch → seasonalCode → type (decrease trước) → paymentDueDate → amounts DESC

---

## Bước 4: FIFO Bonus Calculation (Isolate)

File: `calculate_fifo.dart` → `computeFifo()`

Chạy trong `Isolate.run()` với serialized Maps.

### Group processing
Mỗi nhóm (customerCode, branch, seasonalCode) có stack riêng. Đổi group → reset stack.

### Decrease (type 0) → Push vào stack
```
{sub_type: 'bonus'|'non_bonus', amount, date, doc}
```
Chỉ push 1 item (bonus nếu bonusDecrease > 0, else non_bonus).

### Increase (type 1) → Consume stack (FIFO)
Lấy từ đầu stack. Nếu bonusIncrease > 0 và stack item là 'bonus':
- date ≤ paymentDueDate1 → bonus_1
- date ≤ paymentDueDate2 → bonus_2
- date ≤ paymentDueDate3 → bonus_3

non_bonus increase consume stack nhưng không sinh bonus.

### Matching Detail
Mỗi cặp đối trừ được lưu: increase_doc, decrease_doc, decrease_date, amount, tier.

### Reconciliation
Sau FIFO: verify totalPushed == totalConsumed + totalRemaining.

---

## Bước 5: Write results + Cross-check

File: `calculate_writer.dart` + `calculate_service.dart`

Batch update bonus_1/2/3 + batch insert matching_details (pre-grouped by resultId).
Cross-check: `sum(bonusDecrease + nonBonusDecrease)` of type==0 results vs `totalPushed`. Log warning if mismatch.
Update RunHistory status → 'completed'.
