-- Sample rows for raw_intranet.crm_link_project_client (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_link_project_client";
CREATE TABLE raw_intranet."crm_link_project_client" (
    "idc" integer,
    "idp" integer,
    "comment" varchar(255)
);
INSERT INTO raw_intranet."crm_link_project_client" ("idc", "idp", "comment") VALUES
    (1, 1, 'comment_1'),
    (2, 2, 'comment_2'),
    (3, 3, 'comment_3'),
    (4, 4, '  '),
    (5, 5, 'comment_5');
COMMIT;
