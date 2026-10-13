# dbt + Elementary framework

🇻🇳 [Tiếng Việt](README.vi.md) · 📘 [Hướng dẫn cho khách hàng (VI): dbt & Elementary là gì?](GUIDELINE.vi.md)

Standard skeleton, with one sample source table and one sample model to prove it works. From here on you only add models.

```
Intranet --[ADF]--> raw_intranet --[dbt image: dbt build]--> staging (→ dwh → mart) --[Elementary image]--> HTML report
```

## Try it (Docker only)

```bash
docker compose run --build --rm elementary      # report: ./report/elementary_report.html
docker compose down -v                          # clean up
```

Starts a source DB (3 rows) and an empty warehouse, copies source → raw (what ADF does), runs `dbt build`
(model + tests), then Elementary.

## Layout

| Path | |
|---|---|
| `dbt/` | the dbt project |
| `dbt/models/staging/` | `_sources.yml` (raw tables), `stg_*.sql`, `_staging.yml` (tests) |
| `dbt.Dockerfile`, `elementary.Dockerfile` | the two images |
| `sample/` | demo only: `source.sql` (source table), `raw_init.sql` (what the platform creates once), `ingest_demo.sh` (stand-in for ADF) |
| `docker-compose.yml` | the local test |

## Add a model

1. New raw table? Add it to `dbt/models/staging/_sources.yml` (and ADF must load it into `raw_intranet`, same name).
2. Add `stg_<source>__<table>.sql` and its tests in `_staging.yml`.
3. New layer (`dwh`, `mart`)? Make the folder under `dbt/models/` and uncomment its block in `dbt/dbt_project.yml`.
4. Create the schema once in the warehouse and grant `dbt_rw` on it (see `sample/raw_init.sql`).
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
