-- Sample rows for raw_intranet.crm_sub_segment (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_sub_segment";
CREATE TABLE raw_intranet."crm_sub_segment" (
    "crm_sub_segment_id" integer,
    "crm_segment_id" integer,
    "title" varchar(200),
    "sector_code" varchar(20)
);
INSERT INTO raw_intranet."crm_sub_segment" ("crm_sub_segment_id", "crm_segment_id", "title", "sector_code") VALUES
    (1, 1, 'title_1', 'sector_code_1'),
    (2, 2, 'title_2', 'sector_code_2'),
    (3, 3, 'title_3', 'sector_code_3'),
    (4, 4, '  ', '  '),
    (5, 5, 'title_5', 'sector_code_5');
COMMIT;
