-- Sample rows for raw_intranet.hr_table_direct_manager (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_direct_manager";
CREATE TABLE raw_intranet."hr_table_direct_manager" (
    "id_e" integer,
    "id_m" integer,
    "is_main" varchar(1)
);
INSERT INTO raw_intranet."hr_table_direct_manager" ("id_e", "id_m", "is_main") VALUES
    (1, 2, '1'),
    (2, 3, '1'),
    (3, 4, '1'),
    (4, 5, '1'),
    (5, 1, '1');
COMMIT;
