# Đưa lên Azure

Tài liệu này mô tả những gì cần có để chạy dbt và Elementary trên Azure. **Chưa được chạy thử trên Azure thật**: các lệnh và tên dịch vụ dưới đây là hướng dẫn, kiểm tra từng bước khi làm lần đầu. Phần đã kiểm chứng ở local là image, `dbt build` và báo cáo ([TEST-LOCAL.vi.md](TEST-LOCAL.vi.md)) cùng SQL trong `warehouse/prod/` (chạy được hai lần liền trên Postgres tạm).

## 1. Ai làm gì

```
Intranet (MySQL) --[ingestion: ADF]--> raw_intranet --[job dbt]--> staging → dwh → mart --[job Elementary]--> báo cáo HTML
                                                                                  └──> Power BI đọc schema mart
```

| Phần | Thuộc về | Ghi chú |
|---|---|---|
| Nạp MySQL vào `raw_intranet` (tạo và nạp bảng raw) | **project ingestion** (ADF), ngoài repo này | dbt chỉ đọc raw; bảng raw phải đúng tên và cột như file trong `warehouse/local/seed/raw_intranet/` |
| Schema, role, quyền | platform team, chạy **một lần** từ `warehouse/prod/` | mục 2 |
| `dbt build` (staging, dwh, mart, test) | image `archetype-dbt` | mục 3 và 4 |
| Báo cáo chất lượng | image `archetype-elementary`, chạy **sau** image dbt | mục 6 |

## 2. Chuẩn bị Postgres production (một lần)
Postgres trên Azure (ví dụ Azure Database for PostgreSQL) là server khác với `postgres-local`, nên **không dùng** `warehouse/local/`.

1. Ingestion tạo schema `raw_intranet` và các bảng raw trước (dbt cần đọc được chúng).
2. Một tài khoản admin chạy hai file, mỗi lần đều an toàn nếu chạy lại:
   ```bash
   psql "host=<server> dbname=analytics_db user=<admin> sslmode=require" -v ingestion_role=<login của ingestion> \
     -f warehouse/prod/01_schemas_roles.sql -f warehouse/prod/02_grants.sql
   ```
   Kết quả: ba login `dbt_rw`, `powerbi_ro`, `pii_admin` (chưa có mật khẩu); các schema `staging`, `elementary`, `mart`, `mart_restricted` thuộc `dbt_rw`; quyền đọc raw cho `dbt_rw`, kể cả với bảng ingestion tạo lại sau này (`ingestion_role` dùng cho việc đó); quyền tạo schema (`dwh`) cho `dbt_rw`.
3. Đặt mật khẩu từng login từ secret store (không ghi vào file hay repo), ví dụ `ALTER ROLE dbt_rw PASSWORD '<từ Key Vault>'`.
4. Quyền `SELECT` trên từng bảng mart không nằm trong SQL này: dbt tự cấp ở mỗi lần build theo `+grants` trong `dbt_project.yml` (`mart` cho `powerbi_ro` và `pii_admin`, `mart_restricted` chỉ cho `pii_admin`).

Chưa kiểm chứng trên Azure: `CREATE SCHEMA ... AUTHORIZATION dbt_rw` có thể đòi tài khoản admin là thành viên của `dbt_rw` (`GRANT dbt_rw TO <admin>`), tùy cấu hình server. Nếu gặp lỗi quyền ở bước 2, xử lý ở đây rồi chạy lại.

`warehouse/prod/` và `warehouse/local/init/` phải giữ giống nhau về schema và role; khác biệt có chủ ý là mật khẩu và việc tạo `raw_intranet`.

## 3. Build và đẩy image
Từ thư mục gốc repo (cần internet; lần đầu vài phút):
```bash
docker build -f dbt.Dockerfile        -t <registry>.azurecr.io/archetype-dbt:<tag> .
docker build -f elementary.Dockerfile -t <registry>.azurecr.io/archetype-elementary:<tag> .
az acr login --name <registry>
docker push <registry>.azurecr.io/archetype-dbt:<tag>
docker push <registry>.azurecr.io/archetype-elementary:<tag>
```
- Dùng tag cố định (ví dụ mã commit), không dùng `latest`, để biết job đang chạy code nào và quay lại được.
- Image không chứa secret và không cần internet khi chạy (package dbt đã đóng gói lúc build).
- Không dùng `ingest`: image này không còn trong repo.

