# dbt + Elementary framework

🇻🇳 [Tiếng Việt](README.vi.md) · 📘 [Hướng dẫn cho khách hàng (VI): dbt & Elementary là gì?](docs/GUIDELINE.vi.md) · 📐 [Quy ước đặt tên](docs/NAMING.vi.md) · 📋 [Playbook migrate SSIS](docs/PLAYBOOK.vi.md) · 🧪 [Test local](docs/TEST-LOCAL.vi.md) · ⚖️ [Quyết định chung](docs/DECISIONS.vi.md) · ☁️ [Lên Azure](docs/DEPLOY-AZURE.vi.md)

Migration of the `ACT_Intranet_warehouse_3` SSIS package to ELT: Intranet (MySQL) tables are copied as they are into `raw_intranet`,
and dbt exposes them in `staging`. Business logic (joins, aggregates) belongs to the next layers, `dwh` and `mart`.

```
Intranet --[ADF, ingestion project]--> raw_intranet --[dbt image: dbt build]--> staging (→ dwh → mart) --[Elementary image]--> HTML report
```

## Try it (Docker only)

```bash
./scripts/seed_local.sh           # once, and after editing a seed file: raw tables with their sample rows
./scripts/run_local.sh            # dbt build + Elementary report; short summary on screen, full logs in report/logs/
./scripts/seed_local.sh --reset   # wipe the local database, then seed again
```

dbt only reads `raw_intranet`; loading it from MySQL is the job of the ingestion project (ADF), outside this repo.
Locally, `postgres-local` plays the warehouse: `seed_local.sh` creates each raw table from its file in
`warehouse/local/seed/raw_intranet/` (the `CREATE TABLE` plus a few sample rows). `run_local.sh` then runs `dbt build`
(61 staging models, the `dwh` and `mart` models and their tests) and Elementary. It only checks that the raw tables exist
and warns when the seed files changed (or are older than 7 days) since the last seed; it never rebuilds raw itself.

## Layers

| Layer | Content | Rule |
|---|---|---|
| `raw_intranet` | 61 tables, same name and columns as the MySQL source | loaded by the ingestion project (ADF), no logic, never edited in place |
| `staging` | one `stg_intranet__<table>` view per raw table (`_2015` suffix dropped) | trim text, empty string to NULL, snake_case, no joins, no business rules |
| `dwh` | `dim_*`, `fact_*`, `int_*`: joins, aggregates, business rules | `dim_employee`, `dim_office`, `dim_phase`, `fact_timesheet`, `fact_headcount_monthly`... (Timesheet and HR head count) |
| `mart` | one set of tables per report, personal data masked, read by Power BI (`powerbi_ro`) | `mart_ts_details`, `mart_ts_employees`, `mart_ts_offices`, `mart_ts_departments` |
| `mart_restricted` | unmasked `mart_*_pii` tables, admin role only (`pii_admin`) | `mart_hr_employee_pii` (masked view: `mart.mart_hr_employee`) | |

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
| `dbt/models/mart/`, `mart_restricted/` | report tables; `*_pii` tables |
| `dbt/seeds/` | `public_holidays` (empty, waiting for the customer) |
| `dbt/models/staging/intranet/<domain>/` | `hr`, `timesheet`, `crm`, `prm`, `strategic`: `_<domain>__sources.yml`, `stg_*.sql`, `_<domain>__models.yml` (tests) |
| `warehouse/local/init/` | local Postgres only: schemas, roles, grants (run when its database is empty) |
| `warehouse/local/seed/raw_intranet/` | one file per raw table: `CREATE TABLE` + sample rows, applied by `scripts/seed_local.sh` |
| `dbt.Dockerfile`, `elementary.Dockerfile` | the two production images |
| `scripts/` | `seed_local.sh`, `run_local.sh`, and checks to run by hand: repository rules, model conventions, `check_prod_sql.sh` (see `docs/TEST-LOCAL.vi.md`) |
| `docker-compose.yml` | the local test |

## Add a model

1. New raw table? Add `warehouse/local/seed/raw_intranet/<table>.sql` (`CREATE TABLE` with the source's name and columns, plus sample rows;
   the ingestion project must load the same table into `raw_intranet`). Declare it in the `_<domain>__sources.yml` of its domain.
   A model that needs other values (joins, edge cases)? Edit the rows of the seed file of the table it reads.
2. Add `stg_intranet__<table>.sql` and its tests in `_<domain>__models.yml`.
3. New layer? Make the folder under `dbt/models/` and add its block in `dbt/dbt_project.yml`.
4. Create the schema once in the warehouse and grant `dbt_rw` on it (see `warehouse/local/init/02_grants.sql` for the local one).
5. `./scripts/seed_local.sh` (after any seed change), then `./scripts/run_local.sh` to check.

## Run contract (production)

| Variable | | |
|---|---|---|
| `PGHOST`, `PGUSER`, `PGPASSWORD` | required | warehouse, the `dbt_rw` login, its password (secret store) |
| `PGDATABASE` / `PGPORT` / `PGSSLMODE` | `analytics_db` / `5432` / `require` | |
| `DBT_TARGET` | `prod` | profile target in `dbt/profiles.yml`; only `docker-compose.yml` sets `local` (no SSL), so a forgotten variable never uses local settings; both images refuse `local` unless `PGHOST` is `postgres-local`/`localhost` |
| `DBT_ARGS` (dbt image) | `--selector default` | arguments of `dbt build` |

**Network:** neither image needs internet at run time: the dbt packages (including the ones of `edr`) are baked in at build.
Building the images needs internet (PyPI, hub.getdbt.com); the first build takes several minutes, the next ones about a second
when only models change (layers go from the least to the most changing one).

Run the **dbt image first, then the Elementary image**. Both exit non-zero on failure. Elementary writes
`/report/elementary_report.html` (mount `/report` or upload it). Images run as non-root and hold no secrets.
