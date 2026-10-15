#!/usr/bin/env bash
# Fills the raw tables of the local Postgres with the sample rows of warehouse/local/seed/raw_intranet (one file per table).
# Run it once, then again after adding or editing a seed file. ./scripts/run_local.sh only reads what is here.
#   ./scripts/seed_local.sh           (re)create every raw table from its seed file
#   ./scripts/seed_local.sh --reset   wipe the whole local database first (docker compose down -v), then seed
set -eu
cd "$(dirname "$0")/.."
export COMPOSE_IGNORE_ORPHANS=True

case "${1:-}" in
  "") ;;
  --reset) docker compose down -v >/dev/null 2>&1 ;;
  -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
  *) echo "Unknown option: $1 (see --help)"; exit 2 ;;
esac

start=$SECONDS
docker compose up -d --wait postgres-local >/dev/null 2>&1

# Every file creates its table once (like the ingestion project, rows are replaced, never the table, so the staging views stay)
# and replaces its rows inside one transaction; a failing file leaves its table as it was.
count=$(docker compose exec -T -e PGOPTIONS="-c client_min_messages=warning" postgres-local sh -c '
  n=0
  for f in /seed/raw_intranet/*.sql; do
    psql -q -v ON_ERROR_STOP=1 -U postgres -d archetype_dwh -f "$f" >/dev/null || { echo "FAILED: $f (columns changed in an existing table? run ./scripts/seed_local.sh --reset)" >&2; exit 1; }
    n=$((n + 1))
  done
  echo "$n"
') || exit 1

# Stamp read by run_local.sh: which seed files were applied, and when
hash=$(find warehouse/local/seed -name '*.sql' | LC_ALL=C sort | xargs cat | sha256sum | cut -d' ' -f1)
docker compose exec -T -e PGOPTIONS="-c client_min_messages=warning" postgres-local psql -q -v ON_ERROR_STOP=1 -U postgres -d archetype_dwh <<SQL
CREATE TABLE IF NOT EXISTS public.seed_stamp (hash text, seeded_on date);
TRUNCATE public.seed_stamp;
INSERT INTO public.seed_stamp VALUES ('$hash', current_date);
SQL

echo "Seeded $count raw tables in $((SECONDS - start))s. Next: ./scripts/run_local.sh"
