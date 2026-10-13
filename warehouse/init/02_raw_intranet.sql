-- Raw layer: one table per Intranet (MySQL) table, same name and same columns, no keys and no constraints
-- (a load must never be rejected). Generated from the MySQL DDL. Column names are lower case.
CREATE SCHEMA IF NOT EXISTS raw_intranet;

CREATE TABLE IF NOT EXISTS raw_intranet."crm_component" (
    "crm_component_id" integer,
    "contract_id" integer,
    "component_name" varchar(150),
    "component_code" varchar(100),
    "component_value" varchar(15),
    "currency" varchar(5),
    "total_fee_net_taxes" varchar(255),
    "create_by" varchar(200),
    "last_update" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_link_project_client" (
    "idc" integer,
    "idp" integer,
    "comment" varchar(255)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_link_project_scope" (
    "idp" integer,
    "idps" integer,
    "fee" bigint
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_competitors" (
    "crm_list_competitors_id" integer,
    "name" varchar(250)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_project_scope" (
    "idps" integer,
    "id_main" integer,
    "description" varchar(255),
    "sub_description" varchar(255),
    "ds_pm" varchar(5)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_reason" (
    "id" integer,
    "reason" varchar(255),
    "cat" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_main" (
    "idc" integer,
    "code" varchar(255),
    "name" varchar(255),
    "mother_company_type" integer,
    "mother_company_info" text,
    "crm_company_industry_code_id" varchar(5),
    "crm_market_id" integer,
    "crm_segment_id" integer,
    "crm_sub_segment_id" integer,
    "green_roadmap_status" varchar(30),
    "status" text,
    "flag2" varchar(255),
    "new_flag2" varchar(200),
    "risk_ass" varchar(5),
    "risk_comment" text,
    "is_key" varchar(1),
    "representative" varchar(255),
    "last_modified" timestamp,
    "cdate" timestamp,
    "key_company" varchar(1),
    "asia_headquarter" varchar(400),
    "worldwide_headquarter" varchar(400),
    "nationality" integer,
    "crm_market" text,
    "crm_segment" text,
    "crm_sub_segment" text,
    "list_nationality" text,
    "opportunities" smallint,
    "comment" text,
    "tenantid" smallint,
    "mother_company_id" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_market" (
    "crm_market_id" integer,
    "title" varchar(200),
    "market_code" varchar(20)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_proposal_dead_reason" (
    "crm_proposal_dead_reason_id" integer,
    "proposal_id" integer,
    "competitor" integer,
    "award_price" varchar(255),
    "crm_list_reason_id" integer,
    "other_reason" text,
    "added_by" varchar(150)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_segment" (
    "crm_segment_id" integer,
    "crm_market_id" integer,
    "title" varchar(200),
    "segment_code" varchar(20)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_sub_segment" (
    "crm_sub_segment_id" integer,
    "crm_segment_id" integer,
    "title" varchar(200),
    "sector_code" varchar(20)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_table_contracts" (
    "id" integer,
    "parent_lead_id" integer,
    "parent_proposal_id" integer,
    "refer_contract_id" integer,
    "title" varchar(200),
    "proj_id" integer,
    "description" text,
    "status" integer,
    "expected_sign_contract_date" date,
    "reason" integer,
    "code" varchar(24),
    "manager_in_charge" varchar(255),
    "contract_type" varchar(3),
    "country_initial" varchar(5),
    "office_initial" varchar(5),
    "year" varchar(5),
    "sequential" varchar(5),
    "revision" varchar(5),
    "fee" integer,
    "hide" smallint,
    "attachment" varchar(255),
    "attachment_risk_review" varchar(255),
    "attachment_liquidation" varchar(255),
    "cgroup" integer,
    "last_updated_user" varchar(100),
    "last_updated_date" timestamp,
    "create_date" timestamp,
    "biz_revision" integer,
    "contract_date" date,
    "seller" varchar(255),
    "office_id" integer,
    "fu_office_id" integer,
    "category_office" varchar(100),
    "legal_entity" varchar(250),
    "currency" varchar(50),
    "downpayment" varchar(250),
    "subcontracting" varchar(250),
    "vat" varchar(5),
    "wht" varchar(3),
    "wht_rate" varchar(5),
    "payment_terms" varchar(5),
    "new_version" smallint,
    "is_new_proposal" smallint,
    "is_register_only" smallint,
    "criteria_for_bonus" varchar(5),
    "next_criteria_validator" varchar(255),
    "validate_criteria_status" smallint,
    "crm_finance_client_information_id" integer,
    "client_legal_representative" varchar(200),
    "validate_status" varchar(1),
    "verified_status" varchar(125),
    "signing_date" date,
    "communication" smallint,
    "green_service" varchar(30),
    "green_optional" varchar(255)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_table_contracts_competitor" (
    "competitor_id" bigint,
    "name" varchar(255),
    "fee" bigint,
    "winner" smallint,
    "contract_id" integer,
    "cp_id" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_table_projects" (
    "idproj" integer,
    "author" varchar(255),
    "new_author" varchar(200),
    "pname" varchar(255),
    "pstatus" varchar(50),
    "ptype" integer,
    "share_users" varchar(255),
    "plocation" varchar(255),
    "pcountry" varchar(255),
    "pdesc" text,
    "gfa" varchar(200),
    "psdate" date,
    "pduration" varchar(200),
    "capex" varchar(255),
    "prepresentative" varchar(255),
    "new_prepresentative" varchar(255),
    "project_initiator" varchar(200),
    "quote_ref" varchar(100),
    "quote_date" date,
    "quote_fees" integer,
    "quote_fees_currency" varchar(200),
    "quote_fees_comments" varchar(255),
    "nb_storey" varchar(100),
    "nb_star" varchar(100),
    "nb_key" varchar(100),
    "id_office" integer,
    "id_fu_office" integer,
    "category_office" bigint,
    "crm_market_id" integer,
    "crm_segment_id" integer,
    "crm_sub_segment_id" integer,
    "pfee" varchar(100),
    "repquotation" varchar(255),
    "cdate" date,
    "pcode" varchar(50)
);

