# Quy ước đặt tên

Áp dụng cho mọi package SSIS được migrate sang dbt. Các ví dụ lấy từ repo này.

## 1. Schema (PostgreSQL)

| Schema | Nội dung | Ai ghi |
|---|---|---|
| `raw_<nguồn>` | Bản sao nguyên gốc của nguồn. Ví dụ `raw_intranet`; sau này `raw_nav`, `raw_static`, `raw_sharepoint` | Project ingestion (ADF). Ở local: file seed trong `warehouse/local/seed/` |
| `staging` | Model `stg_*` | dbt |
| `dwh` | `dim_*`, `fact_*`, `int_*`, seed | dbt |
| `mart` | `mart_*`: bản đã che dữ liệu cá nhân, cho Power BI | dbt |
| `mart_restricted` | `mart_*_pii`: bản đầy đủ, chỉ role admin đọc | dbt |
| `elementary` | Kết quả test và lịch sử chạy | dbt (package Elementary) |

Tên schema do dbt macro `generate_schema_name` quyết định: lấy đúng tên đặt trong `dbt_project.yml`, không ghép thêm tiền tố.

## 2. Bảng raw
- **Tên bảng giống hệt nguồn** (`hr_table_main`, `timesheet_entry_2015`). Không đổi tên, không bỏ hậu tố.
- **Tên cột viết thường.** MySQL không phân biệt hoa thường nên `TenantID` thành `tenantid`. Việc đổi sang `snake_case` làm ở staging.
- Giữ **đủ cột** của nguồn, không `SELECT *` rồi bỏ cột. Không khóa, không ràng buộc, để một lần nạp không bao giờ bị từ chối.
- Mỗi bảng raw local là một file `warehouse/local/seed/raw_intranet/<bảng>.sql`: `CREATE TABLE` kèm vài dòng mẫu. Bảng raw mới phải có file này.

Ánh xạ kiểu dữ liệu MySQL sang PostgreSQL:

| MySQL | PostgreSQL |
|---|---|
| `int`, `int unsigned` | `integer`, `bigint` |
| `tinyint`, `smallint` | `smallint` (`smallint unsigned` thành `integer`) |
| `bigint`, `bigint unsigned` | `bigint`, `numeric(20,0)` |
| `varchar(n)`, `char(n)` | `varchar(n)` (không dùng `char` để tránh đệm khoảng trắng) |
| `text`, `mediumtext`, `longtext` | `text` |
| `enum(...)` | `varchar(255)` |
| `date` | `date` |
| `datetime`, `timestamp` | `timestamp` |
| `decimal(p,s)` | `numeric(p,s)` |
| `float`, `double` | `real`, `double precision` |
| `year` | `smallint` |

## 3. Model staging
- Tên: **`stg_<nguồn>__<bảng>`** (hai dấu gạch dưới giữa nguồn và bảng). Ví dụ `stg_intranet__hr_table_main`.
- Bỏ hậu tố `_2015` của bảng nguồn (`stg_intranet__timesheet_entry`). Các tên khác giữ nguyên (`stg_intranet__hr_menu_offices`).
- Mỗi bảng raw đúng một model. Materialized là `view`.
- Thư mục: `dbt/models/staging/<nguồn>/<domain>/`. Domain của Intranet: `hr`, `timesheet`, `crm`, `prm`, `strategic`.
- File khai báo trong cùng thư mục: `_<domain>__sources.yml` (nguồn) và `_<domain>__models.yml` (mô tả và test). Dấu `_` đứng đầu để file YAML nằm trên cùng.
- Cột: `snake_case` (`TenantID` thành `tenant_id`, `oldRevision` thành `old_revision`). Cột văn bản được `btrim`, chuỗi rỗng thành `NULL`.
- Tên cột trùng từ khóa dành riêng của PostgreSQL thì đặt trong dấu ngoặc kép (`"user"`, `"order"`).
- Cột cá nhân và lương **không đưa lên staging** (vẫn nằm trong raw). Danh sách cột bị ẩn ghi trong mô tả model.
- Mỗi domain gắn `tags` cùng tên domain trong `dbt_project.yml`.

