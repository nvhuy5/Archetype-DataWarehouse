-- Contract enriched with job title, level category and contract type (the join the SSIS flow "Get Employee Contracts" did at the source).
select
    c.idcont                      as contract_id,
    c.id_e                        as employee_id,
    c.cfrom                       as contract_from,
    c.cto                         as contract_to,
    c.tdate                       as terminated_date,
    c.probation_end_date,
    c.job_title_id,
    jt.title                      as job_title,
    jt.dept                       as job_title_department_id,
    lvl.title                     as category_name,
    lvl.code                      as category_code,
    c.idcontracttype              as contract_type_id,
    ct.name                       as contract_type,
    case
        when c.probation_end_date is null or c.probation_end_date < c.cto then 'Long Term'
        else 'Probation'
    end                           as contract_term
from {{ ref('stg_intranet__hr_table_contract') }} c
left join {{ ref('stg_intranet__hr_menu_job_title') }} jt on jt.idjt = c.job_title_id
left join {{ ref('stg_intranet__hr_menu_employee_level') }} lvl on lvl.employee_level_id = jt.employee_level_id
left join {{ ref('stg_intranet__hr_table_contract_type') }} ct on ct.id_contract_type = c.idcontracttype
