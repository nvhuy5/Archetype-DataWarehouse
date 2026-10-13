#!/bin/sh
# What Azure Data Factory does: copy each source table as it is into raw_intranet.<same name>.
# Env: SRC_URL (source database), DST_URL (analytics_db)
set -e
for t in $(psql "$SRC_URL" -Atc "select tablename from pg_tables where schemaname = 'public'"); do
  psql "$DST_URL" -qc "delete from raw_intranet.\"$t\""
  psql "$SRC_URL" -c "\copy \"$t\" to stdout csv" | psql "$DST_URL" -c "\copy raw_intranet.\"$t\" from stdin csv"
done
