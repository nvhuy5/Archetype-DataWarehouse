-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    competitor_id,
    nullif(btrim(name), '') as name,
    fee,
    winner,
    contract_id,
    cp_id
from {{ source('raw_intranet', 'crm_table_contracts_competitor') }}
