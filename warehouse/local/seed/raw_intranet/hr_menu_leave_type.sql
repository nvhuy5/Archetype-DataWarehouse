-- Sample rows for raw_intranet.hr_menu_leave_type (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_leave_type";
CREATE TABLE raw_intranet."hr_menu_leave_type" (
    "idht" bigint,
    "code" varchar(20),
    "description" varchar(255),
    "frequency" varchar(255),
    "type" smallint,
    "nav_item_code" varchar(100),
    "nav_code" varchar(10)
);
INSERT INTO raw_intranet."hr_menu_leave_type" ("idht", "code", "description", "frequency", "type", "nav_item_code", "nav_code") VALUES
    (1, 'code_1', 'description_1', 'frequency_1', 1, 'nav_item_code_1', 'nav_code_1'),
    (2, 'code_2', 'description_2', 'frequency_2', 2, 'nav_item_code_2', 'nav_code_2'),
    (3, 'code_3', 'description_3', 'frequency_3', 3, 'nav_item_code_3', 'nav_code_3'),
    (4, '  ', '  ', '  ', 4, '  ', '  '),
    (5, 'code_5', 'description_5', 'frequency_5', 5, 'nav_item_code_5', 'nav_code_5');
COMMIT;
