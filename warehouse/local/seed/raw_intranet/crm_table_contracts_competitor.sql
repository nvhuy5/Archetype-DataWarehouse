-- Sample rows for raw_intranet.crm_table_contracts_competitor (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_table_contracts_competitor" (
    "competitor_id" bigint,
    "name" varchar(255),
    "fee" bigint,
    "winner" smallint,
    "contract_id" integer,
    "cp_id" integer
);
TRUNCATE raw_intranet."crm_table_contracts_competitor";
INSERT INTO raw_intranet."crm_table_contracts_competitor" ("competitor_id", "name", "fee", "winner", "contract_id", "cp_id") VALUES
    (1, 'name_1', 1, 1, 1, 1),
    (2, 'name_2', 2, 2, 2, 2),
    (3, 'name_3', 3, 3, 3, 3),
    (4, '  ', 4, 4, 4, 4),
    (5, 'name_5', 5, 5, 5, 5);
COMMIT;
