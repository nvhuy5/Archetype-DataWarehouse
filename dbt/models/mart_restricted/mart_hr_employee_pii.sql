-- UNMASKED employees (status 7 and 8) with the personal columns. Only pii_admin can read this schema.
-- This is the only place that reads personal columns from raw; staging and dwh keep hiding them.
-- The masked version for Power BI is mart.mart_hr_employee, built from this table, so the two cannot drift apart.
select
    ide                      as employee_id,
    nullif(btrim(code), '')  as employee_code,
    nullif(btrim(fname), '') as first_name,
    nullif(btrim(lname), '') as last_name,
    nullif(btrim(arche_email), '') as company_email,
    birthday,
    nullif(btrim(gender), '') as gender,
    nullif(btrim(nationality), '') as nationality,
    -- identity and finance: dropped in the masked version
    nullif(btrim(id_card), '')             as id_card,
    nullif(btrim(place_issue), '')         as id_card_place_issue,
    nullif(btrim(social_ins_number), '')   as social_insurance_number,
    nullif(btrim(insurance_issue), '')     as insurance_issue,
    nullif(btrim(personal_income_tax), '') as personal_income_tax,
    nullif(btrim(bank_name), '')           as bank_name,
    nullif(btrim(bank_account), '')        as bank_account,
    nullif(btrim(card_holder), '')         as card_holder,
    nullif(btrim(first_installment), '')   as first_installment,
    nullif(btrim(second_installment), '')  as second_installment,
    nullif(btrim(third_installment), '')   as third_installment,
    nullif(btrim(payment), '')             as payment,
    -- contact: partly masked in the masked version
    nullif(btrim(e_email), '')       as personal_email,
    nullif(btrim(phonework), '')     as phone_work,
    nullif(btrim(phonehome), '')     as phone_home,
    nullif(btrim(phonemobile), '')   as phone_mobile,
    nullif(btrim(emerg_contact), '') as emergency_contact,
    nullif(btrim(emerg_phone), '')   as emergency_phone
from {{ source('raw_intranet', 'hr_table_main') }}
where estatus in (7, 8)
