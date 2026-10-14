# Playbook: migrate một package SSIS sang ADF + dbt

Dùng cho mọi package SSIS. Các quyết định chung (Power BI, dữ liệu cá nhân) ở [DECISIONS.vi.md](DECISIONS.vi.md). Mỗi package đi qua đúng 7 bước dưới đây. Tên và cấu trúc xem [NAMING.vi.md](NAMING.vi.md); chạy và kiểm tra xem [TEST-LOCAL.vi.md](TEST-LOCAL.vi.md); tổng quan xem [README.vi.md](../README.vi.md).

```
Phân tích → Phân loại → Raw + Staging → DWH → Mart → Đối soát → Bàn giao
```

Nguyên tắc chung:
- **ELT:** ADF chỉ copy nguyên bản vào raw. Mọi biến đổi làm trong dbt.
- **Chỉ đọc nguồn** (hợp đồng: DWH không ghi ngược). Luồng ghi ngược để ngoài phạm vi và ghi lại để hỏi khách.
- **Không có logic ở raw và staging.** Join và quy tắc nghiệp vụ chỉ nằm ở dwh và mart.
- Mỗi bước kết thúc bằng một commit local.

## Bước 1. Phân tích package
Đầu vào: file `.dtsx`, `SSIS flow.xlsx`, tài liệu thiết kế, định nghĩa view/stored procedure của kho cũ.

Ghi lại vào một file phân tích (mẫu `reference/<package>-analysis.md`, không commit):
- [ ] Nguồn và đích, kết nối, thứ tự chạy, lịch chạy (job SQL Agent).
- [ ] Danh sách task: bảng nguồn, câu SQL nguồn, bảng đích, số cột nguồn và đích, task bị disable.
- [ ] Logic riêng: join, `GROUP BY`, `CASE`, `LIMIT`, mốc ngày hardcode, biến, Lookup, Script Component.
- [ ] Cách xử lý lỗi hiện tại (log, redirect row, ignore failure).
- [ ] Ai đọc đích: báo cáo, view, package khác (xem `List Tables Used For Report.xlsx`).
- [ ] Danh sách câu hỏi mở cho khách, kèm mặc định tạm dùng.

## Bước 2. Phân loại từng phần theo layer
Với mỗi thành phần của package, xác định nó thuộc layer nào:

| Thành phần SSIS | Layer đích |
|---|---|
| Data flow `SELECT * FROM bảng` rồi nạp thẳng | **raw** (ADF copy) + **staging** (1 view) |
| Đổi tên bảng hoặc cột ở đích | **staging** (đổi tên ở model; raw giữ tên nguồn) |
| Cột nguồn bị bỏ ở đích | **raw** giữ đủ, **staging** chọn cột |
| Câu SQL nguồn có `JOIN` | Mỗi bảng một **staging**, phần join ở **dwh** |
| `GROUP BY`, `SUM`, `CASE` nghiệp vụ | **dwh** (`int_*`, `fact_*`) |
| View trên đích (`Dim_*`, `*_Details`) | **dwh**; phần riêng cho báo cáo ở **mart** |
| Mốc ngày hoặc `LIMIT` hardcode | Biến dbt (`vars`), không hardcode |
| Execute SQL `TRUNCATE` / `DELETE` đầu package | Bỏ: ADF thay bảng raw trong một transaction |
| Lookup chống trùng | Bỏ: thay bằng test `unique` (dedupe ở staging nếu nguồn thật sự trùng) |
| Redirect/ignore lỗi dòng, bảng `ETL_ERROR` | Bỏ: thay bằng test dbt và Elementary |
| Script Component, ghi ngược vào hệ thống nguồn | **Ngoài phạm vi**, ghi lại để hỏi khách |
| Biến, connection không dùng | Bỏ |

Bảng nguồn nào cần cho một phép join mà package không nạp riêng (ví dụ `crm_list_reason`) thì thêm vào raw.

## Bước 3. Raw và staging
**Raw**
- [ ] Lấy định nghĩa bảng nguồn (DDL), đổi kiểu theo bảng ánh xạ trong NAMING.vi.md.
- [ ] Thêm `CREATE TABLE` vào `warehouse/init/02_raw_intranet.sql` (hoặc file raw của nguồn mới).
- [ ] Nạp **bảng gốc**, không nạp view của nguồn nếu dựng lại được ở dwh.
- [ ] Loader local: thêm giá trị mẫu cho các cột cần join trong `ingest/load_raw.py` (`OVERRIDES`).

**Staging**
- [ ] Khai báo bảng trong `_<domain>__sources.yml`, mô tả ngắn.
- [ ] Một model `stg_<nguồn>__<bảng>` cho mỗi bảng raw: `btrim`, chuỗi rỗng thành `NULL`, `snake_case`.
- [ ] Ẩn cột cá nhân và lương; ghi vào mô tả model.
- [ ] Test khóa chính trong `_<domain>__models.yml` (khóa ghép dùng `dbt_utils.unique_combination_of_columns`); `elementary.schema_changes`.
- [ ] Bảng không có khóa chính: ghi rõ trong mô tả.

Chạy kiểm tra: `./scripts/run_local.sh`. Kết quả phải là `ERROR=0`.

