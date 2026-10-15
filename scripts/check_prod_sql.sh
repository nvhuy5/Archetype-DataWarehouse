#!/usr/bin/env bash
# Tests warehouse/prod on a throw-away PostgreSQL: builds the database the way the platform team and the ingestion project will,
# runs the real dbt and Elementary images on it, and checks what each login can and cannot do. Nothing of the local database is touched.
#   ./scripts/check_prod_sql.sh        about 2 minutes; run it after editing warehouse/prod or the grants/roles of the dbt project
# SSL is off here because the throw-away server has none: the SSL setting of the prod target is not tested.
set -u
cd "$(dirname "$0")/.."
export COMPOSE_IGNORE_ORPHANS=True

ID=checkprod-$$
PG=$ID-pg
REPORT=$(mktemp -d)
chmod 777 "$REPORT"
cleanup() { docker rm -f "$PG" >/dev/null 2>&1; docker network rm "$ID" >/dev/null 2>&1; rm -rf "$REPORT"; }
trap cleanup EXIT

fail=0
ok()  { printf '  OK      %s\n' "$1"; }
bad() { printf '  FAILED  %s\n' "$1"; fail=1; }
psql_admin() { docker exec -i "$PG" psql -q -v ON_ERROR_STOP=1 -U postgres -d analytics_db "$@"; }
as() { docker exec -e PGPASSWORD="$2" "$PG" psql -h localhost -U "$1" -d analytics_db -Atq -c "$3" 2>&1; }  # as <login> <password> <sql>
can()    { if out=$(as "$1" "$2" "$3") ; then ok "$1 can: $4"; else bad "$1 should be able to: $4 ($out)"; fi; }
cannot() { if out=$(as "$1" "$2" "$3"); then bad "$1 must not be able to: $4"; else ok "$1 cannot: $4"; fi; }

echo "Images"
docker compose build dbt elementary >/dev/null 2>&1 || { echo "  FAILED  docker compose build"; exit 1; }
DBT_IMAGE=$(docker compose config --images | grep -E -- '-dbt$')
EDR_IMAGE=$(docker compose config --images | grep -E -- '-elementary$')
[ -n "$DBT_IMAGE" ] && [ -n "$EDR_IMAGE" ] || { echo "  FAILED  image names not found"; exit 1; }

echo "Database built like production"
docker network create "$ID" >/dev/null
docker run -d --name "$PG" --network "$ID" -e POSTGRES_PASSWORD=x -e POSTGRES_DB=analytics_db postgres:16 >/dev/null
until docker exec "$PG" pg_isready -U postgres -d analytics_db >/dev/null 2>&1; do sleep 1; done; sleep 3
# 0. the Azure admin is NOT a superuser: it can create roles and owns the database, nothing more
psql_admin -c "create role stranger login" >/dev/null || exit 1
psql_admin -c "create role azadmin login createrole createdb" -c "alter database analytics_db owner to azadmin" || exit 1
# 1. the platform team creates the login of the ingestion project; the ingestion project creates raw_intranet with it
docker exec -i "$PG" psql -q -v ON_ERROR_STOP=1 -U azadmin -d analytics_db -c "create role adf_loader login" || exit 1
psql_admin -c "create schema raw_intranet authorization adf_loader" || exit 1
# ... and a second source, with its own login, to check that every raw_<source> schema is picked up
docker exec -i "$PG" psql -q -v ON_ERROR_STOP=1 -U azadmin -d analytics_db -c "create role adf_nav login" || exit 1
psql_admin -c "create schema raw_nav authorization adf_nav" || exit 1
# 2. the platform team runs the prod SQL twice (it must be safe to repeat), then sets the passwords
for i in 1 2; do
  cat warehouse/prod/01_schemas_roles.sql warehouse/prod/02_grants.sql | docker exec -i "$PG" psql -q -v ON_ERROR_STOP=1 -U azadmin -d analytics_db -o /dev/null 2>/dev/null \
    && ok "warehouse/prod applied by a non-superuser admin (run $i)" || bad "warehouse/prod failed (run $i)"
done
[ "$(psql_admin -Atc "select pg_has_role('azadmin','dbt_rw','usage') or pg_has_role('azadmin','dbt_rw','set') or pg_has_role('azadmin','adf_loader','usage') or pg_has_role('azadmin','adf_loader','set')")" = f ] \
  && ok "admin gave back the rights it borrowed on dbt_rw and the ingestion login" || bad "admin still holds rights on dbt_rw or the ingestion login"
