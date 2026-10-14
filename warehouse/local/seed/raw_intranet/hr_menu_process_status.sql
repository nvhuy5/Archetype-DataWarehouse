-- Sample rows for raw_intranet.hr_menu_process_status (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_process_status" (
    "idstatus" integer,
    "name" varchar(100)
);
TRUNCATE raw_intranet."hr_menu_process_status";
INSERT INTO raw_intranet."hr_menu_process_status" ("idstatus", "name") VALUES
    (5, 'name_1'),
    (6, 'name_2'),
    (7, 'name_3'),
    (8, '  '),
    (9, 'name_5');
COMMIT;
