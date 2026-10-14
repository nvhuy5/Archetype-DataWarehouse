# Khung dbt + Elementary

🇬🇧 [English](README.md) · 📘 [Hướng dẫn cho khách hàng: dbt & Elementary là gì?](docs/GUIDELINE.vi.md) · 📐 [Quy ước đặt tên](docs/NAMING.vi.md) · 📋 [Playbook migrate SSIS](docs/PLAYBOOK.vi.md) · 🧪 [Test local](docs/TEST-LOCAL.vi.md) · ⚖️ [Quyết định chung](docs/DECISIONS.vi.md) · ☁️ [Lên Azure](docs/DEPLOY-AZURE.vi.md) · 🧯 [Error scenarios](docs/ERROR-SCENARIOS/README.vi.md)

Chuyển package SSIS `ACT_Intranet_warehouse_3` sang ELT: các bảng Intranet (MySQL) được copy nguyên bản vào `raw_intranet`,
dbt đưa chúng lên `staging`. Logic nghiệp vụ (join, tổng hợp) thuộc các layer sau là `dwh` và `mart`.

```
Intranet --[ADF, project ingestion]--> raw_intranet --[image dbt: dbt build]--> staging (→ dwh → mart) --[image Elementary]--> báo cáo HTML
```

## Chạy thử (chỉ cần Docker)

```bash
./scripts/seed_local.sh           # một lần, và sau khi sửa file seed: tạo bảng raw cùng dòng mẫu
./scripts/run_local.sh            # dbt build + báo cáo Elementary; in tóm tắt ngắn, log chi tiết ở report/logs/
./scripts/seed_local.sh --reset   # xóa sạch database local rồi seed lại
```

dbt chỉ đọc `raw_intranet`; việc nạp từ MySQL là của project ingestion (ADF), nằm ngoài repo này.
Ở local, `postgres-local` đóng vai warehouse: `seed_local.sh` tạo từng bảng raw từ file của nó trong
`warehouse/local/seed/raw_intranet/` (câu `CREATE TABLE` cùng vài dòng mẫu). `run_local.sh` sau đó chạy `dbt build`
(61 model staging, các model `dwh`, `mart` và test) rồi Elementary. Nó chỉ kiểm tra bảng raw đã có và cảnh báo khi file seed
đổi (hoặc seed đã quá 7 ngày) so với lần seed cuối; nó không tự dựng lại raw.

## Các layer

| Layer | Nội dung | Quy tắc |
|---|---|---|
| `raw_intranet` | 61 bảng, cùng tên và cột với nguồn MySQL | project ingestion (ADF) nạp, không có logic, không sửa tại chỗ |
| `staging` | mỗi bảng raw một view `stg_intranet__<bảng>` (bỏ hậu tố `_2015`) | cắt khoảng trắng, chuỗi rỗng thành NULL, snake_case; không join, không quy tắc nghiệp vụ |
| `dwh` | `dim_*`, `fact_*`, `int_*`: join, tổng hợp, quy tắc nghiệp vụ | `dim_employee`, `dim_office`, `dim_phase`, `fact_timesheet`, `fact_headcount_monthly`... (Timesheet và headcount HR) |
| `mart` | bảng riêng cho từng báo cáo, đã che dữ liệu cá nhân, Power BI đọc (`powerbi_ro`) | `mart_ts_details`, `mart_ts_employees`, `mart_ts_offices`, `mart_ts_departments` |
| `mart_restricted` | bảng `mart_*_pii` đầy đủ, chỉ role `pii_admin` đọc | `mart_hr_employee_pii` (bản che: view `mart.mart_hr_employee`) | |

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
| `dbt/models/mart/`, `mart_restricted/` | bảng cho báo cáo; bảng `*_pii` |
| `dbt/tests/generic/` | test dùng chung; `not_empty` áp cho mọi bảng raw (nạp ra bảng rỗng không được qua im lặng) |
| `dbt/seeds/` | `public_holidays` (đang để trống, chờ khách cung cấp) |
| `dbt/models/staging/intranet/<domain>/` | `hr`, `timesheet`, `crm`, `prm`, `strategic`: `_<domain>__sources.yml`, `stg_*.sql`, `_<domain>__models.yml` (test) |
| `warehouse/local/init/` | chỉ cho Postgres local: schema, role, phân quyền (chạy khi database còn trống) |
| `warehouse/local/seed/raw_intranet/` | mỗi bảng raw một file: `CREATE TABLE` + dòng mẫu, `scripts/seed_local.sh` áp vào |
| `warehouse/prod/` | PostgreSQL production: schema, role (không có mật khẩu) và phân quyền, platform team chạy một lần (xem `docs/DEPLOY-AZURE.vi.md`) |
| `dbt.Dockerfile`, `elementary.Dockerfile` | hai image chạy thật |
| `scripts/` | `seed_local.sh`, `run_local.sh` và các kiểm tra chạy bằng tay: quy tắc repo, quy ước model, `check_prod_sql.sh` (xem `docs/TEST-LOCAL.vi.md`) |
| `docker-compose.yml` | môi trường test local |

