-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    nullif(btrim(reason), '') as reason,
    cat
from {{ source('raw_intranet', 'crm_list_reason') }}
