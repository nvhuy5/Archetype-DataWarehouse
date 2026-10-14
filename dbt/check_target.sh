#!/bin/sh
# Runs first in both images. The local target (no SSL) must never point at anything but a local Postgres.
if [ "${DBT_TARGET:-prod}" = local ]; then
  case "${PGHOST:-}" in
    postgres-local|localhost|127.0.0.1) ;;
    *) echo "Refusing to run: DBT_TARGET=local but PGHOST='${PGHOST:-}' is not the local Postgres." >&2; exit 1 ;;
  esac
fi
