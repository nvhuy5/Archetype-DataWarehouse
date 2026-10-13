# Loader that fills raw_intranet (stands in for Azure Data Factory in the local test). Build from this folder:
#   docker build -f ingest.Dockerfile -t archetype-ingest:<tag> .
FROM python:3.12-slim

WORKDIR /app
COPY ingest/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ingest/load_raw.py .

RUN useradd --system --uid 10001 --create-home ingest
USER ingest
ENTRYPOINT ["python", "load_raw.py"]
