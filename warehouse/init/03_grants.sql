GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
GRANT CREATE ON DATABASE analytics_db TO dbt_rw;
GRANT ALL ON SCHEMA staging, elementary TO dbt_rw;
