-- Sample rows for raw_intranet.timesheet_delta (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."timesheet_delta";
CREATE TABLE raw_intranet."timesheet_delta" (
    "id" integer,
    "typedelta" varchar(15),
    "jobno" varchar(60),
    "empcode" varchar(15),
    "phase" varchar(15),
    "dept" varchar(15),
    "delta" real,
    "dateupdate" date
);
INSERT INTO raw_intranet."timesheet_delta" ("id", "typedelta", "jobno", "empcode", "phase", "dept", "delta", "dateupdate") VALUES
    (1, 'typedelta_1', 'jobno_1', 'empcode_1', 'phase_1', 'dept_1', 1, '2026-01-02'),
    (2, 'typedelta_2', 'jobno_2', 'empcode_2', 'phase_2', 'dept_2', 2, '2026-01-03'),
    (3, 'typedelta_3', 'jobno_3', 'empcode_3', 'phase_3', 'dept_3', 3, '2026-01-04'),
    (4, '  ', '  ', '  ', '  ', '  ', 4, '2026-01-05'),
    (5, 'typedelta_5', 'jobno_5', 'empcode_5', 'phase_5', 'dept_5', 5, '2026-01-06');
COMMIT;
