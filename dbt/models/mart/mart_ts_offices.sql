-- Timesheet report, table Offices.
select
    office_id, office_name, office_code, is_hidden, country, region, eproject_office_name, has_employee, has_eproject
from {{ ref('dim_office') }}
