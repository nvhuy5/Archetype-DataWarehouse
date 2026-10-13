# Làm xong và test dưới local

Quy trình sau mỗi lần code xong một phần (model, test, sửa loader...). Chỉ cần **Docker**; không cần MySQL thật hay Azure.

```
Sửa code → Chạy cả chuỗi → Xem kết quả → Kiểm tra quy ước → Dọn → Commit local
```

## 1. Chạy cả chuỗi (cách chính, luôn đúng)
```bash
docker compose run --build --rm elementary
```
Lệnh này tự làm theo thứ tự: dựng warehouse rỗng → tạo bảng raw (`warehouse/init/`) → nạp dữ liệu mẫu (`ingest/`) → `dbt build` (model và test) → Elementary sinh `report/elementary_report.html`. Mất khoảng 2 đến 3 phút.

`--build` bắt buộc khi bạn đã sửa code, vì image đóng gói code lúc build.

**Đạt khi:** lệnh thoát với mã 0. Muốn xem kết quả dbt:
```bash
docker compose logs dbt | grep -E "Done\.|ERROR|WARN"
```
Kết quả mong đợi: `ERROR=0`. Một số `WARN` đến từ dữ liệu mẫu là bình thường (ví dụ một nhân viên mẫu cố ý để trống `employee_code`).

## 2. Xem dữ liệu đã tạo
Sau bước 1 (khi chưa `down`):
```bash
docker compose exec -T pg-analytics psql -U postgres -d analytics_db \
  -c "select * from dwh.dim_phase limit 5"
```
Các schema: `raw_intranet` (bảng nguồn), `staging`, `dwh`, `mart`, `elementary`. Mở `report/elementary_report.html` bằng trình duyệt để xem kết quả test.

## 3. Kiểm tra quy ước và repo
```bash
docker compose build dbt          # bắt buộc, để image có code mới nhất
docker compose run --rm --no-deps -v "$PWD/scripts:/scripts:ro" --entrypoint sh dbt \
  -c "dbt parse >/dev/null && python /scripts/check_conventions.py target/manifest.json"
python3 scripts/check_repo.py
```
- `check_conventions.py`: tên model đúng layer, có mô tả, có test khóa (hoặc ghi rõ "No primary key"), không dùng `select *`.
- `check_repo.py`: không có `reference/`, `.pem`, `.env` hay khóa riêng trong git.

**Đạt khi:** cả hai in ra `OK`.

## 4. Dọn dẹp
```bash
docker compose down -v
```
Xóa container và dữ liệu của lần chạy. Nếu thư mục `report/` thuộc root và không xóa được: `docker run --rm -v "$PWD":/w busybox rm -rf /w/report`.

## 5. Commit
Mỗi phần code xong là một commit **local**, tiếng Anh, ngắn gọn. Không tự push (xem `CLAUDE.md`).

## Lặp nhanh khi đang sửa một model
Chạy cả chuỗi hơi lâu, nên khi đang sửa có thể giữ DB sống và chỉ chạy phần liên quan:
```bash
docker compose up -d --wait pg-analytics
docker compose run --rm ingest                                   # nạp raw một lần
docker compose run --rm --no-deps --entrypoint sh dbt \
  -c "dbt run --select +fact_timesheet"                          # tạo model và mọi thứ nó cần
docker compose run --rm --no-deps --entrypoint sh dbt \
  -c "dbt test --select fact_timesheet --exclude test_name:relationships"
docker compose down -v
```
- Dấu `+` phía trước tên model nghĩa là kèm mọi model upstream. Bỏ dấu `+` thì model phụ thuộc cái chưa được tạo sẽ lỗi.
- Test `relationships` cần các dim khác đã có, nên loại ra khi chỉ chạy một phần.
- Dùng cách này để lặp nhanh; **trước khi commit luôn chạy lại bước 1** để chắc cả chuỗi vẫn pass.

## Chạy với dữ liệu Intranet thật (chỉ đọc)
Cần mạng tới MySQL và một tài khoản chỉ đọc:
```bash
INGEST_MODE=mysql MYSQL_HOST=<host> MYSQL_USER=<user> MYSQL_PASSWORD=<pwd> MYSQL_DATABASE=archetype_intranet \
  docker compose run --build --rm elementary
```
Mỗi bảng được thay trong một transaction; bảng nguồn rỗng bị từ chối (cho phép bằng `ALLOW_EMPTY=bảng1,bảng2`). Ngày `0000-00-00` được đổi thành `NULL`. Chế độ này **chưa được chạy với MySQL thật**.

## Lỗi thường gặp
| Hiện tượng | Nguyên nhân và cách xử lý |
|---|---|
| Kiểm tra quy ước báo đường dẫn cũ hoặc thiếu model mới | Image chưa build lại: `docker compose build dbt` |
| `Permission denied: /report/elementary_report.html` | Thư mục `report/` thuộc root; xóa bằng lệnh `busybox` ở mục 4 |
| `relation "..." does not exist` khi chạy một phần | Thiếu dấu `+` (chưa build upstream) hoặc DB đã bị `down -v` |
| Test khóa ngoại `relationships` báo `ERROR` khi chạy một phần | Bình thường, loại bằng `--exclude test_name:relationships` |
| Cảnh báo `Found orphan containers` | Có container cũ cùng project name trên máy; bỏ qua được, đừng dùng `--remove-orphans` |
| Muốn sạch hoàn toàn | `docker compose down -v` rồi chạy lại bước 1 |
