-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    id,
    id_e,
    nullif(btrim(type), '')             as type,
    balance,
    "from",
    "to",
    approved,
    cuser,
    cdate,
    nullif(btrim(withdraw_history), '') as withdraw_history,
    replace_by,
    force_send_to_managing_director,
    managing_director_ide
from {{ source('raw_intranet', 'hr_table_leave_approval') }}
