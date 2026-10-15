-- ============================================================================
-- FILE 2/2 - CẤP QUYỀN cho các user trên Postgres production (Azure)
-- ============================================================================
-- Ai chạy: admin của platform team, sau file 1 và SAU KHI project ingestion đã tạo schema raw_<nguồn>.
--   psql ... -f 02_grants.sql
-- Bắt buộc chạy một lần khi dựng môi trường; chạy lại không gây hại gì. Khi thêm nguồn mới (raw_nav...): ingestion tạo schema xong
-- thì PHẢI chạy lại file này để dbt_rw đọc được nguồn đó, không cần sửa gì trong file.
--
-- Kết quả cuối cùng:
--   dbt_rw     : đọc mọi schema raw_*; tạo được schema mới (dwh); kết nối và tạo bảng tạm.
--   powerbi_ro : kết nối; vào được schema mart.
--   pii_admin  : kết nối; vào được schema mart và mart_restricted.
--   login ingestion (chủ của schema raw_*): kết nối được database.
--   mọi role khác (PUBLIC): không kết nối được.
-- Quyền SELECT trên TỪNG BẢNG mart không cấp ở đây: dbt tự cấp mỗi lần build, theo `+grants` trong dbt_project.yml.
--
-- Login ingestion không truyền vào nữa: với mỗi schema raw_*, file lấy CHỦ SCHEMA làm login ingestion của nguồn đó.
-- Admin trên Azure không phải superuser nên không phải chủ của schema raw_* hay mart*. Vì vậy trong lúc chạy admin
-- "mượn" tư cách thành viên của dbt_rw và của từng chủ schema raw, làm xong thì "trả". Xong việc admin không giữ quyền gì thêm.
-- ============================================================================

-- Mượn tư cách thành viên dbt_rw (trả ở cuối file): cần để cấp quyền trên schema mart do dbt_rw làm chủ.
GRANT dbt_rw TO CURRENT_USER;

-- ---------- (1) Cho dbt_rw đọc mọi schema raw_<nguồn> ----------
DO $$
DECLARE s record;
BEGIN
  -- Chưa có schema raw nào thì dừng và báo rõ, thay vì chạy xong mà dbt không có gì để đọc.
  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname LIKE 'raw\_%') THEN
    RAISE EXCEPTION 'chưa có schema raw_<nguồn> nào: project ingestion phải tạo schema trước khi chạy file này';
  END IF;

  -- Lặp qua từng schema raw_*: s.name = tên schema, s.owner = chủ schema (= login ingestion của nguồn đó)
  FOR s IN SELECT nspname AS name, pg_get_userbyid(nspowner) AS owner FROM pg_namespace WHERE nspname LIKE 'raw\_%' ORDER BY 1 LOOP
    -- Mượn tư cách chủ schema (trừ khi admin chính là chủ)
    IF s.owner <> current_user THEN EXECUTE format('GRANT %I TO CURRENT_USER', s.owner); END IF;

    -- dbt_rw được vào schema và đọc mọi bảng ĐANG có
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO dbt_rw', s.name);
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO dbt_rw', s.name);

    -- Bảng do login ingestion tạo MỚI sau này (kể cả xóa rồi tạo lại) tự động cho dbt_rw đọc, không cần cấp lại
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT SELECT ON TABLES TO dbt_rw', s.owner, s.name);

    -- Login ingestion phải còn kết nối được database sau khi mục (2) thu hồi quyền của PUBLIC
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), s.owner);

    -- Trả tư cách chủ schema
    IF s.owner <> current_user THEN EXECUTE format('REVOKE %I FROM CURRENT_USER', s.owner); END IF;
  END LOOP;
END $$;

-- ---------- (2) Khóa database: chỉ user của dự án mới được vào ----------
-- Mặc định Postgres cho MỌI role (PUBLIC) kết nối database và tạo bảng tạm. Thu hồi hết, rồi cấp lại đúng người cần.
DO $$
BEGIN
  EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', current_database());
  -- Kết nối: 3 user của dự án + admin đang chạy file này (để admin không tự khóa mình). Login ingestion đã được cấp ở mục (1).
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO dbt_rw, powerbi_ro, pii_admin, CURRENT_USER', current_database());
  -- Chỉ dbt_rw được tạo bảng tạm: model incremental của Elementary cần. Power BI và pii_admin chỉ đọc nên không cần.
  EXECUTE format('GRANT TEMPORARY ON DATABASE %I TO dbt_rw', current_database());
END $$;

-- ---------- (3) Cho Power BI và pii_admin vào schema mart ----------
-- USAGE = được "bước vào" schema. Còn đọc được bảng nào thì do dbt cấp SELECT từng bảng (xem đầu file).
GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;   -- powerbi_ro KHÔNG được vào mart_restricted (dữ liệu cá nhân chưa che)

-- ---------- (4) Cho dbt_rw tạo schema mới ----------
-- Cần để dbt tự tạo schema dwh lúc build.
DO $$ BEGIN EXECUTE format('GRANT CREATE ON DATABASE %I TO dbt_rw', current_database()); END $$;

-- Trả tư cách thành viên dbt_rw
REVOKE dbt_rw FROM CURRENT_USER;
