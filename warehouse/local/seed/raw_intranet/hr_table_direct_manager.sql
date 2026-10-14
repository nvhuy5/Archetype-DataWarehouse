-- Sample rows for raw_intranet.hr_table_direct_manager (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_direct_manager" (
    "id_e" integer,
    "id_m" integer,
    "is_main" varchar(1)
);
TRUNCATE raw_intranet."hr_table_direct_manager";
INSERT INTO raw_intranet."hr_table_direct_manager" ("id_e", "id_m", "is_main") VALUES
    (1, 2, '1'),
    (2, 3, '1'),
    (3, 4, '1'),
    (4, 5, '1'),
    (5, 1, '1');
COMMIT;
