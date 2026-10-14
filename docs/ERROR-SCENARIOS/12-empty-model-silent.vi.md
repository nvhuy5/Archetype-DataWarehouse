# 12. Model rỗng mà build vẫn xanh

> Tình huống giả định. Nguồn đổi quy ước mã trạng thái nhân viên, hoặc dòng dữ liệu mẫu không còn khớp điều kiện lọc của model. `dim_employee` (chỉ lấy nhân viên trạng thái 7 và 8) trở nên **rỗng**, kéo theo báo cáo nhân sự trống. Lần build vẫn kết thúc "thành công".

Ca này khác các ca trước: **không test nào fail**. Mục đích là cho bạn thấy giới hạn của bộ test hiện có.

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "update raw_intranet.hr_table_main set estatus = 1"
```

## Cách phát hiện
```bash
./scripts/run_local.sh
```
```
[2/4] Raw data (seeded)           OK  61 tables
[3/4] dbt build                   OK  PASS=415 WARN=2 ERROR=0 SKIP=0  (55s)
      ! 404 of 415 WARN 5 relationships_fact_timesheet_employee_id__employee_id__ref_dim_employee_  [WARN 5 in 0.06s]
      ! 413 of 415 WARN 5 relationships_mart_ts_details_employee_id__employee_id__ref_mart_ts_employees_  [WARN 5 in 0.14s]
[4/4] Elementary report           OK  report/elementary_report.html  (34s)
---
Done in 91s. Details: report/logs/
```
Mã thoát là **0**. Không có `FAIL`, không có `ERROR`. Hai dòng `WARN` là tín hiệu duy nhất, và chúng nói về timesheet chứ không nói "dim_employee rỗng".

Đếm dòng thật:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "
  select 'dim_employee' t, count(*) from dwh.dim_employee
  union all select 'mart_hr_employee', count(*) from mart.mart_hr_employee
  union all select 'mart_ts_employees', count(*) from mart.mart_ts_employees
  union all select 'fact_timesheet', count(*) from dwh.fact_timesheet"
```
```
         t         | count 
-------------------+-------
 dim_employee      |     0
 mart_hr_employee  |     0
 mart_ts_employees |     0
 fact_timesheet    |     5
```
Trước khi làm hỏng, ba bảng đầu đều có 5 dòng.

## Đọc kết quả và nguyên nhân
- `not_empty` chỉ gắn vào **bảng raw** (nguồn). `hr_table_main` vẫn có 5 dòng nên qua.
- Không test nào yêu cầu `dwh` hay `mart` phải có dòng. `unique`, `not_null`, `schema_changes` đều qua trên bảng rỗng.
- `WARN 5 relationships_...`: 5 dòng timesheet tham chiếu nhân viên không còn trong `dim_employee`. Đây là gợi ý, nhưng dễ bị bỏ qua vì chỉ là cảnh báo. Một mart **không có model nào tham chiếu tới** (ví dụ `mart_hr_employee`) rỗng thì **không có tín hiệu nào**.
- Hậu quả: Power BI đọc `mart.mart_hr_employee` thấy 0 dòng và không ai được báo.

## Cách sửa
1. Đếm dòng các bảng dwh/mart (câu lệnh trên) khi báo cáo trống hoặc khi sau thay đổi lớn.
2. Tìm xem điều kiện lọc nào loại hết dòng. `dim_employee` ghi rõ ở đầu file: "Employees in status 7 and 8". Kiểm tra giá trị thật ở raw:
   ```bash
   docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "select estatus, count(*) from raw_intranet.hr_table_main group by 1"
   ```
3. Nếu mã trạng thái ở nguồn thật sự đổi, sửa điều kiện trong model theo quy tắc nghiệp vụ mới và ghi vào comment đầu file. Nếu chỉ là dòng dữ liệu mẫu lệch thì sửa file seed `warehouse/local/seed/raw_intranet/hr_table_main.sql`.

Ở local, dữ liệu mẫu đúng nằm trong file seed: `./scripts/seed_local.sh`, rồi **chạy lại cả chuỗi** để dựng lại dwh và mart.

## Kiểm tra lại
```bash
./scripts/seed_local.sh
./scripts/run_local.sh
```
```
[3/4] dbt build                   OK  PASS=417 WARN=0 ERROR=0 SKIP=0
```
Đếm lại: `dim_employee`, `mart_hr_employee`, `mart_ts_employees` đều 5 dòng.

## Trả lại như cũ
Chính là bước ở trên (`seed_local.sh` và chạy lại cả chuỗi). Không chạy lại dbt thì dwh và mart vẫn còn dữ liệu rỗng.

## Phòng tránh
Đây là **khoảng trống đã biết**, hiện chưa được chặn tự động. Cách chặn có thể làm sau (cần bạn duyệt trước khi thêm):
- Gắn `not_empty` cho các model `dim_*`, `fact_*` và `mart_*`, giống như đang làm với source.
- Dùng `elementary.volume_anomalies` để báo khi số dòng giảm mạnh so với lịch sử (cần vài lần chạy thật để có mốc).
- Khi viết model có điều kiện lọc, bảo đảm file seed có dòng thỏa điều kiện đó, và có dòng "khó" (xem [09](09-join-fan-out.vi.md)).
