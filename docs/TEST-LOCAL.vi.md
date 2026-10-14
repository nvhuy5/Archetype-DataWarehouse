# Làm xong và test dưới local

Quy trình sau mỗi lần code xong một phần (model, test, dòng mẫu...). Chỉ cần **Docker**; không cần MySQL thật hay Azure.

dbt chỉ **đọc** `raw_intranet`; ở môi trường thật bảng raw do project ingestion (ADF) nạp, không thuộc repo này. Ở local, `postgres-local` giữ các bảng raw mẫu, và việc tạo chúng tách riêng khỏi việc chạy dbt để mỗi lần test không phải dựng lại raw:

```
Sửa seed → ./scripts/seed_local.sh ─┐
Sửa model/test ─────────────────────┴→ ./scripts/run_local.sh → Xem tóm tắt và báo cáo → Kiểm tra quy ước → Commit local
```

## 1. Dựng dữ liệu raw (khi cần)
```bash
./scripts/seed_local.sh
```
Chạy **lần đầu**, và **mỗi khi thêm hoặc sửa file seed**. Mỗi bảng raw là một file `warehouse/local/seed/raw_intranet/<bảng>.sql`: `CREATE TABLE IF NOT EXISTS` (đúng tên và cột của nguồn) + `TRUNCATE` + vài dòng mẫu, trong một transaction. Giống cách ingestion ở prod, bảng chỉ được tạo một lần còn dòng thì được thay, nên view staging của dbt không bị đụng tới và seed chạy lại được bất cứ lúc nào. Script áp cả 61 file (khoảng 7 giây) và ghi lại dấu (hash của thư mục seed và ngày seed).

| Lệnh | Tác dụng |
|---|---|
| `./scripts/seed_local.sh` | Tạo bảng raw nếu chưa có và thay dòng của mọi bảng theo file seed; schema, role, quyền (`warehouse/local/init`) đã có từ lần đầu |
| `./scripts/seed_local.sh --reset` | Xóa sạch database local (`docker compose down -v`), tạo lại schema, role rồi seed |

- Database nằm trong volume Docker `postgres_local_data`, **sống qua các lần chạy** và qua `docker compose down`; chỉ mất khi `--reset` hoặc `docker compose down -v`.
- Script `warehouse/local/init` chỉ chạy khi database trống. Đổi schema hoặc role ở đó thì dùng `--reset`.
- **Thêm model mới** thì bổ sung dòng mẫu tương ứng: bảng raw mới cần file seed mới; model cần giá trị khác (join, trường hợp biên) thì sửa dòng trong file seed của bảng nó đọc. Rồi chạy lại `seed_local.sh`.
- Cột ngày mà model so với ngày hiện tại (tuổi, thâm niên, hợp đồng còn hiệu lực, timesheet gần đây) được viết tương đối trong file seed (`current_date - 30`), nên đúng vào lúc seed. Seed lâu ngày thì chạy lại.

## 2. Chạy dbt và báo cáo
```bash
./scripts/run_local.sh
```
Script chạy lần lượt 4 bước và chỉ in tóm tắt; log chi tiết ghi vào `report/logs/`:
```
[1/4] Build images                OK  (2s)
[2/4] Raw data (seeded)           OK  61 tables
[3/4] dbt build                   OK  PASS=356 WARN=0 ERROR=0 SKIP=0  (59s)
[4/4] Elementary report           OK  report/elementary_report.html  (41s)
---
Done in 102s. Details: report/logs/
```
- **Bước 2 chỉ kiểm tra**, không dựng raw: bật `postgres-local` nếu đang tắt, rồi đếm bảng trong `raw_intranet`. Thiếu bảng thì dừng và báo "Run ./scripts/seed_local.sh first". Nếu file seed đã đổi từ lần seed cuối (hash khác), hoặc lần seed cuối quá 7 ngày, script in cảnh báo `!` nhưng vẫn chạy tiếp (dbt khi đó chạy trên dòng cũ).
- **Đang chạy:** mỗi bước hiện spinner và số giây đã trôi qua. Bước dbt có thanh tiến độ (số model và test đã chạy, ví dụ `models + tests ████░░░░ 164/320`). Các bước còn lại hiện thời gian của lần chạy trước để ước tính. Nhấn `Ctrl+C` để dừng. Khi chạy không có terminal (ví dụ ghi ra file) thì chỉ in dòng kết quả cuối mỗi bước.
- **Đạt khi:** cả 4 bước `OK`, script thoát mã 0, `ERROR=0` và `WARN=0` trên dữ liệu mẫu. Nếu có `WARN`, script liệt kê từng test bị cảnh báo ngay dưới dòng dbt: xem lại model hoặc dòng mẫu trong file seed chứ đừng bỏ qua.
- **Có lỗi:** bước đó hiện `FAILED`, in dòng lỗi (tên model, nội dung lỗi). Xem thêm trong `report/logs/3-dbt.log`. Báo cáo Elementary vẫn được tạo để bạn mở ra xem test nào hỏng.
- Mỗi lần chạy, `dbt build` luôn chạy cả `dbt run --select elementary` trước (tạo bảng Elementary), rồi mới đến model và test.

