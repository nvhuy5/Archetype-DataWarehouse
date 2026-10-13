-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    pa_strategic_plan_level_4_id,
    pa_strategic_plan_level_3_id,
    pa_strategic_plan_level_2_id,
    pa_strategic_plan_level_1_id,
    nullif(btrim(level_4_name), '')           as level_4_name,
    nullif(btrim(status), '')                 as status,
    nullif(btrim(goal_description), '')       as goal_description,
    nullif(btrim(person_in_charge), '')       as person_in_charge,
    expected_date,
    nullif(btrim(person_in_charge_email), '') as person_in_charge_email,
    nullif(btrim(person_report_email), '')    as person_report_email
from {{ source('raw_intranet', 'pa_strategic_plan_level_4') }}
