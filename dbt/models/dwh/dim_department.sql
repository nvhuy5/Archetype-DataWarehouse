select
    id                                                                   as department_id,
    name                                                                 as department_name,
    code                                                                 as department_code,
    description,
    technical_dept = 1                                                   as is_technical,
    coalesce(business_line, 'SUP')                                       as business_line,
    ds_pm,
    hide                                                                 as is_hidden,
    code || ' - ' || name                                                as department_full_name,
    case coalesce(business_line, 'SUP')
        when 'AMP' then 'AMP - Architecture and Master Planning'
        when 'BDE' then 'BDE - Building Design and Engineering'
        when 'IPE' then 'IPE - Instrument and Process Engineering'
        when 'PCS' then 'PCS - Project and Cost Management'
        when 'SUP' then 'SUP - Support'
        else coalesce(business_line, 'SUP') || ' - Others'
    end                                                                  as business_line_full_name
from {{ ref('stg_intranet__hr_menu_department') }}
