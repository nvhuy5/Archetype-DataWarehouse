-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idstatus,
    nullif(btrim(name), '') as name
from {{ source('raw_intranet', 'hr_menu_process_status') }}
