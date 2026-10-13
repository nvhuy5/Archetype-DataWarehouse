-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_e_project_country_id,
    nullif(btrim(country_name), '') as country_name,
    nullif(btrim(country_code), '') as country_code,
    nullif(btrim(office_name), '')  as office_name,
    nullif(btrim(office_code), '')  as office_code,
    office_id,
    nullif(btrim(currency), '')     as currency,
    currency_unit,
    nullif(btrim(language), '')     as language,
    wf_show_currency
from {{ source('raw_intranet', 'prm_e_project_country') }}