## 4. Model dwh
| Loại | Mẫu tên | Ví dụ | Ghi chú |
|---|---|---|---|
| Dimension | `dim_<thực thể số ít>` | `dim_employee`, `dim_phase` | Một dòng cho mỗi thực thể |
| Fact | `fact_<chủ đề>` hoặc `fact_<chủ đề>_<độ mịn>` | `fact_timesheet`, `fact_headcount_monthly` | Thêm hậu tố độ mịn khi không phải mức chi tiết nhất |
| Trung gian | `int_<mô tả>` | `int_hr_contract` | Đặt trong `models/dwh/intermediate/`, là `view` |
| Seed | tên dữ liệu, số nhiều hoặc tập hợp | `public_holidays` | Nằm trong `dbt/seeds/`, schema `dwh` |

Thư mục: `dbt/models/dwh/dim/`, `dbt/models/dwh/fact/`, `dbt/models/dwh/intermediate/`. Mỗi thư mục có một file `_<thư mục>__models.yml` chứa mô tả và test. Cả ba cùng nằm trong schema `dwh`. Khi một thư mục quá đông thì chia tiếp theo domain bên trong (ví dụ `fact/timesheet/`).

Tên cột trong dwh:

| Loại cột | Quy tắc | Ví dụ |
|---|---|---|
| Khóa | `<thực thể>_id` (đổi tên khóa lộn xộn của nguồn: `ide`, `idjt`, `idf`) | `employee_id`, `job_title_id`, `office_id` |
| Mã, tên | `<thực thể>_code`, `<thực thể>_name` | `department_code`, `phase_name` |
| Cờ đúng/sai | Bắt đầu bằng `is_` hoặc `has_` | `is_productive`, `has_employee` |
| Ngày | Kết thúc bằng `_date`; ngày bắt đầu/kết thúc hợp đồng dùng `_from`, `_to` | `entry_date`, `contract_from` |
| Khóa tháng và ngày | `month_key` (YYYYMM, số nguyên), `date_key` (YYYYMMDD) | `202610` |
| Số đo | Danh từ số nhiều hoặc tên đại lượng | `hours`, `head_count`, `leavers` |
| Dấu vết nạp | `last_modified`, `etl_loaded_at` | |

Tất cả `snake_case`, viết thường, không dấu cách, không viết hoa.

## 5. Model mart
- Mẫu: **`mart_<domain>_<thực thể>`**. Ví dụ `mart_ts_details`. Domain viết tắt: `ts` là Timesheet, `hr` là nhân sự.
- Mỗi mart phục vụ một báo cáo hoặc một bảng trong mô hình báo cáo. Chỉ mart được phép mang logic riêng của báo cáo.
- Power BI đọc thẳng mart (cột `snake_case`), không có lớp view `reporting` giữ tên cũ (xem [DECISIONS.vi.md](DECISIONS.vi.md)).
- Dữ liệu cá nhân: bản đầy đủ là `mart_<domain>_<thực thể>_pii` trong schema `mart_restricted`; bản `mart_<domain>_<thực thể>` trong `mart` là view đã che dựng từ bản đó.

## 6. Test và tài liệu model
- Mỗi model có mô tả (`description`) trong file `_<...>__models.yml` hoặc `_dwh__models.yml`.
- Khóa của model có `unique` và `not_null`.
- Test phụ thuộc dữ liệu thật (khóa ngoại, giá trị hợp lệ, số không âm) đặt mức `severity: warn`. Test cấu trúc (khóa, kiểu) để mặc định (lỗi).
- Biến dbt viết `snake_case`, có chú thích trong `dbt_project.yml` (ví dụ `timesheet_from_date`).

## 7. Git
- Nhánh: `feature/<tên-ngắn>`.
- Commit: tiếng Anh, mệnh lệnh, ngắn gọn (`Add dwh layer for Timesheet`). Mỗi commit một ý logic.
- Commit sau mỗi lần code xong một phần. **Không tự push**, người phụ trách tự push.
- Không commit `reference/`, secret, `target/`, `logs/`, `dbt_packages/`, `report/`.
