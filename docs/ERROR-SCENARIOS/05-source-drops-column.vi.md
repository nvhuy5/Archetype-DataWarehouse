# 05. Nguồn bỏ cột mà staging đang dùng

> Tình huống giả định. Đội quản lý hệ thống Intranet bỏ cột `region` khỏi bảng quốc gia `hr_menu_country`. Bảng raw không còn cột này, nhưng model staging `stg_intranet__hr_menu_country` vẫn chọn nó, và `dim_office` ở dwh vẫn dùng `c.region`.

## Cách tạo ra lỗi
Thử xóa cột thẳng sẽ bị Postgres chặn, vì view staging đang phụ thuộc:
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "alter table raw_intranet.hr_menu_country drop column region"
```
```
ERROR:  cannot drop column region of table raw_intranet.hr_menu_country because other objects depend on it
DETAIL:  view staging.stg_intranet__hr_menu_country depends on column region of table raw_intranet.hr_menu_country
```
Để mô phỏng kết quả cuối (bảng raw mất cột, view staging được dựng lại), xóa view trước:
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "drop view staging.stg_intranet__hr_menu_country"
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "alter table raw_intranet.hr_menu_country drop column region"
```
Cách bảng raw ở môi trường thật đổi cấu trúc do project ingestion quyết định; ca này chỉ mô phỏng hệ quả mà dbt nhìn thấy.

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```

## Thông báo lỗi
```
[3/4] dbt build                   FAILED  PASS=3 WARN=0 ERROR=1 SKIP=3  (22s)
      ! 2 of 5 ERROR creating sql view model staging.stg_intranet__hr_menu_country ..... [ERROR in 0.05s]
08:55:16    Database Error in model stg_intranet__hr_menu_country (models/staging/intranet/hr/stg_intranet__hr_menu_country.sql)
  column "region" does not exist
  LINE 12:     nullif(btrim(region), '')           as region,
                            ^
```

## Đọc thông báo và nguyên nhân
- `ERROR creating sql view model staging...`: model staging không tạo được.
- `column "region" does not exist` và dòng `LINE 12`: dbt đang chọn một cột mà bảng raw không còn. `LINE 12` là dòng trong **câu SQL đã biên dịch**, thường lệch so với dòng trong file `.sql`; tìm theo nội dung `nullif(btrim(region)...`.
- `SKIP=3`: các test của view này không chạy.
- Chú ý: **không** phải `schema_changes` báo lỗi ở đây. Test đó canh cột của model staging, mà model staging còn chưa dựng được.

## Cách sửa
Quyết định trước: cột bị bỏ **nhầm** hay **có chủ ý**?

**A. Bỏ nhầm**: yêu cầu bên nguồn hoặc ingestion khôi phục cột, rồi chạy lại. Ở local: đưa cột về bằng
```bash
./scripts/seed_local.sh --reset
```
(`seed_local.sh` thường **không** đủ vì bảng đã tồn tại nên không được tạo lại; xem [16](16-seed-column-changed.vi.md).)

**B. Bỏ có chủ ý**: sửa cả chuỗi model đang dùng cột đó. Ví dụ bỏ `region` khỏi staging (xóa dòng `nullif(btrim(region), '') as region,`):
```bash
./scripts/run_local.sh --select "--select +dim_office"
```
Lần chạy **đầu** sau khi sửa:
```
[3/4] dbt build                   FAILED  PASS=21 WARN=0 ERROR=1 SKIP=4  (23s)
      ! 9 of 24 FAIL 1 elementary_schema_changes_stg_intranet__hr_menu_country_ ........ [FAIL 1 in 0.69s]
```
`schema_changes` báo cột `region` bị bỏ khỏi model staging, và `dim_office` bị bỏ qua (`SKIP`). Đây là chủ ý của test: mỗi lần đổi cột báo lỗi **một lần** (xem [10](10-schema-changes.vi.md)). Chạy lại lần **hai**, lỗi thật của model phía sau mới hiện:
```
[3/4] dbt build                   FAILED  PASS=22 WARN=0 ERROR=1 SKIP=3  (23s)
      ! 21 of 24 ERROR creating sql table model dwh.dim_office ......................... [ERROR in 0.04s]
08:57:37    Database Error in model dim_office (models/dwh/dim/dim_office.sql)
  column c.region does not exist
  LINE 34:     c.region,
```
Tiếp tục sửa `dim_office` (và mọi model, test, mô tả dùng `region`), chạy lại cho tới khi hết lỗi. Chạy `--select "--select +<model cuối chuỗi>"` để dbt đi qua cả đường phụ thuộc.

## Kiểm tra lại
Chạy cả chuỗi `./scripts/run_local.sh` cho tới `ERROR=0 WARN=0`.

## Trả lại như cũ
```bash
git checkout dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql   # nếu đã sửa ở nhánh B
./scripts/seed_local.sh --reset
./scripts/run_local.sh
```

## Phòng tránh
- Staging liệt kê cột tường minh (không `select *`, có `check_conventions.py` kiểm tra), nên lỗi này hiện **ngay** thay vì lặng lẽ.
- Nguồn bỏ cột là thay đổi hợp đồng dữ liệu: nên báo trước cho team dbt. Danh sách việc cần làm ở B nên có trong ticket.
