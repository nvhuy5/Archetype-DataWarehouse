# 04. Thiếu bảng raw

Có hai biến thể: thiếu bảng ở **local** (script chặn trước khi chạy dbt) và source đã khai báo nhưng bảng **chưa được tạo** (dbt báo lỗi).

## 4a. Thiếu một bảng trong `raw_intranet` ở local

> Tình huống giả định. Ai đó xóa nhầm bảng `hr_menu_country` trong database local.

**Tạo lỗi**
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "drop table raw_intranet.hr_menu_country cascade"
```
```
NOTICE:  drop cascades to view staging.stg_intranet__hr_menu_country
```

**Phát hiện**
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```

**Thông báo**
```
[1/4] Build images                OK  (1s)
[2/4] Raw data (seeded)           FAILED  raw_intranet has 60 of 61 tables. Run ./scripts/seed_local.sh first
```
Script dừng ngay ở bước 2, dbt **chưa chạy**.

**Sửa**
```bash
./scripts/seed_local.sh      # tạo lại bảng còn thiếu
./scripts/run_local.sh       # dbt dựng lại view staging bị xóa theo (drop ... cascade)
```
Chú ý: `drop ... cascade` xóa luôn view staging phụ thuộc, nên chạy dbt một lần để dựng lại.

## 4b. Source đã khai báo nhưng ingestion chưa tạo bảng

> Tình huống giả định. Báo cáo mới cần bảng `hr_new_table`. Bạn khai báo source và viết model staging, nhưng project ingestion chưa nạp bảng này vào `raw_intranet`.

**Tạo lỗi**: thêm vào cuối `dbt/models/staging/intranet/hr/_hr__sources.yml`:
```yaml
      - name: hr_new_table
        description: "New table asked by a report."
        tests:
          - not_empty
```
và tạo `dbt/models/staging/intranet/hr/stg_intranet__hr_new_table.sql`:
```sql
select id, nullif(btrim(name), '') as name
from {{ source('raw_intranet', 'hr_new_table') }}
```

**Phát hiện**
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_new_table"
```

**Thông báo**
```
[3/4] dbt build                   FAILED  PASS=2 WARN=0 ERROR=1 SKIP=1  (24s)
      ! 1 of 2 ERROR source_not_empty_raw_intranet_hr_new_table_ ....................... [ERROR in 0.06s]
08:34:42    Database Error in test source_not_empty_raw_intranet_hr_new_table_ (models/staging/intranet/hr/_hr__sources.yml)
  relation "raw_intranet.hr_new_table" does not exist
  LINE 13: where not exists (select 1 from "archetype_dwh"."raw_intranet...
```

**Đọc thông báo**
- `ERROR` (không phải `FAIL`): câu SQL của test không chạy được, vì bảng không tồn tại.
- `SKIP=1`: view `stg_intranet__hr_new_table` bị bỏ qua.
- Ở bước 2 script **không** báo thiếu, vì script chỉ so số bảng với số file seed (61 và 61) chứ không biết bạn vừa thêm source mới.
- `scripts/check_conventions.py` báo thêm (xem [11](11-convention-check.vi.md)):
  ```
  raw_intranet.hr_new_table: source has no seed file /seed/raw_intranet/hr_new_table.sql
  stg_intranet__hr_new_table: missing description
  stg_intranet__hr_new_table: no key test (unique/not_null) and the description does not say 'No primary key'
  ```
  Dòng đầu là chuyện của ca này; hai dòng sau do model mới chưa có mô tả và test trong `_hr__models.yml`.

**Sửa**
- Môi trường thật: yêu cầu project ingestion tạo và nạp `raw_intranet.hr_new_table` (đúng tên và cột như nguồn).
- Local: tạo file `warehouse/local/seed/raw_intranet/hr_new_table.sql` (`CREATE TABLE IF NOT EXISTS` + `TRUNCATE` + `INSERT`, lấy một file seed khác làm khuôn), rồi `./scripts/seed_local.sh`.

**Kiểm tra lại**: chạy lại lệnh ở trên, không còn `ERROR`.

**Trả lại như cũ**
```bash
git checkout dbt/models/staging/intranet/hr/_hr__sources.yml
rm dbt/models/staging/intranet/hr/stg_intranet__hr_new_table.sql
```

## Phòng tránh
- `check_conventions.py` kiểm tra mỗi source có đúng một file seed, và không có file seed thiếu source.
- Quy trình thêm bảng raw mới nằm ở `docs/PLAYBOOK.vi.md` (Bước 3).
