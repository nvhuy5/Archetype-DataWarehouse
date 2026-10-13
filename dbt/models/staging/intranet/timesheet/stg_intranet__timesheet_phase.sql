-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    phase_id,
    nullif(btrim(name), '')           as name,
    nullif(btrim(description), '')    as description,
    nullif(btrim(phase_code), '')     as phase_code,
    nullif(btrim(navision_no), '')    as navision_no,
    nullif(btrim(navision_code), '')  as navision_code,
    nullif(btrim(type), '')           as type,
    budget_phase,
    for_order,
    nullif(btrim(planning_color), '') as planning_color,
    refer_id,
    dept_id
from {{ source('raw_intranet', 'timesheet_phase_2015') }}
