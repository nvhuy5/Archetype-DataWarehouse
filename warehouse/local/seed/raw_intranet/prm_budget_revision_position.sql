-- Sample rows for raw_intranet.prm_budget_revision_position (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
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
TRUNCATE raw_intranet."prm_budget_revision_position";
INSERT INTO raw_intranet."prm_budget_revision_position" ("prm_budget_revision_position_id", "employee_level_id", "type", "cch", "original_cch", "employee_level_title", "rev_id", "phase_id", "dept_id", "initial_budget_amount", "initial_budget_hour", "ctd_amount", "ctd_hour", "ctc_amount", "ctc_hour", "contract_revenue", "percentage_of_revenue_contract", "nav_cost", "nav_hour", "ts_cost", "ts_hour", "added_by", "added_at", "is_inter_office") VALUES
    (1, 1, 'type_1', 1, 1, 'employee_level_title_1', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 'added_by_1', '2026-01-02 08:00:00', 1),
    (2, 2, 'type_2', 2, 2, 'employee_level_title_2', 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 'added_by_2', '2026-01-03 08:00:00', 2),
    (3, 3, 'type_3', 3, 3, 'employee_level_title_3', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 'added_by_3', '2026-01-04 08:00:00', 3),
    (4, 4, '  ', 4, 4, '  ', 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, '  ', '2026-01-05 08:00:00', 4),
    (5, 5, 'type_5', 5, 5, 'employee_level_title_5', 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 'added_by_5', '2026-01-06 08:00:00', 5);
COMMIT;
