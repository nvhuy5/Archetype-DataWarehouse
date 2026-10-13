-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_list_competitors_id,
    nullif(btrim(name), '') as name
from {{ source('raw_intranet', 'crm_list_competitors') }}
