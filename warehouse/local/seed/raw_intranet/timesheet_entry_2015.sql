-- Sample rows for raw_intranet.timesheet_entry_2015 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."timesheet_entry_2015";
CREATE TABLE raw_intranet."timesheet_entry_2015" (
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
INSERT INTO raw_intranet."timesheet_entry_2015" ("id", "date", "uid", "ide", "employee_code", "employee_office", "department_id", "jobtitle_id", "employee_level", "phase_id", "component_id", "contract_id", "proj_id", "time", "rate", "validated", "last_modified", "last_updated_user") VALUES
    (1, current_date - 1, 1, 1, 'employee_code_1', 'emplo', 1, 1, '1', 1, 1, 1, 1, 8, 1, 1, '2026-01-02 08:00:00', 'last_updated_user_1'),
    (2, current_date - 2, 2, 2, 'employee_code_2', 'emplo', 2, 2, '2', 2, 2, 2, 2, 8, 2, 2, '2026-01-03 08:00:00', 'last_updated_user_2'),
    (3, current_date - 3, 3, 3, 'employee_code_3', 'emplo', 3, 3, '3', 3, 3, 3, 3, 8, 3, 0, '2026-01-04 08:00:00', 'last_updated_user_3'),
    (4, current_date - 4, 4, 4, '  ', '  ', 4, 4, '4', 4, 4, 4, 4, 8, 4, 1, '2026-01-05 08:00:00', '  '),
    (5, current_date - 5, 5, 5, 'employee_code_5', 'emplo', 5, 5, '5', 5, 5, 5, 5, 8, 5, 2, '2026-01-06 08:00:00', 'last_updated_user_5');
COMMIT;
