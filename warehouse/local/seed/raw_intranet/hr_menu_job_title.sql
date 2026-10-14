-- Sample rows for raw_intranet.hr_menu_job_title (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_job_title";
CREATE TABLE raw_intranet."hr_menu_job_title" (
    "idjt" integer,
    "title" varchar(255),
    "title_for_business_card" varchar(255),
    "dept" integer,
    "employee_level_id" integer,
    "hide" smallint
);
INSERT INTO raw_intranet."hr_menu_job_title" ("idjt", "title", "title_for_business_card", "dept", "employee_level_id", "hide") VALUES
    (1, 'title_1', 'title_for_business_card_1', 1, 1, 1),
    (2, 'title_2', 'title_for_business_card_2', 2, 2, 2),
    (3, 'title_3', 'title_for_business_card_3', 3, 3, 3),
    (4, '  ', '  ', 4, 4, 4),
    (5, 'title_5', 'title_for_business_card_5', 5, 5, 5);
COMMIT;
