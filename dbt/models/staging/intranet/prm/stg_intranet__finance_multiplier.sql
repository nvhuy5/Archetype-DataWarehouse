-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    country_id,
    nullif(btrim(year), '')                  as year,
    nullif(btrim(percent_of_other_cost), '') as percent_of_other_cost,
    nullif(btrim(external_client), '')       as external_client,
    nullif(btrim(internal_client), '')       as internal_client,
    nullif(btrim(business_line), '')         as business_line,
    overhead_rate
from {{ source('raw_intranet', 'finance_multiplier') }}
