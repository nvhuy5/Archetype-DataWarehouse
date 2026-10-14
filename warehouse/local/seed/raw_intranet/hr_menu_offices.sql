-- Sample rows for raw_intranet.hr_menu_offices (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_menu_offices";
CREATE TABLE raw_intranet."hr_menu_offices" (
    "idf" integer,
    "offices" varchar(255),
    "display_office_name" varchar(500),
    "legal_office_name" varchar(500),
    "countrywork" varchar(255),
    "workinglocation" varchar(255),
    "address" varchar(255),
    "address_v2" varchar(500),
    "default_phone_number" varchar(100),
    "area_code" varchar(20),
    "work_location_only" varchar(1),
    "crm_office" smallint,
    "office_code" varchar(3),
    "country_code" varchar(3),
    "country_id" integer,
    "crm_project_category" smallint,
    "crm_country" varchar(50),
    "hide" smallint,
    "candidate_hide" smallint,
    "grp" varchar(1),
    "bd_manager" varchar(255),
    "managing_director" varchar(255),
    "regional_director" varchar(255),
    "location_longitude" varchar(255),
    "location_latitude" varchar(255),
    "default_tax" integer,
    "hrm_hide" smallint
);
INSERT INTO raw_intranet."hr_menu_offices" ("idf", "offices", "display_office_name", "legal_office_name", "countrywork", "workinglocation", "address", "address_v2", "default_phone_number", "area_code", "work_location_only", "crm_office", "office_code", "country_code", "country_id", "crm_project_category", "crm_country", "hide", "candidate_hide", "grp", "bd_manager", "managing_director", "regional_director", "location_longitude", "location_latitude", "default_tax", "hrm_hide") VALUES
    (1, 'offices_1', 'display_office_name_1', 'legal_office_name_1', 'countrywork_1', 'workinglocation_1', 'address_1', 'address_v2_1', 'default_phone_number_1', 'area_code_1', 'w', 1, 'off', 'cou', 1, 1, 'crm_country_1', 1, 1, 'g', 'bd_manager_1', 'managing_director_1', 'regional_director_1', 'location_longitude_1', 'location_latitude_1', 1, 1),
    (2, 'offices_2', 'display_office_name_2', 'legal_office_name_2', 'countrywork_2', 'workinglocation_2', 'address_2', 'address_v2_2', 'default_phone_number_2', 'area_code_2', 'w', 2, 'off', 'cou', 2, 2, 'crm_country_2', 2, 2, 'g', 'bd_manager_2', 'managing_director_2', 'regional_director_2', 'location_longitude_2', 'location_latitude_2', 2, 2),
    (3, 'offices_3', 'display_office_name_3', 'legal_office_name_3', 'countrywork_3', 'workinglocation_3', 'address_3', 'address_v2_3', 'default_phone_number_3', 'area_code_3', 'w', 3, 'off', 'cou', 3, 3, 'crm_country_3', 3, 3, 'g', 'bd_manager_3', 'managing_director_3', 'regional_director_3', 'location_longitude_3', 'location_latitude_3', 3, 3),
    (4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', 4, '  ', '  ', 4, 4, '  ', 4, 4, '  ', '  ', '  ', '  ', '  ', '  ', 4, 4),
    (5, 'offices_5', 'display_office_name_5', 'legal_office_name_5', 'countrywork_5', 'workinglocation_5', 'address_5', 'address_v2_5', 'default_phone_number_5', 'area_code_5', 'w', 5, 'off', 'cou', 5, 5, 'crm_country_5', 5, 5, 'g', 'bd_manager_5', 'managing_director_5', 'regional_director_5', 'location_longitude_5', 'location_latitude_5', 5, 5);
COMMIT;
