-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_purchase_order_position_id,
    nullif(btrim(name), '')         as name,
    nullif(btrim(position), '')     as position,
    nullif(btrim(email), '')        as email,
    nullif(btrim(country_code), '') as country_code,
    nullif(btrim(office_code), '')  as office_code,
    head_dept_id
from {{ source('raw_intranet', 'prm_purchase_order_position') }}
