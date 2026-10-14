-- Sample rows for raw_intranet.timesheet_contract_2015 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."timesheet_contract_2015";
CREATE TABLE raw_intranet."timesheet_contract_2015" (
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
INSERT INTO raw_intranet."timesheet_contract_2015" ("contract_id", "crm_contract_id", "code", "navision_code", "scope", "project_manager", "title", "timesheet_project_id", "contract_status", "status_effect_date", "change_status_date", "office_id", "added_user", "added_time", "last_updated_date", "last_update_user") VALUES
    (1, 1, 'code_1', 'navision_code_1', 'scope', 'project_manager_1', 'title_1', 1, 'contract_status', '2026-01-02', '2026-01-02 08:00:00', 1, 1, '2026-01-02 08:00:00', '2026-01-02 08:00:00', 'last_update_user_1'),
    (2, 2, 'code_2', 'navision_code_2', 'scope', 'project_manager_2', 'title_2', 2, 'contract_status', '2026-01-03', '2026-01-03 08:00:00', 2, 2, '2026-01-03 08:00:00', '2026-01-03 08:00:00', 'last_update_user_2'),
    (3, 3, 'code_3', 'navision_code_3', 'scope', 'project_manager_3', 'title_3', 3, 'contract_status', '2026-01-04', '2026-01-04 08:00:00', 3, 3, '2026-01-04 08:00:00', '2026-01-04 08:00:00', 'last_update_user_3'),
    (4, 4, '  ', '  ', '  ', '  ', '  ', 4, '  ', '2026-01-05', '2026-01-05 08:00:00', 4, 4, '2026-01-05 08:00:00', '2026-01-05 08:00:00', '  '),
    (5, 5, 'code_5', 'navision_code_5', 'scope', 'project_manager_5', 'title_5', 5, 'contract_status', '2026-01-06', '2026-01-06 08:00:00', 5, 5, '2026-01-06 08:00:00', '2026-01-06 08:00:00', 'last_update_user_5');
COMMIT;
