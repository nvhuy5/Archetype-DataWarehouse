-- Sample rows for raw_intranet.pa_strategic_plan_level_2 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."pa_strategic_plan_level_2" (
    "pa_strategic_plan_level_2_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "level_2_name" varchar(500),
    "year" varchar(4)
);
TRUNCATE raw_intranet."pa_strategic_plan_level_2";
INSERT INTO raw_intranet."pa_strategic_plan_level_2" ("pa_strategic_plan_level_2_id", "pa_strategic_plan_level_1_id", "level_2_name", "year") VALUES
    (1, 1, 'level_2_name_1', 'year'),
    (2, 2, 'level_2_name_2', 'year'),
    (3, 3, 'level_2_name_3', 'year'),
    (4, 4, '  ', '  '),
    (5, 5, 'level_2_name_5', 'year');
COMMIT;
