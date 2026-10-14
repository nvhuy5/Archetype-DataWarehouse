# Error scenarios: gặp lỗi thì đọc gì, sửa sao

Mỗi file là **một lỗi cụ thể**, viết theo cùng một khuôn:

1. **Tình huống**: chuyện giả định như ngoài đời thật.
2. **Cách tạo ra lỗi**: lệnh để tái hiện ở local.
3. **Cách phát hiện**: chạy lệnh nào, nhìn vào đâu.
4. **Thông báo lỗi**: output thật, copy từ lần chạy trên repo này.
5. **Đọc thông báo và nguyên nhân**.
6. **Cách sửa** và **kiểm tra lại**.
7. **Trả lại như cũ** (để thử tiếp ca khác).
8. **Phòng tránh**: test hay quy ước nào chặn lỗi này.

Output trong các file lấy từ lần chạy thật; con số như `PASS=65`, `SKIP=10` đúng với dữ liệu mẫu hiện tại và có thể đổi khi repo có thêm model hay test.

## Tra nhanh theo thông báo

| Bạn thấy | Nghĩa là | File |
|---|---|---|
| `FAIL 1 source_not_empty_raw_intranet_<bảng>_` | bảng raw rỗng | [01](01-raw-table-empty.vi.md) |
| `FAIL 1 unique_...` | có khóa trùng | [02](02-duplicate-key.vi.md) (cũng gặp ở [09](09-join-fan-out.vi.md)) |
| `FAIL 1 not_null_...` | khóa bị rỗng (`NULL`) | [03](03-null-key.vi.md) |
| `raw_intranet has N of 61 tables. Run ./scripts/seed_local.sh first` | thiếu bảng raw ở local | [04](04-missing-raw-table.vi.md), [15](15-raw-not-seeded-or-stale.vi.md) |
| `relation "raw_intranet.<bảng>" does not exist` | source đã khai báo nhưng bảng chưa được tạo | [04](04-missing-raw-table.vi.md) |
| `column "<cột>" does not exist` ở model `stg_*` | nguồn không còn cột mà staging đang dùng | [05](05-source-drops-column.vi.md) |
| `column <bí danh>.<cột> does not exist` ở model dwh | gõ sai tên cột, hoặc cột đã bị bỏ ở model phía trên | [07](07-sql-error-in-model.vi.md), [05](05-source-drops-column.vi.md) |
| `WARN N relationships_...` | khóa ngoại mồ côi (chỉ cảnh báo) | [06](06-orphan-reference-warning.vi.md) |
| `Compilation Error ... which was not found` | `source()` hoặc `ref()` sai tên | [08](08-compilation-error.vi.md) |
| `FAIL 1 elementary_schema_changes_...` | cột của model staging đổi so với lần chạy trước | [10](10-schema-changes.vi.md) |
| `check_conventions.py` in ra `...: missing description`, `must start with`, `no key test`, `uses select *`, `has no not_empty test`, `seed file` | vi phạm quy ước | [11](11-convention-check.vi.md) |
| build xanh nhưng báo cáo trống | dwh/mart rỗng mà không test nào bắt | [12](12-empty-model-silent.vi.md) |
| `permission denied for table/schema ...` | thiếu quyền | [13](13-permission-denied.vi.md) |
| `password authentication failed`, `could not translate host name`, `server does not support SSL`, `Refusing to run: DBT_TARGET=local ...` | không kết nối được hoặc cấu hình môi trường sai | [14](14-connection-error.vi.md) |
| `Seed files changed since the last ./scripts/seed_local.sh` | seed cũ | [15](15-raw-not-seeded-or-stale.vi.md) |
| `FAILED: .../<bảng>.sql (columns changed in an existing table?...)` | đổi cột của bảng seed đã có | [16](16-seed-column-changed.vi.md) |
| `report/logs/...: Permission denied` | thư mục `report/` thuộc root | [17](17-report-folder-not-writable.vi.md) |

## Đọc kết quả của `run_local.sh`

```
[3/4] dbt build        FAILED  PASS=65 WARN=0 ERROR=1 SKIP=10
      ! 10 of 74 FAIL 1 source_not_empty_raw_intranet_hr_table_main_
```