## Bước 4. DWH
- [ ] Tìm định nghĩa view hoặc stored procedure của kho cũ cho phần cần dựng.
- [ ] Dịch sang model dbt: `dim_*` (một dòng mỗi thực thể), `fact_*` (độ mịn rõ ràng), `int_*` khi dùng chung.
- [ ] Phép join đặt ở dwh. Quy tắc nghiệp vụ cũ giữ nguyên; chỗ nào cố ý khác bản cũ thì ghi vào comment đầu file.
- [ ] Mốc lịch sử, ngưỡng: dùng biến dbt có chú thích.
- [ ] Test: khóa (`unique`, `not_null`); khóa ngoại và giá trị hợp lệ để `severity: warn`.
- [ ] Dữ liệu mẫu: bảo đảm loader tạo dữ liệu đủ để model có dòng, kiểm tra kết quả bằng truy vấn thật.

## Bước 5. Mart
- [ ] Chốt với khách báo cáo nào cần.
- [ ] Mỗi bảng của mô hình báo cáo là một `mart_<domain>_<thực thể>`; chỉ đọc từ dwh. Power BI đọc thẳng mart, không có lớp `reporting` ([DECISIONS.vi.md](DECISIONS.vi.md)).
- [ ] Mart có dữ liệu cá nhân: bản đầy đủ `*_pii` ở schema `mart_restricted`, bản đã che là view ở `mart` dựng từ bản đầy đủ (dùng macro `mask_partial`, `age_from_birthday` trong `dbt/macros/mask.sql`; cột cần bỏ hẳn thì không chọn). Quyền gắn sẵn theo thư mục trong `dbt_project.yml`: `mart` cho `powerbi_ro` và `pii_admin`, `mart_restricted` chỉ cho `pii_admin`. Bản `*_pii` là bảng duy nhất được đọc cột cá nhân từ raw.
- [ ] Mart không có cột cá nhân (như `mart_ts_*`): chỉ cần model ở `mart`, ghi rõ trong mô tả là không có gì để che. Ví dụ mẫu cho cặp `*_pii` và bản che: `mart_hr_employee_pii` và `mart_hr_employee`.
- [ ] Test: khóa (`unique`, `not_null`); khóa ngoại để `severity: warn`. Mart không cần `schema_changes`.

## Bước 6. Đối soát
- [ ] Chạy với dữ liệu nguồn thật (`INGEST_MODE=mysql`, chỉ đọc).
- [ ] So kho cũ và mới theo thứ tự: số dòng từng bảng raw so với nguồn; số dòng và tổng giờ/headcount ở dwh; số liệu KPI của báo cáo.
- [ ] So **cùng khoảng ngày** (kho cũ có mốc cố định và có thể thiếu dòng do SSIS nuốt lỗi).
- [ ] Lệch nào cũng phân loại: lỗi của hệ thống mới, lỗi của hệ thống cũ, hay khác biệt có chủ ý. Ghi kết quả.
- [ ] Sai lệch cho phép do khách duyệt; không tự đặt.

## Bước 7. Bàn giao
- [ ] README (EN và VI) cập nhật: layer, model mới, cách chạy.
- [ ] `GUIDELINE.vi.md` cập nhật nếu có khái niệm mới cho khách.
- [ ] Danh sách phụ thuộc và câu hỏi còn mở được ghi lại.
- [ ] Mọi thay đổi đã commit local, sạch `git status`. Người phụ trách tự push.

## Định nghĩa hoàn thành (Definition of Done)
Cách chạy và kiểm tra từng mục: [TEST-LOCAL.vi.md](TEST-LOCAL.vi.md) (có script `scripts/check_conventions.py` và `scripts/check_repo.py`).

- `./scripts/run_local.sh --reset` thành công từ trạng thái sạch, `ERROR=0`.
- Mọi model có mô tả; khóa có test.
- Không còn `SELECT *`, mốc ngày hay `LIMIT` hardcode trong model.
- Không có cột cá nhân hoặc secret trong staging, dwh, mart và trong commit.
- Đã đối soát (hoặc ghi rõ lý do chưa đối soát được).

## Lỗi thường gặp (đã gặp ở package đầu tiên)
| Vấn đề | Cách xử lý |
|---|---|
| Cột nguồn viết hoa kiểu `TenantID`, `oldRevision` | Raw viết thường; staging đổi sang `snake_case` |
| Tên cột trùng từ khóa PostgreSQL | Đặt trong dấu ngoặc kép |
| `int unsigned` vượt giới hạn `integer` | Dùng `bigint` |
| `char(n)` bị đệm khoảng trắng | Raw dùng `varchar(n)`, staging `btrim` |
| Ngày `0000-00-00` trong MySQL | Loader chuyển thành `NULL`; hỏi khách nếu cột đó quan trọng |
| `SELECT *` với view của nguồn: cột mới bị bỏ âm thầm | Nạp bảng gốc, liệt kê cột; `elementary.schema_changes` báo khi nguồn đổi |
| Dữ liệu mẫu cho dim rỗng vì không khớp điều kiện lọc | Thêm giá trị vào `OVERRIDES` của loader |
| Thư mục `report/` thuộc root, Elementary không ghi được | Compose đã có service `report-dir` xử lý |
| Test khóa ngoại fail trên dữ liệu thật (id 0, NULL) | Để `severity: warn`, xem lại khi đối soát |
