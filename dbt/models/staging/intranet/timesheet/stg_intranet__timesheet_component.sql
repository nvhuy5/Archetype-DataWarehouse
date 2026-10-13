-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    timesheet_component_id,
    contract_id,
    nullif(btrim(component_name), '') as component_name,
    nullif(btrim(navision_code), '')  as navision_code,
    nullif(btrim(status), '')         as status,
    department_check,
    status_effect_date,
    last_update,
    change_status_date,
    nullif(btrim(factor), '')         as factor,
    send_to_navision
from {{ source('raw_intranet', 'timesheet_component_2015') }}
