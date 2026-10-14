-- Sample rows for raw_intranet.hr_table_office_tracking (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_office_tracking";
CREATE TABLE raw_intranet."hr_table_office_tracking" (
    "id_e" integer,
    "office_id_from" integer,
    "office_id_to" integer,
    "updated_date" timestamp,
    "updated_user" integer,
    "type" smallint
);
INSERT INTO raw_intranet."hr_table_office_tracking" ("id_e", "office_id_from", "office_id_to", "updated_date", "updated_user", "type") VALUES
    (1, 1, 1, '2026-01-02 08:00:00', 1, 1),
    (2, 2, 2, '2026-01-03 08:00:00', 2, 2),
    (3, 3, 3, '2026-01-04 08:00:00', 3, 3),
    (4, 4, 4, '2026-01-05 08:00:00', 4, 4),
    (5, 5, 5, '2026-01-06 08:00:00', 5, 5);
COMMIT;
