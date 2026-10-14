-- Sample rows for raw_intranet.prm_e_project_country (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."prm_e_project_country";
CREATE TABLE raw_intranet."prm_e_project_country" (
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
INSERT INTO raw_intranet."prm_e_project_country" ("prm_e_project_country_id", "country_name", "country_code", "office_name", "office_code", "office_id", "currency", "currency_unit", "language", "wf_show_currency") VALUES
    (1, 'country_name_1', 'country_co', 'office_name_1', 'office_cod', 1, 'currency_1', 1, 'language_1', 1),
    (2, 'country_name_2', 'country_co', 'office_name_2', 'office_cod', 2, 'currency_2', 2, 'language_2', 2),
    (3, 'country_name_3', 'country_co', 'office_name_3', 'office_cod', 3, 'currency_3', 3, 'language_3', 3),
    (4, '  ', '  ', '  ', '  ', 4, '  ', 4, '  ', 4),
    (5, 'country_name_5', 'country_co', 'office_name_5', 'office_cod', 5, 'currency_5', 5, 'language_5', 5);
COMMIT;
