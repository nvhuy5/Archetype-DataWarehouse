-- Timesheet report, table Employees: employees in status 7 and 8. Personal columns are already left out in dim_employee
-- (no birthday, only age; no ID card, bank, tax, insurance or salary), so this mart has nothing to mask.
select
    employee_id, employee_code, full_name, gender, age, nationality, marital_status, email, employee_type, manager_level,
    employee_status, employee_status_id, department_id, department_code, department_name, is_technical_department,
    job_title_id, job_title, employee_level_id, job_level, working_office_id, working_office_name, working_office_code,
    working_location_id, working_pays, working_region, direct_manager_email, start_working_date, act_seniority_years,
    resign_date, termination_reason, regretted_loss, contract_end_date, contract_job_title, contract_type, contract_term,
    first_interview_date, recruitment_source
from {{ ref('dim_employee') }}
