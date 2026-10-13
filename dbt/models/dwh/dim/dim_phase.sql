-- Timesheet phase (type of event). Replaces Dim_Phases of the old warehouse, which was built from NAV budgets.
-- main_group is the CASE of the "Types Of Event" query of the Power BI report; support_detail rows are flagged, not removed.
select
    phase_id,
    phase_code,
    case when name = 'Non chargeable time' then 'No Workload' else name end as phase_name,
    type                                                                     as phase_type,
    navision_no,
    navision_code,
    type = 'project'                                                         as is_productive,
    type = 'support_detail'                                                  as is_support_detail,
    case
        when type = 'vacation' then 'Leave & Holiday'
        when type = 'project' then 'Billable Project'
        when name in ('Administration Support', 'Training - research - study', 'Business Development support',
                      'Meeting', 'No Workload', 'Non chargeable time') then 'Internal & Downtime'
        when lower(name) like '%support%' then 'Internal & Downtime'
        else 'Others'
    end                                                                      as main_group
from {{ ref('stg_intranet__timesheet_phase') }}
