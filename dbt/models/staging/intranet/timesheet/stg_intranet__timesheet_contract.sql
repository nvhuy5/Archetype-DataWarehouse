-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    contract_id,
    crm_contract_id,
    nullif(btrim(code), '')             as code,
    nullif(btrim(navision_code), '')    as navision_code,
    nullif(btrim(scope), '')            as scope,
    nullif(btrim(project_manager), '')  as project_manager,
    nullif(btrim(title), '')            as title,
    timesheet_project_id,
    nullif(btrim(contract_status), '')  as contract_status,
    status_effect_date,
    change_status_date,
    office_id,
    added_user,
    added_time,
    last_updated_date,
    nullif(btrim(last_update_user), '') as last_update_user
from {{ source('raw_intranet', 'timesheet_contract_2015') }}
