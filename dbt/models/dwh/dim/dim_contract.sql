select
    contract_id,
    crm_contract_id,
    code           as contract_code,
    navision_code  as nav_contract_code,
    title          as contract_name,
    contract_status,
    office_id,
    timesheet_project_id as project_id
from {{ ref('stg_intranet__timesheet_contract') }}
