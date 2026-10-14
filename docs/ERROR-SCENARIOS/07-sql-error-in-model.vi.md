# 07. Lỗi SQL trong model

> Tình huống giả định. Bạn sửa nhanh `dim_employee` và gõ nhầm tên cột `birthday` thành `birthdy`.

## Cách tạo ra lỗi
```bash
sed -i 's/e\.birthday)/e.birthdy)/' dbt/models/dwh/dim/dim_employee.sql
git diff dbt/models/dwh/dim/dim_employee.sql
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```

## Thông báo lỗi
```
[3/4] dbt build                   FAILED  PASS=70 WARN=0 ERROR=1 SKIP=6  (27s)
      ! 69 of 75 ERROR creating sql table model dwh.dim_employee ....................... [ERROR in 0.05s]
08:37:06    Database Error in model dim_employee (models/dwh/dim/dim_employee.sql)
  column e.birthdy does not exist
  LINE 59:     date_part('year', age(current_date, e.birthdy))::int as ...
                                                   ^
  HINT:  Perhaps you meant to reference the column "e.birthday".
```

## Đọc thông báo và nguyên nhân
- `ERROR creating sql table model dwh.dim_employee`: **model này** không tạo được. Mọi thứ phía trên nó (staging) đã chạy xong (`PASS=70`).
- `Database Error`: lỗi do Postgres trả về (khác với `FAIL` của test).
- `column e.birthdy does not exist` cho tên cột sai. Dòng `HINT: Perhaps you meant ...` thường gợi ý đúng tên.
- `LINE 59` là dòng trong **SQL đã biên dịch** (đã thay `{{ ref() }}` và macro), không phải dòng trong file model. Tìm bằng nội dung dòng đó (`age(current_date, e.birthdy)`).
- `SKIP=6`: các test của `dim_employee` và test phụ thuộc không chạy.

## Cách sửa
Sửa lại đúng tên cột:
```bash
git diff dbt/models/dwh/dim/dim_employee.sql      # xem bạn vừa đổi gì
```
Nếu `HINT` không có, kiểm tra tên cột ở model hoặc nguồn:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "\d staging.stg_intranet__hr_table_main"
```

## Kiểm tra lại
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```
Không còn `ERROR`.

## Trả lại như cũ
```bash
git checkout dbt/models/dwh/dim/dim_employee.sql
```

## Phòng tránh
- Chạy `./scripts/run_local.sh --select "--select +<model bạn sửa>"` **ngay sau mỗi lần sửa**, không dồn nhiều thay đổi rồi mới chạy.
- Lỗi SQL ở môi trường thật cũng hiện đúng như vậy; không thể lọt qua vì job dbt thoát mã khác 0 và model phía sau bị bỏ qua.
