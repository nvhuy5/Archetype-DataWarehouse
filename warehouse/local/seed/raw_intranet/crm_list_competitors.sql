-- Sample rows for raw_intranet.crm_list_competitors (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_list_competitors" (
    "crm_list_competitors_id" integer,
    "name" varchar(250)
);
TRUNCATE raw_intranet."crm_list_competitors";
INSERT INTO raw_intranet."crm_list_competitors" ("crm_list_competitors_id", "name") VALUES
    (1, 'name_1'),
    (2, 'name_2'),
    (3, 'name_3'),
    (4, '  '),
    (5, 'name_5');
COMMIT;
