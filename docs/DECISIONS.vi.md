# Quyết định chung

Các quyết định áp dụng cho mọi package SSIS. Mỗi quyết định ghi rõ ai chốt và còn chờ gì.

## 1. Power BI trỏ vào mart (B1)
- Power BI đọc **bảng mart** mới (cột `snake_case`), không có lớp view `reporting` giữ tên cũ.
- Hệ quả: báo cáo hiện tại phải đổi nguồn và tên cột. Việc này thuộc Archetype (report và model Power BI thuộc Archetype theo hợp đồng), cần báo họ sớm.

## 2. Dữ liệu cá nhân (B5)
Mô hình: **một nguồn đầy đủ, một bản đã che**, tách quyền theo schema.

| | Bản không che | Bản đã che |
|---|---|---|
| Vị trí | schema `mart_restricted`, model `mart_<domain>_<thực thể>_pii` | schema `mart`, model `mart_<domain>_<thực thể>` |
| Bản chất | bảng gốc, đầy đủ cột | **view** dựng từ bảng gốc, dùng macro che dữ liệu |
| Ai đọc | role admin (`pii_admin`) | role Power BI (`powerbi_ro`) |

- Bản đã che là view dựng từ bảng gốc nên hai bản **không thể lệch nhau**.
- Quyền gắn bằng cấu hình `grants` của dbt; `powerbi_ro` chỉ được đọc schema `mart`.
- Staging và dwh dùng chung **vẫn ẩn** cột cá nhân. Chỉ các model `*_pii` đọc cột cá nhân từ raw, đặt trong phạm vi hạn chế.

Danh sách cột và cách che (**mặc định tạm, chờ khách xác nhận B5**):

| Nhóm | Cột | Bản đã che |
|---|---|---|
| Danh tính, tài chính | CCCD, nơi cấp, số bảo hiểm, mã số thuế, tên ngân hàng, số tài khoản, chủ thẻ, lương, thưởng, các đợt trả | **Bỏ hẳn** |
| Liên lạc | email cá nhân, điện thoại, người liên hệ khẩn cấp | **Che một phần** (ví dụ `***1234`) |
| Ngày sinh | `birthday` | Chỉ có `age` |
| Cần cho báo cáo | `employee_id`, `employee_code`, `full_name`, email công ty | Giữ nguyên (báo cáo Timesheet cần tên và mã nhân viên) |

## 3. CI
- **Chưa dùng CI.** Việc kiểm tra làm bằng tay dưới local theo [TEST-LOCAL.vi.md](TEST-LOCAL.vi.md), kèm hai script `scripts/check_conventions.py` (quy ước model) và `scripts/check_repo.py` (không có thứ riêng tư trong git).
- Khi có nhiều người cùng làm hoặc lên Azure thì bật CI (GitHub Actions) chạy lại đúng các lệnh trong TEST-LOCAL, thêm lint SQL, `state:modified+` và đẩy image lên registry.

## 4. Khác
- Project Docker compose tên `archetype-dbt`, để không trùng với stack khác trên cùng máy.
