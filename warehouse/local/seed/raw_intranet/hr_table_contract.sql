-- Sample rows for raw_intranet.hr_table_contract (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_contract";
CREATE TABLE raw_intranet."hr_table_contract" (
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
INSERT INTO raw_intranet."hr_table_contract" ("idcont", "id_e", "cfrom", "cto", "job_title_id", "cposition", "ccontract", "ctype", "tdate", "lock", "idcontracttype", "probation_end_date", "archived", "probation_appraisal_data", "appraisal_data", "appraisal_submited", "appraisal_comments", "contract_appraisal_comments", "contract_appraisal_submited", "end_contract_comment", "added_user", "added_time", "last_updated_user", "last_updated_time", "exit_interviewed", "manager_level", "market", "payment", "exit_interview_date", "hr_menu_grade_id") VALUES
    (1, 1, '2025-01-01', '2027-12-31', 1, 'cposition_1', 'ccontract_1', 'c', NULL, 'l', 1, NULL, 1, 'probation_appraisal_data_1', 'appraisal_data_1', 1, 'appraisal_comments_1', 'contract_appraisal_comments_1', 1, 'end_contract_comment_1', 1, '2026-01-02 08:00:00', 1, '2026-01-02 08:00:00', 'exit_interviewed_1', 'm', 'market_1', 'p', '2026-01-02', 1),
    (2, 2, '2025-01-01', '2027-12-31', 2, 'cposition_2', 'ccontract_2', 'c', NULL, 'l', 2, NULL, 2, 'probation_appraisal_data_2', 'appraisal_data_2', 2, 'appraisal_comments_2', 'contract_appraisal_comments_2', 2, 'end_contract_comment_2', 2, '2026-01-03 08:00:00', 2, '2026-01-03 08:00:00', 'exit_interviewed_2', 'm', 'market_2', 'p', '2026-01-03', 2),
    (3, 3, '2025-01-01', '2027-12-31', 3, 'cposition_3', 'ccontract_3', 'c', NULL, 'l', 3, NULL, 3, 'probation_appraisal_data_3', 'appraisal_data_3', 3, 'appraisal_comments_3', 'contract_appraisal_comments_3', 3, 'end_contract_comment_3', 3, '2026-01-04 08:00:00', 3, '2026-01-04 08:00:00', 'exit_interviewed_3', 'm', 'market_3', 'p', '2026-01-04', 3),
    (4, 4, '2025-01-01', '2027-12-31', 4, '  ', '  ', '  ', NULL, '  ', 4, '2025-06-30', 4, '  ', '  ', 4, '  ', '  ', 4, '  ', 4, '2026-01-05 08:00:00', 4, '2026-01-05 08:00:00', '  ', '  ', '  ', '  ', '2026-01-05', 4),
    (5, 5, '2025-01-01', '2027-12-31', 5, 'cposition_5', 'ccontract_5', 'c', '2026-06-30', 'l', 5, '2025-06-30', 5, 'probation_appraisal_data_5', 'appraisal_data_5', 5, 'appraisal_comments_5', 'contract_appraisal_comments_5', 5, 'end_contract_comment_5', 5, '2026-01-06 08:00:00', 5, '2026-01-06 08:00:00', 'exit_interviewed_5', 'm', 'market_5', 'p', '2026-01-06', 5);
COMMIT;
