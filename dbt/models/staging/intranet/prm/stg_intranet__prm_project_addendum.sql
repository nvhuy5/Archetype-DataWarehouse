-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_project_addendum_id,
    crm_project_id,
    nullif(btrim(addendum_code), '') as addendum_code,
    nullif(btrim(scope), '')         as scope,
    nullif(btrim(ds_pm), '')         as ds_pm,
    nullif(btrim(value), '')         as value,
    nullif(btrim(name), '')          as name,
    nullif(btrim(currency), '')      as currency,
    created_date,
    nullif(btrim(created_by), '')    as created_by
from {{ source('raw_intranet', 'prm_project_addendum') }}
