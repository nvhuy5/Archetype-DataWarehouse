-- Sample rows for raw_intranet.prm_subcontract (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
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
TRUNCATE raw_intranet."prm_subcontract";
INSERT INTO raw_intranet."prm_subcontract" ("prm_subcontract_id", "crm_project_id", "subcontract_status", "consultant_pm_email", "consultant_pm_name", "consultant_md_email", "consultant_md_name", "consultant_branch", "sub_consultant_branch", "sub_consultant_office", "type_of_contract", "sub_contract_code", "sub_consultant_pm_email", "sub_consultant_pm_name", "sub_consultant_md_email", "sub_consultant_md_name", "contract_provided", "price_type", "price_value", "currency", "payment_schedule_type", "effective_date", "estimated_duration", "others_fees", "summary", "inclusions", "exclusions", "submit_status", "consultant_office", "consultant_office_id", "sub_consultant_office_id", "wht_tax", "exclude_withholding_tax", "liquidation_file", "revise_comment", "dont_change_sub_contract_code", "revise_date", "liquidation_addendum_files", "updated_at") VALUES
    (1, 1, 'subcontract_status_1', 'consultant_pm_email_1', 'consultant_pm_name_1', 'consultant_md_email_1', 'consultant_md_name_1', 'consultant', 'sub_consultant_branch_1', 'sub_consultant_office_1', 1, 'sub_contract_code_1', 'sub_consultant_pm_email_1', 'sub_consultant_pm_name_1', 'sub_consultant_md_email_1', 'sub_consultant_md_name_1', 'con', 1, 'price_value_1', 'curre', 1, '2026-01-02', 'estimated_duration_1', 'others_fee', 'summary_1', 'inclusions_1', 'exclusions_1', 1, 'consultant_office_1', 1, 1, 1, 1, 'liquidation_file_1', 'revise_comment_1', 1, '2026-01-02', 'liquidation_addendum_files_1', '2026-01-02 08:00:00'),
    (2, 2, 'subcontract_status_2', 'consultant_pm_email_2', 'consultant_pm_name_2', 'consultant_md_email_2', 'consultant_md_name_2', 'consultant', 'sub_consultant_branch_2', 'sub_consultant_office_2', 2, 'sub_contract_code_2', 'sub_consultant_pm_email_2', 'sub_consultant_pm_name_2', 'sub_consultant_md_email_2', 'sub_consultant_md_name_2', 'con', 2, 'price_value_2', 'curre', 2, '2026-01-03', 'estimated_duration_2', 'others_fee', 'summary_2', 'inclusions_2', 'exclusions_2', 2, 'consultant_office_2', 2, 2, 2, 2, 'liquidation_file_2', 'revise_comment_2', 2, '2026-01-03', 'liquidation_addendum_files_2', '2026-01-03 08:00:00'),
    (3, 3, 'subcontract_status_3', 'consultant_pm_email_3', 'consultant_pm_name_3', 'consultant_md_email_3', 'consultant_md_name_3', 'consultant', 'sub_consultant_branch_3', 'sub_consultant_office_3', 3, 'sub_contract_code_3', 'sub_consultant_pm_email_3', 'sub_consultant_pm_name_3', 'sub_consultant_md_email_3', 'sub_consultant_md_name_3', 'con', 3, 'price_value_3', 'curre', 3, '2026-01-04', 'estimated_duration_3', 'others_fee', 'summary_3', 'inclusions_3', 'exclusions_3', 3, 'consultant_office_3', 3, 3, 3, 3, 'liquidation_file_3', 'revise_comment_3', 3, '2026-01-04', 'liquidation_addendum_files_3', '2026-01-04 08:00:00'),
    (4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', 4, '  ', '  ', '  ', '  ', '  ', '  ', 4, '  ', '  ', 4, '2026-01-05', '  ', '  ', '  ', '  ', '  ', 4, '  ', 4, 4, 4, 4, '  ', '  ', 4, '2026-01-05', '  ', '2026-01-05 08:00:00'),
    (5, 5, 'subcontract_status_5', 'consultant_pm_email_5', 'consultant_pm_name_5', 'consultant_md_email_5', 'consultant_md_name_5', 'consultant', 'sub_consultant_branch_5', 'sub_consultant_office_5', 5, 'sub_contract_code_5', 'sub_consultant_pm_email_5', 'sub_consultant_pm_name_5', 'sub_consultant_md_email_5', 'sub_consultant_md_name_5', 'con', 5, 'price_value_5', 'curre', 5, '2026-01-06', 'estimated_duration_5', 'others_fee', 'summary_5', 'inclusions_5', 'exclusions_5', 5, 'consultant_office_5', 5, 5, 5, 5, 'liquidation_file_5', 'revise_comment_5', 5, '2026-01-06', 'liquidation_addendum_files_5', '2026-01-06 08:00:00');
COMMIT;
