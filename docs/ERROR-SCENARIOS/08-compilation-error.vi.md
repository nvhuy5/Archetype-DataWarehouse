# 08. Compilation Error (sai tên source hoặc ref)

> Tình huống giả định. Bạn gõ sai tên bảng trong `source()` hoặc sai tên model trong `ref()`.

Khác với [07](07-sql-error-in-model.vi.md): lỗi này xảy ra **trước khi** chạy bất kỳ câu SQL nào. dbt không dựng được đồ thị phụ thuộc nên **không có gì chạy**, và dòng kết quả không có `PASS=...`.

## 8a. Sai tên trong `source()`

**Tạo lỗi**
```bash
sed -i "s/source('raw_intranet', 'hr_menu_country')/source('raw_intranet', 'hr_menu_contry')/" \
  dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
```
**Phát hiện**
```bash
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"
```
**Thông báo**
```
[3/4] dbt build                   FAILED    (9s)
Compilation Error
  Model 'model.archetype.stg_intranet__hr_menu_country' (models/staging/intranet/hr/stg_intranet__hr_menu_country.sql) depends on a source named 'raw_intranet.hr_menu_contry' which was not found
```
**Sửa**: `source('raw_intranet', '<bảng>')` phải trùng tên đã khai báo trong `_<domain>__sources.yml`. Xem tên đúng:
```bash
grep -rn "name: hr_menu_country" dbt/models/staging
```
**Trả lại**: `git checkout dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql`

## 8b. Sai tên trong `ref()`

**Tạo lỗi**
```bash
sed -i "s/ref('dim_phase')/ref('dim_fase')/" dbt/models/dwh/fact/fact_timesheet.sql
```
**Phát hiện**
```bash
./scripts/run_local.sh --select "--select +fact_timesheet"
```
**Thông báo**
```
[3/4] dbt build                   FAILED    (9s)
Compilation Error
  Model 'model.archetype.fact_timesheet' (models/dwh/fact/fact_timesheet.sql) depends on a node named 'dim_fase' which was not found
```
**Sửa**: `ref('<tên>')` phải trùng **tên file model** (không có `.sql`).
```bash
ls dbt/models/dwh/dim/ | grep dim_
```
**Trả lại**: `git checkout dbt/models/dwh/fact/fact_timesheet.sql`

## Đọc thông báo (cả hai ca)
- `Compilation Error` và **không có** `PASS=`: dbt dừng ở bước đọc project. Dữ liệu và bảng hiện có **không bị đụng tới**.
- Câu báo lỗi nêu rõ **model nào** (`model.archetype.<tên>` và đường dẫn file) và **tên nào** không tìm thấy (`source named ...` hoặc `node named ...`).
- Bước `[4/4] Elementary report` vẫn chạy và tạo báo cáo, nhưng báo cáo chỉ phản ánh lần chạy trước.

## Kiểm tra lại
Chạy lại lệnh ở ca vừa sửa; phải có dòng `PASS=...` và không còn `Compilation Error`.

## Phòng tránh
- Chạy `./scripts/run_local.sh --select "--select +<model>"` sau mỗi sửa đổi.
- Tên model là tên file: đừng đổi tên file mà quên đổi mọi `ref()` đến nó.
