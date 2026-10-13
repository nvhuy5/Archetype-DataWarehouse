-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idht,
    nullif(btrim(code), '')          as code,
    nullif(btrim(description), '')   as description,
    nullif(btrim(frequency), '')     as frequency,
    type,
    nullif(btrim(nav_item_code), '') as nav_item_code,
    nullif(btrim(nav_code), '')      as nav_code
from {{ source('raw_intranet', 'hr_menu_leave_type') }}
