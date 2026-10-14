-- Timesheet report, table Departments.
select
    department_id, department_name, department_code, description, is_technical, business_line,
    department_full_name, business_line_full_name, is_hidden
from {{ ref('dim_department') }}
