-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idjt,
    nullif(btrim(title), '')                   as title,
    nullif(btrim(title_for_business_card), '') as title_for_business_card,
    dept,
    employee_level_id,
    hide
from {{ source('raw_intranet', 'hr_menu_job_title') }}
