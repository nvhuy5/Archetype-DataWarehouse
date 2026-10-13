-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    strategic_goal_id,
    strategic_objective_id,
    nullif(btrim(goal), '')        as goal,
    start_date,
    deadline,
    nullif(btrim(level), '')       as level,
    nullif(btrim(status), '')      as status,
    nullif(btrim(weight_goal), '') as weight_goal,
    nullif(btrim(year), '')        as year,
    nullif(btrim(priority), '')    as priority
from {{ source('raw_intranet', 'strategic_goal') }}
