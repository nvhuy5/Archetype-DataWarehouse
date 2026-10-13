-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_proposal_dead_reason_id,
    proposal_id,
    competitor,
    nullif(btrim(award_price), '')  as award_price,
    crm_list_reason_id,
    nullif(btrim(other_reason), '') as other_reason,
    nullif(btrim(added_by), '')     as added_by
from {{ source('raw_intranet', 'crm_proposal_dead_reason') }}
