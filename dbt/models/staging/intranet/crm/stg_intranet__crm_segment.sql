-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_segment_id,
    crm_market_id,
    nullif(btrim(title), '')        as title,
    nullif(btrim(segment_code), '') as segment_code
from {{ source('raw_intranet', 'crm_segment') }}
