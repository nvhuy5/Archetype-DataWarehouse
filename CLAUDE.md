# Quy tắc làm việc trong repo này

## Git
- Sau mỗi lần code xong một thay đổi (một ý logic hoàn chỉnh) thì **commit lên local ngay**.
- **Tuyệt đối KHÔNG tự ý `git push`** (kể cả `--force`, tạo PR, hay push tag). Việc push do người dùng tự làm thủ công.
- Mỗi commit chỉ chứa một thay đổi logic; message ngắn gọn, mô tả rõ thay đổi gì.
- Không commit: thư mục `reference/`, secret/credential thật, `target/`, `logs/`, `dbt_packages/`, `report/`.
- Làm việc trên nhánh `feature/dbt-init`, không code trực tiếp trên `main`.

## Quy trình
- Khi làm tính năng hoặc sửa code: đưa ra hướng giải quyết trước, đợi người dùng xác nhận rồi mới code.
- Trả lời bằng tiếng Việt.

## Tài liệu
- Tài liệu của repo nằm trong `docs/`: `PLAYBOOK.vi.md` (quy trình migrate một package SSIS), `NAMING.vi.md` (quy ước đặt tên), `DECISIONS.vi.md` (quyết định chung: Power BI, dữ liệu cá nhân, CI), `GUIDELINE.vi.md` (giới thiệu cho khách hàng), `TEST-LOCAL.vi.md` (cách chạy và test dưới local sau khi code xong). Code mới phải theo các file này.
- `reference/` là tài liệu tham khảo nội bộ (không commit); đọc để hiểu nguồn, không sửa.
- `README.md` (EN) và `README.vi.md` (VI) chỉ chứa phần kỹ thuật ngắn gọn; giữ hai bản đồng bộ khi sửa.
- `docs/GUIDELINE.vi.md` là tài liệu giới thiệu dbt và Elementary cho khách hàng; không nhồi nội dung này vào README.
