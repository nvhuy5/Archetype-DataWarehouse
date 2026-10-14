-- Sample rows for raw_intranet.hr_table_leave_approval_detail (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_leave_approval_detail";
CREATE TABLE raw_intranet."hr_table_leave_approval_detail" (
    "approval_id" integer,
    "date" date,
    "is_haftday" smallint
);
INSERT INTO raw_intranet."hr_table_leave_approval_detail" ("approval_id", "date", "is_haftday") VALUES
    (1, '2026-01-02', 1),
    (2, '2026-01-03', 2),
    (3, '2026-01-04', 3),
    (4, '2026-01-05', 4),
    (5, '2026-01-06', 5);
COMMIT;
