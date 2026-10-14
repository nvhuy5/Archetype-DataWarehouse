# Làm xong và test dưới local

Quy trình sau mỗi lần code xong một phần (model, test, sửa loader...). Chỉ cần **Docker**; không cần MySQL thật hay Azure.

```
Sửa code → ./scripts/run_local.sh → Xem tóm tắt và báo cáo → Kiểm tra quy ước → Commit local
```

## 1. Chạy cả chuỗi
```bash
./scripts/run_local.sh
```
Script chạy lần lượt 4 bước và chỉ in tóm tắt; log chi tiết ghi vào `report/logs/`:
```
[1/4] Build images                OK  (2s)
[2/4] Raw data (sample)           OK  0 tables loaded, 61 kept  (2s)
[3/4] dbt build                   OK  PASS=322 WARN=0 ERROR=0 SKIP=0  (55s)
[4/4] Elementary report           OK  report/elementary_report.html  (38s)
---
Done in 96s. Details: report/logs/
```
- **Đang chạy:** mỗi bước hiện spinner và số giây đã trôi qua. Bước dbt có thanh tiến độ (số model và test đã chạy, ví dụ `models + tests ████░░░░ 164/320`). Các bước còn lại hiện thời gian của lần chạy trước để ước tính (ví dụ `usually ~37s`). Nhấn `Ctrl+C` để dừng. Khi chạy không có terminal (ví dụ ghi ra file) thì chỉ in dòng kết quả cuối mỗi bước.
- **Đạt khi:** cả 4 bước `OK`, script thoát mã 0, `ERROR=0` và `WARN=0` trên dữ liệu mẫu. Nếu có `WARN`, script liệt kê từng test bị cảnh báo ngay dưới dòng dbt: xem lại model hoặc dữ liệu mẫu (`OVERRIDES`) chứ đừng bỏ qua.
- **Có lỗi:** bước đó hiện `FAILED`, in dòng lỗi (tên model, nội dung lỗi). Xem thêm trong `report/logs/3-dbt.log`. Báo cáo Elementary vẫn được tạo để bạn mở ra xem test nào hỏng.
- Mỗi lần chạy, `dbt build` luôn chạy cả `dbt run --select elementary` trước (tạo bảng Elementary), rồi mới đến model và test.

Các tùy chọn:
| Lệnh | Tác dụng |
|---|---|
| `./scripts/run_local.sh --reset` | Xóa sạch database (`docker compose down -v`) rồi chạy lại từ đầu |
| `./scripts/run_local.sh --reset-data` | Tạo lại toàn bộ dữ liệu mẫu (dùng sau khi sửa giá trị mẫu `OVERRIDES` trong `ingest/load_raw.py`) |
| `./scripts/run_local.sh --select "--select +fact_timesheet"` | Chỉ build một phần (tham số của `dbt build`); báo cáo Elementary vẫn luôn được tạo |
| `./scripts/run_local.sh --mysql` | Nạp từ MySQL Intranet thật (xem mục 5) |

## 2. Dữ liệu mẫu được giữ lại
- Database nằm trong một volume Docker, **sống qua các lần chạy** (chỉ mất khi `--reset` hoặc `docker compose down -v`).
- Loader chế độ `sample` chỉ tạo những dòng còn thiếu: bảng nào đã đủ dòng thì bỏ qua (`kept`), bảng nào trống hoặc thiếu mới được tạo thêm.
- Thêm bảng raw mới vào `warehouse/init/02_raw_intranet.sql` thì lần chạy sau tự tạo bảng đó (câu lệnh `CREATE TABLE IF NOT EXISTS`), không cần reset. Nhưng nếu **đổi cột** của bảng đã có thì phải `--reset`.
- Sửa cách sinh giá trị mẫu (`OVERRIDES`) thì dùng `--reset-data` để các dòng cũ được tạo lại theo quy tắc mới.

## 3. Xem dữ liệu đã tạo
```bash
docker compose exec -T pg-analytics psql -U postgres -d analytics_db -c "select * from dwh.dim_phase limit 5"
```
Các schema: `raw_intranet` (bảng nguồn), `staging`, `dwh`, `mart`, `elementary`. Mở `report/elementary_report.html` bằng trình duyệt để xem kết quả test.

