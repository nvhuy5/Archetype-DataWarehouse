-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    strategic_task_id,
    strategic_goal_id,
    nullif(btrim(task_description), '') as task_description,
    nullif(btrim(resources), '')        as resources,
    nullif(btrim(comments), '')         as comments,
    deadline,
    nullif(btrim(progress), '')         as progress,
    nullif(btrim(weight), '')           as weight,
    nullif(btrim(added_by), '')         as added_by,
    added_time
from {{ source('raw_intranet', 'strategic_task') }}
