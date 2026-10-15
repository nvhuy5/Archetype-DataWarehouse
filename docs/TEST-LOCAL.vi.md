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
[3/4] dbt build                   OK  PASS=434 WARN=0 ERROR=0 SKIP=0  (59s)
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
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh -c "select * from dwh.dim_phase limit 5"
```
Các schema: `raw_intranet` (bảng nguồn mẫu), `staging`, `dwh`, `mart`, `mart_restricted`, `elementary`. Mở `report/elementary_report.html` bằng trình duyệt để xem kết quả test; cách đọc từng phần của báo cáo: [ELEMENTARY-REPORT.vi.md](ELEMENTARY-REPORT.vi.md).

### Xem câu SQL mà dbt gửi cho Postgres
File model viết bằng Jinja (`ref`, `source`, macro), nên SQL thật khác với file trong repo. Muốn xem SQL thật (đã thay `ref`/`source` bằng tên bảng) thì dùng:
```bash
./scripts/compile_local.sh dim_phase    # in SQL của một model ra màn hình, đồng thời lưu file
./scripts/compile_local.sh +dim_phase   # model đó và mọi model nó đọc từ (selector của dbt)
./scripts/compile_local.sh              # tất cả model
```
- File lưu ở `report/compiled/compiled/archetype/models/<layer>/...` (một file một model), mở bằng editor được. Mỗi lần chạy xóa kết quả lần trước. `report/` không được commit.
- Chỉ biên dịch, **không ghi gì vào database**. Cần `postgres-local` đang chạy (script tự bật).
- SQL này chưa bọc `create table/view`; dùng để soi lỗi SQL (xem [07](ERROR-SCENARIOS/07-sql-error-in-model.vi.md)), kiểm tra join, hoặc dán vào `psql` chạy thử.
- Chỉ muốn xem vài dòng kết quả mà không tạo bảng: `docker compose run --rm --no-deps -T --entrypoint dbt dbt show --select dim_phase --limit 5`.

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
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d archetype_dwh -c "select count(*) from mart.mart_ts_employees"   # đọc được
docker compose exec -T -e PGPASSWORD=powerbi_ro postgres-local psql -h localhost -U powerbi_ro -d archetype_dwh -c "select count(*) from dwh.dim_employee"        # permission denied
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
Mỗi lỗi có một file hướng dẫn riêng trong [ERROR-SCENARIOS/](ERROR-SCENARIOS/README.vi.md): tình huống giả định, lệnh tạo lỗi, thông báo thật, nguyên nhân, cách sửa và cách trả lại như cũ. Mục lục có bảng tra nhanh theo thông báo lỗi.

| Muốn thử | File |
|---|---|
| bảng raw rỗng, trùng khóa, khóa NULL, thiếu bảng, nguồn bỏ cột, tham chiếu mồ côi | [01](ERROR-SCENARIOS/01-raw-table-empty.vi.md) đến [06](ERROR-SCENARIOS/06-orphan-reference-warning.vi.md) |
| lỗi SQL, Compilation Error, join nhân đôi dòng, `schema_changes` | [07](ERROR-SCENARIOS/07-sql-error-in-model.vi.md) đến [10](ERROR-SCENARIOS/10-schema-changes.vi.md) |
| vi phạm quy ước, model dwh/mart rỗng | [11](ERROR-SCENARIOS/11-convention-check.vi.md), [12](ERROR-SCENARIOS/12-empty-model.vi.md) |
| quyền, kết nối, seed, thư mục `report/` | [13](ERROR-SCENARIOS/13-permission-denied.vi.md) đến [17](ERROR-SCENARIOS/17-report-folder-not-writable.vi.md) |

## Lỗi thường gặp
| Hiện tượng | Nguyên nhân và cách xử lý |
|---|---|
| `report/logs/...: Permission denied` (kèm `Build images FAILED` và log cũ gây hiểu nhầm) | Thư mục `report/logs/` thuộc root từ lần chạy cũ: `docker run --rm -v "$PWD":/w busybox rm -rf /w/report`. Chi tiết: [17](ERROR-SCENARIOS/17-report-folder-not-writable.vi.md) |
| Kiểm tra quy ước báo đường dẫn cũ hoặc thiếu model mới | Image chưa build lại: `docker compose build dbt` |
| `relation "..." does not exist` khi dùng `--select` | Thiếu dấu `+` trước tên model (chưa build upstream), hoặc DB vừa bị `seed_local.sh --reset` (chưa seed lại) |
| Test `relationships` báo `ERROR` khi chỉ build một phần | Bình thường: các dim khác chưa được build trong lần chạy đó |
| `raw_intranet has N of 61 tables. Run ./scripts/seed_local.sh first` | Chưa seed, hoặc database vừa bị xóa: chạy `./scripts/seed_local.sh` |
| Cảnh báo `Seed files changed since the last seed` | Vừa sửa file seed mà chưa seed lại: chạy `./scripts/seed_local.sh` |
| Sau khi sửa file seed mà dữ liệu vẫn như cũ | Chưa chạy `./scripts/seed_local.sh` |
| `seed_local.sh` báo `FAILED: ... (columns changed in an existing table?)` | Bạn đã đổi cột của bảng đã tồn tại (bảng chỉ được tạo một lần): chạy `./scripts/seed_local.sh --reset` |
