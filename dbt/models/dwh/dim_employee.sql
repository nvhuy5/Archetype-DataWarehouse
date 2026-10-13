-- Employees in status 7 and 8, with what the old view get_employee_etl (department, job title, level, offices, status)
-- and Dim_Employees (current contract, direct manager, first interview) added. Birthday is not exposed, only the age.
-- working_pays follows get_employee_etl (country of working_location); the report takes the country from dim_office instead.
with employee as (
    select * from {{ ref('stg_intranet__hr_table_main') }}
),

main_manager as (
    select id_e, max(id_m) as manager_id
    from {{ ref('stg_intranet__hr_table_direct_manager') }}
    where is_main = '1'
    group by id_e
),

current_contract as (
    select distinct on (employee_id) *
    from {{ ref('int_hr_contract') }}
    where terminated_date is null
      and current_date between contract_from and contract_to
    order by employee_id, contract_id desc
),

interview as (
    select employee_id, min(interview_date) as first_interview_date
    from (
        select m.ide as employee_id, ph.interview_date::date as interview_date
        from {{ ref('stg_intranet__hr_table_phone_interview') }} ph
        join employee m on m.id_md5 = ph.idm
        where ph.interview_date is not null
        union all
        select id_e, ap_date::date from {{ ref('stg_intranet__hr_table_pre_interview') }} where ap_date is not null
        union all
        select id_e, tadate::date from {{ ref('stg_intranet__hr_table_tech_interview') }} where tadate is not null
    ) t
    group by employee_id
)

select
    e.ide                                              as employee_id,
    e.code                                             as employee_code,
    e.fname || ' ' || e.lname                          as full_name,
    e.gender,
    date_part('year', age(current_date, e.birthday))::int as age,
    e.nationality,
    e.marital_status,
    e.arche_email                                      as email,
    case when e.type = 'Local' then 'National' else 'Foreigner' end as employee_type,
    e.manager_level,
    st.name                                            as employee_status,
    e.estatus                                          as employee_status_id,
    e.department_id,
    d.code                                             as department_code,
    d.name                                             as department_name,
    d.technical_dept = 1                               as is_technical_department,
    e.job_title_id,
    jt.title                                           as job_title,
    e.employee_level_id,
    lvl.title                                          as job_level,
    e.country_work                                     as working_office_id,
    oa.offices                                         as working_office_name,
    oa.office_code                                     as working_office_code,
    e.working_location                                 as working_location_id,
    c.pays                                             as working_pays,
    c.region                                           as working_region,
    dm.arche_email                                     as direct_manager_email,
    e.startworking                                     as start_working_date,
    round((current_date - e.startworking) / 365.25, 1) as act_seniority_years,
    e.resign_date,
    e.termination_reason,
    e.regretted_loss,
    cc.contract_to                                     as contract_end_date,
    cc.job_title                                       as contract_job_title,
    cc.contract_type,
    cc.contract_term,
    i.first_interview_date,
    case
        when e.p_reference ilike '%@archetype-group.com%' then 'Employee Referral'
        when e.p_reference ilike 'Agency:%' or e.p_reference ilike 'vietnamwork' or e.p_reference ilike '%naukri%'
             or e.p_reference ilike '%first alliance%' or e.p_reference ilike '%jobstreet%' then 'Recruitment Agencies'
        when e.p_reference ilike '%Direct%' or coalesce(e.p_reference, '') = '' then 'Direct'
        when e.p_reference ilike '%Advertisement%' or e.p_reference ilike '%internet%' then 'Newspaper Adv'
        else 'Other'
    end                                                as recruitment_source
from employee e
left join {{ ref('stg_intranet__hr_menu_department') }} d on d.id = e.department_id
left join {{ ref('stg_intranet__hr_menu_job_title') }} jt on jt.idjt = e.job_title_id
left join {{ ref('stg_intranet__hr_menu_employee_level') }} lvl on lvl.employee_level_id = jt.employee_level_id
left join {{ ref('stg_intranet__hr_menu_process_status') }} st on st.idstatus = e.estatus
left join {{ ref('stg_intranet__hr_menu_offices') }} o on o.idf = e.working_location
left join {{ ref('stg_intranet__hr_menu_offices') }} oa on oa.idf = e.country_work
left join {{ ref('stg_intranet__hr_menu_country') }} c on c.idp = o.country_id
left join main_manager mm on mm.id_e = e.ide
left join employee dm on dm.ide = mm.manager_id
left join current_contract cc on cc.employee_id = e.ide
left join interview i on i.employee_id = e.ide
where e.estatus in (7, 8)
