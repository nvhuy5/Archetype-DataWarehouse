-- Production PostgreSQL (Azure): what the platform team runs ONCE, as an admin, on the analytics database.
--   psql "host=<server> dbname=analytics_db user=<admin> sslmode=require" -f 01_schemas_roles.sql -f 02_grants.sql -v ingestion_role=<login of the ingestion project>
-- Same schemas and roles as warehouse/local/init (keep the two in step), with two differences:
--   - the logins are created WITHOUT a password: set each one from the secret store (see docs/DEPLOY-AZURE.vi.md);
--   - raw_intranet is not created here: the ingestion project owns it and its tables, and must have created it before 02_grants.sql.
-- Idempotent: safe to run again.
DO $$
DECLARE r text;
BEGIN
  FOREACH r IN ARRAY ARRAY['dbt_rw', 'powerbi_ro', 'pii_admin'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
      EXECUTE format('CREATE ROLE %I LOGIN', r);
    END IF;
  END LOOP;
END $$;
-- dbt_rw: reads raw, owns every schema dbt writes to (staging, dwh, mart, mart_restricted, elementary).
-- powerbi_ro: Power BI, reads mart only.  pii_admin: admins, read mart and mart_restricted.

CREATE SCHEMA IF NOT EXISTS staging         AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS elementary      AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS mart            AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS mart_restricted AUTHORIZATION dbt_rw;
-- dwh is created by dbt itself (needs CREATE on the database, granted in 02_grants.sql)

-- Nobody may create objects in public (already the default since PostgreSQL 15; explicit for older servers)
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
