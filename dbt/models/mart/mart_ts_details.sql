-- Timesheet report, table TS_Details: one row per timesheet entry with phase, project, contract, component and calendar names added.
-- Entries without a phase, project, contract or component are kept (those columns are then NULL).
select
    f.entry_id,
    f.entry_date,
    d.date_key,
    d.month_key,
    d.year,
    d.month,
    d.month_name,
    d.is_work_day,
    f.employee_id,
    f.employee_code,
    f.employee_office,
    f.department_id,
    f.job_title_id,
    f.employee_level_id,
    f.phase_id,
    p.phase_code,
    p.phase_name,
    p.phase_type,
    p.navision_code as phase_navision_code,
    f.main_group,
    f.project_id,
    pr.project_name,
    pr.project_type,
    pr.project_status,
    f.contract_id,
    c.contract_code,
    c.contract_name,
    c.contract_status,
    f.component_id,
    cm.component_name,
    cm.component_code,
    f.hours,
    f.rate,
    f.productive_hours,
    f.is_productive,
    f.validated_status,
    f.validated_status_name,
    f.last_modified,
    f.last_updated_user
from {{ ref('fact_timesheet') }} f
left join {{ ref('dim_date') }} d on d.date_full = f.entry_date
left join {{ ref('dim_phase') }} p on p.phase_id = f.phase_id
left join {{ ref('dim_project') }} pr on pr.project_id = f.project_id
left join {{ ref('dim_contract') }} c on c.contract_id = f.contract_id
left join {{ ref('dim_component') }} cm on cm.component_id = f.component_id
