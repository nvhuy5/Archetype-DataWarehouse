# 16. Đổi cột trong file seed của bảng đã tồn tại

> Tình huống giả định. Bảng nguồn `hr_menu_country` có thêm cột `extra_col`. Bạn thêm cột này vào file seed để model mới dùng được. `seed_local.sh` báo lỗi.

Bảng raw ở local chỉ được **tạo một lần** (`CREATE TABLE IF NOT EXISTS`); các lần seed sau chỉ thay dòng. Giống cách ingestion ở môi trường thật không xóa bảng mà chỉ thay dòng, và nhờ vậy view staging không bị đụng tới. Cái giá là: đổi **cột** của bảng đã có không tự áp dụng.

## Cách tạo ra lỗi
Sửa `warehouse/local/seed/raw_intranet/hr_menu_country.sql`: thêm cột vào cả `CREATE TABLE` và `INSERT`:
```diff
-    "hr_hide" smallint
+    "hr_hide" smallint,
+    "extra_col" integer
 );
 TRUNCATE raw_intranet."hr_menu_country";
-INSERT INTO ... ("idp", ..., "hr_hide") VALUES
+INSERT INTO ... ("idp", ..., "hr_hide", "extra_col") VALUES
-    (1, 'pays_1', ..., 'act', 1),
+    (1, 'pays_1', ..., 'act', 1, 1),
 ...
```
(Mỗi dòng giá trị thêm một giá trị cho `extra_col`.)

## Cách phát hiện
```bash
./scripts/seed_local.sh
```

## Thông báo lỗi
```
psql:/seed/raw_intranet/hr_menu_country.sql:25: ERROR:  column "extra_col" of relation "hr_menu_country" does not exist
LINE 1: ...iso_country_code", "act_country_code", "hr_hide", "extra_col...
FAILED: /seed/raw_intranet/hr_menu_country.sql (columns changed in an existing table? run ./scripts/seed_local.sh --reset)
```
Mã thoát 1.

## Đọc thông báo và nguyên nhân
- `column "extra_col" of relation "hr_menu_country" does not exist`: `INSERT` nhắc tới cột mà **bảng đang có** chưa có, vì `CREATE TABLE IF NOT EXISTS` bỏ qua khi bảng đã tồn tại.
- Mỗi file seed chạy trong một transaction, nên file lỗi **không để lại nửa vời**: bảng giữ nguyên như trước.
- Nếu bạn chỉ sửa `CREATE TABLE` mà quên `INSERT`, lỗi sẽ **không** hiện (bảng cũ vẫn dùng được với `INSERT` cũ), nhưng cột mới không có. Luôn sửa cả hai.

## Cách sửa
Xóa database local để bảng được tạo lại theo định nghĩa mới:
```bash
./scripts/seed_local.sh --reset
```
```
Seeded 61 raw tables in 7s. Next: ./scripts/run_local.sh
```
Kiểm tra cột mới có dữ liệu:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -Atc "select idp, extra_col from raw_intranet.hr_menu_country order by 1 limit 2"
```
```
1|1
2|1
```
`--reset` xóa cả view staging và bảng dwh/mart, nên **chạy lại cả chuỗi** `./scripts/run_local.sh` sau đó.

## Trả lại như cũ
```bash
git checkout warehouse/local/seed/raw_intranet/hr_menu_country.sql
./scripts/seed_local.sh --reset
./scripts/run_local.sh
```

## Phòng tránh
- Đổi cột trong file seed luôn đi kèm `--reset`.
- Ở môi trường thật, nếu nguồn thêm cột mà project ingestion chưa nạp thì dbt không thấy cột đó; xem [05](05-source-drops-column.vi.md) và [10](10-schema-changes.vi.md).
