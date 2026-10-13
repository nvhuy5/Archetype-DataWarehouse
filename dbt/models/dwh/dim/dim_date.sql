-- Calendar from 2020-01-01 to the end of next year. Fiscal year = calendar year, work day = Monday to Friday except public holidays.
with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast(date_trunc('year', current_date) + interval '2 years' as date)"
    ) }}
),

holidays as (
    select distinct holiday_date from {{ ref('public_holidays') }}
)

select
    to_char(d.date_day, 'YYYYMMDD')::int                        as date_key,
    d.date_day::date                                            as date_full,
    extract(year from d.date_day)::int                          as year,
    extract(quarter from d.date_day)::int                       as quarter,
    extract(month from d.date_day)::int                         as month,
    trim(to_char(d.date_day, 'Month'))                          as month_name,
    to_char(d.date_day, 'YYYYMM')::int                          as month_key,
    date_trunc('month', d.date_day)::date                       as month_start_date,
    extract(day from d.date_day)::int                           as day,
    extract(isodow from d.date_day)::int                        as day_of_week,
    extract(week from d.date_day)::int                          as week_of_year,
    extract(isodow from d.date_day) in (6, 7)                   as is_weekend,
    h.holiday_date is not null                                  as is_public_holiday,
    extract(isodow from d.date_day) < 6 and h.holiday_date is null as is_work_day,
    extract(year from d.date_day)::int                          as fiscal_year,
    extract(quarter from d.date_day)::int                       as fiscal_quarter,
    extract(month from d.date_day)::int                         as fiscal_month
from spine d
left join holidays h on h.holiday_date = d.date_day::date
