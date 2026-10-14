{{ config(materialized='view') }}
-- MASKED employees for Power BI, built from mart_restricted.mart_hr_employee_pii (rules: DECISIONS.vi.md, section 2).
-- Dropped: ID card, tax, insurance, bank, installments. Partly masked: personal email and phones. Birthday becomes age.
-- A view runs with its owner's rights, so powerbi_ro can read it without any access to mart_restricted.
select
    employee_id,
    employee_code,
    first_name || ' ' || last_name                        as full_name,
    company_email,
    {{ age_from_birthday('birthday') }}                   as age,
    gender,
    nationality,
    {{ mask_partial('personal_email') }}                  as personal_email,
    {{ mask_partial('phone_work') }}                      as phone_work,
    {{ mask_partial('phone_home') }}                      as phone_home,
    {{ mask_partial('phone_mobile') }}                    as phone_mobile,
    {{ mask_partial('emergency_contact') }}               as emergency_contact,
    {{ mask_partial('emergency_phone') }}                 as emergency_phone
from {{ ref('mart_hr_employee_pii') }}
