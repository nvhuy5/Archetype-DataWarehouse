-- Sample rows for raw_intranet.prm_budget_revision_setup (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."prm_budget_revision_setup" (
    "prm_budget_revision_setup_id" integer,
    "rev_id" integer,
    "dept_id" integer,
    "phase_id" integer,
    "added_by" varchar(150),
    "added_at" timestamp
);
TRUNCATE raw_intranet."prm_budget_revision_setup";
INSERT INTO raw_intranet."prm_budget_revision_setup" ("prm_budget_revision_setup_id", "rev_id", "dept_id", "phase_id", "added_by", "added_at") VALUES
    (1, 1, 1, 1, 'added_by_1', '2026-01-02 08:00:00'),
    (2, 2, 2, 2, 'added_by_2', '2026-01-03 08:00:00'),
    (3, 3, 3, 3, 'added_by_3', '2026-01-04 08:00:00'),
    (4, 4, 4, 4, '  ', '2026-01-05 08:00:00'),
    (5, 5, 5, 5, 'added_by_5', '2026-01-06 08:00:00');
COMMIT;
