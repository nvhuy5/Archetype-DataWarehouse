-- Sample rows for raw_intranet.crm_market (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_market" (
    "crm_market_id" integer,
    "title" varchar(200),
    "market_code" varchar(20)
);
TRUNCATE raw_intranet."crm_market";
INSERT INTO raw_intranet."crm_market" ("crm_market_id", "title", "market_code") VALUES
    (1, 'title_1', 'market_code_1'),
    (2, 'title_2', 'market_code_2'),
    (3, 'title_3', 'market_code_3'),
    (4, '  ', '  '),
    (5, 'title_5', 'market_code_5');
COMMIT;
