-- Local test only: access of the three roles. Same grants as warehouse/prod/02_grants.sql (see 01_schemas_roles.sql).
GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
-- Raw tables are created by the seed files (as postgres): new ones must be readable by dbt without a new grant
ALTER DEFAULT PRIVILEGES IN SCHEMA raw_intranet GRANT SELECT ON TABLES TO dbt_rw;

GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;
-- SELECT on each mart table comes from the `grants` config of dbt_project.yml, applied at every dbt build

GRANT CREATE ON DATABASE archetype_dwh TO dbt_rw;

-- Only the logins of this project may connect (by default every role may, and may create temporary tables). postgres (seed, healthcheck) is a superuser.
-- Elementary's incremental models create temporary tables: dbt_rw needs this, the read-only logins do not.
REVOKE ALL ON DATABASE archetype_dwh FROM PUBLIC;
GRANT CONNECT ON DATABASE archetype_dwh TO dbt_rw, powerbi_ro, pii_admin;
GRANT TEMPORARY ON DATABASE archetype_dwh TO dbt_rw;
