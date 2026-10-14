-- Sample rows for raw_intranet.crm_target (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_target";
CREATE TABLE raw_intranet."crm_target" (
    "crm_target_id" integer,
    "country_id" integer,
    "user" varchar(200),
    "building_q1" varchar(20),
    "building_q2" varchar(20),
    "building_q3" varchar(20),
    "building_q4" varchar(20),
    "others_q1" varchar(20),
    "others_q2" varchar(20),
    "others_q3" varchar(20),
    "others_q4" varchar(20),
    "healthcare_q1" varchar(20),
    "healthcare_q2" varchar(20),
    "healthcare_q3" varchar(20),
    "healthcare_q4" varchar(20),
    "designbuild_q1" varchar(20),
    "designbuild_q2" varchar(20),
    "designbuild_q3" varchar(20),
    "designbuild_q4" varchar(20),
    "type" varchar(10),
    "year" smallint
);
INSERT INTO raw_intranet."crm_target" ("crm_target_id", "country_id", "user", "building_q1", "building_q2", "building_q3", "building_q4", "others_q1", "others_q2", "others_q3", "others_q4", "healthcare_q1", "healthcare_q2", "healthcare_q3", "healthcare_q4", "designbuild_q1", "designbuild_q2", "designbuild_q3", "designbuild_q4", "type", "year") VALUES
    (1, 1, 'user_1', 'building_q1_1', 'building_q2_1', 'building_q3_1', 'building_q4_1', 'others_q1_1', 'others_q2_1', 'others_q3_1', 'others_q4_1', 'healthcare_q1_1', 'healthcare_q2_1', 'healthcare_q3_1', 'healthcare_q4_1', 'designbuild_q1_1', 'designbuild_q2_1', 'designbuild_q3_1', 'designbuild_q4_1', 'type_1', 1),
    (2, 2, 'user_2', 'building_q1_2', 'building_q2_2', 'building_q3_2', 'building_q4_2', 'others_q1_2', 'others_q2_2', 'others_q3_2', 'others_q4_2', 'healthcare_q1_2', 'healthcare_q2_2', 'healthcare_q3_2', 'healthcare_q4_2', 'designbuild_q1_2', 'designbuild_q2_2', 'designbuild_q3_2', 'designbuild_q4_2', 'type_2', 2),
    (3, 3, 'user_3', 'building_q1_3', 'building_q2_3', 'building_q3_3', 'building_q4_3', 'others_q1_3', 'others_q2_3', 'others_q3_3', 'others_q4_3', 'healthcare_q1_3', 'healthcare_q2_3', 'healthcare_q3_3', 'healthcare_q4_3', 'designbuild_q1_3', 'designbuild_q2_3', 'designbuild_q3_3', 'designbuild_q4_3', 'type_3', 3),
    (4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', 4),
    (5, 5, 'user_5', 'building_q1_5', 'building_q2_5', 'building_q3_5', 'building_q4_5', 'others_q1_5', 'others_q2_5', 'others_q3_5', 'others_q4_5', 'healthcare_q1_5', 'healthcare_q2_5', 'healthcare_q3_5', 'healthcare_q4_5', 'designbuild_q1_5', 'designbuild_q2_5', 'designbuild_q3_5', 'designbuild_q4_5', 'type_5', 5);
COMMIT;
