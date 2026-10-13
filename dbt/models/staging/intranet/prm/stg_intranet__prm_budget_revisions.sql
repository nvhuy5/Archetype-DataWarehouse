-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_budget_revisions_id,
    nullif(btrim(component_code), '') as component_code,
    nullif(btrim(type_contract), '')  as type_contract,
    office_id,
    nullif(btrim(currency), '')       as currency,
    value,
    serial,
    nullif(btrim(type), '')           as type,
    status,
    oldrevision                       as old_revision,
    nullif(btrim(description), '')    as description,
    nullif(btrim(created_by), '')     as created_by,
    created_at,
    validated_at
from {{ source('raw_intranet', 'prm_budget_revisions') }}
