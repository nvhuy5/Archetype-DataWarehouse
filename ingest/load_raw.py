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


TODAY = datetime.date.today()
CYCLE = lambda *vals: (lambda i: vals[(i - 1) % len(vals)])

# Values that make the synthetic rows join each other (every id is the row number i) and exercise the business rules of dwh.
OVERRIDES = {
    ("hr_table_main", "estatus"): lambda i: 8 if i == 5 else 7,
    ("hr_table_main", "id_md5"): lambda i: f"md5_{i}",
    ("hr_table_main", "type"): CYCLE("Local", "Foreign"),
    ("hr_table_main", "p_reference"): CYCLE("a@archetype-group.com", "Agency: x", "Direct", "internet", "other"),
    ("hr_table_main", "birthday"): lambda i: datetime.date(1990, 1, 1) + datetime.timedelta(days=i),
    ("hr_table_main", "startworking"): lambda i: datetime.date(2024, 1, 1) + datetime.timedelta(days=i),
    ("hr_table_phone_interview", "idm"): lambda i: f"md5_{i}",
    ("hr_menu_process_status", "idstatus"): lambda i: i + 4,
    ("hr_menu_department", "business_line"): CYCLE("AMP", "BDE", "IPE", "", "OTH"),
    ("hr_table_direct_manager", "id_m"): lambda i: i % 5 + 1,
    ("hr_table_direct_manager", "is_main"): lambda i: "1",
    ("hr_table_contract", "cfrom"): lambda i: datetime.date(2025, 1, 1),
    ("hr_table_contract", "cto"): lambda i: datetime.date(2027, 12, 31),
    ("hr_table_contract", "tdate"): lambda i: datetime.date(2026, 6, 30) if i == 5 else None,
    ("hr_table_contract", "probation_end_date"): lambda i: None if i <= 3 else datetime.date(2025, 6, 30),
    ("timesheet_phase_2015", "type"): CYCLE("project", "vacation", "support", "support_detail", "project"),
    ("timesheet_phase_2015", "name"): CYCLE("Design", "Annual leave", "Meeting", "Detail", "Construction"),
    ("timesheet_entry_2015", "date"): lambda i: TODAY - datetime.timedelta(days=i),
    ("timesheet_entry_2015", "time"): lambda i: 8,
    ("timesheet_entry_2015", "validated"): lambda i: i % 3,
    ("timesheet_entry_2015", "employee_level"): lambda i: str(i),
}


def sample_value(dtype, length, col, i, table=None):
    if (table, col) in OVERRIDES:
        return OVERRIDES[(table, col)](i)
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


def sample_rows(table, cols):
    for i in range(1, SAMPLE_ROWS + 1):
        yield tuple(sample_value(dtype, length, col, i, table) for col, dtype, length in cols)


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
            rows = mysql_rows(src, table, cols) if src else sample_rows(table, cols)
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
