-- One row per office that has at least one employee record. The NAV columns of the old Dim_Offices
-- (NAV entity, local currency, VAT, forex) are not here: NAV is not loaded yet.
with eproject as (
    select office_id, min(office_name) as eproject_office_name
    from {{ ref('stg_intranet__prm_e_project_country') }}
    group by office_id
),

employee_office as (
    select
        working_location,
        bool_or(estatus = 7) as has_employee
    from {{ ref('stg_intranet__hr_table_main') }}
    group by working_location
)

select
    o.idf                                as office_id,
    o.offices                            as office_name,
    o.office_code,
    o.hide                               as is_hidden,
    c.pays                               as country,
    c.region,
    e.eproject_office_name,
    ho.has_employee,
    e.office_id is not null              as has_eproject
from {{ ref('stg_intranet__hr_menu_offices') }} o
join employee_office ho on ho.working_location = o.idf
left join {{ ref('stg_intranet__hr_menu_country') }} c on c.idp = o.country_id
left join eproject e on e.office_id = o.idf
