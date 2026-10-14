# Elementary image: reads the `elementary` schema that `dbt build` filled and writes a static HTML report.
#   docker build -f elementary.Dockerfile -t archetype-elementary:<tag> .
# Run it after the dbt image. Same PG* variables. Mount or upload /report afterwards.
# Same layer order as dbt.Dockerfile (layers 1 and 2 are identical, so they come from the build cache of the dbt image).
FROM python:3.12-slim

WORKDIR /app

# 1. Python packages
COPY dbt/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. dbt packages of the project
COPY dbt/packages.yml /deps/packages.yml
RUN printf "name: deps\nversion: '1.0.0'\nconfig-version: 2\n" > /deps/dbt_project.yml \
 && dbt deps --project-dir /deps \
 && mv /deps/dbt_packages /deps/package-lock.yml /app/ \
 && rm -rf /deps

# 3. edr has its own dbt project (inside the package). It runs `dbt deps` at run time only when its packages are missing,
#    so installing them now means the report needs no internet. The user must be able to write in that folder (only that folder).
ENV EDR_DBT=/usr/local/lib/python3.12/site-packages/elementary/monitor/dbt_project
RUN cd "$EDR_DBT" && dbt deps
RUN useradd --system --uid 10001 --create-home edr && mkdir /report \
 && chown edr /app /report && chown -R edr "$EDR_DBT"

# 4. The dbt project (edr reads profiles and project from /app)
ENV DBT_PROFILES_DIR=/app
COPY --chown=edr dbt/ .
USER edr
VOLUME /report

ENTRYPOINT ["sh", "-c", "sh /app/check_target.sh && exec edr report --profiles-dir /app --project-dir /app --file-path /report/elementary_report.html"]
