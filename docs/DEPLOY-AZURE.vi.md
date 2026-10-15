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

1. Ingestion tạo schema `raw_<nguồn>` (hiện là `raw_intranet`; sau này `raw_nav`...) bằng login riêng của từng nguồn, rồi các bảng raw (dbt cần đọc được chúng). Login nào tạo schema là chủ schema; `02_grants.sql` coi chủ schema là login ingestion.
2. Một tài khoản admin chạy hai file, mỗi lần đều an toàn nếu chạy lại:
   ```bash
   psql "host=<server> dbname=analytics_db user=<admin> sslmode=require" \
     -f warehouse/prod/01_schemas_roles.sql -f warehouse/prod/02_grants.sql
   ```
   Kết quả: ba login `dbt_rw`, `powerbi_ro`, `pii_admin` (chưa có mật khẩu); các schema `staging`, `elementary`, `mart`, `mart_restricted` thuộc `dbt_rw`; quyền đọc mọi schema `raw_<nguồn>` cho `dbt_rw`, kể cả với bảng ingestion tạo lại sau này (theo chủ schema); thêm nguồn mới thì chạy lại `02_grants.sql`; quyền tạo schema (`dwh`) cho `dbt_rw`; thu hồi quyền mặc định của `PUBLIC` trên database, chỉ `dbt_rw`, `powerbi_ro`, `pii_admin`, login ingestion (chủ các schema raw) và admin đang chạy được `CONNECT`, riêng `dbt_rw` có thêm `TEMPORARY` (model incremental của Elementary tạo bảng tạm).
3. Đặt mật khẩu từng login từ secret store (không ghi vào file hay repo), ví dụ `ALTER ROLE dbt_rw PASSWORD '<từ Key Vault>'`.
4. Quyền `SELECT` trên từng bảng mart không nằm trong SQL này: dbt tự cấp ở mỗi lần build theo `+grants` trong `dbt_project.yml` (`mart` cho `powerbi_ro` và `pii_admin`, `mart_restricted` chỉ cho `pii_admin`).

Trước khi giao SQL này cho platform team, chạy `./scripts/check_prod_sql.sh` ([TEST-LOCAL.vi.md](TEST-LOCAL.vi.md)): nó dựng Postgres tạm theo đúng trình tự trên, chạy dbt và Elementary thật, và kiểm tra quyền của từng login.

Admin của Azure không phải superuser. Hai file SQL tự mượn quyền thành viên `dbt_rw` và của chủ từng schema raw (cần cho `CREATE SCHEMA ... AUTHORIZATION`, `ALTER DEFAULT PRIVILEGES`, `GRANT`) rồi trả lại khi xong; `./scripts/check_prod_sql.sh` chạy chúng bằng một admin không phải superuser trên Postgres tạm. **Chưa kiểm chứng trên Azure thật**: admin cần quyền `CREATEROLE` và là chủ database (hoặc có quyền `CREATE` trên nó). Sau khi thu hồi `PUBLIC`, các role hệ thống hoặc công cụ của Azure kết nối bằng role riêng có thể mất quyền vào database này; nếu có, cấp `CONNECT` cho role đó. Nếu gặp lỗi quyền ở bước 2, xử lý ở đây rồi chạy lại; nếu `ALTER DEFAULT PRIVILEGES` không dùng được thì ingestion phải cấp `SELECT` cho `dbt_rw` sau mỗi lần nạp.

### Đọc nhanh: ai được làm gì
Có 5 user. Mỗi người chỉ có đúng quyền cần để làm việc của mình:

| User | Là ai | Ai tạo | Được làm gì | Không được |
|---|---|---|---|---|
| **admin Azure** | tài khoản quản trị server | có sẵn | chạy 2 file SQL một lần | không dùng cho job; sau khi chạy xong không giữ quyền gì thêm |
| **login ingestion** (ví dụ `adf_loader`) | ADF nạp dữ liệu; mỗi nguồn một login | platform team | tạo và nạp bảng trong schema `raw_<nguồn>` của mình (là chủ schema đó) | không đụng tới schema khác |
| **`dbt_rw`** | job dbt và job Elementary | `01_schemas_roles.sql` | đọc mọi schema `raw_*`; tạo và ghi `staging`, `dwh`, `mart`, `mart_restricted`, `elementary`; tạo bảng tạm | không ghi vào `raw_*` |
| **`powerbi_ro`** | Power BI | `01_schemas_roles.sql` | chỉ đọc các bảng trong `mart` | không thấy `raw`, `staging`, `dwh`, `elementary`, `mart_restricted`; không tạo được gì |
| **`pii_admin`** | người được xem dữ liệu cá nhân | `01_schemas_roles.sql` | đọc `mart` và `mart_restricted` | không thấy `raw`, `staging`, `dwh`; không tạo được gì |

