-- Local test only: access of the three roles. Same grants as warehouse/prod/02_grants.sql (see 01_schemas_roles.sql).
GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
-- Raw tables are created by the seed files (as postgres): new ones must be readable by dbt without a new grant
ALTER DEFAULT PRIVILEGES IN SCHEMA raw_intranet GRANT SELECT ON TABLES TO dbt_rw;

GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;
-- SELECT on each mart table comes from the `grants` config of dbt_project.yml, applied at every dbt build

GRANT CREATE ON DATABASE analytics_db TO dbt_rw;
