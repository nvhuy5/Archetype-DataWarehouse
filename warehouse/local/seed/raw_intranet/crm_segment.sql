-- Sample rows for raw_intranet.crm_segment (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_segment" (
    "crm_segment_id" integer,
    "crm_market_id" integer,
    "title" varchar(200),
    "segment_code" varchar(20)
);
TRUNCATE raw_intranet."crm_segment";
INSERT INTO raw_intranet."crm_segment" ("crm_segment_id", "crm_market_id", "title", "segment_code") VALUES
    (1, 1, 'title_1', 'segment_code_1'),
    (2, 2, 'title_2', 'segment_code_2'),
    (3, 3, 'title_3', 'segment_code_3'),
    (4, 4, '  ', '  '),
    (5, 5, 'title_5', 'segment_code_5');
COMMIT;
