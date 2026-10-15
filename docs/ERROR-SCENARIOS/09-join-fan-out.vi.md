# 09. Join làm nhân đôi dòng (fan-out)

> Tình huống giả định. `dim_office` có một CTE gom nhóm bảng e-project theo văn phòng. Bạn thấy nó "rườm rà" nên bỏ CTE, join thẳng bảng `stg_intranet__prm_e_project_country`. Build vẫn xanh trên dữ liệu mẫu. Một thời gian sau, dữ liệu thật có văn phòng với **hai** dòng e-project, và dim văn phòng xuất hiện hai dòng cho cùng một văn phòng.

## Cách tạo ra lỗi
Sửa `dbt/models/dwh/dim/dim_office.sql` (bỏ CTE `eproject`, join thẳng):
```diff
-left join eproject e on e.office_id = o.idf
+left join {{ ref('stg_intranet__prm_e_project_country') }} e on e.office_id = o.idf
...
-    e.eproject_office_name,
+    e.office_name                        as eproject_office_name,
```

**Bước 1: dữ liệu mẫu mỗi văn phòng một dòng e-project**
```bash
./scripts/run_local.sh --select "--select +dim_office"
```
```
[3/4] dbt build                   OK  PASS=26 WARN=0 ERROR=0 SKIP=0  (23s)
```
Xanh. Model sai nhưng dữ liệu mẫu quan hệ 1-1 **che mất lỗi**.

**Bước 2: thêm một dòng e-project thứ hai cho văn phòng 1** (giống dữ liệu thật)
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh \
  -c "insert into raw_intranet.prm_e_project_country select * from raw_intranet.prm_e_project_country where prm_e_project_country_id = 1"
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh \
  -c "update raw_intranet.prm_e_project_country set prm_e_project_country_id = 99 where prm_e_project_country_id = 1 and ctid = (select max(ctid) from raw_intranet.prm_e_project_country where prm_e_project_country_id = 1)"
```
Cách này giữ khóa `prm_e_project_country_id` của staging **duy nhất** (1 và 99) nên test của staging vẫn qua; chỉ `office_id` bị lặp, đúng như thực tế.

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +dim_office"
```

## Thông báo lỗi
```
[3/4] dbt build                   FAILED  PASS=25 WARN=0 ERROR=1 SKIP=0  (24s)
      ! 24 of 24 FAIL 1 unique_dim_office_office_id .................................... [FAIL 1 in 0.03s]
```
Trong log:
```
Failure in test unique_dim_office_office_id (models/dwh/dim/_dim__models.yml)
  Got 1 result, configured to fail if != 0
```

## Đọc thông báo và nguyên nhân
- `unique_dim_office_office_id` fail ở **dwh** (`dim_office`), trong khi test `unique` của staging đều qua. Nghĩa là dòng trùng sinh ra **do phép join**, không phải từ nguồn.
- Phân biệt với [02](02-duplicate-key.vi.md): ở đó test fail ở **staging** (dữ liệu nguồn trùng); ở đây staging sạch nhưng dim bị trùng.
- Lưu ý: dbt tạo bảng `dim_office` **trước** rồi mới chạy test, nên bảng này đã được ghi (có dòng trùng). Các model phía sau bị `SKIP`; bản thân bảng dim thì phải dựng lại sau khi sửa.

Tìm văn phòng bị nhân đôi:
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "
  select office_id, count(*) from (
    select o.idf as office_id
    from staging.stg_intranet__hr_menu_offices o
    join staging.stg_intranet__prm_e_project_country e on e.office_id = o.idf) t
  group by 1 having count(*) > 1"
```
```
 office_id | count 
-----------+-------
         1 |     2
(1 row)
```

## Cách sửa
Gom bảng "nhiều" về một dòng cho mỗi khóa **trước khi join** (đúng như CTE `eproject` ban đầu, `min(office_name)` theo `office_id`). Khôi phục bản gốc:
```bash
git checkout dbt/models/dwh/dim/dim_office.sql
```

## Kiểm tra lại
Giữ nguyên dòng e-project thứ hai (dữ liệu "khó"):
```bash
./scripts/run_local.sh --select "--select +dim_office"
```
```
[3/4] dbt build                   OK  PASS=26 WARN=0 ERROR=0 SKIP=0  (24s)
```
Xanh **dù có dòng thứ hai**, nghĩa là model đã đúng.

## Trả lại như cũ
```bash
./scripts/seed_local.sh
```

## Phòng tránh
- Test `unique` trên khóa của mọi `dim_*` là thứ bắt được lỗi này; đừng bỏ test.
- **Dữ liệu mẫu quan hệ 1-1 che lỗi fan-out.** Khi viết model có join, thêm vào file seed những dòng "khó" (một văn phòng nhiều e-project, một nhân viên nhiều hợp đồng...) để lỗi hiện ở local. Xem [12](12-empty-model.vi.md) cho cách chỉnh dòng seed.
