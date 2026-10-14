-- Sample rows for raw_intranet.prm_e_project_country (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."prm_e_project_country" (
    "prm_e_project_country_id" integer,
    "country_name" varchar(50),
    "country_code" varchar(10),
    "office_name" varchar(40),
    "office_code" varchar(10),
    "office_id" integer,
    "currency" varchar(20),
    "currency_unit" integer,
    "language" varchar(100),
    "wf_show_currency" integer
);
TRUNCATE raw_intranet."prm_e_project_country";
INSERT INTO raw_intranet."prm_e_project_country" ("prm_e_project_country_id", "country_name", "country_code", "office_name", "office_code", "office_id", "currency", "currency_unit", "language", "wf_show_currency") VALUES
    (1, 'country_name_1', 'country_co', 'office_name_1', 'office_cod', 1, 'currency_1', 1, 'language_1', 1),
    (2, 'country_name_2', 'country_co', 'office_name_2', 'office_cod', 2, 'currency_2', 2, 'language_2', 2),
    (3, 'country_name_3', 'country_co', 'office_name_3', 'office_cod', 3, 'currency_3', 3, 'language_3', 3),
    (4, '  ', '  ', '  ', '  ', 4, '  ', 4, '  ', 4),
    (5, 'country_name_5', 'country_co', 'office_name_5', 'office_cod', 5, 'currency_5', 5, 'language_5', 5);
COMMIT;
