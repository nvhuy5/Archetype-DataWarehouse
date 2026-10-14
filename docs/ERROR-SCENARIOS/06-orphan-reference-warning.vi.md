# 06. Tham chiếu mồ côi (chỉ cảnh báo)

> Tình huống giả định. Một dòng timesheet tham chiếu `phase_id = 999`, nhưng bảng phase của Intranet không có mã đó (phase bị xóa, hoặc nhập sai). Kho vẫn nạp được, nhưng dòng timesheet này không gắn được vào phase nào.

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db \
  -c "update raw_intranet.timesheet_entry_2015 set phase_id = 999 where id = 1"
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +fact_timesheet"
```

## Thông báo lỗi
```
[3/4] dbt build                   OK  PASS=30 WARN=1 ERROR=0 SKIP=0  (24s)
      ! 26 of 29 WARN 1 relationships_fact_timesheet_phase_id__phase_id__ref_dim_phase_  [WARN 1 in 0.06s]
[4/4] Elementary report           OK  report/elementary_report.html  (37s)
---
Done in 60s. Details: report/logs/
```
Trong log:
```
Warning in test relationships_fact_timesheet_phase_id__phase_id__ref_dim_phase_ (models/dwh/fact/_fact__models.yml)
  Got 1 result, configured to warn if != 0
```
Mã thoát của `run_local.sh` là **0**.

## Đọc thông báo và nguyên nhân
- `OK` và `WARN`: build **không bị chặn**. Dòng `!` liệt kê từng cảnh báo.
- `relationships_<model>_<cột>__<cột>__ref_<dim>_`: kiểm tra mọi `phase_id` trong `fact_timesheet` phải có trong `dim_phase`. `WARN 1` là có **1 giá trị** `phase_id` không khớp.
- Test này đặt `severity: warn` trong `dbt/models/dwh/fact/_fact__models.yml`. Lý do: dữ liệu nguồn thật có thể có mồ côi từ trước và không nên chặn cả báo cáo.
- Quy ước của repo: test **khóa** (`unique`, `not_null`) là lỗi; test **khóa ngoại** (`relationships`) là cảnh báo.

Tìm dòng mồ côi:
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db -c "
  select f.phase_id, count(*) as entries
  from dwh.fact_timesheet f left join dwh.dim_phase p using (phase_id)
  where p.phase_id is null and f.phase_id is not null group by 1"
```
```
 phase_id | entries 
----------+---------
      999 |       1
(1 row)
```

## Cách sửa
1. Hỏi người sở hữu dữ liệu: `phase_id = 999` là phase đã xóa hay nhập sai?
2. Sửa ở nguồn (thêm phase hoặc sửa dòng timesheet) rồi nạp lại.
3. Nếu số mồ côi ổn định và được khách chấp nhận thì ghi nhận (xem Bước 6 `docs/PLAYBOOK.vi.md`: sai lệch cho phép do khách duyệt, không tự đặt). Đừng chuyển test thành `error` chỉ để cho xanh, hoặc xóa test để hết cảnh báo.

Ở local: `./scripts/seed_local.sh`.

## Kiểm tra lại
```bash
./scripts/run_local.sh --select "--select +fact_timesheet"
```
`WARN=0`.

## Trả lại như cũ
`./scripts/seed_local.sh`.

## Phòng tránh
Cảnh báo không tự biến mất: ai chạy `run_local.sh` cũng thấy dòng `!`. Mục tiêu trên dữ liệu mẫu là `WARN=0` (xem `docs/TEST-LOCAL.vi.md`); nếu có cảnh báo thì xem lại model hoặc dòng mẫu, không bỏ qua.
