-- Sample rows for raw_intranet.timesheet_component_2015 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."timesheet_component_2015";
CREATE TABLE raw_intranet."timesheet_component_2015" (
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
INSERT INTO raw_intranet."timesheet_component_2015" ("timesheet_component_id", "contract_id", "component_name", "navision_code", "status", "department_check", "status_effect_date", "last_update", "change_status_date", "factor", "send_to_navision") VALUES
    (1, 1, 'component_name_1', 'navision_code_1', 'status_1', 1, '2026-01-02', '2026-01-02', '2026-01-02 08:00:00', 'facto', '2026-01-02'),
    (2, 2, 'component_name_2', 'navision_code_2', 'status_2', 2, '2026-01-03', '2026-01-03', '2026-01-03 08:00:00', 'facto', '2026-01-03'),
    (3, 3, 'component_name_3', 'navision_code_3', 'status_3', 3, '2026-01-04', '2026-01-04', '2026-01-04 08:00:00', 'facto', '2026-01-04'),
    (4, 4, '  ', '  ', '  ', 4, '2026-01-05', '2026-01-05', '2026-01-05 08:00:00', '  ', '2026-01-05'),
    (5, 5, 'component_name_5', 'navision_code_5', 'status_5', 5, '2026-01-06', '2026-01-06', '2026-01-06 08:00:00', 'facto', '2026-01-06');
COMMIT;