Tùy chọn:
| Lệnh | Tác dụng |
|---|---|
| `./scripts/run_local.sh --select "--select +fact_timesheet"` | Chỉ build một phần (tham số của `dbt build`); báo cáo Elementary vẫn luôn được tạo |

## 3. Xem dữ liệu đã tạo
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "select * from dwh.dim_phase limit 5"
```
Các schema: `raw_intranet` (bảng nguồn mẫu), `staging`, `dwh`, `mart`, `mart_restricted`, `elementary`. Mở `report/elementary_report.html` bằng trình duyệt để xem kết quả test.

## 4. Kiểm tra quy ước và repo
```bash
docker compose build dbt          # để image có code mới nhất (run_local.sh đã làm sẵn ở bước 1)
docker compose run --rm --no-deps -T -v "$PWD/scripts:/scripts:ro" -v "$PWD/warehouse/local/seed:/seed:ro" --entrypoint sh dbt \
  -c "dbt parse >/dev/null && python /scripts/check_conventions.py target/manifest.json /seed"
python3 scripts/check_repo.py
```
- `check_conventions.py`: tên model đúng layer, có mô tả, có test khóa (hoặc ghi rõ "No primary key"), không dùng `select *`.
  Khi có tham số seed (`/seed`) còn kiểm tra: mỗi bảng nguồn (source) khai báo trong dbt có đúng một file `warehouse/local/seed/<schema>/<bảng>.sql`, và không có file seed nào thiếu source.
- `check_repo.py`: không có `reference/`, `.pem`, `.env` hay khóa riêng trong git.

**Đạt khi:** cả hai in ra `OK`.

### Kiểm tra quyền mart
Sau `./scripts/seed_local.sh --reset` (script init chỉ chạy khi database trống), `powerbi_ro` phải đọc được `mart` và bị chặn ở `dwh` và `mart_restricted`:
```bash
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d analytics_db -c "select count(*) from mart.mart_ts_employees"   # đọc được
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d analytics_db -c "select count(*) from dwh.dim_employee"        # permission denied
```

### Kiểm tra SQL của prod
Sửa `warehouse/prod/` hoặc quyền/role của dự án dbt thì chạy:
```bash
./scripts/check_prod_sql.sh
```
Script dựng một Postgres tạm đúng như ở prod (ingestion tạo `raw_intranet`, platform chạy `warehouse/prod` hai lần, đặt mật khẩu, ingestion nạp raw sau cùng), chạy image dbt và Elementary thật trên đó, rồi kiểm tra từng login (`dbt_rw`, `powerbi_ro`, `pii_admin`) đọc được và bị chặn những gì. Mất khoảng 2 phút, không đụng tới database local. **Đạt khi** in `Prod SQL OK` (mã thoát 0). SSL tắt vì server tạm không có, nên cấu hình SSL của target `prod` chưa được kiểm tra ở đây.

Sau cùng commit **local** (tiếng Anh, ngắn gọn, mỗi commit một ý). Không tự push (xem `CLAUDE.md`).

## 5. Tốc độ
- Build image khi chỉ sửa code: khoảng 1 giây (các layer cài đặt được cache; xem comment trong `dbt.Dockerfile`). Chỉ khi đổi `dbt/requirements.txt` hoặc `dbt/packages.yml` mới cài lại và cần internet.
- Seed raw: khoảng 7 giây, chỉ chạy khi sửa file seed.
- Chạy cả chuỗi `run_local.sh`: khoảng 1,5 phút. Phần lớn là `dbt build` (khoảng 55 giây, trong đó Elementary tốn khoảng 20 giây) và báo cáo Elementary (khoảng 38 giây).

## 6. Thử xem lỗi được bắt như thế nào
Mỗi tình huống dưới đây cố ý làm hỏng dữ liệu raw rồi chạy dbt, để bạn thấy lỗi hiện ra ở đâu. Chạy theo thứ tự bất kỳ; **sau mỗi tình huống nhớ chạy `./scripts/seed_local.sh`** để trả raw về như cũ (3 giây). Cần đã chạy `./scripts/run_local.sh` thành công ít nhất một lần.

Gọn lệnh: `psql_local` dưới đây chỉ là tên gọi tắt, bạn có thể dán nguyên lệnh `docker compose exec ...`.
```bash
psql_local() { docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "$1"; }
```

| | Làm hỏng | dbt bắt bằng | Kết quả mong đợi |
|---|---|---|---|
| A | bảng raw rỗng | `not_empty` (test source) | `FAILED`, **model phía sau bị `SKIP`** |
| B | trùng khóa | `unique` | `FAILED`, model phía sau bị `SKIP` |
| C | khóa bị `NULL` | `not_null` | `FAILED` |
| D | tham chiếu tới bản ghi không tồn tại | `relationships` (`severity: warn`) | `OK` nhưng có `WARN`, script thoát mã 0 |
| E | đổi cột của model staging | `elementary.schema_changes` | `FAILED` ở lần chạy đổi, các lần sau xanh |

**A. Bảng raw rỗng** (nguồn nạp ra bảng trống)
```bash
psql_local "truncate raw_intranet.hr_table_main"
./scripts/run_local.sh --select "--select +dim_employee"
```
Mong đợi: bước 3 `FAILED  PASS=65 ... ERROR=1 SKIP=10` và dòng `! ... FAIL 1 source_not_empty_raw_intranet_hr_table_main_`. 10 model phía sau (trong đó `dim_employee`) bị bỏ qua nên không cập nhật mart bằng dữ liệu rỗng. Không có test này thì dbt vẫn xanh trên bảng rỗng.

**B. Trùng khóa**
```bash
psql_local "insert into raw_intranet.hr_table_main select * from raw_intranet.hr_table_main where ide = 1"
./scripts/run_local.sh --select "--select +dim_employee"
```
Mong đợi: `FAILED ... ERROR=1 SKIP=6` và `! ... FAIL 1 unique_stg_intranet__hr_table_main_ide`.

**C. Khóa bị NULL**
```bash
psql_local "update raw_intranet.hr_menu_country set idp = null where idp = 1"
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```
Mong đợi: `FAILED ... ERROR=1` và `! ... FAIL 1 not_null_stg_intranet__hr_menu_country_idp`.

**D. Tham chiếu hỏng (chỉ cảnh báo)**
```bash
psql_local "update raw_intranet.timesheet_entry_2015 set phase_id = 999 where id = 1"
./scripts/run_local.sh --select "--select +fact_timesheet"
```
Mong đợi: bước 3 `OK  PASS=28 WARN=1 ERROR=0` kèm dòng `! ... WARN 1 relationships_fact_timesheet_phase_id__phase_id__ref_dim_phase_`. Test này đặt `severity: warn` nên không chặn chuỗi; đây là cách phân biệt lỗi nặng và lỗi nhẹ.

**E. Đổi cột của model staging** (`schema_changes`)
```bash
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"          # lấy mốc
sed -i 's/^    hr_hide$/    hr_hide,\n    1 as extra_column/' dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"          # FAILED
git checkout dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"          # FAILED lần nữa (cột bị bớt đi)
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"          # xanh trở lại
```
Mong đợi: `FAILED ... ! ... FAIL 1 elementary_schema_changes_stg_intranet__hr_menu_country_`. `schema_changes` so cột với **lần chạy trước**, nên mỗi thay đổi cột báo lỗi đúng một lần rồi lần sau thành mốc mới. Lưu ý: test này canh cột của **model staging**. Cột raw bị xóa mà staging còn dùng thì Postgres báo lỗi ngay (không xóa được vì view đang phụ thuộc), còn cột raw thêm mới không ảnh hưởng vì staging liệt kê cột tường minh.

**Xem chi tiết lỗi**
- Log chi tiết: `report/logs/3-dbt.log` (tìm tên test, có câu SQL và số dòng lỗi).
- Mở `report/elementary_report.html` bằng trình duyệt: báo cáo vẫn được tạo khi có lỗi và liệt kê test nào hỏng.
- Sau khi xem xong: `./scripts/seed_local.sh` rồi `./scripts/run_local.sh`, kết quả phải về `ERROR=0 WARN=0`.

## Lỗi thường gặp
| Hiện tượng | Nguyên nhân và cách xử lý |
|---|---|
| `report/ is not writable` | Thư mục `report/` thuộc root từ lần chạy cũ: `docker run --rm -v "$PWD":/w busybox rm -rf /w/report` |
| Kiểm tra quy ước báo đường dẫn cũ hoặc thiếu model mới | Image chưa build lại: `docker compose build dbt` |
| `relation "..." does not exist` khi dùng `--select` | Thiếu dấu `+` trước tên model (chưa build upstream), hoặc DB vừa bị `seed_local.sh --reset` (chưa seed lại) |
| Test `relationships` báo `ERROR` khi chỉ build một phần | Bình thường: các dim khác chưa được build trong lần chạy đó |
| `raw_intranet has N of 61 tables. Run ./scripts/seed_local.sh first` | Chưa seed, hoặc database vừa bị xóa: chạy `./scripts/seed_local.sh` |
| Cảnh báo `Seed files changed since the last seed` | Vừa sửa file seed mà chưa seed lại: chạy `./scripts/seed_local.sh` |
| Sau khi sửa file seed mà dữ liệu vẫn như cũ | Chưa chạy `./scripts/seed_local.sh` |
| `seed_local.sh` báo `FAILED: ... (columns changed in an existing table?)` | Bạn đã đổi cột của bảng đã tồn tại (bảng chỉ được tạo một lần): chạy `./scripts/seed_local.sh --reset` |
