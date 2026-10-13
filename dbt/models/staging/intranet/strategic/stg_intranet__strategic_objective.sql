-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    strategic_objective_id,
    nullif(btrim(theme), '')         as theme,
    nullif(btrim(objective), '')     as objective,
    nullif(btrim(sponsor_name), '')  as sponsor_name,
    nullif(btrim(sponsor_email), '') as sponsor_email,
    nullif(btrim(leader_name), '')   as leader_name,
    nullif(btrim(leader_email), '')  as leader_email,
    nullif(btrim(year), '')          as year
from {{ source('raw_intranet', 'strategic_objective') }}
