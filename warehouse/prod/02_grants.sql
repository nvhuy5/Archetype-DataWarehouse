-- Production: access of the three roles. Run after 01_schemas_roles.sql, and after the ingestion project created its raw_<source> schemas.
--   psql ... -f 02_grants.sql
-- Every schema named raw_<source> (raw_intranet today; raw_nav, raw_static... later) is found automatically: no variable to pass, and a new source
-- only needs this file run again. The owner of each raw schema is taken to be the login the ingestion project uses for that source.
-- Idempotent: safe to run again.
-- The admin (not a superuser on Azure) owns neither the raw schemas nor the mart schemas: it borrows membership of each raw schema owner
-- and of dbt_rw for the grants below, and gives them back.
GRANT dbt_rw TO CURRENT_USER;

DO $$
DECLARE s record;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname LIKE 'raw\_%') THEN
    RAISE EXCEPTION 'no raw_<source> schema found: the ingestion project must create it before this file runs';
  END IF;
  FOR s IN SELECT nspname AS name, pg_get_userbyid(nspowner) AS owner FROM pg_namespace WHERE nspname LIKE 'raw\_%' ORDER BY 1 LOOP
    IF s.owner <> current_user THEN EXECUTE format('GRANT %I TO CURRENT_USER', s.owner); END IF;
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO dbt_rw', s.name);
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO dbt_rw', s.name);
    -- Tables that the ingestion project drops and recreates must stay readable by dbt without a new grant
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT SELECT ON TABLES TO dbt_rw', s.owner, s.name);
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), s.owner);
    IF s.owner <> current_user THEN EXECUTE format('REVOKE %I FROM CURRENT_USER', s.owner); END IF;
  END LOOP;
END $$;

-- Only the logins of this project may connect (by default every role may, and may create temporary tables).
-- The ingestion logins (owners of the raw schemas, above) and the admin that runs this file keep their access.
DO $$
BEGIN
  EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', current_database());
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO dbt_rw, powerbi_ro, pii_admin, CURRENT_USER', current_database());
  -- Elementary's incremental models create temporary tables: dbt_rw needs this, the read-only logins do not
  EXECUTE format('GRANT TEMPORARY ON DATABASE %I TO dbt_rw', current_database());
END $$;

GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;
-- SELECT on each mart table comes from the `grants` config of dbt_project.yml, applied at every dbt build

DO $$ BEGIN EXECUTE format('GRANT CREATE ON DATABASE %I TO dbt_rw', current_database()); END $$;

REVOKE dbt_rw FROM CURRENT_USER;
