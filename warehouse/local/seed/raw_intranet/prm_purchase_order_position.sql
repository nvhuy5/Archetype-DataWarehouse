-- Sample rows for raw_intranet.prm_purchase_order_position (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."prm_purchase_order_position" (
    "prm_purchase_order_position_id" integer,
    "name" varchar(40),
    "position" varchar(40),
    "email" varchar(300),
    "country_code" varchar(30),
    "office_code" varchar(20),
    "head_dept_id" integer
);
TRUNCATE raw_intranet."prm_purchase_order_position";
INSERT INTO raw_intranet."prm_purchase_order_position" ("prm_purchase_order_position_id", "name", "position", "email", "country_code", "office_code", "head_dept_id") VALUES
    (1, 'name_1', 'position_1', 'email_1', 'country_code_1', 'office_code_1', 1),
    (2, 'name_2', 'position_2', 'email_2', 'country_code_2', 'office_code_2', 2),
    (3, 'name_3', 'position_3', 'email_3', 'country_code_3', 'office_code_3', 3),
    (4, '  ', '  ', '  ', '  ', '  ', 4),
    (5, 'name_5', 'position_5', 'email_5', 'country_code_5', 'office_code_5', 5);
COMMIT;
