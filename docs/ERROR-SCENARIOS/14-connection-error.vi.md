# 14. Lỗi kết nối và cấu hình môi trường

Image dbt nhận thông tin kết nối qua biến môi trường (`DBT_TARGET`, `PGHOST`, `PGUSER`, `PGPASSWORD`, `PGSSLMODE`...), xem `README.md` mục "Run contract". Các ca dưới đây tái hiện bằng cách chạy image dbt với một biến sai. Chạy trong thư mục gốc repo; lệnh dùng chung:
```bash
docker compose run --rm --no-deps -T -e <BIẾN>=<GIÁ TRỊ SAI> dbt
```
Các lệnh này không đụng tới dữ liệu (chúng dừng ngay ở bước kết nối). Kết quả thật còn có thêm dòng cảnh báo "This version of dbt is deprecated..." của dbt; bên dưới bỏ bớt cho gọn.

## 14a. Sai mật khẩu
```bash
docker compose run --rm --no-deps -T -e PGPASSWORD=wrong dbt
```
```
Database Error
  connection to server at "postgres-local" (172.21.0.2), port 5432 failed: FATAL:  password authentication failed for user "dbt_rw"
```
Mã thoát 2. **Sửa**: mật khẩu từ secret store khác với mật khẩu đã đặt cho login `dbt_rw` trên Postgres. Đặt lại một trong hai cho khớp (`ALTER ROLE dbt_rw PASSWORD '...'` do admin chạy).

## 14b. Sai tên máy chủ (với target `prod`)
```bash
docker compose run --rm --no-deps -T -e DBT_TARGET=prod -e PGHOST=postgres-locall -e PGSSLMODE=disable dbt
```
```
Database Error
  could not translate host name "postgres-locall" to address: Temporary failure in name resolution
```
**Sửa**: `PGHOST` gõ sai, hoặc job không phân giải được tên (DNS, mạng riêng). Kiểm tra giá trị biến và quyền mạng tới Postgres (firewall, VNet).

## 14c. Dùng target `prod` với server không có SSL
```bash
docker compose run --rm --no-deps -T -e DBT_TARGET=prod dbt
```
```
Database Error
  connection to server at "postgres-local" (172.21.0.2), port 5432 failed: server does not support SSL, but SSL was required
```
**Giải thích**: target `prod` mặc định `sslmode: require` (đúng cho Azure). Postgres local không có SSL nên bị từ chối.
**Sửa**: ở local dùng `DBT_TARGET=local` (mặc định của `docker-compose.yml`). Trên Azure **không** hạ `PGSSLMODE` xuống `disable` để "cho chạy được".

## 14d. Target `local` nhưng `PGHOST` không phải Postgres local
```bash
docker compose run --rm --no-deps -T -e PGHOST=my-server.postgres.database.azure.com dbt
```
```
Refusing to run: DBT_TARGET=local but PGHOST='my-server.postgres.database.azure.com' is not the local Postgres.
```
Mã thoát 1 (từ script chặn, dbt chưa chạy). **Giải thích**: hai image từ chối chạy `DBT_TARGET=local` trừ khi `PGHOST` là `postgres-local`, `localhost` hoặc `127.0.0.1`, để cấu hình không SSL không bao giờ trỏ nhầm vào server thật. **Sửa**: trên server thật bỏ `DBT_TARGET` (mặc định `prod`); local thì dùng `docker compose` như bình thường.

Lưu ý: gõ sai tên máy local (ví dụ `postgres-locall` ở target `local`) cũng bị chặn ở bước này với cùng một thông báo, thay vì lỗi DNS.

## Phòng tránh
- Bảng biến môi trường đầy đủ và giá trị mặc định: `README.md`, mục "Run contract (production)".
- Cách chạy và lưu ý Azure: `docs/DEPLOY-AZURE.vi.md`, mục 4.
- `PGSSLMODE=require` của target `prod` chưa được thử trên Azure thật (xem `docs/DEPLOY-AZURE.vi.md`).
