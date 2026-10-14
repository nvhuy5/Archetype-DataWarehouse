# dbt image: runs `dbt build` (models + tests). Build from this folder:
#   docker build -f dbt.Dockerfile -t archetype-dbt:<tag> .
# Layers go from the one that changes least to the one that changes most, so editing a model only rebuilds the last layer.
FROM python:3.12-slim

WORKDIR /app

# 1. Python packages: rebuilt only when requirements.txt changes (shared with elementary.Dockerfile)
COPY dbt/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. dbt packages (hub.getdbt.com): rebuilt only when packages.yml changes. `dbt deps` needs a project file, a stub is enough.
COPY dbt/packages.yml /deps/packages.yml
RUN printf "name: deps\nversion: '1.0.0'\nconfig-version: 2\n" > /deps/dbt_project.yml \
 && dbt deps --project-dir /deps \
 && mv /deps/dbt_packages /deps/package-lock.yml /app/ \
 && rm -rf /deps

# 3. Non-root user; /app itself is writable for dbt's target/ and logs/
RUN useradd --system --uid 10001 --create-home dbt && chown dbt /app

# 4. The dbt project: the only layer that changes with day-to-day work
ENV DBT_PROFILES_DIR=/app
COPY --chown=dbt dbt/ .
USER dbt

# PGHOST / PGUSER / PGPASSWORD (PGDATABASE, PGPORT, PGSSLMODE optional) come from the environment, never baked in.
# DBT_ARGS selects what to build. Exit code != 0 when a model or test fails.
ENV DBT_ARGS="--selector default"
# Elementary tables first (they receive the test results of the build that follows)
ENTRYPOINT ["sh", "-c", "sh /app/check_target.sh && dbt run --select elementary && dbt build ${DBT_ARGS}"]
