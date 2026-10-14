-- Sample rows for raw_intranet.timesheet_project_2015 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
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
TRUNCATE raw_intranet."timesheet_project_2015";
INSERT INTO raw_intranet."timesheet_project_2015" ("timesheet_project_id", "project_name", "office", "project_type", "status", "status_effect_date", "project_manager", "last_update", "change_status_date") VALUES
    (1, 'project_name_1', 1, 'pr', 'status_1', '2026-01-02', 'project_manager_1', '2026-01-02 08:00:00', '2026-01-02 08:00:00'),
    (2, 'project_name_2', 2, 'pr', 'status_2', '2026-01-03', 'project_manager_2', '2026-01-03 08:00:00', '2026-01-03 08:00:00'),
    (3, 'project_name_3', 3, 'pr', 'status_3', '2026-01-04', 'project_manager_3', '2026-01-04 08:00:00', '2026-01-04 08:00:00'),
    (4, '  ', 4, '  ', '  ', '2026-01-05', '  ', '2026-01-05 08:00:00', '2026-01-05 08:00:00'),
    (5, 'project_name_5', 5, 'pr', 'status_5', '2026-01-06', 'project_manager_5', '2026-01-06 08:00:00', '2026-01-06 08:00:00');
COMMIT;