CREATE TABLE IF NOT EXISTS raw_intranet."crm_target" (
    "crm_target_id" integer,
    "country_id" integer,
    "user" varchar(200),
    "building_q1" varchar(20),
    "building_q2" varchar(20),
    "building_q3" varchar(20),
    "building_q4" varchar(20),
    "others_q1" varchar(20),
    "others_q2" varchar(20),
    "others_q3" varchar(20),
    "others_q4" varchar(20),
    "healthcare_q1" varchar(20),
    "healthcare_q2" varchar(20),
    "healthcare_q3" varchar(20),
    "healthcare_q4" varchar(20),
    "designbuild_q1" varchar(20),
    "designbuild_q2" varchar(20),
    "designbuild_q3" varchar(20),
    "designbuild_q4" varchar(20),
    "type" varchar(10),
    "year" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."finance_multiplier" (
    "id" integer,
    "country_id" integer,
    "year" varchar(10),
    "percent_of_other_cost" varchar(20),
    "external_client" varchar(20),
    "internal_client" varchar(20),
    "business_line" varchar(100),
    "overhead_rate" real
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_country" (
    "idp" integer,
    "pays" varchar(100),
    "nationality" varchar(100),
    "region" varchar(25),
    "iso2c" varchar(2),
    "iso3c" varchar(3),
    "calling_code" varchar(10),
    "iso_country_code" integer,
    "act_country_code" varchar(3),
    "hr_hide" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_department" (
    "id" integer,
    "group_id" integer,
    "name" varchar(100),
    "code" varchar(3),
    "description" varchar(200),
    "technical_dept" smallint,
    "business_line" varchar(5),
    "ds_pm" smallint,
    "hide" varchar(1)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_employee_level" (
    "employee_level_id" integer,
    "title" varchar(100),
    "code" varchar(10),
    "department_id" integer,
    "level_in_dept" integer,
    "hide" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_job_title" (
    "idjt" integer,
    "title" varchar(255),
    "title_for_business_card" varchar(255),
    "dept" integer,
    "employee_level_id" integer,
    "hide" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_leave_type" (
    "idht" bigint,
    "code" varchar(20),
    "description" varchar(255),
    "frequency" varchar(255),
    "type" smallint,
    "nav_item_code" varchar(100),
    "nav_code" varchar(10)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_offices" (
    "idf" integer,
    "offices" varchar(255),
    "display_office_name" varchar(500),
    "legal_office_name" varchar(500),
    "countrywork" varchar(255),
    "workinglocation" varchar(255),
    "address" varchar(255),
    "address_v2" varchar(500),
    "default_phone_number" varchar(100),
    "area_code" varchar(20),
    "work_location_only" varchar(1),
    "crm_office" smallint,
    "office_code" varchar(3),
    "country_code" varchar(3),
    "country_id" integer,
    "crm_project_category" smallint,
    "crm_country" varchar(50),
    "hide" smallint,
    "candidate_hide" smallint,
    "grp" varchar(1),
    "bd_manager" varchar(255),
    "managing_director" varchar(255),
    "regional_director" varchar(255),
    "location_longitude" varchar(255),
    "location_latitude" varchar(255),
    "default_tax" integer,
    "hrm_hide" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_menu_process_status" (
    "idstatus" integer,
    "name" varchar(100)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_pa_objectives" (
    "objectives_id" integer,
    "ide" integer,
    "appraisal_type" smallint,
    "year" smallint,
    "objective" text,
    "goal" varchar(50),
    "success_factor" varchar(8000),
    "smart" text,
    "action_required" text,
    "weight" integer,
    "due_date" varchar(500),
    "result_achieved" varchar(8000),
    "self_evaluation" integer,
    "manager_evaluation" integer,
    "agreed_evaluation" integer,
    "result_evaluation" integer,
    "mid_year_done" text,
    "mid_year_not_done" text,
    "mid_year_need_support" text,
    "mid_year_problem" text,
    "manager_comment" varchar(2500),
    "manager_comment_after_meeting" varchar(2500),
    "mid_year_submit_status" smallint,
    "validated" smallint,
    "mid_year_status_updated_by" varchar(255)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_contract" (
    "idcont" integer,
    "id_e" integer,
    "cfrom" date,
    "cto" date,
    "job_title_id" integer,
    "cposition" varchar(255),
    "ccontract" varchar(255),
    "ctype" varchar(1),
    "tdate" date,
    "lock" varchar(1),
    "idcontracttype" integer,
    "probation_end_date" date,
    "archived" smallint,
    "probation_appraisal_data" text,
    "appraisal_data" text,
    "appraisal_submited" smallint,
    "appraisal_comments" text,
    "contract_appraisal_comments" text,
    "contract_appraisal_submited" smallint,
    "end_contract_comment" text,
    "added_user" integer,
    "added_time" timestamp,
    "last_updated_user" integer,
    "last_updated_time" timestamp,
    "exit_interviewed" text,
    "manager_level" varchar(1),
    "market" varchar(55),
    "payment" varchar(1),
    "exit_interview_date" date,
    "hr_menu_grade_id" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_contract_type" (
    "id_contract_type" integer,
    "name" varchar(250),
    "hide" varchar(1)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_direct_manager" (
    "id_e" integer,
    "id_m" integer,
    "is_main" varchar(1)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_leave" (
    "idh" integer,
    "id_e" integer,
    "type" varchar(20),
    "last_balance" numeric(6,2),
    "balance" numeric(6,2),
    "last_month_added" date
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_leave_approval" (
    "id" integer,
    "id_e" integer,
    "type" varchar(20),
    "balance" numeric(4,1),
    "from" date,
    "to" date,
    "approved" integer,
    "cuser" integer,
    "cdate" timestamp,
    "withdraw_history" text,
    "replace_by" integer,
    "force_send_to_managing_director" smallint,
    "managing_director_ide" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_leave_approval_detail" (
    "approval_id" integer,
    "date" date,
    "is_haftday" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_main" (
    "ide" integer,
    "code" varchar(20),
    "arche_email" varchar(255),
    "department_id" integer,
    "job_title_id" integer,
    "employee_level_id" integer,
    "id_md5" varchar(64),
    "fname" varchar(200),
    "lname" varchar(200),
    "nickname" varchar(255),
    "birthday" date,
    "gender" varchar(1),
    "estatus" integer,
    "offer_date" date,
    "offer_position" varchar(255),
    "enumber" integer,
    "phonework" varchar(100),
    "phonehome" varchar(100),
    "phonemobile" varchar(100),
    "emerg_contact" varchar(255),
    "emerg_phone" varchar(100),
    "nationality" varchar(255),
    "marital_status" varchar(200),
    "remarks" text,
    "p_reference" varchar(200),
    "p_nationalite" varchar(200),
    "p_experience" varchar(100),
    "e_email" varchar(255),
    "country" varchar(255),
    "city" varchar(255),
    "nb_children" varchar(20),
    "incharge_children" varchar(3),
    "visa_exp_date" date,
    "sent_presentation" varchar(1),
    "sent_tech" varchar(1),
    "country_work" integer,
    "working_location" integer,
    "type" varchar(50),
    "manager_level" smallint,
    "idskype" varchar(100),
    "id_card" varchar(50),
    "place_issue" varchar(50),
    "social_ins_number" varchar(30),
    "employee_add" varchar(255),
    "id_synchro" integer,
    "direct_manager" varchar(255),
    "personal_income_tax" varchar(200),
    "termination_reason" varchar(100),
    "regretted_loss" smallint,
    "added_user" integer,
    "added_time" timestamp,
    "last_updated_user" integer,
    "last_updated_time" timestamp,
    "bank_name" varchar(155),
    "bank_account" varchar(155),
    "card_holder" varchar(155),
    "startworking" date,
    "nb_dependants" varchar(45),
    "resign_date" date,
    "nb_dependants_date" date,
    "insurance_issue" varchar(255),
    "first_installment" varchar(45),
    "second_installment" varchar(45),
    "third_installment" varchar(45),
    "voluntary_detail" varchar(255),
    "payment" varchar(1),
    "market" varchar(55),
    "buddy_id" varchar(45),
    "education_level" integer,
    "email_config" varchar(255),
    "legal_office" integer,
    "branch_group" smallint,
    "branch_industry" smallint,
    "branch_reality" smallint,
    "branch_y" smallint,
    "branch_bect" smallint,
    "branch_archesco" smallint,
    "primary_branch" smallint,
    "terminated_date" timestamp,
    "email_action" smallint,
    "terminated_user" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_office_tracking" (
    "id_e" integer,
    "office_id_from" integer,
    "office_id_to" integer,
    "updated_date" timestamp,
    "updated_user" integer,
    "type" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_phone_interview" (
    "hr_table_phone_interview_id" integer,
    "idm" varchar(50),
    "birthday" date,
    "nationality" varchar(200),
    "family_status" varchar(200),
    "education" varchar(500),
    "current_location" varchar(200),
    "current_position_detail" text,
    "technical_specialty" text,
    "reason_leaving" varchar(200),
    "personality" varchar(100),
    "current_salary" varchar(200),
    "expectations" varchar(200),
    "availabilities" varchar(200),
    "recommend" varchar(30),
    "interview_date" date,
    "interviewer" varchar(100),
    "precommend" varchar(45),
    "frecommend" varchar(45),
    "pnote" varchar(45),
    "fnote" varchar(45),
    "vacant_position" varchar(55),
    "family_childs" varchar(55)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_pre_interview" (
    "idpre" integer,
    "id_e" integer,
    "ap_date" date,
    "adate" date,
    "interviewer" varchar(100),
    "location" varchar(255),
    "motivation" varchar(255),
    "marital" varchar(100),
    "wife_occ" varchar(255),
    "child_nb" integer,
    "child_school" varchar(1),
    "current_employer" varchar(255),
    "current_position" varchar(255),
    "position_since" varchar(100),
    "notice_delay" varchar(100),
    "umployed_since" varchar(100),
    "reason" text,
    "current_salary" varchar(100),
    "current_accomodo" varchar(100),
    "current_transp" varchar(100),
    "current_mobili" varchar(100),
    "current_fticket" varchar(100),
    "current_insurances" varchar(100),
    "current_other" varchar(100),
    "expected_salary" varchar(100),
    "expected_accomodo" varchar(100),
    "expected_transp" varchar(100),
    "expected_mobili" varchar(100),
    "expected_fticket" varchar(100),
    "expected_insurances" varchar(100),
    "expected_other" varchar(100),
    "preferred_location" varchar(255),
    "tech_interview" varchar(255),
    "prefered_date" date,
    "contact_number" varchar(100),
    "not_selected" varchar(1),
    "not_selected_reason" text,
    "salary_curr_gross" varchar(255),
    "salary_exp_gross" varchar(255),
    "bonus" varchar(255),
    "school" varchar(255),
    "retire" varchar(255),
    "ex_bonus" varchar(255),
    "ex_school" varchar(255),
    "ex_retire" varchar(255)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_tech_interview" (
    "idtech" integer,
    "id_e" integer,
    "tadate" timestamp,
    "tdatej" timestamp,
    "tinterviewer" varchar(255),
    "tevaluation" text,
    "tcomments" text,
    "tlocation" varchar(255),
    "organizer" varchar(100),
    "recommend" varchar(50),
    "vacant_position" varchar(200),
    "interviewer_position" varchar(200),
    "trequirements" varchar(255),
    "tfactors" varchar(255),
    "texperience" varchar(500),
    "tqualifications" varchar(500),
    "tdemonstation" varchar(500),
    "tweaknesses" varchar(500),
    "tstrength" varchar(500),
    "tpersonality" varchar(500),
    "precommend" varchar(5),
    "frecommend" varchar(5),
    "fnote" varchar(255),
    "pnote" varchar(255),
    "tenglish" varchar(255),
    "tlevel" varchar(255),
    "taddinfo" varchar(255),
    "office" varchar(55)
);

CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_training_kpi" (
    "idhr_table_training_kpi" bigint,
    "office_id" varchar(5),
    "dept_id" varchar(5),
    "emp_code" varchar(15),
    "internal" varchar(15),
    "external" varchar(15),
    "technical" varchar(15),
    "non_technical" varchar(15),
    "total_hours_person" varchar(45),
    "trainers_facilitators" varchar(45),
    "month" varchar(45),
    "position" varchar(255),
    "course_name" varchar(255),
    "tfrom" varchar(45),
    "tto" varchar(45),
    "ctfrom" varchar(45),
    "ctto" varchar(45),
    "update_by" varchar(255),
    "total_hours_course" varchar(45),
    "total_fee_course" varchar(45)
);

