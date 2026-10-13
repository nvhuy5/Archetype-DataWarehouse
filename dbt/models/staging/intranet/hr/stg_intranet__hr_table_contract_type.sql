-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id_contract_type,
    nullif(btrim(name), '') as name,
    nullif(btrim(hide), '') as hide
from {{ source('raw_intranet', 'hr_table_contract_type') }}
