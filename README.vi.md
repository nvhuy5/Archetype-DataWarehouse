# Khung dbt + Elementary

🇬🇧 [English](README.md) · 📘 [Hướng dẫn cho khách hàng: dbt & Elementary là gì?](GUIDELINE.vi.md)

Bộ khung chuẩn, kèm một bảng nguồn mẫu và một model mẫu để chứng minh luồng chạy được. Từ đây trở đi chỉ cần thêm model.

```
Intranet --[ADF]--> raw_intranet --[image dbt: dbt build]--> staging (→ dwh → mart) --[image Elementary]--> báo cáo HTML
```

## Chạy thử (chỉ cần Docker)

```bash
docker compose run --build --rm elementary      # báo cáo: ./report/elementary_report.html
docker compose down -v                          # dọn dẹp
```

Lệnh trên dựng một DB nguồn (3 dòng) và một warehouse rỗng, copy nguồn → raw (việc của ADF), chạy `dbt build`
(model + test), rồi chạy Elementary.

## Cấu trúc thư mục

| Đường dẫn | Ý nghĩa |
|---|---|
| `dbt/` | project dbt |
| `dbt/models/staging/` | `_sources.yml` (bảng raw), `stg_*.sql`, `_staging.yml` (test) |
| `dbt.Dockerfile`, `elementary.Dockerfile` | hai image |
| `sample/` | chỉ để demo: `source.sql` (bảng nguồn), `raw_init.sql` (phần platform tạo một lần), `ingest_demo.sh` (thay cho ADF) |
| `docker-compose.yml` | môi trường test local |

## Thêm một model

1. Có bảng raw mới? Khai báo trong `dbt/models/staging/_sources.yml` (và ADF phải nạp vào `raw_intranet` với cùng tên).
2. Thêm `stg_<nguồn>__<bảng>.sql` và test tương ứng trong `_staging.yml`.
3. Cần layer mới (`dwh`, `mart`)? Tạo thư mục dưới `dbt/models/` và bỏ comment khối tương ứng trong `dbt/dbt_project.yml`.
4. Tạo schema một lần trong warehouse và cấp quyền cho `dbt_rw` (xem `sample/raw_init.sql`).
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