CREATE TABLE IF NOT EXISTS raw_intranet."jobs_list" (
    "idj" integer,
    "code" varchar(25),
    "posting_date" date,
    "job_title" varchar(255),
    "job_title_id" integer,
    "job_status" date,
    "job_reason" varchar(25),
    "job_type" varchar(50),
    "job_office" varchar(255),
    "job_office_id" integer,
    "no_of_vacancy" integer,
    "job_location" varchar(255),
    "job_department" varchar(255),
    "job_department_id" integer,
    "job_reports" varchar(255),
    "job_respons" text,
    "job_education" text,
    "job_skills" text,
    "job_experience" text,
    "job_package" text,
    "job_package_note" varchar(255),
    "project_work" text,
    "manage_peoples" text,
    "hr_rep" varchar(100),
    "hr_email" varchar(255),
    "hr_sent_to" varchar(255),
    "valid" varchar(1),
    "confidential" smallint,
    "request_user" integer,
    "request_date" timestamp,
    "offer_date" date,
    "offer_ide" integer,
    "arrival_date" date,
    "arrival_asap" smallint,
    "closed" smallint,
    "canceled" smallint,
    "completed" smallint,
    "onhold" smallint,
    "ondraft" smallint,
    "group_department_id" integer,
    "group_department" varchar(255),
    "project_name" varchar(255)
);

