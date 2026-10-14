-- Sample rows for raw_intranet.timesheet_phase_2015 (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
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
TRUNCATE raw_intranet."timesheet_phase_2015";
INSERT INTO raw_intranet."timesheet_phase_2015" ("phase_id", "name", "description", "phase_code", "navision_no", "navision_code", "type", "budget_phase", "for_order", "planning_color", "refer_id", "dept_id") VALUES
    (1, 'Design', 'description_1', 'phas', 'navision_n', 'navis', 'project', 1, 1, 'planning_color_', 1, 1),
    (2, 'Annual leave', 'description_2', 'phas', 'navision_n', 'navis', 'vacation', 2, 2, 'planning_color_', 2, 2),
    (3, 'Meeting', 'description_3', 'phas', 'navision_n', 'navis', 'support', 3, 3, 'planning_color_', 3, 3),
    (4, 'Detail', '  ', '  ', '  ', '  ', 'support_detail', 4, 4, '  ', 4, 4),
    (5, 'Construction', 'description_5', 'phas', 'navision_n', 'navis', 'project', 5, 5, 'planning_color_', 5, 5);
COMMIT;
