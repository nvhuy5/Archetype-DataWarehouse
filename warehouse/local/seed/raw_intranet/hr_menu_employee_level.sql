-- Sample rows for raw_intranet.hr_menu_employee_level (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_employee_level";
CREATE TABLE raw_intranet."hr_menu_employee_level" (
    "employee_level_id" integer,
    "title" varchar(100),
    "code" varchar(10),
    "department_id" integer,
    "level_in_dept" integer,
    "hide" smallint
);
INSERT INTO raw_intranet."hr_menu_employee_level" ("employee_level_id", "title", "code", "department_id", "level_in_dept", "hide") VALUES
    (1, 'title_1', 'code_1', 1, 1, 1),
    (2, 'title_2', 'code_2', 2, 2, 2),
    (3, 'title_3', 'code_3', 3, 3, 3),
    (4, '  ', '  ', 4, 4, 4),
    (5, 'title_5', 'code_5', 5, 5, 5);
COMMIT;
