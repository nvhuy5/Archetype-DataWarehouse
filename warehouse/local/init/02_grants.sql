GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
-- The seed files drop and recreate the raw tables: new ones must stay readable by dbt without a new grant
ALTER DEFAULT PRIVILEGES IN SCHEMA raw_intranet GRANT SELECT ON TABLES TO dbt_rw;
GRANT CREATE ON DATABASE analytics_db TO dbt_rw;
GRANT ALL ON SCHEMA staging, elementary TO dbt_rw;
