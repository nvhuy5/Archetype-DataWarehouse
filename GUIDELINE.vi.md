# Hướng dẫn dành cho khách hàng: dbt và Elementary

Tài liệu này giải thích, bằng ngôn ngữ dễ hiểu, hệ thống dữ liệu của chúng tôi làm những gì và hai công cụ chính là **dbt** và **Elementary** đóng vai trò gì. Bạn không cần biết lập trình để đọc.

## 1. Bức tranh tổng thể

Dữ liệu của doanh nghiệp nằm rải rác ở nhiều hệ thống (ví dụ Intranet). Để làm báo cáo, dữ liệu cần được gom về một nơi, làm sạch, rồi tổng hợp. Hệ thống này làm việc đó theo 4 bước:

```
 Intranet ──(1) ADF──▶ raw ──(2) dbt──▶ staging ─▶ dwh ─▶ mart ──(3) Elementary──▶ Báo cáo chất lượng
 (hệ thống nguồn)     (bản sao      (làm sạch, tổng hợp)        (kiểm tra & theo dõi)
                       nguyên gốc)
```

| Bước | Công cụ | Việc làm | Ví dụ đời thường |
|---|---|---|---|
| 1 | Azure Data Factory (ADF) | Sao chép nguyên bản dữ liệu từ nguồn về kho `raw` | Chở nguyên liệu từ nông trại về kho |
| 2 | **dbt** | Biến dữ liệu thô thành bảng sạch, đúng nghiệp vụ, đã kiểm tra | Bếp sơ chế, nấu nướng nguyên liệu |
| 3 | **Elementary** | Giám sát, báo cáo dữ liệu có đáng tin hay không | Bộ phận kiểm định chất lượng thực phẩm |

Quy tắc quan trọng: dữ liệu `raw` **không bao giờ bị sửa tại chỗ**. Mọi thay đổi diễn ra ở các bảng phía sau, nên luôn truy vết ngược được về dữ liệu gốc.

## 2. dbt là gì?

**dbt** (data build tool) là công cụ để **biến đổi dữ liệu ngay bên trong kho dữ liệu** bằng các câu lệnh SQL, theo cách có tổ chức, có kiểm thử và có tài liệu.

### Vấn đề dbt giải quyết
Nếu không có dbt, các phép tính biến đổi dữ liệu thường nằm rải rác trong file Excel, script riêng lẻ, hoặc trong đầu một vài người. Hậu quả: khó kiểm tra, khó bàn giao, sửa chỗ này hỏng chỗ khác. dbt gom tất cả về một nơi, quản lý như một dự án phần mềm.

### Các khái niệm chính

| Khái niệm | Giải thích đơn giản | Trong dự án này |
|---|---|---|
| **Source** (nguồn) | Khai báo các bảng dữ liệu thô dbt sẽ đọc | `dbt/models/staging/_sources.yml` khai báo bảng `hr_menu_department` |
| **Model** | Một file SQL mô tả "bảng/view kết quả mong muốn". dbt tự chạy và tạo ra bảng đó | `stg_intranet__hr_menu_department.sql` |
| **Test** | Quy tắc kiểm tra dữ liệu, ví dụ "mã không được trống", "id không được trùng" | `unique`, `not_null` trong `_staging.yml` |
| **Layer** (tầng) | Các lớp xử lý nối tiếp nhau | `staging` → `dwh` → `mart` |
| **Selector** | Chọn tập model nào sẽ chạy | `dbt/selectors.yml` |

### Các tầng dữ liệu
- **raw**: bản sao nguyên gốc từ hệ thống nguồn (do ADF nạp, dbt chỉ đọc).
- **staging**: làm sạch cơ bản. Mỗi dòng một khóa, cắt khoảng trắng thừa, chuỗi rỗng thành `NULL`. **Chưa có quy tắc nghiệp vụ.**
- **dwh**: kho dữ liệu đã được mô hình hóa theo nghiệp vụ (sẽ bổ sung).
- **mart**: bảng sẵn sàng phục vụ từng báo cáo/phòng ban (sẽ bổ sung).

### Ví dụ cụ thể trong dự án
Bảng nguồn `hr_menu_department` (danh sách phòng ban) có thể chứa khoảng trắng thừa hoặc chuỗi rỗng. Model `stg_intranet__hr_menu_department` sẽ:
1. Giữ mỗi `id` đúng một dòng.
2. Cắt khoảng trắng ở `name`, `code`, `business_line`.
3. Đổi chuỗi rỗng thành `NULL`.

Sau đó các test tự động kiểm tra `id` không trùng/không trống và `code` không trống.

