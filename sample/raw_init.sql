-- Warehouse side: what the platform team creates once (schemas, the dbt login, the raw table ADF writes to).
-- Raw tables have the same name and columns as the source and no keys: a load must never be rejected.
CREATE SCHEMA IF NOT EXISTS raw_intranet;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS elementary;

CREATE TABLE IF NOT EXISTS raw_intranet.hr_menu_department (
    id integer, group_id integer, name varchar(100), code varchar(3), description varchar(200),
    technical_dept boolean, business_line varchar(5), ds_pm smallint, hide varchar(1)
);

-- dbt login: reads raw, owns staging and elementary
CREATE ROLE dbt_rw LOGIN PASSWORD 'dbt_rw';
GRANT USAGE ON SCHEMA raw_intranet TO dbt_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA raw_intranet TO dbt_rw;
GRANT CREATE ON DATABASE analytics_db TO dbt_rw;
GRANT ALL ON SCHEMA staging, elementary TO dbt_rw;
