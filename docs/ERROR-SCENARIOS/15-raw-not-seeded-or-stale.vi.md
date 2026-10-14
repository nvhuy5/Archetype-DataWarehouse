# 15. Chưa seed hoặc seed cũ

Ở local, `run_local.sh` **không tự dựng dữ liệu raw**; nó chỉ kiểm tra. Hai tình huống thường gặp.

## 15a. Chưa seed (database trống)

> Tình huống giả định. Bạn vừa clone repo, hoặc vừa chạy `docker compose down -v` (xóa cả volume dữ liệu), rồi chạy thẳng `run_local.sh`.

**Tạo lỗi**
```bash
docker compose down -v
```
**Phát hiện**
```bash
./scripts/run_local.sh
```
**Thông báo**
```
[1/4] Build images                OK  (1s)
[2/4] Raw data (seeded)           FAILED  raw_intranet has 0 of 61 tables. Run ./scripts/seed_local.sh first
```
**Đọc thông báo**: `postgres-local` được bật lại (schema và role được tạo từ `warehouse/local/init`), nhưng chưa có bảng raw nào. Script dừng ở bước 2, dbt **chưa chạy**. Số `0 of 61` là số bảng có trong `raw_intranet` so với số file seed.
**Sửa**
```bash
./scripts/seed_local.sh      # khoảng 3 đến 7 giây
./scripts/run_local.sh
```
**Kiểm tra lại**: `[2/4] ... OK  61 tables`, rồi dbt chạy.

## 15b. Seed cũ so với file

> Tình huống giả định. Bạn sửa dòng mẫu trong một file seed (ví dụ để test một trường hợp biên) nhưng quên chạy `seed_local.sh`, rồi chạy dbt và thấy kết quả không đổi.

**Tạo lỗi**
```bash
echo "-- edited" >> warehouse/local/seed/raw_intranet/crm_segment.sql
```
**Phát hiện**
```bash
./scripts/run_local.sh --select "--select stg_intranet__crm_segment"
```
**Thông báo**
```
[1/4] Build images                OK  (1s)
[2/4] Raw data (seeded)           OK  61 tables
      ! Seed files changed since the last ./scripts/seed_local.sh: dbt runs on the old rows
[3/4] dbt build                   OK  PASS=6 WARN=0 ERROR=0 SKIP=0  (23s)
```
**Đọc thông báo**
- Đây là **cảnh báo** (`!`), không dừng chuỗi: dbt vẫn chạy, nhưng trên dòng **cũ** trong database.
- Script so hash của thư mục `warehouse/local/seed` với hash ghi lúc seed lần cuối. Bất kỳ thay đổi nào (kể cả một dòng comment) đều đổi hash.
- Có một cảnh báo thứ hai khi lần seed cuối **quá 7 ngày**: `Raw data was seeded on <ngày>: dates relative to today have drifted, run ./scripts/seed_local.sh`. Lý do: các cột ngày mà model so với `current_date` (tuổi, thâm niên, hợp đồng còn hiệu lực) được viết tương đối trong file seed, nên chỉ đúng vào lúc seed.

**Sửa**
```bash
./scripts/seed_local.sh
./scripts/run_local.sh
```
Cảnh báo biến mất.

**Trả lại như cũ**
```bash
git checkout warehouse/local/seed/raw_intranet/crm_segment.sql
./scripts/seed_local.sh
```

## Phòng tránh
Quy trình nhớ: **sửa seed thì chạy `seed_local.sh`, sửa model thì chạy `run_local.sh`**. Dòng cảnh báo `!` ở bước 2 là chốt chặn cho trường hợp quên.
