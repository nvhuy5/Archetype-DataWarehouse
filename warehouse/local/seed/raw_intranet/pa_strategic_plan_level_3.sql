-- Sample rows for raw_intranet.pa_strategic_plan_level_3 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."pa_strategic_plan_level_3";
CREATE TABLE raw_intranet."pa_strategic_plan_level_3" (
    "pa_strategic_plan_level_3_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "pa_strategic_plan_level_2_id" integer,
    "level_3_name" varchar(500),
    "year" varchar(4)
);
INSERT INTO raw_intranet."pa_strategic_plan_level_3" ("pa_strategic_plan_level_3_id", "pa_strategic_plan_level_1_id", "pa_strategic_plan_level_2_id", "level_3_name", "year") VALUES
    (1, 1, 1, 'level_3_name_1', 'year'),
    (2, 2, 2, 'level_3_name_2', 'year'),
    (3, 3, 3, 'level_3_name_3', 'year'),
    (4, 4, 4, '  ', '  '),
    (5, 5, 5, 'level_3_name_5', 'year');
COMMIT;
