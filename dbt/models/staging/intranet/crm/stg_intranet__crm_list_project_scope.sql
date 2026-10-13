-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idps,
    id_main,
    nullif(btrim(description), '')     as description,
    nullif(btrim(sub_description), '') as sub_description,
    nullif(btrim(ds_pm), '')           as ds_pm
from {{ source('raw_intranet', 'crm_list_project_scope') }}
