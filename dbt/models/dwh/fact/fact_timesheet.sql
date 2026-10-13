-- One row per timesheet entry (replaces Summarized_Timesheet, which summed hours per day, employee, component and phase).
-- History starts at var timesheet_from_date. Entries without a phase are kept (phase columns are then NULL).
-- validated_status_name: Draft only counts for productive time, as in the Power BI report.
select
    e.id                                                        as entry_id,
    e.date                                                      as entry_date,
    e.ide                                                       as employee_id,
    e.employee_code,
    e.employee_office,
    e.department_id,
    e.jobtitle_id                                               as job_title_id,
    case when e.employee_level ~ '^[0-9]+$' then e.employee_level::int end as employee_level_id,
    e.phase_id,
    e.component_id,
    e.contract_id,
    e.proj_id                                                   as project_id,
    e.time                                                      as hours,
    e.rate,
    e.validated                                                 as validated_status,
    case
        when e.validated = 0 and p.is_productive then 'Draft'
        when e.validated = 1 then 'Submitted'
        when e.validated = 2 then 'Validated'
    end                                                         as validated_status_name,
    coalesce(p.is_productive, false)                            as is_productive,
    case when p.is_productive then e.time else 0 end            as productive_hours,
    p.main_group,
    e.last_modified,
    e.last_updated_user
from {{ ref('stg_intranet__timesheet_entry') }} e
left join {{ ref('dim_phase') }} p on p.phase_id = e.phase_id
where e.date >= '{{ var("timesheet_from_date") }}'::date
