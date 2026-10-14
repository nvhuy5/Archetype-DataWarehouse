# 01. Bảng raw rỗng

> Tình huống giả định. Ingestion chạy đêm, nhưng nguồn MySQL không trả về dòng nào cho bảng `hr_table_main` (kết nối chập chờn, bảo trì nguồn...). Bảng raw được thay bằng một bảng **rỗng** và job nạp vẫn báo thành công. Sáng thứ Hai báo cáo nhân sự có nguy cơ trống.

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "truncate raw_intranet.hr_table_main"
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```

## Thông báo lỗi
Trên màn hình:
```
[2/4] Raw data (seeded)           OK  61 tables
[3/4] dbt build                   FAILED  PASS=65 WARN=0 ERROR=1 SKIP=10  (29s)
      ! 10 of 74 FAIL 1 source_not_empty_raw_intranet_hr_table_main_ ................... [FAIL 1 in 0.06s]
[4/4] Elementary report           OK  report/elementary_report.html  (35s)
---
Finished with errors in 66s. Details: report/logs/
```
Trong `report/logs/3-dbt.log`:
```
10 of 74 FAIL 1 source_not_empty_raw_intranet_hr_table_main_ ................... [FAIL 1 in 0.06s]
22 of 74 SKIP relation staging.stg_intranet__hr_table_main ..................... [SKIP]
...
69 of 74 SKIP relation dwh.dim_employee ........................................ [SKIP]
...
Failure in test source_not_empty_raw_intranet_hr_table_main_ (models/staging/intranet/hr/_hr__sources.yml)
  Got 1 result, configured to fail if != 0
```

## Đọc thông báo và nguyên nhân
- Tên test `source_not_empty_raw_intranet_hr_table_main_` cho biết **bảng nào** rỗng: `raw_intranet.hr_table_main`.
- `FAIL` (không phải `ERROR`): test chạy được và kết luận dữ liệu xấu.
- `SKIP=10`: 10 phần tử phụ thuộc bảng này (view `stg_intranet__hr_table_main`, các test của nó, `dim_employee` và test của nó) **không chạy**. Nhờ vậy `dwh` và `mart` **không bị ghi đè bằng dữ liệu rỗng**; chúng giữ dữ liệu của lần build thành công trước.
- Vì sao cần test riêng: `unique`, `not_null` và `schema_changes` đều **pass** trên bảng rỗng. Không có `not_empty` thì dbt xanh và `dim_employee` rỗng mà không ai biết.

## Cách sửa
Trên môi trường thật, lỗi nằm ở **nguồn hoặc ingestion**, không phải ở dbt:
1. Kiểm tra lần nạp gần nhất của bảng đó (log ingestion, bảng nguồn MySQL có dữ liệu không).
2. Nạp lại bảng.
3. Chạy lại job dbt.

Nếu một bảng **hợp lệ khi rỗng** (ví dụ bảng cấu hình chưa có dữ liệu), đổi test thành cảnh báo và ghi lý do trong `_<domain>__sources.yml`:
```yaml
      - name: hr_menu_something
        tests:
          - not_empty:
              config: {severity: warn}   # lý do: bảng chưa dùng, khách chưa nhập dữ liệu
```

Ở local, "nạp lại" là:
```bash
./scripts/seed_local.sh
```

## Kiểm tra lại
```bash
./scripts/run_local.sh --select "--select +dim_employee"
```
Không còn `FAIL`, `ERROR` hay `SKIP`.

## Trả lại như cũ
`./scripts/seed_local.sh` (bước sửa ở trên đã là bước trả lại).

## Phòng tránh
- `not_empty` được gắn vào **cả 61 source** (`dbt/tests/generic/not_empty.sql`), và `scripts/check_conventions.py` báo lỗi nếu có source thiếu test này.
- Test này chỉ bắt bảng rỗng **hoàn toàn**. Bảng nạp thiếu nhiều dòng thì chưa có test; xem ý tưởng `elementary.volume_anomalies` trong [12](12-empty-model-silent.vi.md).
