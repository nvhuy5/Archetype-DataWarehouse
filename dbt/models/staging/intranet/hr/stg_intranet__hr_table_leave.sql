-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idh,
    id_e,
    nullif(btrim(type), '') as type,
    last_balance,
    balance,
    last_month_added
from {{ source('raw_intranet', 'hr_table_leave') }}
