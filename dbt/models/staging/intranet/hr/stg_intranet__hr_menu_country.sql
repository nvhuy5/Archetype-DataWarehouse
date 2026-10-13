-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    idp,
    nullif(btrim(pays), '')             as pays,
    nullif(btrim(nationality), '')      as nationality,
    nullif(btrim(region), '')           as region,
    nullif(btrim(iso2c), '')            as iso2c,
    nullif(btrim(iso3c), '')            as iso3c,
    nullif(btrim(calling_code), '')     as calling_code,
    iso_country_code,
    nullif(btrim(act_country_code), '') as act_country_code,
    hr_hide
from {{ source('raw_intranet', 'hr_menu_country') }}
