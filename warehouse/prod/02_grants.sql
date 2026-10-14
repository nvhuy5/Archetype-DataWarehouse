-- Production: access of the three roles. Run after 01_schemas_roles.sql, and after the ingestion project created raw_intranet.
-- Needs the psql variable ingestion_role: the login the ingestion project (ADF) uses to create and fill raw_intranet tables.
--   psql ... -v ingestion_role=<login> -f 02_grants.sql
-- Idempotent: safe to run again.
GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
-- Tables that the ingestion project drops and recreates must stay readable by dbt without a new grant
ALTER DEFAULT PRIVILEGES FOR ROLE :"ingestion_role" IN SCHEMA raw_intranet GRANT SELECT ON TABLES TO dbt_rw;

GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;
-- SELECT on each mart table comes from the `grants` config of dbt_project.yml, applied at every dbt build

DO $$ BEGIN EXECUTE format('GRANT CREATE ON DATABASE %I TO dbt_rw', current_database()); END $$;
