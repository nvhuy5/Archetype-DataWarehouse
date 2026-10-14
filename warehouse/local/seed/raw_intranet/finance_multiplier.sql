-- Sample rows for raw_intranet.finance_multiplier (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."finance_multiplier";
CREATE TABLE raw_intranet."finance_multiplier" (
    "id" integer,
    "country_id" integer,
    "year" varchar(10),
    "percent_of_other_cost" varchar(20),
    "external_client" varchar(20),
    "internal_client" varchar(20),
    "business_line" varchar(100),
    "overhead_rate" real
);
INSERT INTO raw_intranet."finance_multiplier" ("id", "country_id", "year", "percent_of_other_cost", "external_client", "internal_client", "business_line", "overhead_rate") VALUES
    (1, 1, 'year_1', 'percent_of_other_cos', 'external_client_1', 'internal_client_1', 'business_line_1', 1),
    (2, 2, 'year_2', 'percent_of_other_cos', 'external_client_2', 'internal_client_2', 'business_line_2', 2),
    (3, 3, 'year_3', 'percent_of_other_cos', 'external_client_3', 'internal_client_3', 'business_line_3', 3),
    (4, 4, '  ', '  ', '  ', '  ', '  ', 4),
    (5, 5, 'year_5', 'percent_of_other_cos', 'external_client_5', 'internal_client_5', 'business_line_5', 5);
COMMIT;
