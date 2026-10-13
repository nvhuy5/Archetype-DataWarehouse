-- One row per employee and month while the employee has a contract: head count, leavers, newcomers, seniority.
-- Rebuilt from the old view HR_ContractHeadCount. Differences: months without any contract are not listed,
-- names and job title are not repeated (join dim_employee / int_hr_contract on employee_id / contract_id).
with months as (
    select distinct month_key, month_start_date
    from {{ ref('dim_date') }}
    where month_key <= to_char(current_date, 'YYYYMM')::int
),

contract as (
    select
        employee_id,
        contract_id,
        to_char(contract_from, 'YYYYMM')::int as from_month_key,
        to_char(contract_to, 'YYYYMM')::int   as to_month_key
    from {{ ref('int_hr_contract') }}
),

employee as (
    select ide, startworking, estatus from {{ ref('stg_intranet__hr_table_main') }}
),

leavers as (
    select
        c.employee_id,
        max(to_char(c.terminated_date, 'YYYYMM')::int) as leave_month_key,
        max(c.terminated_date)                         as terminal_date
    from {{ ref('int_hr_contract') }} c
    join employee e on e.ide = c.employee_id
    where c.terminated_date is not null
      and e.estatus <> 7
    group by c.employee_id
),

newcomers as (
    select employee_id, min(to_char(contract_from, 'YYYYMM')::int) as newcomer_month_key
    from {{ ref('int_hr_contract') }}
    where job_title_id is not null
    group by employee_id
)

select
    m.month_key,
    m.month_start_date,
    c.employee_id,
    max(c.contract_id)                                                   as contract_id,
    round(
        ((extract(year from m.month_start_date) - extract(year from e.startworking)) * 12
         + extract(month from m.month_start_date) - extract(month from e.startworking)) / 12.0, 2
    )                                                                    as act_seniority_years_history,
    case when lv.leave_month_key = m.month_key then 0 else 1 end         as head_count,
    case when lv.leave_month_key = m.month_key then 1 else 0 end         as leavers,
    case when nc.newcomer_month_key = m.month_key then 1 else 0 end      as newcomers,
    lv.terminal_date
from months m
join contract c on m.month_key between c.from_month_key and c.to_month_key
join employee e on e.ide = c.employee_id
left join leavers lv on lv.employee_id = c.employee_id and lv.leave_month_key <= m.month_key
left join newcomers nc on nc.employee_id = c.employee_id and nc.newcomer_month_key = m.month_key
where m.month_key <= coalesce(lv.leave_month_key, m.month_key)
group by m.month_key, m.month_start_date, c.employee_id, e.startworking, lv.leave_month_key, nc.newcomer_month_key, lv.terminal_date
