-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_component_id,
    contract_id,
    nullif(btrim(component_name), '')      as component_name,
    nullif(btrim(component_code), '')      as component_code,
    nullif(btrim(component_value), '')     as component_value,
    nullif(btrim(currency), '')            as currency,
    nullif(btrim(total_fee_net_taxes), '') as total_fee_net_taxes,
    nullif(btrim(create_by), '')           as create_by,
    last_update
from {{ source('raw_intranet', 'crm_component') }}
