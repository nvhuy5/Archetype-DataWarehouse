-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_budget_revision_setup_id,
    rev_id,
    dept_id,
    phase_id,
    nullif(btrim(added_by), '')  as added_by,
    added_at
from {{ source('raw_intranet', 'prm_budget_revision_setup') }}
