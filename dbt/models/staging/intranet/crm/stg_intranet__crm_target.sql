-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    crm_target_id,
    country_id,
    nullif(btrim("user"), '')         as "user",
    nullif(btrim(building_q1), '')    as building_q1,
    nullif(btrim(building_q2), '')    as building_q2,
    nullif(btrim(building_q3), '')    as building_q3,
    nullif(btrim(building_q4), '')    as building_q4,
    nullif(btrim(others_q1), '')      as others_q1,
    nullif(btrim(others_q2), '')      as others_q2,
    nullif(btrim(others_q3), '')      as others_q3,
    nullif(btrim(others_q4), '')      as others_q4,
    nullif(btrim(healthcare_q1), '')  as healthcare_q1,
    nullif(btrim(healthcare_q2), '')  as healthcare_q2,
    nullif(btrim(healthcare_q3), '')  as healthcare_q3,
    nullif(btrim(healthcare_q4), '')  as healthcare_q4,
    nullif(btrim(designbuild_q1), '') as designbuild_q1,
    nullif(btrim(designbuild_q2), '') as designbuild_q2,
    nullif(btrim(designbuild_q3), '') as designbuild_q3,
    nullif(btrim(designbuild_q4), '') as designbuild_q4,
    nullif(btrim(type), '')           as type,
    year
from {{ source('raw_intranet', 'crm_target') }}
