-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idc,
    idp,
    nullif(btrim(comment), '') as comment
from {{ source('raw_intranet', 'crm_link_project_client') }}