### Lệnh `dbt build` làm gì?
Một lệnh duy nhất, theo thứ tự: **tạo các model → chạy test**. Nếu test nào không đạt, hệ thống báo lỗi (thoát với mã khác 0) để không ai dùng nhầm dữ liệu sai.

### Lợi ích cho khách hàng
- **Đáng tin cậy:** mọi bảng đều được kiểm tra tự động trước khi dùng.
- **Minh bạch:** logic nằm trong file SQL đọc được, lưu lịch sử thay đổi bằng Git.
- **Dễ mở rộng:** thêm báo cáo mới chỉ là thêm model mới, không phải làm lại từ đầu.
- **Lặp lại được:** chạy lại bao nhiêu lần cũng ra cùng kết quả.

## 3. Elementary là gì?

**Elementary** là công cụ **giám sát chất lượng dữ liệu** chạy sau dbt. Nếu dbt là người nấu ăn thì Elementary là người kiểm định: nó cho biết dữ liệu hôm nay **có bình thường không**.

### Elementary theo dõi những gì
- **Kết quả test của dbt:** test nào đạt, test nào hỏng, hỏng từ khi nào.
- **Thay đổi cấu trúc bảng (schema changes):** có cột nào bị thêm, xóa hoặc đổi kiểu dữ liệu không. Dự án này đã bật kiểm tra đó cho bảng phòng ban.
- **Lịch sử chạy:** mỗi lần chạy mất bao lâu, model nào thành công hay thất bại.
- **Các bất thường (anomaly):** số dòng đột nhiên giảm mạnh, dữ liệu không được cập nhật... (có thể bật thêm khi cần).

### Đầu ra: báo cáo HTML
Sau mỗi lần chạy, Elementary tạo file **`elementary_report.html`**. Mở bằng trình duyệt là xem được, không cần cài thêm gì. Báo cáo gồm:
- Tổng quan sức khỏe dữ liệu (bao nhiêu test đạt / lỗi).
- Danh sách lỗi và thời điểm xảy ra.
- Lịch sử chạy từng model.
- Sơ đồ phụ thuộc giữa các bảng (bảng nào sinh ra từ bảng nào).

### Cách đọc nhanh báo cáo
1. Nhìn phần tổng quan: màu xanh là ổn, đỏ/vàng cần xem.
2. Vào mục lỗi (test results) để biết bảng nào, quy tắc nào bị vi phạm.
3. Chuyển cho đội kỹ thuật kèm tên bảng và thời điểm lỗi để xử lý.

## 4. Cách vận hành

### Chạy thử trên máy (chỉ cần Docker)
```bash
docker compose run --build --rm elementary      # báo cáo: ./report/elementary_report.html
docker compose down -v                          # dọn dẹp
```
Lệnh này tự dựng nguồn mẫu, nạp dữ liệu, chạy dbt rồi chạy Elementary, bạn chỉ cần mở file báo cáo.

### Khi chạy thật
- Chạy **image dbt trước, image Elementary sau**.
- Nếu bước nào lỗi, hệ thống dừng và báo lỗi, không tạo ra dữ liệu sai âm thầm.
- Thông tin kết nối (máy chủ, tài khoản, mật khẩu) được cấp qua biến môi trường từ kho bí mật, **không nằm trong mã nguồn**.
- Image Elementary cần truy cập internet (HTTPS tới `hub.getdbt.com`) mỗi lần chạy.

Chi tiết kỹ thuật xem [README.vi.md](README.vi.md).

## 5. Khi cần thêm dữ liệu/báo cáo mới

Đội kỹ thuật sẽ làm theo quy trình:
1. Khai báo bảng nguồn mới (và ADF nạp bảng đó vào `raw`).
2. Viết model làm sạch (`staging`) kèm các test.
3. Thêm model nghiệp vụ ở tầng `dwh` và `mart` khi cần.
4. Chạy thử, xem báo cáo Elementary để chắc chắn dữ liệu đạt.

Bạn chỉ cần cung cấp: **cần dữ liệu gì, dùng cho báo cáo nào, và quy tắc nghiệp vụ ra sao**.

## 6. Thuật ngữ

| Thuật ngữ | Nghĩa |
|---|---|
| ADF | Azure Data Factory, dịch vụ chuyển dữ liệu giữa các hệ thống |
| Data warehouse (kho dữ liệu) | Cơ sở dữ liệu tập trung phục vụ phân tích, báo cáo |
| SQL | Ngôn ngữ truy vấn dữ liệu |
| Model | File SQL định nghĩa một bảng/view kết quả |
| Test | Quy tắc tự động kiểm tra chất lượng dữ liệu |
| Schema | Cấu trúc bảng (tên cột, kiểu dữ liệu) hoặc nhóm các bảng |
| Anomaly | Điểm bất thường so với quy luật thường thấy |
