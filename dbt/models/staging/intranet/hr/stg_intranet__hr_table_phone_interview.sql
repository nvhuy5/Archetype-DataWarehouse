-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    hr_table_phone_interview_id,
    nullif(btrim(idm), '')                     as idm,
    nullif(btrim(family_status), '')           as family_status,
    nullif(btrim(education), '')               as education,
    nullif(btrim(current_location), '')        as current_location,
    nullif(btrim(current_position_detail), '') as current_position_detail,
    nullif(btrim(technical_specialty), '')     as technical_specialty,
    nullif(btrim(reason_leaving), '')          as reason_leaving,
    nullif(btrim(personality), '')             as personality,
    nullif(btrim(expectations), '')            as expectations,
    nullif(btrim(availabilities), '')          as availabilities,
    nullif(btrim(recommend), '')               as recommend,
    interview_date,
    nullif(btrim(interviewer), '')             as interviewer,
    nullif(btrim(precommend), '')              as precommend,
    nullif(btrim(frecommend), '')              as frecommend,
    nullif(btrim(pnote), '')                   as pnote,
    nullif(btrim(fnote), '')                   as fnote,
    nullif(btrim(vacant_position), '')         as vacant_position,
    nullif(btrim(family_childs), '')           as family_childs
from {{ source('raw_intranet', 'hr_table_phone_interview') }}
