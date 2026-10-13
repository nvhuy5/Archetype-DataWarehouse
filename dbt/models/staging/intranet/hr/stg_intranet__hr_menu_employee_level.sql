-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    employee_level_id,
    nullif(btrim(title), '') as title,
    nullif(btrim(code), '')  as code,
    department_id,
    level_in_dept,
    hide
from {{ source('raw_intranet', 'hr_menu_employee_level') }}
