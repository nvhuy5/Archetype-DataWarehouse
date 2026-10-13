-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    pa_strategic_plan_level_1_id,
    nullif(btrim(level_1_name), '') as level_1_name,
    nullif(btrim(year), '')         as year
from {{ source('raw_intranet', 'pa_strategic_plan_level_1') }}
