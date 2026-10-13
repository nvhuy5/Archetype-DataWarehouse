#!/usr/bin/env bash
# Runs the whole chain locally and prints a short summary. Full logs go to report/logs/.
#   ./scripts/run_local.sh                 sample data, whole project
#   ./scripts/run_local.sh --reset         wipe the database first (docker compose down -v)
#   ./scripts/run_local.sh --reset-data    recreate the sample rows (use after changing OVERRIDES in ingest/load_raw.py)
#   ./scripts/run_local.sh --select "--select +fact_timesheet"   arguments of `dbt build` (the Elementary report is always built)
#   INGEST_MODE=mysql MYSQL_HOST=... MYSQL_USER=... MYSQL_PASSWORD=... ./scripts/run_local.sh --mysql   real Intranet data
set -u
cd "$(dirname "$0")/.."
export COMPOSE_IGNORE_ORPHANS=True

SELECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --reset) RESET=1 ;;
    --reset-data) export SAMPLE_RESET=1 ;;
    --mysql) export INGEST_MODE=mysql ;;
    --select) shift; SELECT="${1:-}" ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1 (see --help)"; exit 2 ;;
  esac
  shift
done

if [ -t 1 ]; then OK=$'\e[32mOK\e[0m'; FAIL=$'\e[31mFAILED\e[0m'; WARN=$'\e[33m'; END=$'\e[0m'; else OK=OK; FAIL=FAILED; WARN=""; END=""; fi
strip() { sed 's/\x1b\[[0-9;]*m//g' "$1"; }
status=0
total_start=$SECONDS

[ "${RESET:-0}" = 1 ] && docker compose down -v >/dev/null 2>&1

# report/ must be writable by the container user; log files live there too
docker compose run --rm --no-deps -T report-dir >/dev/null 2>&1
mkdir -p report/logs || { echo "report/ is not writable. Remove it once: docker run --rm -v \"\$PWD\":/w busybox rm -rf /w/report"; exit 1; }
LOGS=report/logs

stage() { printf '%-34s' "$1"; stage_start=$SECONDS; }
took() { printf '(%ss)' $((SECONDS - stage_start)); }

# 1. images
stage "[1/4] Build images"
if docker compose build >"$LOGS/1-build.log" 2>&1; then echo "$OK  $(took)"; else echo "$FAIL"; tail -15 "$LOGS/1-build.log"; exit 1; fi

# 2. warehouse + raw data
stage "[2/4] Raw data (${INGEST_MODE:-sample})"
docker compose up -d --wait pg-analytics >"$LOGS/2-ingest.log" 2>&1
if docker compose run --rm --no-deps -T ingest >>"$LOGS/2-ingest.log" 2>&1; then
  created=$(grep -c "rows created\| rows$" "$LOGS/2-ingest.log"); kept=$(grep -c ": kept" "$LOGS/2-ingest.log")
  echo "$OK  $created tables loaded, $kept kept  $(took)"
else
  echo "$FAIL"; grep -E "FAILED|Error|error" "$LOGS/2-ingest.log" | head -10; exit 1
fi

# 3. dbt
stage "[3/4] dbt build"
docker compose run --rm --no-deps -T -e DBT_ARGS="${SELECT:---selector default}" dbt >"$LOGS/3-dbt.log" 2>&1
rc=$?
summary=$(strip "$LOGS/3-dbt.log" | grep -E "Done\. PASS=" | tail -1 | sed 's/^[0-9:]* *//; s/ TOTAL=.*//; s/Done\. //')
if [ $rc -eq 0 ]; then echo "$OK  $summary  $(took)"; else echo "$FAIL  $summary  $(took)"; status=1; fi
strip "$LOGS/3-dbt.log" | grep -E "^[0-9:]+ +[0-9]+ of [0-9]+ (WARN|ERROR|FAIL)" | sed 's/^[0-9:]* *//' | sort -u | head -15 |
  while read -r line; do echo "      ${WARN}! ${line}${END}"; done
[ $rc -ne 0 ] && { strip "$LOGS/3-dbt.log" | grep -A6 -E "Database Error|Compilation Error" | head -20; }

# 4. Elementary report (always built)
stage "[4/4] Elementary report"
rm -f report/elementary_report.html
docker compose run --rm --no-deps -T elementary >"$LOGS/4-elementary.log" 2>&1
if [ $? -eq 0 ] && [ -s report/elementary_report.html ]; then
  echo "$OK  report/elementary_report.html  $(took)"
else
  echo "$FAIL"; strip "$LOGS/4-elementary.log" | grep -vE "^(INFO|DEBUG):" | tail -12; status=1
fi

echo "---"
[ $status -eq 0 ] && echo "Done in $((SECONDS - total_start))s. Details: $LOGS/" || echo "Finished with errors in $((SECONDS - total_start))s. Details: $LOGS/"
exit $status
