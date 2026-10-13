-- Staging: one row per source row, trimmed text, empty strings become NULL, snake_case names. No joins, no business rules.
select
    prm_organization_contact_id,
    crm_project_id,
    prm_company_id,
    act_member,
    nullif(btrim(name), '')             as name,
    nullif(btrim(position), '')         as position,
    nullif(btrim(phone), '')            as phone,
    nullif(btrim(email), '')            as email,
    nullif(btrim(team_type), '')        as team_type,
    nullif(btrim(added_user), '')       as added_user,
    nullif(btrim(prm_rfi_category), '') as prm_rfi_category,
    user_ide
from {{ source('raw_intranet', 'prm_organization_contact') }}
