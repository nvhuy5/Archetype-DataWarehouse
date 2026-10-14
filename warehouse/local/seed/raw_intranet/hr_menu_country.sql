-- Sample rows for raw_intranet.hr_menu_country (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_country";
CREATE TABLE raw_intranet."hr_menu_country" (
    "idp" integer,
    "pays" varchar(100),
    "nationality" varchar(100),
    "region" varchar(25),
    "iso2c" varchar(2),
    "iso3c" varchar(3),
    "calling_code" varchar(10),
    "iso_country_code" integer,
    "act_country_code" varchar(3),
    "hr_hide" smallint
);
INSERT INTO raw_intranet."hr_menu_country" ("idp", "pays", "nationality", "region", "iso2c", "iso3c", "calling_code", "iso_country_code", "act_country_code", "hr_hide") VALUES
    (1, 'pays_1', 'nationality_1', 'region_1', 'is', 'iso', 'calling_co', 1, 'act', 1),
    (2, 'pays_2', 'nationality_2', 'region_2', 'is', 'iso', 'calling_co', 2, 'act', 2),
    (3, 'pays_3', 'nationality_3', 'region_3', 'is', 'iso', 'calling_co', 3, 'act', 3),
    (4, '  ', '  ', '  ', '  ', '  ', '  ', 4, '  ', 4),
    (5, 'pays_5', 'nationality_5', 'region_5', 'is', 'iso', 'calling_co', 5, 'act', 5);
COMMIT;
