# 10. Đổi cột của model staging (`schema_changes`)

> Tình huống giả định. Bạn thêm một cột vào model staging `stg_intranet__hr_menu_country`, hoặc ai đó bỏ một cột. Test `elementary.schema_changes` báo lỗi, dù SQL chạy hoàn toàn bình thường.

## Cách tạo ra lỗi
Cần chạy một lần thành công làm **mốc** trước, rồi mới đổi cột:
```bash
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"      # mốc: PASS=6

sed -i 's/^    hr_hide$/    hr_hide,\n    1 as extra_column/' dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
git diff dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
```
```diff
-    hr_hide
+    hr_hide,
+    1 as extra_column
```

## Cách phát hiện
```bash
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"
```

## Thông báo lỗi
```
[3/4] dbt build                   FAILED  PASS=5 WARN=0 ERROR=1 SKIP=0  (24s)
      ! 2 of 4 FAIL 1 elementary_schema_changes_stg_intranet__hr_menu_country_ ......... [FAIL 1 in 0.65s]
```
Trong log:
```
Failure in test elementary_schema_changes_stg_intranet__hr_menu_country_ (models/staging/intranet/hr/_hr__models.yml)
  Got 1 result, configured to fail if != 0
```
Xem **cột nào** thay đổi (Elementary ghi vào database):
```bash
docker compose exec -T postgres-local psql -U postgres -d analytics_db \
  -c "select sub_type, alert_description from elementary.alerts_schema_changes order by detected_at desc limit 2"
```
```
column_added | The column "extra_column" was added
```

## Đọc thông báo và nguyên nhân
- `schema_changes` so **danh sách cột và kiểu** của model với **lần chạy trước** (mốc). Khác nhau thì báo lỗi.
- Test canh cột của **model staging**. Nó không canh bảng raw: bảng raw thêm cột mới thì staging (liệt kê cột tường minh) không đổi nên test không báo; raw bỏ cột mà staging còn dùng thì lỗi SQL đến trước (xem [05](05-source-drops-column.vi.md)).

## Cách sửa
Tùy bạn đổi cột **có chủ ý** hay **nhầm**:

**Có chủ ý (ví dụ cần cột mới)**: không cần sửa gì. Lần chạy sau, trạng thái mới thành mốc mới và test xanh.
```bash
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"
# [3/4] dbt build   OK  PASS=6 WARN=0 ERROR=0 SKIP=0
```
Nghĩa là mỗi lần đổi cột có chủ ý, job **fail đúng một lần**. Hãy báo cho người chạy job để họ không giật mình.

**Nhầm**: hoàn tác thay đổi.
```bash
git checkout dbt/models/staging/intranet/hr/stg_intranet__hr_menu_country.sql
./scripts/run_local.sh --select "--select stg_intranet__hr_menu_country"
```
Lần chạy này **cũng fail một lần** (cột `extra_column` bị bớt đi so với mốc, Elementary ghi `column_removed: The column "extra_column" was removed`). Chạy thêm một lần nữa mới xanh:
```
FAILED  PASS=5 ... ERROR=1     <- lần ngay sau khi hoàn tác
OK      PASS=6 ... ERROR=0     <- lần kế tiếp
```

## Trả lại như cũ
Làm đúng mục **Nhầm** ở trên (hoàn tác file rồi chạy hai lần) để mốc về như ban đầu.

## Phòng tránh
`elementary.schema_changes` có ở cả 61 model staging. Nó là chốt chặn để **không ai đổi cột staging mà không biết**, vì dwh và mart đọc từ đó. Khi đổi cột có chủ ý, hãy rà các model phía sau dùng cột đó.
