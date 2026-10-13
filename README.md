# dbt + Elementary framework

🇻🇳 [Tiếng Việt](README.vi.md) · 📘 [Hướng dẫn cho khách hàng (VI): dbt & Elementary là gì?](docs/GUIDELINE.vi.md) · 📐 [Quy ước đặt tên](docs/NAMING.vi.md) · 📋 [Playbook migrate SSIS](docs/PLAYBOOK.vi.md) · 🧪 [Test local](docs/TEST-LOCAL.vi.md) · ⚖️ [Quyết định chung](docs/DECISIONS.vi.md)

Migration of the `ACT_Intranet_warehouse_3` SSIS package to ELT: Intranet (MySQL) tables are copied as they are into `raw_intranet`,
and dbt exposes them in `staging`. Business logic (joins, aggregates) belongs to the next layers, `dwh` and `mart`.

```
Intranet --[ADF]--> raw_intranet --[dbt image: dbt build]--> staging (→ dwh → mart) --[Elementary image]--> HTML report
```

## Try it (Docker only)

```bash
docker compose run --build --rm elementary      # report: ./report/elementary_report.html
docker compose down -v                          # clean up
```

Starts an empty warehouse (raw tables created from `warehouse/init`), fills `raw_intranet` with a few synthetic rows per table
(stands in for ADF), runs `dbt build` (61 staging models, the `dwh` models and their tests), then Elementary.

Real Intranet data (read only, needs network access to MySQL):

```bash
INGEST_MODE=mysql MYSQL_HOST=<host> MYSQL_USER=<user> MYSQL_PASSWORD=<pwd> MYSQL_DATABASE=archetype_intranet \
  docker compose run --build --rm elementary
```

## Layers

| Layer | Content | Rule |
|---|---|---|
| `raw_intranet` | 61 tables, same name and columns as the MySQL source | loaded by ADF, no logic, never edited in place |
| `staging` | one `stg_intranet__<table>` view per raw table (`_2015` suffix dropped) | trim text, empty string to NULL, snake_case, no joins, no business rules |
| `dwh` | `dim_*`, `fact_*`, `int_*`: joins, aggregates, business rules | `dim_employee`, `dim_office`, `dim_phase`, `fact_timesheet`, `fact_headcount_monthly`... (Timesheet and HR head count) |
| `mart` (next, round 3) | one set of tables per report | e.g. `mart_ts_*` |

`fact_timesheet` has one row per timesheet entry since `timesheet_from_date` (dbt var, default 2020-01-01 as in SSIS). The NAV columns of the old `Dim_Offices` are not in `dim_office` yet because NAV is not loaded.

From the SSIS package, only the plain copy of tables lands in raw and staging. The enrichment joins of `hr_table_contract`, the
`Summarized_Timesheet` aggregate and the `get_employee_etl` view are rebuilt in `dwh` from the raw base tables (`int_hr_contract`, `dim_employee`, `fact_timesheet`). Raw therefore holds
`hr_table_main` (not the view) plus `hr_menu_process_status`, `crm_list_reason` and `timesheet_phase_2015`, which those joins need.

Personal data (ID card, bank, tax, insurance, phones, salaries) stays in raw but is **not exposed in staging**; see the model descriptions.

## Layout

| Path | |
|---|---|
| `dbt/` | the dbt project |
| `dbt/models/dwh/` | dimensions, facts, `intermediate/` |
| `dbt/seeds/` | `public_holidays` (empty, waiting for the customer) |
| `dbt/models/staging/intranet/<domain>/` | `hr`, `timesheet`, `crm`, `prm`, `strategic`: `_<domain>__sources.yml`, `stg_*.sql`, `_<domain>__models.yml` (tests) |
| `warehouse/init/` | what the platform team creates once: schemas and login, raw tables, grants |
| `ingest/`, `ingest.Dockerfile` | local stand-in for ADF (`sample` or `mysql` mode) |
| `dbt.Dockerfile`, `elementary.Dockerfile` | the two production images |
| `scripts/` | checks to run by hand: repository rules and model conventions (see `docs/TEST-LOCAL.vi.md`) |
| `docker-compose.yml` | the local test |

## Add a model

1. New raw table? Add its `CREATE TABLE` to `warehouse/init/02_raw_intranet.sql` (and ADF must load it into `raw_intranet`, same name).
   Declare it in the `_<domain>__sources.yml` of its domain.
2. Add `stg_intranet__<table>.sql` and its tests in `_<domain>__models.yml`.
3. New layer (`dwh`, `mart`)? Make the folder under `dbt/models/` and uncomment its block in `dbt/dbt_project.yml`.
4. Create the schema once in the warehouse and grant `dbt_rw` on it (see `warehouse/init/03_grants.sql`).
5. `docker compose run --build --rm elementary` to check.

## Run contract (production)

| Variable | | |
|---|---|---|
| `PGHOST`, `PGUSER`, `PGPASSWORD` | required | warehouse, the `dbt_rw` login, its password (secret store) |
| `PGDATABASE` / `PGPORT` / `PGSSLMODE` | `analytics_db` / `5432` / `require` | |
| `DBT_ARGS` (dbt image) | `--selector default` | arguments of `dbt build` |

**Network:** the dbt image needs no internet at run time (packages are baked in at build). The Elementary image does: `edr` downloads
its dbt packages from `hub.getdbt.com` on every run, so allow outbound HTTPS to it (or use a proxy). Building the images also needs
internet (PyPI, hub.getdbt.com) and takes several minutes without cache.

Run the **dbt image first, then the Elementary image**. Both exit non-zero on failure. Elementary writes
`/report/elementary_report.html` (mount `/report` or upload it). Images run as non-root and hold no secrets.
