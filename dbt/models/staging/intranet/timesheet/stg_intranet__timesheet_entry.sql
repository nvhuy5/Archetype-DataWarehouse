-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    date,
    uid,
    ide,
    nullif(btrim(employee_code), '')     as employee_code,
    nullif(btrim(employee_office), '')   as employee_office,
    department_id,
    jobtitle_id,
    nullif(btrim(employee_level), '')    as employee_level,
    phase_id,
    component_id,
    contract_id,
    proj_id,
    time,
    rate,
    validated,
    last_modified,
    nullif(btrim(last_updated_user), '') as last_updated_user
from {{ source('raw_intranet', 'timesheet_entry_2015') }}
