-- Sample rows for raw_intranet.hr_table_leave (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_leave";
CREATE TABLE raw_intranet."hr_table_leave" (
    "idh" integer,
    "id_e" integer,
    "type" varchar(20),
    "last_balance" numeric(6,2),
    "balance" numeric(6,2),
    "last_month_added" date
);
INSERT INTO raw_intranet."hr_table_leave" ("idh", "id_e", "type", "last_balance", "balance", "last_month_added") VALUES
    (1, 1, 'type_1', 1, 1, '2026-01-02'),
    (2, 2, 'type_2', 2, 2, '2026-01-03'),
    (3, 3, 'type_3', 3, 3, '2026-01-04'),
    (4, 4, '  ', 4, 4, '2026-01-05'),
    (5, 5, 'type_5', 5, 5, '2026-01-06');
COMMIT;
