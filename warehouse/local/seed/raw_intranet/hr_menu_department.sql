-- Sample rows for raw_intranet.hr_menu_department (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_department" (
    "id" integer,
    "group_id" integer,
    "name" varchar(100),
    "code" varchar(3),
    "description" varchar(200),
    "technical_dept" smallint,
    "business_line" varchar(5),
    "ds_pm" smallint,
    "hide" varchar(1)
);
TRUNCATE raw_intranet."hr_menu_department";
INSERT INTO raw_intranet."hr_menu_department" ("id", "group_id", "name", "code", "description", "technical_dept", "business_line", "ds_pm", "hide") VALUES
    (1, 1, 'name_1', 'cod', 'description_1', 1, 'AMP', 1, 'h'),
    (2, 2, 'name_2', 'cod', 'description_2', 2, 'BDE', 2, 'h'),
    (3, 3, 'name_3', 'cod', 'description_3', 3, 'IPE', 3, 'h'),
    (4, 4, '  ', '  ', '  ', 4, '', 4, '  '),
    (5, 5, 'name_5', 'cod', 'description_5', 5, 'OTH', 5, 'h');
COMMIT;