| Từ khóa | Ý nghĩa |
|---|---|
| `FAIL` | test chạy được và **tìm ra dữ liệu xấu** (`Got N results`). Mã thoát khác 0 |
| `ERROR` | câu SQL **không chạy được** (`Database Error`): sai tên cột, thiếu quyền, bảng không tồn tại... Mã thoát khác 0 |
| `WARN` | test đặt `severity: warn` thấy vấn đề. Không chặn gì, mã thoát vẫn 0 |
| `SKIP` | bị bỏ qua vì một thứ nó phụ thuộc đã `FAIL` hoặc `ERROR`. Bảng đó giữ nguyên dữ liệu của lần build thành công trước |
| `Compilation Error` | dbt **chưa chạy được gì**: sai tên `source()`/`ref()`, sai cú pháp YAML. Không có dòng `PASS=...` |

Cách xem chi tiết:
- `report/logs/3-dbt.log`: log đầy đủ (tìm tên test hoặc model ở dòng `Failure in test` hoặc `Database Error`).
- Dòng `compiled code at target/...` trong log trỏ vào **bên trong container** (container bị xóa sau mỗi lần chạy), nên bạn không mở file đó được. Muốn thấy dòng dữ liệu hỏng thì tự truy vấn, mỗi file có sẵn câu lệnh.
- Kết quả test cũng được ghi vào schema `elementary` (bảng `elementary.elementary_test_results`) và `report/elementary_report.html` được tạo cả khi có lỗi:
  ```bash
  docker compose exec -T postgres-local psql -U postgres -d analytics_db \
    -c "select status, test_short_name, table_name, column_name from elementary.elementary_test_results where status <> 'pass' order by detected_at desc limit 5"
  ```

## Quy tắc khi tự thử

Hai lệnh dùng ở mọi ca:
```bash
# chạy SQL vào database local
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "<câu SQL>"
# trả dữ liệu raw về như cũ (3 giây)
./scripts/seed_local.sh
```
- Trước khi thử, chạy `./scripts/seed_local.sh` rồi `./scripts/run_local.sh` cho xanh (`ERROR=0 WARN=0`).
- Sau mỗi ca: làm mục **Trả lại như cũ** của file đó. Ca nào sửa file trong repo thì `git checkout <file>`.
- Chạy `./scripts/run_local.sh --select "--select +<model>"` cho nhanh (khoảng 1 phút). Chạy không `--select` thì mất khoảng 1,5 phút.
- Cuối buổi thử, chạy lại cả chuỗi `./scripts/run_local.sh` để các bảng dwh/mart được dựng lại từ dữ liệu đúng.

## Danh sách

| # | Lỗi | Dạng |
|---|---|---|
| 01 | [Bảng raw rỗng](01-raw-table-empty.vi.md) | dữ liệu nguồn |
| 02 | [Trùng khóa](02-duplicate-key.vi.md) | dữ liệu nguồn |
| 03 | [Khóa bị NULL](03-null-key.vi.md) | dữ liệu nguồn |
| 04 | [Thiếu bảng raw](04-missing-raw-table.vi.md) | dữ liệu nguồn |
| 05 | [Nguồn bỏ cột mà staging đang dùng](05-source-drops-column.vi.md) | dữ liệu nguồn |
| 06 | [Tham chiếu mồ côi (chỉ cảnh báo)](06-orphan-reference-warning.vi.md) | dữ liệu nguồn |
| 07 | [Lỗi SQL trong model](07-sql-error-in-model.vi.md) | code model |
| 08 | [Compilation Error](08-compilation-error.vi.md) | code model |
| 09 | [Join làm nhân đôi dòng](09-join-fan-out.vi.md) | code model |
| 10 | [Đổi cột model staging (schema_changes)](10-schema-changes.vi.md) | code model |
| 11 | [Vi phạm quy ước (check_conventions)](11-convention-check.vi.md) | quy ước |
| 12 | [Model rỗng mà build vẫn xanh](12-empty-model-silent.vi.md) | dữ liệu mẫu |
| 13 | [Permission denied](13-permission-denied.vi.md) | quyền |
| 14 | [Lỗi kết nối và cấu hình môi trường](14-connection-error.vi.md) | môi trường |
| 15 | [Chưa seed hoặc seed cũ](15-raw-not-seeded-or-stale.vi.md) | môi trường local |
| 16 | [Đổi cột trong file seed](16-seed-column-changed.vi.md) | môi trường local |
| 17 | [Thư mục report/ không ghi được](17-report-folder-not-writable.vi.md) | môi trường local |

Bổ sung ca mới: copy một file làm khuôn, đặt tên `NN-ten-loi.vi.md`, thêm vào hai bảng trên.