## 4. Kiểm tra quy ước và repo
```bash
docker compose build dbt          # để image có code mới nhất (run_local.sh đã làm sẵn ở bước 1)
docker compose run --rm --no-deps -T -v "$PWD/scripts:/scripts:ro" --entrypoint sh dbt \
  -c "dbt parse >/dev/null && python /scripts/check_conventions.py target/manifest.json"
python3 scripts/check_repo.py
```
- `check_conventions.py`: tên model đúng layer, có mô tả, có test khóa (hoặc ghi rõ "No primary key"), không dùng `select *`.
- `check_repo.py`: không có `reference/`, `.pem`, `.env` hay khóa riêng trong git.

**Đạt khi:** cả hai in ra `OK`.

### Kiểm tra quyền mart
Sau `--reset` (script init chỉ chạy khi database trống), `powerbi_ro` phải đọc được `mart` và bị chặn ở `dwh` và `mart_restricted`:
```bash
docker compose exec -T -e PGPASSWORD=powerbi_ro pg-analytics psql -h localhost -U powerbi_ro -d analytics_db -c "select count(*) from mart.mart_ts_employees"   # đọc được
docker compose exec -T -e PGPASSWORD=powerbi_ro pg-analytics psql -h localhost -U powerbi_ro -d analytics_db -c "select count(*) from dwh.dim_employee"        # permission denied
```

Sau cùng commit **local** (tiếng Anh, ngắn gọn, mỗi commit một ý). Không tự push (xem `CLAUDE.md`).

## 5. Chạy với dữ liệu Intranet thật (chỉ đọc)
Cần mạng tới MySQL và một tài khoản chỉ đọc:
```bash
INGEST_MODE=mysql MYSQL_HOST=<host> MYSQL_USER=<user> MYSQL_PASSWORD=<pwd> MYSQL_DATABASE=archetype_intranet \
  ./scripts/run_local.sh --mysql
```
Chế độ này thay từng bảng raw trong một transaction (khác chế độ mẫu, nó nạp lại nguồn thật mỗi lần); bảng nguồn rỗng bị từ chối (cho phép bằng `ALLOW_EMPTY=bảng1,bảng2`). Ngày `0000-00-00` được đổi thành `NULL`. Nên dùng `--reset` trước khi chuyển từ dữ liệu mẫu sang dữ liệu thật để các bảng không lẫn dữ liệu mẫu. Chế độ này **chưa được chạy với MySQL thật**.

## 6. Tốc độ
- Build image khi chỉ sửa code: khoảng 1 giây (các layer cài đặt được cache; xem comment trong `dbt.Dockerfile`). Chỉ khi đổi `dbt/requirements.txt` hoặc `dbt/packages.yml` mới cài lại và cần internet.
- Chạy cả chuỗi: khoảng 1,5 phút. Phần lớn là `dbt build` (khoảng 55 giây, trong đó Elementary tốn khoảng 20 giây) và báo cáo Elementary (khoảng 38 giây).

## Lỗi thường gặp
| Hiện tượng | Nguyên nhân và cách xử lý |
|---|---|
| `report/ is not writable` | Thư mục `report/` thuộc root từ lần chạy cũ: `docker run --rm -v "$PWD":/w busybox rm -rf /w/report` |
| Kiểm tra quy ước báo đường dẫn cũ hoặc thiếu model mới | Image chưa build lại: `docker compose build dbt` |
| `relation "..." does not exist` khi dùng `--select` | Thiếu dấu `+` trước tên model (chưa build upstream), hoặc DB vừa bị `--reset` |
| Test `relationships` báo `ERROR` khi chỉ build một phần | Bình thường: các dim khác chưa được build trong lần chạy đó |
| Bảng raw không có cột mới sau khi sửa `02_raw_intranet.sql` | Đổi cột của bảng đã tồn tại thì cần `--reset` |
| Sau khi sửa giá trị mẫu mà dữ liệu vẫn như cũ | Dùng `--reset-data` |
