# Elementary image: reads the `elementary` schema that `dbt build` filled and writes a static HTML report.
#   docker build -f elementary.Dockerfile -t archetype-elementary:<tag> .
# Run it after the dbt image. Same PG* variables. Mount or upload /report afterwards.
FROM python:3.12-slim

WORKDIR /app
COPY dbt/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY dbt/ .
ENV DBT_PROFILES_DIR=/app
RUN dbt deps

# edr runs `dbt deps` inside its own package folder, so the user must be able to write there
RUN useradd --system --uid 10001 --create-home edr && mkdir /report \
 && chown -R edr /app /report /usr/local/lib/python3.12/site-packages/elementary
USER edr
VOLUME /report

ENTRYPOINT ["edr", "report", "--profiles-dir", "/app", "--project-dir", "/app", "--file-path", "/report/elementary_report.html"]
