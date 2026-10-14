-- Sample rows for raw_intranet.hr_menu_employee_level (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_employee_level" (
    "employee_level_id" integer,
    "title" varchar(100),
    "code" varchar(10),
    "department_id" integer,
    "level_in_dept" integer,
    "hide" smallint
);
TRUNCATE raw_intranet."hr_menu_employee_level";
INSERT INTO raw_intranet."hr_menu_employee_level" ("employee_level_id", "title", "code", "department_id", "level_in_dept", "hide") VALUES
    (1, 'title_1', 'code_1', 1, 1, 1),
    (2, 'title_2', 'code_2', 2, 2, 2),
    (3, 'title_3', 'code_3', 3, 3, 3),
    (4, '  ', '  ', 4, 4, 4),
    (5, 'title_5', 'code_5', 5, 5, 5);
COMMIT;
