# 13. Permission denied

Ba tài khoản có quyền khác nhau (xem `docs/DEPLOY-AZURE.vi.md`): `dbt_rw` (dbt, đọc raw và ghi các schema dbt), `powerbi_ro` (Power BI, chỉ đọc `mart`), `pii_admin` (đọc `mart` và `mart_restricted`). Lỗi quyền có hai hướng.

## 13a. dbt không đọc được bảng raw

> Tình huống giả định. Project ingestion tạo lại bảng `hr_menu_country` bằng một login khác. Bảng mới không có quyền `SELECT` cho `dbt_rw`, và job dbt sáng hôm sau lỗi.

**Tạo lỗi**
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "revoke select on raw_intranet.hr_menu_country from dbt_rw"
```
**Phát hiện**
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```
**Thông báo**
```
[3/4] dbt build                   FAILED  PASS=2 WARN=0 ERROR=1 SKIP=4  (22s)
      ! 1 of 5 ERROR source_not_empty_raw_intranet_hr_menu_country_ .................... [ERROR in 0.06s]
08:50:13    Database Error in test source_not_empty_raw_intranet_hr_menu_country_ (models/staging/intranet/hr/_hr__sources.yml)
  permission denied for table hr_menu_country
```
Tự kiểm tra bằng đúng tài khoản của dbt:
```bash
docker compose exec -T -e PGPASSWORD=dbt_rw postgres-local psql -h localhost -U dbt_rw -d archetype_dwh -c "select count(*) from raw_intranet.hr_menu_country"
```
```
ERROR:  permission denied for table hr_menu_country
```
**Đọc thông báo**
- `ERROR` và `permission denied for table <bảng>`: bảng **có**, nhưng `dbt_rw` không được đọc.
- Test `not_empty` của source là thứ đầu tiên đọc bảng nên nó lộ lỗi trước. Các model phía sau `SKIP=4`.
**Sửa**: cấp lại quyền đọc cho `dbt_rw` (admin chạy):
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "grant select on raw_intranet.hr_menu_country to dbt_rw"
```
Kiểm tra lại bằng lệnh `select count(*)` ở trên: ra `5`. Rồi chạy lại dbt.

**Nguyên nhân gốc ở môi trường thật**: bảng được tạo bởi một login mà `ALTER DEFAULT PRIVILEGES` chưa áp dụng. `warehouse/prod/02_grants.sql` có dòng cho phần này. File tự tìm mọi schema `raw_<nguồn>` và lấy **chủ sở hữu của schema** làm login ingestion của nguồn đó:
```sql
ALTER DEFAULT PRIVILEGES FOR ROLE <chủ schema> IN SCHEMA raw_<nguồn> GRANT SELECT ON TABLES TO dbt_rw;
```
Nếu ingestion đổi login hoặc bảng được tạo bởi một login khác chủ schema, cần chuyển quyền sở hữu schema hoặc cấp `SELECT` cho `dbt_rw` sau mỗi lần nạp. Thêm nguồn mới (`raw_nav`...) thì chạy lại `02_grants.sql`. `./scripts/check_prod_sql.sh` kiểm tra rằng bảng do ingestion tạo **sau** khi cấp quyền vẫn đọc được.

**Trả lại**: bước sửa ở trên đã trả quyền; chạy lại dbt cho xanh.

## 13b. Power BI đọc nhầm schema `mart_restricted`

> Tình huống giả định. Một người dựng báo cáo Power BI chọn bảng `mart_restricted.mart_hr_employee_pii` (đầy đủ dữ liệu cá nhân) thay vì bản đã che.

**Tạo lỗi**: dùng tài khoản Power BI:
```bash
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d archetype_dwh \
  -c "select count(*) from mart_restricted.mart_hr_employee_pii"
```
**Thông báo**
```
ERROR:  permission denied for schema mart_restricted
LINE 1: select count(*) from mart_restricted.mart_hr_employee_pii
```
**Đọc thông báo**: `permission denied for schema` (không phải `for table`): `powerbi_ro` không có cả quyền vào schema. Đây là **thiết kế có chủ ý** để dữ liệu cá nhân chưa che không lọt ra Power BI, chứ không phải lỗi cấu hình.

**Sửa**: **không** cấp thêm quyền cho `powerbi_ro`. Đổi báo cáo sang bản đã che trong schema `mart`:
```bash
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d archetype_dwh \
  -c "select count(*) from mart.mart_hr_employee"
```
```
 count 
-------
     5
```
Nếu một người thật sự cần xem bản đầy đủ, dùng tài khoản `pii_admin` (xem `docs/DECISIONS.vi.md`, mục dữ liệu cá nhân).

## Phòng tránh
- Quyền của `mart` và `mart_restricted` gắn theo **thư mục model** trong `dbt_project.yml`; đặt model `*_pii` sai thư mục là cách duy nhất làm hỏng ranh giới này (xem [11](11-convention-check.vi.md), ca 11b).
- Sau khi sửa SQL trong `warehouse/prod/` hoặc quyền dự án, chạy `./scripts/check_prod_sql.sh`: nó kiểm tra 17 điều về việc mỗi tài khoản đọc được và bị chặn những gì.
