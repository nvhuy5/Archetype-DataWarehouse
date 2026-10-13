-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id_e,
    id_m,
    nullif(btrim(is_main), '') as is_main
from {{ source('raw_intranet', 'hr_table_direct_manager') }}
