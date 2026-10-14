-- Sample rows for raw_intranet.crm_segment (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_segment";
CREATE TABLE raw_intranet."crm_segment" (
    "crm_segment_id" integer,
    "crm_market_id" integer,
    "title" varchar(200),
    "segment_code" varchar(20)
);
INSERT INTO raw_intranet."crm_segment" ("crm_segment_id", "crm_market_id", "title", "segment_code") VALUES
    (1, 1, 'title_1', 'segment_code_1'),
    (2, 2, 'title_2', 'segment_code_2'),
    (3, 3, 'title_3', 'segment_code_3'),
    (4, 4, '  ', '  '),
    (5, 5, 'title_5', 'segment_code_5');
COMMIT;
