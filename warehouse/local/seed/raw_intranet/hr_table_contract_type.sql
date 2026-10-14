-- Sample rows for raw_intranet.hr_table_contract_type (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_contract_type";
CREATE TABLE raw_intranet."hr_table_contract_type" (
    "id_contract_type" integer,
    "name" varchar(250),
    "hide" varchar(1)
);
INSERT INTO raw_intranet."hr_table_contract_type" ("id_contract_type", "name", "hide") VALUES
    (1, 'name_1', 'h'),
    (2, 'name_2', 'h'),
    (3, 'name_3', 'h'),
    (4, '  ', '  '),
    (5, 'name_5', 'h');
COMMIT;
