-- Warehouse side: what the platform team creates once (schemas and the dbt login).
-- Runs first (files in this folder run in name order); 02_raw_intranet.sql creates the raw tables, 03_grants.sql grants access.
CREATE SCHEMA IF NOT EXISTS raw_intranet;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS elementary;

-- dbt login: reads raw, owns staging and elementary. Local test password only; production uses its own secret.
CREATE ROLE dbt_rw LOGIN PASSWORD 'dbt_rw';
