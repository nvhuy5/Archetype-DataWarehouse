-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    nullif(btrim(typedelta), '') as type_delta,
    nullif(btrim(jobno), '')     as job_no,
    nullif(btrim(empcode), '')   as emp_code,
    nullif(btrim(phase), '')     as phase,
    nullif(btrim(dept), '')      as dept,
    delta,
    dateupdate                   as date_update
from {{ source('raw_intranet', 'timesheet_delta') }}
