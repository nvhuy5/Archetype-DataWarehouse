-- Local test only: schemas and roles of the local Postgres, created once when its database is empty (files run in name order).
-- Same schemas, owners and roles as warehouse/prod (keep the two in step: scripts/check_prod_sql.sh tests the prod ones). Differences:
--   - the logins have a fixed test password here; production sets its own from the secret store;
--   - raw_intranet is created here (owned by postgres, whose seed files fill it); in production the ingestion project owns it.
-- The raw tables are not here: each one is a file in ../seed/raw_intranet, applied by scripts/seed_local.sh.
CREATE ROLE dbt_rw     LOGIN PASSWORD 'dbt_rw';       -- dbt and Elementary: reads raw, owns every schema dbt writes to
CREATE ROLE powerbi_ro LOGIN PASSWORD 'powerbi_ro';   -- Power BI: reads mart only
CREATE ROLE pii_admin  LOGIN PASSWORD 'pii_admin';    -- admins: read mart and mart_restricted

CREATE SCHEMA IF NOT EXISTS raw_intranet;
CREATE SCHEMA IF NOT EXISTS staging         AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS elementary      AUTHORIZATION dbt_rw;
-- `mart` is what Power BI reads (personal data already masked); `mart_restricted` holds the unmasked *_pii tables.
-- The two reader roles get USAGE in 02_grants.sql and SELECT on each table from the dbt `grants` config.
CREATE SCHEMA IF NOT EXISTS mart            AUTHORIZATION dbt_rw;
CREATE SCHEMA IF NOT EXISTS mart_restricted AUTHORIZATION dbt_rw;
-- dwh is created by dbt itself (needs CREATE on the database, granted in 02_grants.sql)

-- Nobody may create objects in public (already the default since PostgreSQL 15; explicit for older servers)
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
