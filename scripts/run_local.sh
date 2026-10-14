#!/usr/bin/env bash
# dbt build (models + tests) and the Elementary report on the local Postgres, with a short summary. Full logs go to report/logs/.
# The raw tables must exist: run ./scripts/seed_local.sh first, and again after editing a seed file.
#   ./scripts/run_local.sh                 whole project
#   ./scripts/run_local.sh --select "--select +fact_timesheet"   arguments of `dbt build` (the Elementary report is always built)
set -u
cd "$(dirname "$0")/.."
export COMPOSE_IGNORE_ORPHANS=True

SELECT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --select) shift; SELECT="${1:-}" ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1 (see --help)"; exit 2 ;;
  esac
  shift
done

if [ -t 1 ]; then OK=$'\e[32mOK\e[0m'; FAIL=$'\e[31mFAILED\e[0m'; WARN=$'\e[33m'; END=$'\e[0m'; else OK=OK; FAIL=FAILED; WARN=""; END=""; fi
strip() { sed 's/\x1b\[[0-9;]*m//g' "$1"; }
status=0
total_start=$SECONDS

# report/ must be writable by the container user; log files live there too
docker compose run --rm --no-deps -T report-dir >/dev/null 2>&1
mkdir -p report/logs || { echo "report/ is not writable. Remove it once: docker run --rm -v \"\$PWD\":/w busybox rm -rf /w/report"; exit 1; }
LOGS=report/logs

stage() { LABEL="$1"; stage_start=$SECONDS; }
took() { printf '(%ss)' $((SECONDS - stage_start)); }

# Progress shown while a stage runs (only on a terminal): spinner, elapsed seconds, and
#  - dbt: a bar made from the "N of M" lines of its log
#  - other stages: the duration of the previous run, as an estimate
bar() { # $1 = done, $2 = total
  local w=20 f=$(( $1 * 20 / $2 )) out="" i
  for ((i = 0; i < w; i++)); do [ $i -lt $f ] && out+="█" || out+="░"; done
  printf '%s' "$out"
}
progress() { # $1 = log, $2 = stage key
  local last n m phase
  if [ "$2" = dbt ]; then
    # dbt runs twice in one log: first the Elementary tables, then the models and tests
    phase="elementary tables"; [ "$(sed 's/\x1b\[[0-9;]*m//g' "$1" | grep -c 'Done\. PASS')" -ge 1 ] && phase="models + tests"
    last=$(tail -n 200 "$1" | sed 's/\x1b\[[0-9;]*m//g' | grep -oE '[0-9]+ of [0-9]+ ' | awk '$3 > 1 { l = $0 } END { print l }')
    if [ -n "$last" ]; then n=${last%% of *}; m=${last##* of }; m=${m% }; printf '%s %s %s/%s' "$phase" "$(bar "$n" "$m")" "$n" "$m"; return; fi
    printf '%s' "$phase"; return
  fi
  [ -s "$LOGS/.last_$2" ] && printf '(usually ~%ss)' "$(cat "$LOGS/.last_$2")"
}
# run_stage <key> <logfile> <command...>: runs the command, sets RC. Log is overwritten.
run_stage() {
  local key=$1 log=$2; shift 2
  "$@" >"$log" 2>&1 &
  local pid=$! i=0 frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  trap 'kill $pid 2>/dev/null; printf "\033[?25h\n"; exit 130' INT TERM
  if [ -t 1 ]; then
    printf '\033[?25l'
    while kill -0 $pid 2>/dev/null; do
      printf '\r%-34s%s %3ss  %s\033[K' "$LABEL" "${frames:i%10:1}" $((SECONDS - stage_start)) "$(progress "$log" "$key")"
      i=$((i + 1)); sleep 0.2
    done
    printf '\r\033[K\033[?25h'
  fi
  wait $pid; RC=$?
  trap - INT TERM
  [ $RC -eq 0 ] && echo $((SECONDS - stage_start)) >"$LOGS/.last_$key"
  printf '%-34s' "$LABEL"
}

# 1. images
stage "[1/4] Build images"
run_stage build "$LOGS/1-build.log" docker compose build
if [ $RC -eq 0 ]; then echo "$OK  $(took)"; else echo "$FAIL"; tail -15 "$LOGS/1-build.log"; exit 1; fi

# 2. raw data: only checked here, seed_local.sh creates it
stage "[2/4] Raw data (seeded)"
seed_hash() { find warehouse/local/seed -name '*.sql' | LC_ALL=C sort | xargs cat | sha256sum | cut -d' ' -f1; }
psql_local() { docker compose exec -T postgres-local psql -At -U postgres -d analytics_db -c "$1"; }
docker compose up -d --wait postgres-local >"$LOGS/2-raw.log" 2>&1
expected=$(ls warehouse/local/seed/raw_intranet/*.sql | wc -l)
have=$(psql_local "select count(*) from information_schema.tables where table_schema = 'raw_intranet'" 2>>"$LOGS/2-raw.log" || echo 0)
if [ "$have" != "$expected" ]; then
  printf '%-34s' "$LABEL"; echo "$FAIL  raw_intranet has $have of $expected tables. Run ./scripts/seed_local.sh first"; exit 1
fi
printf '%-34s' "$LABEL"; echo "$OK  $have tables"
stamp=$(psql_local "select hash || ' ' || seeded_on from public.seed_stamp" 2>/dev/null || true)
if [ "${stamp%% *}" != "$(seed_hash)" ]; then
  echo "      ${WARN}! Seed files changed since the last ./scripts/seed_local.sh: dbt runs on the old rows${END}"
elif [ -n "$stamp" ] && [ "$(( ($(date +%s) - $(date -d "${stamp##* }" +%s)) / 86400 ))" -gt 7 ]; then
  echo "      ${WARN}! Raw data was seeded on ${stamp##* }: dates relative to today have drifted, run ./scripts/seed_local.sh${END}"
fi

# 3. dbt
stage "[3/4] dbt build"
run_stage dbt "$LOGS/3-dbt.log" docker compose run --rm --no-deps -T -e DBT_ARGS="${SELECT:---selector default}" dbt
rc=$RC
summary=$(strip "$LOGS/3-dbt.log" | grep -E "Done\. PASS=" | tail -1 | sed 's/^[0-9:]* *//; s/ TOTAL=.*//; s/Done\. //')
if [ $rc -eq 0 ]; then echo "$OK  $summary  $(took)"; else echo "$FAIL  $summary  $(took)"; status=1; fi
strip "$LOGS/3-dbt.log" | grep -E "^[0-9:]+ +[0-9]+ of [0-9]+ (WARN|ERROR|FAIL)" | sed 's/^[0-9:]* *//' | sort -u | head -15 |
  while read -r line; do echo "      ${WARN}! ${line}${END}"; done
[ $rc -ne 0 ] && { strip "$LOGS/3-dbt.log" | grep -A6 -E "Database Error|Compilation Error" | head -20; }

# 4. Elementary report (always built)
stage "[4/4] Elementary report"
rm -f report/elementary_report.html
run_stage elementary "$LOGS/4-elementary.log" docker compose run --rm --no-deps -T elementary
if [ $RC -eq 0 ] && [ -s report/elementary_report.html ]; then
  echo "$OK  report/elementary_report.html  $(took)"
else
  echo "$FAIL"; strip "$LOGS/4-elementary.log" | grep -vE "^(INFO|DEBUG):" | tail -12; status=1
fi

echo "---"
[ $status -eq 0 ] && echo "Done in $((SECONDS - total_start))s. Details: $LOGS/" || echo "Finished with errors in $((SECONDS - total_start))s. Details: $LOGS/"
exit $status