## 4. Cấu hình job
Cả hai job nhận cấu hình qua biến môi trường (bảng đầy đủ ở `README.vi.md`, mục "Biến môi trường khi chạy thật"):

| Biến | Giá trị trên Azure | Ghi chú |
|---|---|---|
| `PGHOST` | `<server>.postgres.database.azure.com` | |
| `PGUSER`, `PGPASSWORD` | `dbt_rw` và mật khẩu | mật khẩu lấy từ Key Vault hoặc secret của dịch vụ chạy job, không viết thẳng vào cấu hình |
| `PGDATABASE`, `PGPORT` | `analytics_db`, `5432` | mặc định, thường không cần đặt |
| `PGSSLMODE` | không đặt | target `prod` mặc định là `require` |
| `DBT_TARGET` | **không đặt** | mặc định `prod`. Không bao giờ đặt `local` trên Azure: image sẽ từ chối chạy nếu `PGHOST` không phải Postgres local |
| `DBT_ARGS` (image dbt) | tùy chọn | mặc định `--selector default` |

Job phải truy cập được Postgres qua mạng (firewall hoặc VNet).

## 5. Thứ tự chạy
1. Ingestion nạp xong `raw_intranet`.
2. **Job dbt** chạy `dbt run --select elementary` rồi `dbt build`. Thoát mã khác 0 nếu model hoặc test lỗi.
3. **Job Elementary** chạy sau khi job dbt xong **thành công**.
4. Power BI đọc schema `mart` bằng login `powerbi_ro`.

Hai job nối tiếp nhau: Elementary đọc kết quả test mà job dbt vừa ghi. Dừng chuỗi khi một bước thoát mã khác 0 (nếu job dbt lỗi thì mart có thể dở dang; xem log trước khi chạy lại).

## 6. Báo cáo Elementary
Image ghi `/report/elementary_report.html`. Trên Azure cần một chỗ để lấy file ra:
- gắn `/report` vào một Azure Files share, hoặc
- thêm một bước upload file lên Blob Storage rồi chia sẻ link cho người xem.

Repo **chưa có** bước upload này; chọn cách làm khi chốt cách điều phối (mục 7).

## 7. Việc chưa có hoặc cần chốt
| Việc | Trạng thái |
|---|---|
| Cái điều phối chạy chuỗi ingestion → dbt → Elementary và lịch chạy (ADF gọi job, cron của dịch vụ chạy job, hoặc GitHub Actions) | **chưa chốt**; repo chưa có |
| Nơi lưu và ai xem báo cáo Elementary | chưa chốt (mục 6) |
| CI: build, chạy `check_conventions.py` / `check_repo.py`, đẩy image lên registry | chưa có; xem mục 3 của [DECISIONS.vi.md](DECISIONS.vi.md) |
| Chạy thử cả chuỗi trên Azure | chưa làm |
| Đối soát số liệu với kho cũ trên dữ liệu thật | xem Bước 6 của [PLAYBOOK.vi.md](PLAYBOOK.vi.md) |

## 8. Local và Azure khác nhau ở đâu

| | Local | Azure |
|---|---|---|
| Postgres | container `postgres-local` | Postgres managed, server khác |
| Bảng raw | file seed (`warehouse/local/seed`), `seed_local.sh` | project ingestion (ADF), dữ liệu thật |
| Schema, role, quyền | `warehouse/local/init` (tự chạy khi DB trống, mật khẩu test) | `warehouse/prod` (admin chạy một lần, mật khẩu từ secret) |
| `DBT_TARGET` | `local` (compose đặt) | `prod` (mặc định) |
| SSL | tắt | bắt buộc (`require`) |
| Chạy | `run_local.sh` | job chạy image đã đẩy lên registry |
| Báo cáo | `./report/` | Azure Files hoặc Blob (chưa làm) |

Code dbt (model, test, macro) **giống hệt** ở cả hai môi trường.
