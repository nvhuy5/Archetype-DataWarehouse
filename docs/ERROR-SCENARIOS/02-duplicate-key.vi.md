# 02. Trùng khóa

> Tình huống giả định. Ingestion bị chạy hai lần chồng nhau (hoặc retry sau lỗi mạng) và chèn thêm dòng thay vì thay bảng. Bảng `hr_table_main` có hai dòng cho nhân viên `ide = 1`.

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db \
  -c "insert into raw_intranet.hr_table_main select * from raw_intranet.hr_table_main where ide = 1"
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```

## Thông báo lỗi
Trên màn hình:
```
[3/4] dbt build                   FAILED  PASS=69 WARN=0 ERROR=1 SKIP=6  (28s)
      ! 58 of 74 FAIL 1 unique_stg_intranet__hr_table_main_ide ......................... [FAIL 1 in 0.11s]
```
Trong `report/logs/3-dbt.log`:
```
69 of 74 SKIP relation dwh.dim_employee ........................................ [SKIP]
...
74 of 74 SKIP test unique_dim_employee_employee_id ............................. [SKIP]
Failure in test unique_stg_intranet__hr_table_main_ide (models/staging/intranet/hr/_hr__models.yml)
  Got 1 result, configured to fail if != 0
```

## Đọc thông báo và nguyên nhân
- `unique_stg_intranet__hr_table_main_ide`: test `unique` trên cột `ide` của model `stg_intranet__hr_table_main`.
- `Got 1 result`: có **1 giá trị** `ide` bị trùng (không phải 1 dòng thừa).
- Staging là view, không lọc dòng, nên dòng trùng đi thẳng vào staging và test bắt được. Đây là chủ ý: dbt **không âm thầm bỏ dòng** (khác với redirect lỗi của SSIS cũ).
- `SKIP=6`: `dim_employee` và các test của nó không chạy, nên `dwh.dim_employee` giữ bản của lần build trước thay vì nhân đôi nhân viên.

Tìm dòng trùng:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db \
  -c "select ide, count(*) from raw_intranet.hr_table_main group by ide having count(*) > 1"
```
```
 ide | count 
-----+-------
   1 |     2
(1 row)
```

## Cách sửa
Sửa ở **nguồn nạp**, không sửa trong dbt:
1. Tìm nguyên nhân nạp trùng (chạy chồng, retry không an toàn).
2. Nạp lại bằng cách **thay bảng** (xóa cũ và chèn mới trong cùng một transaction), không chèn thêm.
3. Chạy lại dbt.

Không nên thêm `distinct` hay `row_number()` vào staging để "che" lỗi: bạn sẽ mất tín hiệu rằng nguồn đang nạp sai, và có thể che luôn dòng trùng nhưng khác nội dung.

Ở local: `./scripts/seed_local.sh`.

## Kiểm tra lại
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```
Không còn `FAIL` và `SKIP`.

## Trả lại như cũ
`./scripts/seed_local.sh`.

## Phòng tránh
- Mỗi bảng staging có test khóa (`unique` và `not_null`), `scripts/check_conventions.py` bắt buộc điều này. Bảng không có khóa trong nguồn dùng `unique_combination_of_columns` hoặc ghi rõ "No primary key" trong mô tả.
- Khi bảng có khóa trùng nhưng do **join** ở dwh chứ không phải do nguồn, xem [09](09-join-fan-out.vi.md).
