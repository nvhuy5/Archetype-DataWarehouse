-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    approval_id,
    date,
    is_haftday
from {{ source('raw_intranet', 'hr_table_leave_approval_detail') }}
