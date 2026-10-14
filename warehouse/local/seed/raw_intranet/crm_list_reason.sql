-- Sample rows for raw_intranet.crm_list_reason (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_reason" (
    "id" integer,
    "reason" varchar(255),
    "cat" integer
);
TRUNCATE raw_intranet."crm_list_reason";
INSERT INTO raw_intranet."crm_list_reason" ("id", "reason", "cat") VALUES
    (1, 'reason_1', 1),
    (2, 'reason_2', 2),
    (3, 'reason_3', 3),
    (4, '  ', 4),
    (5, 'reason_5', 5);
COMMIT;
