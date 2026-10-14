-- Sample rows for raw_intranet.pa_strategic_plan_level_4 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."pa_strategic_plan_level_4";
CREATE TABLE raw_intranet."pa_strategic_plan_level_4" (
    "pa_strategic_plan_level_4_id" integer,
    "pa_strategic_plan_level_3_id" integer,
    "pa_strategic_plan_level_2_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "level_4_name" varchar(500),
    "status" varchar(80),
    "goal_description" text,
    "person_in_charge" varchar(80),
    "expected_date" date,
    "person_in_charge_email" varchar(70),
    "person_report_email" varchar(70)
);
INSERT INTO raw_intranet."pa_strategic_plan_level_4" ("pa_strategic_plan_level_4_id", "pa_strategic_plan_level_3_id", "pa_strategic_plan_level_2_id", "pa_strategic_plan_level_1_id", "level_4_name", "status", "goal_description", "person_in_charge", "expected_date", "person_in_charge_email", "person_report_email") VALUES
    (1, 1, 1, 1, 'level_4_name_1', 'status_1', 'goal_description_1', 'person_in_charge_1', '2026-01-02', 'person_in_charge_email_1', 'person_report_email_1'),
    (2, 2, 2, 2, 'level_4_name_2', 'status_2', 'goal_description_2', 'person_in_charge_2', '2026-01-03', 'person_in_charge_email_2', 'person_report_email_2'),
    (3, 3, 3, 3, 'level_4_name_3', 'status_3', 'goal_description_3', 'person_in_charge_3', '2026-01-04', 'person_in_charge_email_3', 'person_report_email_3'),
    (4, 4, 4, 4, '  ', '  ', '  ', '  ', '2026-01-05', '  ', '  '),
    (5, 5, 5, 5, 'level_4_name_5', 'status_5', 'goal_description_5', 'person_in_charge_5', '2026-01-06', 'person_in_charge_email_5', 'person_report_email_5');
COMMIT;
