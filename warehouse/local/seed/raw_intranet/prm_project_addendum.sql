-- Sample rows for raw_intranet.prm_project_addendum (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."prm_project_addendum";
CREATE TABLE raw_intranet."prm_project_addendum" (
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
INSERT INTO raw_intranet."prm_project_addendum" ("prm_project_addendum_id", "crm_project_id", "addendum_code", "scope", "ds_pm", "value", "name", "currency", "created_date", "created_by") VALUES
    (1, 1, 'addendum_code_1', 'scope_1', 'ds_pm_1', 'value_1', 'name_1', 'currency_1', '2026-01-02', 'created_by_1'),
    (2, 2, 'addendum_code_2', 'scope_2', 'ds_pm_2', 'value_2', 'name_2', 'currency_2', '2026-01-03', 'created_by_2'),
    (3, 3, 'addendum_code_3', 'scope_3', 'ds_pm_3', 'value_3', 'name_3', 'currency_3', '2026-01-04', 'created_by_3'),
    (4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '2026-01-05', '  '),
    (5, 5, 'addendum_code_5', 'scope_5', 'ds_pm_5', 'value_5', 'name_5', 'currency_5', '2026-01-06', 'created_by_5');
COMMIT;
