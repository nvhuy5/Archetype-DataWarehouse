-- Staging: one row per key, trimmed text, empty strings become NULL. No business rules here.
select distinct on (id)
    id,
    group_id,
    nullif(btrim(name), '')          as name,
    nullif(btrim(code), '')          as code,
    technical_dept,
    nullif(btrim(business_line), '') as business_line
from {{ source('raw_intranet', 'hr_menu_department') }}
order by id
