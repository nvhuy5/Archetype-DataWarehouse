-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id_e,
    office_id_from,
    office_id_to,
    updated_date,
    updated_user,
    type
from {{ source('raw_intranet', 'hr_table_office_tracking') }}
