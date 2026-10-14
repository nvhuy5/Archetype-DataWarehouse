-- Sample rows for raw_intranet.crm_list_project_scope (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_project_scope" (
    "idps" integer,
    "id_main" integer,
    "description" varchar(255),
    "sub_description" varchar(255),
    "ds_pm" varchar(5)
);
TRUNCATE raw_intranet."crm_list_project_scope";
INSERT INTO raw_intranet."crm_list_project_scope" ("idps", "id_main", "description", "sub_description", "ds_pm") VALUES
    (1, 1, 'description_1', 'sub_description_1', 'ds_pm'),
    (2, 2, 'description_2', 'sub_description_2', 'ds_pm'),
    (3, 3, 'description_3', 'sub_description_3', 'ds_pm'),
    (4, 4, '  ', '  ', '  '),
    (5, 5, 'description_5', 'sub_description_5', 'ds_pm');
COMMIT;