CREATE TABLE IF NOT EXISTS raw_intranet."pa_strategic_plan_level_1" (
    "pa_strategic_plan_level_1_id" integer,
    "level_1_name" varchar(500),
    "year" varchar(4)
);

CREATE TABLE IF NOT EXISTS raw_intranet."pa_strategic_plan_level_2" (
    "pa_strategic_plan_level_2_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "level_2_name" varchar(500),
    "year" varchar(4)
);

CREATE TABLE IF NOT EXISTS raw_intranet."pa_strategic_plan_level_3" (
    "pa_strategic_plan_level_3_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "pa_strategic_plan_level_2_id" integer,
    "level_3_name" varchar(500),
    "year" varchar(4)
);

CREATE TABLE IF NOT EXISTS raw_intranet."pa_strategic_plan_level_4" (
    "pa_strategic_plan_level_4_id" integer,
    "pa_strategic_plan_level_3_id" integer,
    "pa_strategic_plan_level_2_id" integer,
    "pa_strategic_plan_level_1_id" integer,
    "level_4_name" varchar(500),
    "status" varchar(80),
    "goal_description" text,
    "person_in_charge" varchar(80),
    "expected_date" date,
    "person_in_charge_email" varchar(70),
    "person_report_email" varchar(70)
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_budget_revision_position" (
    "prm_budget_revision_position_id" integer,
    "employee_level_id" integer,
    "type" varchar(15),
    "cch" numeric(13,4),
    "original_cch" numeric(13,4),
    "employee_level_title" varchar(100),
    "rev_id" integer,
    "phase_id" integer,
    "dept_id" integer,
    "initial_budget_amount" numeric(38,4),
    "initial_budget_hour" real,
    "ctd_amount" numeric(38,4),
    "ctd_hour" real,
    "ctc_amount" numeric(38,4),
    "ctc_hour" real,
    "contract_revenue" numeric(38,4),
    "percentage_of_revenue_contract" numeric(13,10),
    "nav_cost" numeric(38,4),
    "nav_hour" real,
    "ts_cost" numeric(38,4),
    "ts_hour" real,
    "added_by" varchar(255),
    "added_at" timestamp,
    "is_inter_office" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_budget_revision_setup" (
    "prm_budget_revision_setup_id" integer,
    "rev_id" integer,
    "dept_id" integer,
    "phase_id" integer,
    "added_by" varchar(150),
    "added_at" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_budget_revisions" (
    "prm_budget_revisions_id" integer,
    "component_code" varchar(50),
    "type_contract" varchar(15),
    "office_id" integer,
    "currency" varchar(15),
    "value" numeric(38,4),
    "serial" integer,
    "type" varchar(15),
    "status" smallint,
    "oldrevision" integer,
    "description" varchar(500),
    "created_by" varchar(255),
    "created_at" timestamp,
    "validated_at" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_e_project_country" (
    "prm_e_project_country_id" integer,
    "country_name" varchar(50),
    "country_code" varchar(10),
    "office_name" varchar(40),
    "office_code" varchar(10),
    "office_id" integer,
    "currency" varchar(20),
    "currency_unit" integer,
    "language" varchar(100),
    "wf_show_currency" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_organization_contact" (
    "prm_organization_contact_id" integer,
    "crm_project_id" integer,
    "prm_company_id" integer,
    "act_member" smallint,
    "name" varchar(100),
    "position" varchar(200),
    "phone" varchar(20),
    "email" varchar(100),
    "team_type" varchar(100),
    "added_user" varchar(100),
    "prm_rfi_category" varchar(255),
    "user_ide" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_project" (
    "prm_project_id" integer,
    "project_id" integer,
    "crm_project_id" integer,
    "project_code" varchar(5),
    "project_name" varchar(200),
    "company_name" varchar(200),
    "company_code" varchar(5),
    "address" varchar(500),
    "phone" varchar(20),
    "fax" varchar(20),
    "logo" varchar(100),
    "project_picture" varchar(100),
    "project_location" varchar(100),
    "latitude" varchar(255),
    "longitude" varchar(255),
    "description" text,
    "gfa" varchar(20),
    "land_area" varchar(20),
    "category" varchar(200),
    "office" varchar(200),
    "city" varchar(200),
    "follow_office" varchar(200),
    "country" varchar(200),
    "email" varchar(100),
    "contract_number" varchar(50),
    "effective_date" date,
    "warranties" varchar(200),
    "disputy_resolution" varchar(200),
    "tpl_insurance" varchar(200),
    "performance_bond" varchar(200),
    "letter_of_award" varchar(10),
    "conditions_of_contract" varchar(200),
    "limitation_of_liability" varchar(200),
    "penalties" varchar(200),
    "pi_insurance" varchar(200),
    "other_insurance" varchar(200),
    "project_fee" varchar(100),
    "down_payment_paid" varchar(5),
    "contract_signed" varchar(5),
    "client_reputation" varchar(200),
    "nature_of_client" varchar(200),
    "services_control" varchar(200),
    "legal_signing" varchar(200),
    "contract_value" varchar(20),
    "cost_description" text,
    "cost_excluded" real,
    "downpayment" varchar(300),
    "currency" varchar(5),
    "internal_subcontract" varchar(100),
    "term_of_payment" varchar(5),
    "type_of_services" varchar(200),
    "project_category" integer,
    "ext_subcontract" varchar(200),
    "project_manager" varchar(50),
    "deputy_project_manager" varchar(100),
    "project_assistant" varchar(50),
    "financial_manager" varchar(50),
    "contract_manager" varchar(50),
    "project_mailbox" varchar(50),
    "project_manager_email" varchar(100),
    "deputy_project_manager_email" varchar(150),
    "project_assistant_email" varchar(100),
    "financial_manager_email" varchar(100),
    "contract_manager_email" varchar(100),
    "ftp_link" varchar(200),
    "transfer_date" date,
    "vat" varchar(11),
    "liquidation_files" varchar(150),
    "liquidation_date" timestamp,
    "archetype_description" text,
    "client_description" text,
    "project_description" text,
    "project_status" varchar(40),
    "addendum" varchar(300),
    "contract_design_element" varchar(40),
    "contract_pcmqs" varchar(40),
    "downpayment_design" varchar(40),
    "downpayment_pcmqs" varchar(40),
    "safety" smallint,
    "num_day_suspension" integer,
    "num_day_termination" integer,
    "design_contract_no" varchar(30),
    "pm_contract_no" varchar(30),
    "contact_email" varchar(150),
    "create_by" varchar(250),
    "create_date" date,
    "directory_link" varchar(255),
    "tenantid" smallint,
    "client_deployment_schedule" varchar(200),
    "project_branch" smallint
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_project_addendum" (
    "prm_project_addendum_id" integer,
    "crm_project_id" integer,
    "addendum_code" varchar(40),
    "scope" varchar(400),
    "ds_pm" varchar(10),
    "value" varchar(30),
    "name" varchar(200),
    "currency" text,
    "created_date" date,
    "created_by" varchar(100)
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_purchase_order_position" (
    "prm_purchase_order_position_id" integer,
    "name" varchar(40),
    "position" varchar(40),
    "email" varchar(300),
    "country_code" varchar(30),
    "office_code" varchar(20),
    "head_dept_id" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."prm_subcontract" (
    "prm_subcontract_id" integer,
    "crm_project_id" integer,
    "subcontract_status" varchar(50),
    "consultant_pm_email" varchar(150),
    "consultant_pm_name" varchar(100),
    "consultant_md_email" varchar(150),
    "consultant_md_name" varchar(150),
    "consultant_branch" varchar(10),
    "sub_consultant_branch" varchar(50),
    "sub_consultant_office" varchar(50),
    "type_of_contract" smallint,
    "sub_contract_code" varchar(30),
    "sub_consultant_pm_email" varchar(150),
    "sub_consultant_pm_name" varchar(100),
    "sub_consultant_md_email" varchar(150),
    "sub_consultant_md_name" varchar(150),
    "contract_provided" varchar(3),
    "price_type" smallint,
    "price_value" varchar(14),
    "currency" varchar(5),
    "payment_schedule_type" smallint,
    "effective_date" date,
    "estimated_duration" varchar(30),
    "others_fees" varchar(10),
    "summary" varchar(200),
    "inclusions" text,
    "exclusions" text,
    "submit_status" smallint,
    "consultant_office" varchar(50),
    "consultant_office_id" integer,
    "sub_consultant_office_id" integer,
    "wht_tax" smallint,
    "exclude_withholding_tax" smallint,
    "liquidation_file" varchar(300),
    "revise_comment" varchar(2000),
    "dont_change_sub_contract_code" smallint,
    "revise_date" date,
    "liquidation_addendum_files" varchar(1000),
    "updated_at" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."strategic_goal" (
    "strategic_goal_id" integer,
    "strategic_objective_id" integer,
    "goal" varchar(500),
    "start_date" date,
    "deadline" date,
    "level" varchar(50),
    "status" varchar(20),
    "weight_goal" varchar(4),
    "year" varchar(4),
    "priority" varchar(1)
);

CREATE TABLE IF NOT EXISTS raw_intranet."strategic_leader" (
    "strategic_leader_id" integer,
    "strategic_goal_id" integer,
    "leader_name" varchar(150),
    "leader_email" varchar(150),
    "type" smallint,
    "added_by" varchar(200),
    "added_time" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."strategic_member_of_task" (
    "strategic_member_of_task_id" integer,
    "strategic_task_id" integer,
    "email" varchar(250),
    "added_by" varchar(250),
    "added_time" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."strategic_objective" (
    "strategic_objective_id" integer,
    "theme" varchar(50),
    "objective" varchar(200),
    "sponsor_name" varchar(100),
    "sponsor_email" varchar(100),
    "leader_name" varchar(100),
    "leader_email" varchar(100),
    "year" varchar(4)
);

CREATE TABLE IF NOT EXISTS raw_intranet."strategic_task" (
    "strategic_task_id" integer,
    "strategic_goal_id" integer,
    "task_description" text,
    "resources" text,
    "comments" text,
    "deadline" date,
    "progress" varchar(5),
    "weight" varchar(3),
    "added_by" varchar(250),
    "added_time" timestamp
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_component_2015" (
    "timesheet_component_id" integer,
    "contract_id" integer,
    "component_name" varchar(200),
    "navision_code" varchar(50),
    "status" varchar(15),
    "department_check" smallint,
    "status_effect_date" date,
    "last_update" date,
    "change_status_date" timestamp,
    "factor" varchar(5),
    "send_to_navision" date
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_contract_2015" (
    "contract_id" integer,
    "crm_contract_id" integer,
    "code" varchar(30),
    "navision_code" varchar(30),
    "scope" varchar(5),
    "project_manager" varchar(20),
    "title" varchar(255),
    "timesheet_project_id" integer,
    "contract_status" varchar(15),
    "status_effect_date" date,
    "change_status_date" timestamp,
    "office_id" integer,
    "added_user" integer,
    "added_time" timestamp,
    "last_updated_date" timestamp,
    "last_update_user" varchar(100)
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_delta" (
    "id" integer,
    "typedelta" varchar(15),
    "jobno" varchar(60),
    "empcode" varchar(15),
    "phase" varchar(15),
    "dept" varchar(15),
    "delta" real,
    "dateupdate" date
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_entry_2015" (
    "id" integer,
    "date" date,
    "uid" integer,
    "ide" integer,
    "employee_code" varchar(20),
    "employee_office" varchar(5),
    "department_id" integer,
    "jobtitle_id" integer,
    "employee_level" varchar(20),
    "phase_id" integer,
    "component_id" integer,
    "contract_id" integer,
    "proj_id" integer,
    "time" numeric(4,2),
    "rate" numeric(4,2),
    "validated" integer,
    "last_modified" timestamp,
    "last_updated_user" varchar(150)
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_phase_2015" (
    "phase_id" integer,
    "name" varchar(255),
    "description" text,
    "phase_code" varchar(4),
    "navision_no" varchar(10),
    "navision_code" varchar(5),
    "type" varchar(15),
    "budget_phase" smallint,
    "for_order" smallint,
    "planning_color" varchar(15),
    "refer_id" integer,
    "dept_id" integer
);

CREATE TABLE IF NOT EXISTS raw_intranet."timesheet_project_2015" (
    "timesheet_project_id" integer,
    "project_name" varchar(200),
    "office" smallint,
    "project_type" varchar(2),
    "status" varchar(15),
    "status_effect_date" date,
    "project_manager" varchar(150),
    "last_update" timestamp,
    "change_status_date" timestamp
);
