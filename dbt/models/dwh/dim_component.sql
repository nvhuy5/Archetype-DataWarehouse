select
    timesheet_component_id as component_id,
    contract_id,
    component_name,
    navision_code          as component_code,
    status                 as component_status
from {{ ref('stg_intranet__timesheet_component') }}
