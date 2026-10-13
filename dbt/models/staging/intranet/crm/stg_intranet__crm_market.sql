-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_market_id,
    nullif(btrim(title), '')       as title,
    nullif(btrim(market_code), '') as market_code
from {{ source('raw_intranet', 'crm_market') }}
