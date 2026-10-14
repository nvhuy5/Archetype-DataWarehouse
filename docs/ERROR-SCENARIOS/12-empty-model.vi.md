# 12. Model dwh/mart rỗng

> Tình huống giả định. Nguồn đổi quy ước mã trạng thái nhân viên, hoặc dòng dữ liệu mẫu không còn khớp điều kiện lọc của model. `dim_employee` (chỉ lấy nhân viên trạng thái 7 và 8) trở nên **rỗng**, kéo theo báo cáo nhân sự trống.

Trước đây ca này **không test nào bắt**: build xanh, mã thoát 0, báo cáo trống mà không ai biết. Hiện mọi model `dim_*`, `fact_*`, `mart_*` đều có test `not_empty` nên lỗi được bắt, nhưng có một **tác dụng phụ** cần biết (mục "Tác dụng phụ").

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "update raw_intranet.hr_table_main set estatus = 1"
```

## Cách phát hiện
```bash
./scripts/run_local.sh
```

## Thông báo lỗi
```
[2/4] Raw data (seeded)           OK  61 tables
[3/4] dbt build                   FAILED  PASS=420 WARN=1 ERROR=2 SKIP=11  (55s)
      ! 263 of 432 FAIL 1 not_empty_mart_hr_employee_pii_ .............................. [FAIL 1 in 0.10s]
      ! 399 of 432 FAIL 1 not_empty_dim_employee_ ...................................... [FAIL 1 in 0.06s]
      ! 419 of 432 WARN 5 relationships_fact_timesheet_employee_id__employee_id__ref_dim_employee_  [WARN 5 in 0.07s]
[4/4] Elementary report           OK  report/elementary_report.html  (35s)
---
Finished with errors in 92s. Details: report/logs/
```
Trong `report/logs/3-dbt.log`:
```
Failure in test not_empty_mart_hr_employee_pii_ (models/mart_restricted/_mart_restricted__models.yml)
  Got 1 result, configured to fail if != 0
Failure in test not_empty_dim_employee_ (models/dwh/dim/_dim__models.yml)
  Got 1 result, configured to fail if != 0
...
353 of 432 SKIP relation mart.mart_hr_employee ................................. [SKIP]
423 of 432 SKIP relation mart.mart_ts_employees ................................ [SKIP]
```

## Đọc thông báo và nguyên nhân
- `not_empty_<model>_`: test `not_empty` của **model** (khác với `source_not_empty_...` của bảng raw ở [01](01-raw-table-empty.vi.md)). Có hai model rỗng: `dim_employee` và `mart_hr_employee_pii`. Cái sau cũng rỗng vì nó đọc nhân viên trực tiếp từ raw.
- `SKIP=11`: view `mart_hr_employee` và `mart_ts_employees` cùng các test của chúng không chạy, nên **`mart_ts_*` giữ dữ liệu của lần build trước** (không bị ghi đè bằng dữ liệu rỗng).
- `WARN 5 relationships_...`: 5 dòng timesheet tham chiếu nhân viên không còn trong `dim_employee`. Đây chỉ là gợi ý phụ; thủ phạm chính là hai dòng `FAIL`.

## Tác dụng phụ: bảng đã bị thay, view Power BI biến mất
dbt **dựng bảng trước rồi mới chạy test**. Nên khi `not_empty` fail thì bảng rỗng **đã được ghi**. Sau lần chạy trên:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "
  select 'dim_employee' t, count(*) from dwh.dim_employee
  union all select 'mart_hr_employee_pii', count(*) from mart_restricted.mart_hr_employee_pii
  union all select 'mart_ts_employees (giữ lại)', count(*) from mart.mart_ts_employees
  union all select 'fact_timesheet', count(*) from dwh.fact_timesheet"
```
```
              t               | count
------------------------------+-------
 dim_employee                 |     0
 mart_hr_employee_pii         |     0
 mart_ts_employees (giữ lại)  |     5
 fact_timesheet               |     5
```
Quan trọng hơn: view **`mart.mart_hr_employee` không còn tồn tại**. Power BI (tài khoản `powerbi_ro`) gặp:
```
ERROR:  relation "mart.mart_hr_employee" does not exist
```
Lý do: view này dựng trên bảng `mart_hr_employee_pii`. Khi dbt thay bảng đó, view phụ thuộc bị xóa theo; lần này view bị bỏ qua (`SKIP`) nên không được dựng lại. Kết quả là báo cáo nhân sự của Power BI **báo lỗi thay vì hiện số cũ**, cho tới lần build thành công kế tiếp.

Đây là hành vi quan sát được ở bản hiện tại của repo; chưa có cách xử lý riêng. Nó chỉ xảy ra với cặp `mart_hr_employee_pii` và view `mart_hr_employee`. Các bảng `mart_ts_*` là bảng độc lập nên không bị.

## Cách sửa
1. Tìm xem điều kiện lọc nào loại hết dòng. `dim_employee` ghi rõ ở đầu file: "Employees in status 7 and 8". Kiểm tra giá trị thật ở raw:
   ```bash
   docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "select estatus, count(*) from raw_intranet.hr_table_main group by 1"
   ```
2. Nếu mã trạng thái ở nguồn thật sự đổi: sửa điều kiện trong model theo quy tắc nghiệp vụ mới và ghi vào comment đầu file. Nếu chỉ là dòng dữ liệu mẫu lệch: sửa file seed `warehouse/local/seed/raw_intranet/hr_table_main.sql`.
3. Chạy lại **cả chuỗi** để dựng lại dwh, mart và view:
   ```bash
   ./scripts/seed_local.sh
   ./scripts/run_local.sh
   ```

## Kiểm tra lại
```
[3/4] dbt build                   OK  PASS=434 WARN=0 ERROR=0 SKIP=0
```
View đã trở lại, `powerbi_ro` đọc được:
```bash
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d analytics_db -Atc "select count(*) from mart.mart_hr_employee"
```
```
5
```

## Trả lại như cũ
Chính là bước 3 ở trên (`seed_local.sh` rồi chạy lại cả chuỗi). Chưa chạy lại dbt thì dwh còn dữ liệu rỗng và view Power BI vẫn mất.

## Phòng tránh
- `not_empty` có trên mọi source và mọi model `dim_*`, `fact_*`, `mart_*`; `check_conventions.py` kiểm tra điều này ([11](11-convention-check.vi.md)).
- Test chạy **sau** khi bảng đã được dựng, nên nó **báo** lỗi chứ chưa **ngăn** bảng rỗng được ghi. Các bảng phía sau (mart) thì được bảo vệ nhờ `SKIP`.
- Khoảng trống còn lại: view `mart_hr_employee` bị mất khi bảng `_pii` của nó được thay mà test fail (mô tả ở trên). Cần quyết định cách xử lý (ví dụ dựng bản đã che theo cách không phụ thuộc vào bảng `_pii`); chưa làm.
- Bảng nạp thiếu nhiều dòng (không rỗng hẳn) vẫn chưa có test; ý tưởng `elementary.volume_anomalies` cần vài lần chạy thật để có mốc so sánh.
- Khi viết model có điều kiện lọc, bảo đảm file seed có dòng thỏa điều kiện đó, và có dòng "khó" (xem [09](09-join-fan-out.vi.md)).
