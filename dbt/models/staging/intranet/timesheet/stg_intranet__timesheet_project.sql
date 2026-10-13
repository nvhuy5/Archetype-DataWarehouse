-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    timesheet_project_id,
    nullif(btrim(project_name), '')    as project_name,
    office,
    nullif(btrim(project_type), '')    as project_type,
    nullif(btrim(status), '')          as status,
    status_effect_date,
    nullif(btrim(project_manager), '') as project_manager,
    last_update,
    change_status_date
from {{ source('raw_intranet', 'timesheet_project_2015') }}