psql_admin -c "alter role dbt_rw password 'dbtpw'" -c "alter role powerbi_ro password 'pbipw'" -c "alter role pii_admin password 'piipw'" >/dev/null
# 3. the ingestion project loads the raw tables AFTER the grants (the seed files stand in for the real data)
for f in warehouse/local/seed/raw_intranet/*.sql; do
  (echo "set role adf_loader;"; cat "$f") | docker exec -i -e PGOPTIONS="-c client_min_messages=warning" "$PG" psql -q -v ON_ERROR_STOP=1 -U postgres -d analytics_db >/dev/null 2>&1 || { bad "raw load failed: $f"; break; }
done
n=$(psql_admin -Atc "select count(*) from pg_tables where schemaname = 'raw_intranet'"); [ "$n" = "$(ls warehouse/local/seed/raw_intranet/*.sql | wc -l)" ] && ok "$n raw tables loaded by the ingestion login" || bad "raw tables: $n"

(echo "set role adf_nav;"; echo "create table raw_nav.customer (id int); insert into raw_nav.customer values (1);") | psql_admin >/dev/null 2>&1 || bad "raw_nav load failed"
echo "dbt and Elementary images (default target: prod)"
run_env=(--network "$ID" -e PGHOST="$PG" -e PGUSER=dbt_rw -e PGPASSWORD=dbtpw -e PGSSLMODE=disable)
dbt_log=$(docker run --rm "${run_env[@]}" "$DBT_IMAGE" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
summary=$(echo "$dbt_log" | grep -E "Done\. PASS" | tail -1)
case "$summary" in *"ERROR=0"*"SKIP=0"*) ok "dbt build: ${summary#*Done. }";; *) bad "dbt build: ${summary:-no result}"; echo "$dbt_log" | grep -E -B1 -A4 "Database Error" | head -30;; esac
docker run --rm "${run_env[@]}" -v "$REPORT:/report" "$EDR_IMAGE" >/dev/null 2>&1 && [ -s "$REPORT/elementary_report.html" ] \
  && ok "Elementary report written" || bad "Elementary report failed"

echo "What each login can do"
can    powerbi_ro pbipw "select count(*) from mart.mart_ts_details"          "read mart"
can    powerbi_ro pbipw "select count(*) from mart.mart_hr_employee"         "read the masked view in mart"
cannot powerbi_ro pbipw "select count(*) from mart_restricted.mart_hr_employee_pii" "read mart_restricted"
for s in "dwh.dim_employee" "staging.stg_intranet__hr_table_main" "raw_intranet.hr_table_main" "elementary.dbt_run_results"; do
  cannot powerbi_ro pbipw "select count(*) from $s" "read $s"
done
cannot powerbi_ro pbipw "create table public.x (a int)" "create a table in public"
cannot powerbi_ro pbipw "create table mart.x (a int)"   "create a table in mart"
can    pii_admin piipw "select count(*) from mart.mart_hr_employee"          "read mart"
can    pii_admin piipw "select count(*) from mart_restricted.mart_hr_employee_pii" "read mart_restricted"
for s in "dwh.dim_employee" "staging.stg_intranet__hr_table_main" "raw_intranet.hr_table_main"; do
  cannot pii_admin piipw "select count(*) from $s" "read $s"
done
cannot pii_admin piipw "create table mart.x (a int)" "create a table in mart"
can    dbt_rw dbtpw "select count(*) from raw_intranet.hr_table_main"        "read raw_intranet"
can    adf_loader x "select 1" "connect (ingestion login of raw_intranet)"
can    adf_nav x "select 1" "connect (ingestion login of raw_nav)"
cannot stranger x "select 1" "connect (a role outside the project)"
cannot powerbi_ro pbipw "create temp table t (a int)" "create a temporary table"
can    dbt_rw dbtpw "select count(*) from raw_nav.customer"                 "read raw_nav (second source, table created after the grants)"
cannot dbt_rw dbtpw "insert into raw_intranet.hr_table_main (idm) values ('x')" "write raw_intranet"

echo "---"
[ $fail -eq 0 ] && echo "Prod SQL OK" || echo "Prod SQL has problems (see FAILED above)"
exit $fail
