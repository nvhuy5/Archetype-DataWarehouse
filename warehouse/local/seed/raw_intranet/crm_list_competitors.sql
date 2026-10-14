-- Sample rows for raw_intranet.crm_list_competitors (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_list_competitors";
CREATE TABLE raw_intranet."crm_list_competitors" (
    "crm_list_competitors_id" integer,
    "name" varchar(250)
);
INSERT INTO raw_intranet."crm_list_competitors" ("crm_list_competitors_id", "name") VALUES
    (1, 'name_1'),
    (2, 'name_2'),
    (3, 'name_3'),
    (4, '  '),
    (5, 'name_5');
COMMIT;
