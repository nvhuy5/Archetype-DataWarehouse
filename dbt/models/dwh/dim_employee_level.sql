select
    employee_level_id,
    title as level_title,
    code  as level_code,
    department_id,
    level_in_dept,
    hide  as is_hidden
from {{ ref('stg_intranet__hr_menu_employee_level') }}
