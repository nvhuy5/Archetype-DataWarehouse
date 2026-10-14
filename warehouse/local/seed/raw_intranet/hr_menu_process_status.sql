-- Sample rows for raw_intranet.hr_menu_process_status (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_process_status";
CREATE TABLE raw_intranet."hr_menu_process_status" (
    "idstatus" integer,
    "name" varchar(100)
);
INSERT INTO raw_intranet."hr_menu_process_status" ("idstatus", "name") VALUES
    (5, 'name_1'),
    (6, 'name_2'),
    (7, 'name_3'),
    (8, '  '),
    (9, 'name_5');
COMMIT;
