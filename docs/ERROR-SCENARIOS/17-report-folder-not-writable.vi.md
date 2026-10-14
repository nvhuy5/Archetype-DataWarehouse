# 17. Thư mục `report/` không ghi được

> Tình huống giả định. Một lần bạn chạy lệnh Docker bằng quyền root có ghi vào `report/` (ví dụ gắn thư mục vào container rồi tạo file), nên `report/` và `report/logs/` giờ thuộc root. Lần sau chạy `run_local.sh` bằng user thường thì lỗi ngay ở bước đầu.

## Cách tạo ra lỗi
```bash
docker run --rm -v "$PWD":/w busybox sh -c "chown -R root:root /w/report && chmod -R 755 /w/report"
ls -ld report report/logs
```
```
drwxr-xr-x ... root ... report
drwxr-xr-x ... root ... report/logs
```

## Cách phát hiện
```bash
./scripts/run_local.sh
```

## Thông báo lỗi
```
./scripts/run_local.sh: line 55: report/logs/1-build.log: Permission denied
[1/4] Build images                FAILED
#21 CACHED

#22 [elementary 9/9] COPY --chown=edr dbt/ .
#22 CACHED
...
```
Mã thoát 1.

## Đọc thông báo và nguyên nhân
- Dòng đầu tiên mới là lỗi thật: `report/logs/1-build.log: Permission denied`. Script không ghi được log vào `report/logs/` vì thư mục thuộc root.
- Phần `#21 CACHED ...` phía dưới **gây hiểu nhầm**: đó là nội dung **file log cũ** của lần build trước (script đọc lại log để in khi lỗi, mà log mới không ghi được). Build image **không** hỏng; chỉ `report/` bị khóa.
- Vì vậy dòng `[1/4] Build images FAILED` nhìn như lỗi build, nhưng đừng đi tìm lỗi trong Dockerfile.

## Cách sửa
Xóa thư mục `report/` bằng quyền root (qua Docker), script sẽ tạo lại:
```bash
docker run --rm -v "$PWD":/w busybox rm -rf /w/report
./scripts/run_local.sh
```
`report/` chỉ chứa kết quả chạy (log và báo cáo) nên xóa không mất dữ liệu nào của repo; nó nằm trong `.gitignore`.

## Kiểm tra lại
`./scripts/run_local.sh` chạy qua cả 4 bước.

## Trả lại như cũ
Chính là bước sửa ở trên.

## Phòng tránh
- Không chạy container bằng root với `-v "$PWD":...` ghi vào `report/`.
- Script tự `chmod 777` thư mục `report/` ở mức trên cùng trước khi chạy, nên `report/` thuộc root mà **chưa có** `report/logs/` vẫn chạy được (đã thử). Lỗi chỉ xảy ra khi **bên trong** (`report/logs/` và các file log) thuộc root, như ca này, và khi đó thông báo là `Permission denied` ở trên, không phải `report/ is not writable`.
