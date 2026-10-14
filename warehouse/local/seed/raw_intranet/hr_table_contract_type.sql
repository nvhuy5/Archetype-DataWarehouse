-- Sample rows for raw_intranet.hr_table_contract_type (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_contract_type" (
    "id_contract_type" integer,
    "name" varchar(250),
    "hide" varchar(1)
);
TRUNCATE raw_intranet."hr_table_contract_type";
INSERT INTO raw_intranet."hr_table_contract_type" ("id_contract_type", "name", "hide") VALUES
    (1, 'name_1', 'h'),
    (2, 'name_2', 'h'),
    (3, 'name_3', 'h'),
    (4, '  ', '  '),
    (5, 'name_5', 'h');
COMMIT;
