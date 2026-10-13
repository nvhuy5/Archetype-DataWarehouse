-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    strategic_member_of_task_id,
    strategic_task_id,
    nullif(btrim(email), '')    as email,
    nullif(btrim(added_by), '') as added_by,
    added_time
from {{ source('raw_intranet', 'strategic_member_of_task') }}
