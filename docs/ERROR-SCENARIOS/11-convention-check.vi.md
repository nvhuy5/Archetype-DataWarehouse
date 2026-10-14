# 11. Vi phạm quy ước (`check_conventions.py`)

> Tình huống giả định. Bạn thêm model mới, `run_local.sh` xanh, nhưng khi chạy script kiểm tra quy ước thì nó báo lỗi. Đây không phải lỗi dữ liệu mà là lỗi **cách đặt tên, mô tả, test**, theo `docs/NAMING.vi.md`.

## Lệnh kiểm tra
```bash
docker compose build dbt          # để image có code mới nhất
docker compose run --rm --no-deps -T -v "$PWD/scripts:/scripts:ro" -v "$PWD/warehouse/local/seed:/seed:ro" --entrypoint sh dbt \
  -c "dbt parse >/dev/null && python /scripts/check_conventions.py target/manifest.json /seed"
```
Đạt khi in `OK: conventions respected` (mã thoát 0). Có lỗi thì mỗi dòng là một vi phạm, mã thoát 1.

## 11a. Model sai tên, thiếu mô tả, thiếu test khóa, dùng `select *`

**Tạo lỗi**: tạo `dbt/models/dwh/dim/employee_summary.sql`:
```sql
select * from {{ ref('dim_employee') }}
```
**Thông báo**
```
employee_summary: missing description
employee_summary: model in dwh/dim must start with dim_
employee_summary: no key test (unique/not_null) and the description does not say 'No primary key'
employee_summary: no not_empty test (an empty model must not pass silently)
employee_summary: uses select *; list the columns
```
**Sửa**: từng dòng một:
| Thông báo | Cách sửa |
|---|---|
| `missing description` | thêm `description:` cho model trong `_dim__models.yml` |
| `model in dwh/dim must start with dim_` | đổi tên file (và mọi `ref()` tới nó) thành `dim_employee_summary.sql`, hoặc đặt vào thư mục đúng loại |
| `no key test` | thêm `tests: [unique, not_null]` trên cột khóa; bảng thật sự không có khóa thì ghi "No primary key" trong mô tả |
| `no not_empty test` | thêm `tests: [not_empty]` ở **mức model** trong yml (bắt buộc cho mọi `dim_*`, `fact_*`, `mart_*`); xem [12](12-empty-model.vi.md) |
| `uses select *` | liệt kê cột; `select *` làm cột nguồn đổi mà không ai biết |

**Trả lại**: `rm dbt/models/dwh/dim/employee_summary.sql`

## 11b. Model `_pii` đặt nhầm thư mục

**Tạo lỗi**: tạo `dbt/models/mart/mart_hr_salary_pii.sql`:
```sql
select employee_id from {{ ref('dim_employee') }}
```
**Thông báo**
```
mart_hr_salary_pii: mart model must start with mart_ and must not end with _pii (those go in mart_restricted)
mart_hr_salary_pii: missing description
mart_hr_salary_pii: no key test (unique/not_null) and the description does not say 'No primary key'
mart_hr_salary_pii: no not_empty test (an empty model must not pass silently)
```
**Sửa**: bảng chứa dữ liệu cá nhân **chưa che** (`*_pii`) phải nằm ở `dbt/models/mart_restricted/`; bản đã che là view ở `mart`. Đặt sai thư mục sẽ làm Power BI (`powerbi_ro`) đọc được dữ liệu cá nhân, vì quyền gắn theo **thư mục** (xem `docs/DECISIONS.vi.md`, `docs/PLAYBOOK.vi.md` Bước 5).

**Trả lại**: `rm dbt/models/mart/mart_hr_salary_pii.sql`

## 11c. Source thiếu `not_empty`, thiếu hoặc thừa file seed

**Tạo lỗi**
```bash
# 1) xóa test not_empty của một source trong dbt/models/staging/intranet/hr/_hr__sources.yml (bảng hr_menu_country)
# 2) bỏ một file seed
mv warehouse/local/seed/raw_intranet/crm_segment.sql /tmp/crm_segment.bak
# 3) thêm một file seed không có source
touch warehouse/local/seed/raw_intranet/hr_typo_table.sql
```
**Thông báo**
```
/seed/raw_intranet/hr_typo_table.sql: seed file without a source declared in dbt
raw_intranet.crm_segment: source has no seed file /seed/raw_intranet/crm_segment.sql
raw_intranet.hr_menu_country: source has no not_empty test
```
**Sửa**
| Thông báo | Cách sửa |
|---|---|
| `source has no not_empty test` | thêm `tests: [not_empty]` cho bảng trong `_<domain>__sources.yml` (cho phép `severity: warn` kèm lý do, xem [01](01-raw-table-empty.vi.md)) |
| `source has no seed file` | tạo `warehouse/local/seed/raw_intranet/<bảng>.sql` |
| `seed file without a source` | xóa file seed thừa, hoặc khai báo source còn thiếu (thường do gõ sai tên file) |

**Trả lại**
```bash
git checkout dbt/models/staging/intranet/hr/_hr__sources.yml
mv /tmp/crm_segment.bak warehouse/local/seed/raw_intranet/crm_segment.sql
rm warehouse/local/seed/raw_intranet/hr_typo_table.sql
```

## Kiểm tra lại
Chạy lại lệnh kiểm tra: `OK: conventions respected`.

## Phòng tránh
Chạy script này (và `python3 scripts/check_repo.py`) **trước khi commit**; đây là hai bước cuối trong quy trình `docs/TEST-LOCAL.vi.md`.
