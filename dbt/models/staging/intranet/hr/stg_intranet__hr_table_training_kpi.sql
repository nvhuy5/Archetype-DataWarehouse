-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idhr_table_training_kpi,
    nullif(btrim(office_id), '')             as office_id,
    nullif(btrim(dept_id), '')               as dept_id,
    nullif(btrim(emp_code), '')              as emp_code,
    nullif(btrim(internal), '')              as internal,
    nullif(btrim(external), '')              as external,
    nullif(btrim(technical), '')             as technical,
    nullif(btrim(non_technical), '')         as non_technical,
    nullif(btrim(total_hours_person), '')    as total_hours_person,
    nullif(btrim(trainers_facilitators), '') as trainers_facilitators,
    nullif(btrim(month), '')                 as month,
    nullif(btrim(position), '')              as position,
    nullif(btrim(course_name), '')           as course_name,
    nullif(btrim(tfrom), '')                 as tfrom,
    nullif(btrim(tto), '')                   as tto,
    nullif(btrim(ctfrom), '')                as ctfrom,
    nullif(btrim(ctto), '')                  as ctto,
    nullif(btrim(update_by), '')             as update_by,
    nullif(btrim(total_hours_course), '')    as total_hours_course,
    nullif(btrim(total_fee_course), '')      as total_fee_course
from {{ source('raw_intranet', 'hr_table_training_kpi') }}
