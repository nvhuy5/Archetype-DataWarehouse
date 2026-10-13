# Khung dbt + Elementary

🇬🇧 [English](README.md) · 📘 [Hướng dẫn cho khách hàng: dbt & Elementary là gì?](GUIDELINE.vi.md) · 📐 [Quy ước đặt tên](NAMING.vi.md) · 📋 [Playbook migrate SSIS](PLAYBOOK.vi.md) · ⚖️ [Quyết định chung](DECISIONS.vi.md)

Chuyển package SSIS `ACT_Intranet_warehouse_3` sang ELT: các bảng Intranet (MySQL) được copy nguyên bản vào `raw_intranet`,
dbt đưa chúng lên `staging`. Logic nghiệp vụ (join, tổng hợp) thuộc các layer sau là `dwh` và `mart`.

```
Intranet --[ADF]--> raw_intranet --[image dbt: dbt build]--> staging (→ dwh → mart) --[image Elementary]--> báo cáo HTML
```

## Chạy thử (chỉ cần Docker)

```bash
docker compose run --build --rm elementary      # báo cáo: ./report/elementary_report.html
docker compose down -v                          # dọn dẹp
```

Lệnh trên dựng warehouse rỗng (bảng raw tạo từ `warehouse/init`), nạp vào `raw_intranet` vài dòng dữ liệu giả cho mỗi bảng
(thay cho ADF), chạy `dbt build` (61 model staging, các model `dwh` và test), rồi chạy Elementary.

Chạy với dữ liệu Intranet thật (chỉ đọc, cần mạng tới MySQL):

```bash
INGEST_MODE=mysql MYSQL_HOST=<host> MYSQL_USER=<user> MYSQL_PASSWORD=<pwd> MYSQL_DATABASE=archetype_intranet \
  docker compose run --build --rm elementary
```

## Các layer

| Layer | Nội dung | Quy tắc |
|---|---|---|
| `raw_intranet` | 61 bảng, cùng tên và cột với nguồn MySQL | ADF nạp, không có logic, không sửa tại chỗ |
| `staging` | mỗi bảng raw một view `stg_intranet__<bảng>` (bỏ hậu tố `_2015`) | cắt khoảng trắng, chuỗi rỗng thành NULL, snake_case; không join, không quy tắc nghiệp vụ |
| `dwh` | `dim_*`, `fact_*`, `int_*`: join, tổng hợp, quy tắc nghiệp vụ | `dim_employee`, `dim_office`, `dim_phase`, `fact_timesheet`, `fact_headcount_monthly`... (Timesheet và headcount HR) |
| `mart` (đợt 3) | bảng riêng cho từng báo cáo | ví dụ `mart_ts_*` |

`fact_timesheet` có một dòng cho mỗi dòng timesheet từ `timesheet_from_date` (biến dbt, mặc định 2020-01-01 như SSIS). `dim_office` chưa có các cột NAV của `Dim_Offices` cũ vì NAV chưa được nạp.

Từ package SSIS, chỉ phần copy bảng nằm ở raw và staging. Các phép join làm giàu của `hr_table_contract`, phép tổng hợp
`Summarized_Timesheet` và view `get_employee_etl` sẽ được dựng lại ở `dwh` từ các bảng gốc trong raw (`int_hr_contract`, `dim_employee`, `fact_timesheet`). Vì vậy raw chứa
`hr_table_main` (không phải view) cùng `hr_menu_process_status`, `crm_list_reason`, `timesheet_phase_2015` mà các phép join đó cần.

Dữ liệu cá nhân (CCCD, ngân hàng, thuế, bảo hiểm, điện thoại, lương) vẫn nằm trong raw nhưng **không đưa lên staging**; xem mô tả từng model.

## Cấu trúc thư mục

| Đường dẫn | Ý nghĩa |
|---|---|
| `dbt/` | project dbt |
| `dbt/models/dwh/` | dimension, fact, thư mục `intermediate/` |
| `dbt/seeds/` | `public_holidays` (đang để trống, chờ khách cung cấp) |
| `dbt/models/staging/intranet/<domain>/` | `hr`, `timesheet`, `crm`, `prm`, `strategic`: `_<domain>__sources.yml`, `stg_*.sql`, `_<domain>__models.yml` (test) |
| `warehouse/init/` | phần platform tạo một lần: schema và login, bảng raw, phân quyền |
| `ingest/`, `ingest.Dockerfile` | thay thế ADF khi test local (chế độ `sample` hoặc `mysql`) |
| `dbt.Dockerfile`, `elementary.Dockerfile` | hai image chạy thật |
| `scripts/`, `.github/workflows/ci.yml` | kiểm tra tự động (CI) |
| `docker-compose.yml` | môi trường test local |

## Thêm một model

1. Có bảng raw mới? Thêm `CREATE TABLE` vào `warehouse/init/02_raw_intranet.sql` (và ADF phải nạp vào `raw_intranet` với cùng tên).
   Khai báo trong `_<domain>__sources.yml` của domain đó.
2. Thêm `stg_intranet__<bảng>.sql` và test tương ứng trong `_<domain>__models.yml`.
3. Cần layer mới (`dwh`, `mart`)? Tạo thư mục dưới `dbt/models/` và bỏ comment khối tương ứng trong `dbt/dbt_project.yml`.
4. Tạo schema một lần trong warehouse và cấp quyền cho `dbt_rw` (xem `warehouse/init/03_grants.sql`).
5. Chạy `docker compose run --build --rm elementary` để kiểm tra.

## Biến môi trường khi chạy thật (production)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `PGHOST`, `PGUSER`, `PGPASSWORD` | bắt buộc | warehouse, tài khoản `dbt_rw`, mật khẩu (lấy từ secret store) |
| `PGDATABASE` / `PGPORT` / `PGSSLMODE` | `analytics_db` / `5432` / `require` | |
| `DBT_ARGS` (image dbt) | `--selector default` | tham số của `dbt build` |

**Mạng:** image dbt không cần internet khi chạy (package đã được đóng gói lúc build). Image Elementary thì cần: `edr` tải
package dbt từ `hub.getdbt.com` mỗi lần chạy, nên cần mở outbound HTTPS tới đó (hoặc dùng proxy). Build image cũng cần
internet (PyPI, hub.getdbt.com) và mất vài phút nếu chưa có cache.

Chạy **image dbt trước, rồi image Elementary**. Cả hai thoát với mã khác 0 khi lỗi. Elementary ghi báo cáo ra
`/report/elementary_report.html` (mount `/report` hoặc upload file này). Image chạy bằng user không phải root và không chứa secret.
