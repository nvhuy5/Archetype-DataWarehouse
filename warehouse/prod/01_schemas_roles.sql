-- ============================================================================
-- FILE 1/2 - TẠO USER (ROLE) VÀ SCHEMA trên Postgres production (Azure)
-- ============================================================================
-- Ai chạy: admin của platform team, MỘT LẦN, trên database analytics_db. Chạy lại bao nhiêu lần cũng an toàn.
--   psql "host=<server> dbname=analytics_db user=<admin> sslmode=require" -f 01_schemas_roles.sql -f 02_grants.sql
--
-- File này làm 2 việc:
--   (1) Tạo 3 user (login): dbt_rw, powerbi_ro, pii_admin. Chưa có mật khẩu: đặt sau, lấy từ Key Vault
--       (xem docs/DEPLOY-AZURE.vi.md, mục 2 bước 3).
--   (2) Tạo các schema do dbt ghi vào và giao cho dbt_rw làm chủ: staging, elementary, mart, mart_restricted.
--
-- Không tạo ở đây:
--   - raw_<nguồn> (raw_intranet, raw_nav...): do project ingestion (ADF) tạo, bằng login riêng của nó. Phải có trước khi chạy file 2.
--   - dwh: do dbt tự tạo lúc build (dbt_rw có quyền CREATE trên database, cấp ở file 2).
--
-- Giống warehouse/local/init (hai bên phải giữ khớp nhau). Khác nhau có chủ ý: local có mật khẩu test và tự tạo raw_intranet.
--
-- Admin trên Azure KHÔNG phải superuser: cần quyền CREATEROLE và CREATE trên database. Admin chưa phải chủ của schema nào
-- thuộc dbt_rw, mà Postgres đòi phải là thành viên của dbt_rw mới được tạo schema cho nó. Vì vậy file này:
-- "mượn" tư cách thành viên dbt_rw ngay đầu file và "trả" lại ở cuối file. Xong việc admin không giữ quyền gì của dbt_rw.
-- ============================================================================

-- ---------- (1) Tạo 3 user, mỗi user một việc ----------
--   dbt_rw     : job dbt và job Elementary. Đọc raw, là chủ của mọi schema mà dbt ghi vào.
--   powerbi_ro : Power BI. Chỉ đọc schema mart.
--   pii_admin  : quản trị viên được xem dữ liệu cá nhân. Đọc mart và mart_restricted.
-- Chỉ tạo nếu chưa có (chạy lại không lỗi). LOGIN = được đăng nhập; không có quyền gì khác (không superuser, không tạo role).
DO $$
DECLARE r text;
BEGIN
  FOREACH r IN ARRAY ARRAY['dbt_rw', 'powerbi_ro', 'pii_admin'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
      EXECUTE format('CREATE ROLE %I LOGIN', r);
    END IF;
  END LOOP;
END $$;

-- ---------- Mượn tư cách thành viên dbt_rw (trả ở cuối file) ----------
GRANT dbt_rw TO CURRENT_USER;

-- ---------- (2) Tạo schema, giao cho dbt_rw làm chủ ----------
-- Luồng dữ liệu: raw_<nguồn> -> staging -> dwh -> mart (Power BI đọc). Thêm hai schema phụ:
CREATE SCHEMA IF NOT EXISTS staging         AUTHORIZATION dbt_rw;   -- làm sạch, đổi tên cột từ raw (view)
CREATE SCHEMA IF NOT EXISTS elementary      AUTHORIZATION dbt_rw;   -- kết quả test và dữ liệu cho báo cáo Elementary
CREATE SCHEMA IF NOT EXISTS mart            AUTHORIZATION dbt_rw;   -- bảng cho Power BI (dữ liệu cá nhân đã che)
CREATE SCHEMA IF NOT EXISTS mart_restricted AUTHORIZATION dbt_rw;   -- bảng dữ liệu cá nhân CHƯA che, chỉ pii_admin đọc được
-- (dwh: dbt tự tạo, xem ghi chú ở đầu file)

-- Không ai được tạo đối tượng trong schema public. (Từ PostgreSQL 15 đã là mặc định; ghi rõ cho server bản cũ hơn.)
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- ---------- Trả lại tư cách thành viên dbt_rw ----------
REVOKE dbt_rw FROM CURRENT_USER;
