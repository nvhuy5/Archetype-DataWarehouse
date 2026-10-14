-- Sample rows for raw_intranet.crm_link_project_scope (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_link_project_scope";
CREATE TABLE raw_intranet."crm_link_project_scope" (
    "idp" integer,
    "idps" integer,
    "fee" bigint
);
INSERT INTO raw_intranet."crm_link_project_scope" ("idp", "idps", "fee") VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5);
COMMIT;
