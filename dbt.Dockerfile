# dbt image: runs `dbt build` (models + tests). Build from this folder:
#   docker build -f dbt.Dockerfile -t archetype-dbt:<tag> .
FROM python:3.12-slim

WORKDIR /app
COPY dbt/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY dbt/ .
ENV DBT_PROFILES_DIR=/app
RUN dbt deps

RUN useradd --system --uid 10001 --create-home dbt && chown -R dbt /app
USER dbt

# PGHOST / PGUSER / PGPASSWORD (PGDATABASE, PGPORT, PGSSLMODE optional) come from the environment, never baked in.
# DBT_ARGS selects what to build. Exit code != 0 when a model or test fails.
ENV DBT_ARGS="--selector default"
# Elementary tables first (they receive the test results of the build that follows)
ENTRYPOINT ["sh", "-c", "dbt run --select elementary && dbt build ${DBT_ARGS}"]
