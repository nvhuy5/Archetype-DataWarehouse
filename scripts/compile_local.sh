#!/usr/bin/env bash
# Shows the SQL that dbt really sends to Postgres (ref/source/macros already resolved). Writes nothing to the database.
#   ./scripts/compile_local.sh               compile every model into report/compiled/ (one .sql file per model)
#   ./scripts/compile_local.sh dim_phase     compile that model (or a dbt selector such as +dim_phase), print its SQL, also save it
set -eu
cd "$(dirname "$0")/.."
export COMPOSE_IGNORE_ORPHANS=True

case "${1:-}" in
  -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
  -*) echo "Unknown option: $1 (see --help)"; exit 2 ;;
esac

out=report/compiled
rm -rf "$out"; mkdir -p "$out"
docker compose up -d --wait postgres-local >/dev/null 2>&1

# The container user cannot write into the repo, so run as the current user; dbt also writes logs, keep them beside the SQL
if ! docker compose run --rm --no-deps -T --user "$(id -u):$(id -g)" -v "$PWD/$out:/out" --entrypoint sh dbt \
  -c 'dbt compile --select "resource_type:model${1:+,$1}" --target-path /out --log-path /out/logs' sh "${1:-}" >"$out/compile.log" 2>&1; then
  tail -20 "$out/compile.log"; echo "dbt compile failed (full log: $out/compile.log)"; exit 1
fi

# Tests are compiled too (in *.yml folders); only the models are of interest
files=$(find "$out/compiled/archetype/models" -name '*.sql' -not -path '*.yml/*' 2>/dev/null | sort)
n=$(echo "$files" | grep -c . || true)
if [ "$n" -eq 0 ]; then
  echo "No model matched '${1:-}' (see $out/compile.log)"; exit 1
elif [ -n "${1:-}" ] && [ "$n" -eq 1 ]; then
  cat "$files"; echo; echo "-- saved: $files"
else
  echo "Compiled $n models into $out/compiled/archetype/models/"
fi
