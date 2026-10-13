-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_sub_segment_id,
    crm_segment_id,
    nullif(btrim(title), '')       as title,
    nullif(btrim(sector_code), '') as sector_code
from {{ source('raw_intranet', 'crm_sub_segment') }}
