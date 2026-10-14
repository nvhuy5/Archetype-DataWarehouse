-- Sample rows for raw_intranet.prm_organization_contact (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."prm_organization_contact";
CREATE TABLE raw_intranet."prm_organization_contact" (
    "prm_organization_contact_id" integer,
    "crm_project_id" integer,
    "prm_company_id" integer,
    "act_member" smallint,
    "name" varchar(100),
    "position" varchar(200),
    "phone" varchar(20),
    "email" varchar(100),
    "team_type" varchar(100),
    "added_user" varchar(100),
    "prm_rfi_category" varchar(255),
    "user_ide" integer
);
INSERT INTO raw_intranet."prm_organization_contact" ("prm_organization_contact_id", "crm_project_id", "prm_company_id", "act_member", "name", "position", "phone", "email", "team_type", "added_user", "prm_rfi_category", "user_ide") VALUES
    (1, 1, 1, 1, 'name_1', 'position_1', 'phone_1', 'email_1', 'team_type_1', 'added_user_1', 'prm_rfi_category_1', 1),
    (2, 2, 2, 2, 'name_2', 'position_2', 'phone_2', 'email_2', 'team_type_2', 'added_user_2', 'prm_rfi_category_2', 2),
    (3, 3, 3, 3, 'name_3', 'position_3', 'phone_3', 'email_3', 'team_type_3', 'added_user_3', 'prm_rfi_category_3', 3),
    (4, 4, 4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', 4),
    (5, 5, 5, 5, 'name_5', 'position_5', 'phone_5', 'email_5', 'team_type_5', 'added_user_5', 'prm_rfi_category_5', 5);
COMMIT;
