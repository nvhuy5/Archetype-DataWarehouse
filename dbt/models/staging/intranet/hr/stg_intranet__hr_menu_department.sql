-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    group_id,
    nullif(btrim(name), '')          as name,
    nullif(btrim(code), '')          as code,
    nullif(btrim(description), '')   as description,
    technical_dept,
    nullif(btrim(business_line), '') as business_line,
    ds_pm,
    nullif(btrim(hide), '')          as hide
from {{ source('raw_intranet', 'hr_menu_department') }}