Luồng dữ liệu và ai chạm vào lớp nào:
```
raw_<nguồn>  ──(dbt_rw đọc)──>  staging ──> dwh ──> mart ──(powerbi_ro đọc)──> Power BI
 ingestion ghi                  └──── dbt_rw ghi hết ────┘   └─(pii_admin đọc)─> mart_restricted
```

Mấy điều dễ nhầm:
- **Quyền đọc từng bảng mart do dbt cấp** mỗi lần build (theo `+grants` trong `dbt_project.yml`), không nằm trong file SQL. Thêm bảng mart mới không cần sửa SQL.
- **"Mượn quyền" của admin**: admin Azure không phải superuser nên không tự có quyền trên schema của `dbt_rw` hay của ingestion. Trong lúc chạy, file SQL cho admin tạm làm thành viên của các role đó, làm xong thì rút lại. Mục đích chỉ là để chạy được; sau đó admin không còn quyền của họ.
- **`PUBLIC`** là "mọi role trên server". Mặc định ai cũng kết nối được vào database và tạo bảng tạm. SQL thu hồi quyền đó: chỉ 3 login của dự án, các login ingestion và admin mới vào được. `dbt_rw` có thêm quyền tạo bảng tạm vì Elementary cần.
- **Thêm nguồn mới** (ví dụ `raw_nav`): ingestion tạo schema bằng login riêng, rồi admin chạy lại `02_grants.sql`. Không phải sửa file.
- **Đổi mật khẩu**: đổi trong Key Vault, rồi `ALTER ROLE ... PASSWORD` trong Postgres cho khớp (mục 4 bên dưới).

`warehouse/prod/` và `warehouse/local/init/` phải giữ giống nhau về schema và role; khác biệt có chủ ý chỉ là mật khẩu và việc tạo `raw_intranet` (local tạo sẵn, prod do ingestion tạo). Quyền trên database (chỉ 3 login của dự án được `CONNECT`, `dbt_rw` có thêm `TEMPORARY`) giống nhau ở cả hai nơi.

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

### Dùng Azure Container Apps Job và Key Vault
dbt **không tự đọc Key Vault**: `profiles.yml` chỉ đọc biến môi trường. Container Apps Job lấy secret từ Key Vault rồi đưa vào container dưới dạng biến môi trường. Chưa chạy thử trên Azure thật, kiểm tra từng bước khi làm lần đầu.

1. Tạo một user-assigned managed identity, gán cho job (và cho job Elementary nếu tách riêng).
2. Gán cho identity đó role **Key Vault Secrets User** trên vault (vault dùng RBAC), hoặc quyền `get` trên secret (vault dùng access policy). Cho phép identity kéo image từ registry (role `AcrPull`).
3. Tạo job, khai báo secret trỏ tới Key Vault và gán vào `PGPASSWORD`:
   ```bash
   az containerapp job create \
     -n <tên job dbt> -g <resource group> --environment <container apps environment> \
     --trigger-type Manual \
     --image <registry>.azurecr.io/archetype-dbt:<tag> \
     --registry-server <registry>.azurecr.io --registry-identity <resource id của identity> \
     --mi-user-assigned <resource id của identity> \
     --secrets "pgpassword=keyvaultref:https://<vault>.vault.azure.net/secrets/<tên secret>,identityref:<resource id của identity>" \
     --env-vars PGPASSWORD=secretref:pgpassword \
                PGUSER=dbt_rw PGHOST=<server>.postgres.database.azure.com
   ```
   - Không đặt `DBT_TARGET` và `PGSSLMODE` (xem bảng trên). Job Elementary làm tương tự với image `archetype-elementary`.
   - `--trigger-type` đổi thành `Schedule` kèm `--cron-expression` nếu để job tự chạy theo lịch (xem mục 7).
4. Đổi mật khẩu trong Key Vault: các lần chạy mới của job dùng giá trị mới, không cần build lại image. Nhớ đặt lại mật khẩu role trong Postgres cho khớp (`ALTER ROLE ...`, mục 2 bước 3).

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
