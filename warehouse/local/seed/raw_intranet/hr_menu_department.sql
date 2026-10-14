-- Sample rows for raw_intranet.hr_menu_department (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_department";
CREATE TABLE raw_intranet."hr_menu_department" (
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
INSERT INTO raw_intranet."hr_menu_department" ("id", "group_id", "name", "code", "description", "technical_dept", "business_line", "ds_pm", "hide") VALUES
    (1, 1, 'name_1', 'cod', 'description_1', 1, 'AMP', 1, 'h'),
    (2, 2, 'name_2', 'cod', 'description_2', 2, 'BDE', 2, 'h'),
    (3, 3, 'name_3', 'cod', 'description_3', 3, 'IPE', 3, 'h'),
    (4, 4, '  ', '  ', '  ', 4, '', 4, '  '),
    (5, 5, 'name_5', 'cod', 'description_5', 5, 'OTH', 5, 'h');
COMMIT;
