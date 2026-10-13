select
    timesheet_project_id as project_id,
    project_name,
    office               as office_id,
    project_type,
    status               as project_status
from {{ ref('stg_intranet__timesheet_project') }}
