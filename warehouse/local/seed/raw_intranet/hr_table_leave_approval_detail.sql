-- Sample rows for raw_intranet.hr_table_leave_approval_detail (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_leave_approval_detail" (
    "approval_id" integer,
    "date" date,
    "is_haftday" smallint
);
TRUNCATE raw_intranet."hr_table_leave_approval_detail";
INSERT INTO raw_intranet."hr_table_leave_approval_detail" ("approval_id", "date", "is_haftday") VALUES
    (1, '2026-01-02', 1),
    (2, '2026-01-03', 2),
    (3, '2026-01-04', 3),
    (4, '2026-01-05', 4),
    (5, '2026-01-06', 5);
COMMIT;
