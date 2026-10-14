-- Sample rows for raw_intranet.crm_list_reason (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_list_reason";
CREATE TABLE raw_intranet."crm_list_reason" (
    "id" integer,
    "reason" varchar(255),
    "cat" integer
);
INSERT INTO raw_intranet."crm_list_reason" ("id", "reason", "cat") VALUES
    (1, 'reason_1', 1),
    (2, 'reason_2', 2),
    (3, 'reason_3', 3),
    (4, '  ', 4),
    (5, 'reason_5', 5);
COMMIT;
