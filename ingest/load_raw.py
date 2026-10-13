"""Fills raw_intranet. Stands in for Azure Data Factory when testing locally.

INGEST_MODE=sample  few synthetic rows per table, built from the raw table definitions (default, no source needed)
INGEST_MODE=mysql   full copy of every raw table from the Intranet MySQL database

Each table is replaced in one transaction: if the copy fails, the old rows stay. An empty extract is rejected
(set ALLOW_EMPTY=table1,table2 to accept it for given tables).
Env: PGHOST PGUSER PGPASSWORD [PGDATABASE PGPORT]; for mysql: MYSQL_HOST MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE [MYSQL_PORT]
"""
import datetime
import os
import sys

import psycopg2
from psycopg2.extras import execute_values

MODE = os.environ.get("INGEST_MODE", "sample")
SAMPLE_ROWS = int(os.environ.get("SAMPLE_ROWS", "5"))
ALLOW_EMPTY = set(filter(None, os.environ.get("ALLOW_EMPTY", "").split(",")))
BATCH = 5000


def pg_connect():
    return psycopg2.connect(
        host=os.environ["PGHOST"], user=os.environ["PGUSER"], password=os.environ["PGPASSWORD"],
        dbname=os.environ.get("PGDATABASE", "analytics_db"), port=os.environ.get("PGPORT", "5432"),
        sslmode=os.environ.get("PGSSLMODE", "prefer"),
    )


def raw_tables(cur):
    cur.execute(
        "select table_name, column_name, data_type, character_maximum_length from information_schema.columns "
        "where table_schema = 'raw_intranet' order by table_name, ordinal_position"
    )
    tables = {}
    for table, col, dtype, length in cur.fetchall():
        tables.setdefault(table, []).append((col, dtype, length))
    return tables


def sample_value(dtype, length, col, i):
    if dtype in ("integer", "bigint", "smallint"):
        return i
    if dtype in ("numeric", "real", "double precision"):
        return i
    if dtype == "date":
        return datetime.date(2026, 1, 1) + datetime.timedelta(days=i)
    if dtype.startswith("timestamp"):
        return datetime.datetime(2026, 1, 1, 8, 0) + datetime.timedelta(days=i)
    if i % 4 == 0:
        return "  "  # blank text, staging must turn it into NULL
    text = f"{col}_{i}"
    return text[:length] if length else text


def sample_rows(cols):
    for i in range(1, SAMPLE_ROWS + 1):
        yield tuple(sample_value(dtype, length, col, i) for col, dtype, length in cols)


def mysql_rows(conn, table, cols):
    cur = conn.cursor()  # unbuffered: rows are streamed, the 1.5M-row timesheet table does not fit in a list
    cur.execute("select %s from `%s`" % (", ".join("`%s`" % c for c, _, _ in cols), table))
    while True:
        chunk = cur.fetchmany(BATCH)
        if not chunk:
            return
        yield from chunk


def main():
    src = None
    if MODE == "mysql":
        import pymysql
        from pymysql.cursors import SSCursor

        src = pymysql.connect(
            host=os.environ["MYSQL_HOST"], user=os.environ["MYSQL_USER"], password=os.environ["MYSQL_PASSWORD"],
            database=os.environ["MYSQL_DATABASE"], port=int(os.environ.get("MYSQL_PORT", "3306")),
            cursorclass=SSCursor, read_timeout=3600,
        )
    elif MODE != "sample":
        sys.exit("INGEST_MODE must be sample or mysql")

    dst = pg_connect()
    failed = []
    with dst.cursor() as cur:
        tables = raw_tables(cur)
    for table, cols in tables.items():
        try:
            rows = mysql_rows(src, table, cols) if src else sample_rows(cols)
            with dst.cursor() as cur:
                cur.execute('delete from raw_intranet."%s"' % table)
                sql = 'insert into raw_intranet."%s" (%s) values %%s' % (table, ", ".join('"%s"' % c for c, _, _ in cols))
                n, batch = 0, []
                for row in rows:
                    batch.append(row)
                    if len(batch) >= BATCH:
                        execute_values(cur, sql, batch)
                        n, batch = n + len(batch), []
                if batch:
                    execute_values(cur, sql, batch)
                    n += len(batch)
                if n == 0 and table not in ALLOW_EMPTY:
                    raise RuntimeError("empty extract rejected")
            dst.commit()
            print(f"{table}: {n} rows", flush=True)
        except Exception as exc:  # keep the old rows of this table, go on with the others
            dst.rollback()
            failed.append(table)
            print(f"{table}: FAILED ({exc})", file=sys.stderr, flush=True)
    if failed:
        sys.exit(f"{len(failed)} table(s) failed: {', '.join(failed)}")


if __name__ == "__main__":
    main()
