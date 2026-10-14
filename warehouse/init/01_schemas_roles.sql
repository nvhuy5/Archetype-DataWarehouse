-- Warehouse side: what the platform team creates once (schemas and the dbt login).
-- Runs first (files in this folder run in name order); 02_raw_intranet.sql creates the raw tables, 03_grants.sql grants access.
CREATE SCHEMA IF NOT EXISTS raw_intranet;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS elementary;

-- dbt login: reads raw, owns staging and elementary. Local test password only; production uses its own secret.
CREATE ROLE dbt_rw LOGIN PASSWORD 'dbt_rw';

-- Mart layer: `mart` is what Power BI reads (personal data already masked); `mart_restricted` holds the unmasked *_pii tables.
-- dbt owns both schemas; the two reader roles get USAGE here and SELECT on each table from the dbt `grants` config.
CREATE ROLE powerbi_ro LOGIN PASSWORD 'powerbi_ro';   -- Power BI: reads mart only. Local test password only.
CREATE ROLE pii_admin  LOGIN PASSWORD 'pii_admin';    -- admins: read mart and mart_restricted
CREATE SCHEMA IF NOT EXISTS mart            AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS mart_restricted AUTHORIZATION dbt_rw;
GRANT USAGE ON SCHEMA mart TO powerbi_ro, pii_admin;
GRANT USAGE ON SCHEMA mart_restricted TO pii_admin;