## Thêm một model

1. Có bảng raw mới? Thêm `warehouse/local/seed/raw_intranet/<bảng>.sql` (`CREATE TABLE` đúng tên và cột của nguồn, kèm dòng mẫu;
   project ingestion phải nạp đúng bảng đó vào `raw_intranet`). Khai báo trong `_<domain>__sources.yml` của domain đó, kèm test `not_empty` (`check_conventions.py` bắt buộc).
   Model cần giá trị khác (join, trường hợp biên)? Sửa dòng mẫu trong file seed của bảng nó đọc.
2. Thêm `stg_intranet__<bảng>.sql` và test tương ứng trong `_<domain>__models.yml`.
3. Cần layer mới? Tạo thư mục dưới `dbt/models/` và thêm khối tương ứng trong `dbt/dbt_project.yml`.
4. Tạo schema một lần trong warehouse và cấp quyền cho `dbt_rw`: trong `warehouse/local/init/` cho local và `warehouse/prod/` cho production (giữ hai bên giống nhau, rồi chạy `./scripts/check_prod_sql.sh`).
5. Chạy `./scripts/seed_local.sh` (sau mỗi thay đổi seed), rồi `./scripts/run_local.sh` để kiểm tra.

## Biến môi trường khi chạy thật (production)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `PGHOST`, `PGUSER`, `PGPASSWORD` | bắt buộc | warehouse, tài khoản `dbt_rw`, mật khẩu (lấy từ secret store) |
| `PGDATABASE` / `PGPORT` / `PGSSLMODE` | `analytics_db` / `5432` / `require` | |
| `DBT_TARGET` | `prod` | target trong `dbt/profiles.yml`; chỉ `docker-compose.yml` đặt `local` (không SSL), nên quên biến này cũng không dùng cấu hình local; cả hai image từ chối chạy `local` nếu `PGHOST` không phải `postgres-local`/`localhost` |
| `DBT_ARGS` (image dbt) | `--selector default` | tham số của `dbt build` |

**Mạng:** cả hai image đều không cần internet khi chạy: package dbt (kể cả package riêng của `edr`) đã được đóng gói lúc build.
Build image cần internet (PyPI, hub.getdbt.com); lần build đầu mất vài phút, các lần sau chỉ khoảng 1 giây khi chỉ sửa model
(các layer xếp từ ít đổi nhất đến hay đổi nhất).

Chạy **image dbt trước, rồi image Elementary**. Cả hai thoát với mã khác 0 khi lỗi. Elementary ghi báo cáo ra
`/report/elementary_report.html` (mount `/report` hoặc upload file này). Image chạy bằng user không phải root và không chứa secret.
