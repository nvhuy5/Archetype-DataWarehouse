-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    strategic_leader_id,
    strategic_goal_id,
    nullif(btrim(leader_name), '')  as leader_name,
    nullif(btrim(leader_email), '') as leader_email,
    type,
    nullif(btrim(added_by), '')     as added_by,
    added_time
from {{ source('raw_intranet', 'strategic_leader') }}
