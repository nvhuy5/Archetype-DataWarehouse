# 03. Khóa bị NULL

> Tình huống giả định. Nguồn có một dòng quốc gia mới nhập dở: chưa có `idp` (mã quốc gia). Dòng đi vào raw với khóa rỗng.

## Cách tạo ra lỗi
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh \
  -c "update raw_intranet.hr_menu_country set idp = null where idp = 1"
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```

## Thông báo lỗi
```
[3/4] dbt build                   FAILED  PASS=6 WARN=0 ERROR=1 SKIP=0  (21s)
      ! 4 of 5 FAIL 1 not_null_stg_intranet__hr_menu_country_idp ....................... [FAIL 1 in 0.16s]
```
Trong log:
```
Failure in test not_null_stg_intranet__hr_menu_country_idp (models/staging/intranet/hr/_hr__models.yml)
  Got 1 result, configured to fail if != 0
```

## Đọc thông báo và nguyên nhân
- `not_null_<model>_<cột>`: cột `idp` của `stg_intranet__hr_menu_country` có giá trị rỗng.
- `Got 1 result`: có 1 dòng với khóa `NULL`.
- Test `unique` **không** bắt trường hợp này (`NULL` không bị coi là trùng nhau), nên cần cả hai test.
- Ở lần chạy này `SKIP=0` vì chỉ chọn `+stg_intranet__hr_menu_country`, không có model nào phụ thuộc trong phạm vi chọn. Chạy cả chuỗi thì các model phía sau bị bỏ qua.

Tìm dòng hỏng:
```bash
docker compose exec -T postgres-local psql -U postgres -d archetype_dwh \
  -c "select * from raw_intranet.hr_menu_country where idp is null"
```

## Cách sửa
Khóa rỗng nghĩa là dòng đó không xác định được. Quyết định theo thực tế:
1. Dữ liệu nhập dở ở nguồn: yêu cầu bên nguồn điền khóa; nạp lại.
2. Dòng thật sự không cần: nguồn xóa dòng đó.
3. Không dùng `where idp is not null` trong staging chỉ để qua test; làm vậy là lặng lẽ bỏ dòng.

Ở local: `./scripts/seed_local.sh`.

## Kiểm tra lại
```bash
./scripts/run_local.sh --select "--select +stg_intranet__hr_menu_country"
```
`PASS=7 ... ERROR=0`.

## Trả lại như cũ
`./scripts/seed_local.sh`.

## Phòng tránh
`not_null` và `unique` đi cùng nhau trên cột khóa của mọi bảng staging (xem [02](02-duplicate-key.vi.md)).
