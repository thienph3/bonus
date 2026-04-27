# DATABASE SCHEMA

SQLite database (`debt_matching.db`), sử dụng Drift ORM.
6 bảng, UUID string primary key. Schema version 2.
Mọi data table có `runId` để phân biệt kỳ.

---

## run_histories

Lịch sử các lần chạy.

| Column | Type | Default | Mô tả |
|--------|------|---------|--------|
| id | Text | PK | UUID, cũng là runId |
| timestamp | DateTime | | Thời điểm chạy |
| filePath | Text | '' | Đường dẫn file input |
| recordCount | Integer | 0 | Số records imported |
| levelCount | Integer | 0 | Số levels imported |
| holidayCount | Integer | 0 | Số holidays imported |
| totalBonus | Integer | 0 | Tổng bonus sau calculate |
| status | Text | 'pending' | importing → imported → completed |

---

## holiday_configs

| Column | Type | Mô tả |
|--------|------|--------|
| id | Text (PK) | |
| runId | Text (nullable) | FK → run_histories.id |
| date | DateTime | Ngày nghỉ lễ |
| name | Text (nullable) | |
| description | Text (nullable) | |

---

## level_configs

| Column | Type | Mô tả |
|--------|------|--------|
| id | Text (PK) | |
| runId | Text (nullable) | |
| seasonalCode | Text | Mã vụ việc |
| salesMethod | Text | Phương thức bán hàng |
| paymentPeriod | Integer | Kỳ hạn (ngày) — dùng để match |
| paymentPeriod1/2/3 | Integer | Số ngày tính bonus tier 1/2/3 |
| paymentDueDate1/2/3 | DateTime (nullable) | Ngày cố định tier 1/2/3 (ưu tiên) |

---

## main_datas

Sổ chi tiết TK 131.

| Column | Type | Mô tả |
|--------|------|--------|
| id | Text (PK) | |
| runId | Text (nullable) | |
| idx | Integer (nullable) | STT trong Excel |
| documentDate | DateTime (nullable) | Ngày chứng từ |
| documentNumber | Text (nullable) | Số chứng từ |
| description | Text (nullable) | |
| correspondingAccount | Text (nullable) | TK đối ứng |
| increase | Integer (nullable) | Phát sinh tăng (Nợ TK 131) |
| decrease | Integer (nullable) | Phát sinh giảm (Có TK 131) |
| adjustIncrease | Integer (nullable) | Điều chỉnh tăng |
| adjustDecrease | Integer (nullable) | Điều chỉnh giảm |
| endAmount | Integer (nullable) | Số dư cuối kỳ |
| seasonalCode | Text | Mã vụ việc |
| paymentPeriod | Integer (nullable) | Kỳ hạn thanh toán |
| customerCode | Text | Mã khách hàng |
| customerName | Text (nullable) | |
| branch | Text | Chi nhánh |
| code | Text (nullable) | |
| salesMethod | Text | Phương thức bán hàng |

---

## results

| Column | Type | Default | Mô tả |
|--------|------|---------|--------|
| id | Text (PK) | | |
| runId | Text (nullable) | | |
| mainDataId | Text | FK → main_datas.id | |
| levelConfigId | Text (nullable) | FK → level_configs.id | |
| sortedIdx | Integer | 0 | Thứ tự FIFO |
| originalIdx | Integer | 0 | Thứ tự gốc |
| type | Integer | 0 | -1=invalid, 0=decrease, 1=increase |
| paymentDueDate | DateTime (nullable) | | |
| bonusIncrease | Integer | 0 | |
| nonBonusIncrease | Integer | 0 | |
| bonusDecrease | Integer | 0 | |
| nonBonusDecrease | Integer | 0 | |
| paymentDueDate1/2/3 | DateTime (nullable) | | Mốc đáo hạn tier |
| bonus1/2/3 | Integer | 0 | Số tiền đủ điều kiện thưởng |
| beforeRemain | Text | '' | Stack trước xử lý |
| afterRemain | Text | '' | Stack sau xử lý |
| calculateStatus | Text | 'valid' | valid / invalid |
| calculateMessage | Text | '' | Lý do invalid |

---

## matching_details

Chi tiết từng cặp đối trừ (cho kiểm toán).

| Column | Type | Default | Mô tả |
|--------|------|---------|--------|
| id | Text (PK) | | |
| runId | Text (nullable) | | |
| resultId | Text | FK → results.id | |
| increaseDocNumber | Text | '' | Số CT mua hàng |
| decreaseDocNumber | Text | '' | Số CT thanh toán |
| decreaseDate | DateTime (nullable) | | Ngày thanh toán |
| amountMatched | Integer | 0 | Số tiền đối trừ |
| bonusTier | Text | '' | none / bonus_1 / bonus_2 / bonus_3 |

---

## Relationships

```
run_histories (1) ←── (N) holiday_configs, level_configs, main_datas, results, matching_details
main_datas (1) ←── (N) results
level_configs (1) ←── (N) results
results (1) ←── (N) matching_details
```
