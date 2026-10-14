-- Sample rows for raw_intranet.crm_main (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_main";
CREATE TABLE raw_intranet."crm_main" (
    "idc" integer,
    "code" varchar(255),
    "name" varchar(255),
    "mother_company_type" integer,
    "mother_company_info" text,
    "crm_company_industry_code_id" varchar(5),
    "crm_market_id" integer,
    "crm_segment_id" integer,
    "crm_sub_segment_id" integer,
    "green_roadmap_status" varchar(30),
    "status" text,
    "flag2" varchar(255),
    "new_flag2" varchar(200),
    "risk_ass" varchar(5),
    "risk_comment" text,
    "is_key" varchar(1),
    "representative" varchar(255),
    "last_modified" timestamp,
    "cdate" timestamp,
    "key_company" varchar(1),
    "asia_headquarter" varchar(400),
    "worldwide_headquarter" varchar(400),
    "nationality" integer,
    "crm_market" text,
    "crm_segment" text,
    "crm_sub_segment" text,
    "list_nationality" text,
    "opportunities" smallint,
    "comment" text,
    "tenantid" smallint,
    "mother_company_id" integer
);
INSERT INTO raw_intranet."crm_main" ("idc", "code", "name", "mother_company_type", "mother_company_info", "crm_company_industry_code_id", "crm_market_id", "crm_segment_id", "crm_sub_segment_id", "green_roadmap_status", "status", "flag2", "new_flag2", "risk_ass", "risk_comment", "is_key", "representative", "last_modified", "cdate", "key_company", "asia_headquarter", "worldwide_headquarter", "nationality", "crm_market", "crm_segment", "crm_sub_segment", "list_nationality", "opportunities", "comment", "tenantid", "mother_company_id") VALUES
    (1, 'code_1', 'name_1', 1, 'mother_company_info_1', 'crm_c', 1, 1, 1, 'green_roadmap_status_1', 'status_1', 'flag2_1', 'new_flag2_1', 'risk_', 'risk_comment_1', 'i', 'representative_1', '2026-01-02 08:00:00', '2026-01-02 08:00:00', 'k', 'asia_headquarter_1', 'worldwide_headquarter_1', 1, 'crm_market_1', 'crm_segment_1', 'crm_sub_segment_1', 'list_nationality_1', 1, 'comment_1', 1, 1),
    (2, 'code_2', 'name_2', 2, 'mother_company_info_2', 'crm_c', 2, 2, 2, 'green_roadmap_status_2', 'status_2', 'flag2_2', 'new_flag2_2', 'risk_', 'risk_comment_2', 'i', 'representative_2', '2026-01-03 08:00:00', '2026-01-03 08:00:00', 'k', 'asia_headquarter_2', 'worldwide_headquarter_2', 2, 'crm_market_2', 'crm_segment_2', 'crm_sub_segment_2', 'list_nationality_2', 2, 'comment_2', 2, 2),
    (3, 'code_3', 'name_3', 3, 'mother_company_info_3', 'crm_c', 3, 3, 3, 'green_roadmap_status_3', 'status_3', 'flag2_3', 'new_flag2_3', 'risk_', 'risk_comment_3', 'i', 'representative_3', '2026-01-04 08:00:00', '2026-01-04 08:00:00', 'k', 'asia_headquarter_3', 'worldwide_headquarter_3', 3, 'crm_market_3', 'crm_segment_3', 'crm_sub_segment_3', 'list_nationality_3', 3, 'comment_3', 3, 3),
    (4, '  ', '  ', 4, '  ', '  ', 4, 4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '2026-01-05 08:00:00', '2026-01-05 08:00:00', '  ', '  ', '  ', 4, '  ', '  ', '  ', '  ', 4, '  ', 4, 4),
    (5, 'code_5', 'name_5', 5, 'mother_company_info_5', 'crm_c', 5, 5, 5, 'green_roadmap_status_5', 'status_5', 'flag2_5', 'new_flag2_5', 'risk_', 'risk_comment_5', 'i', 'representative_5', '2026-01-06 08:00:00', '2026-01-06 08:00:00', 'k', 'asia_headquarter_5', 'worldwide_headquarter_5', 5, 'crm_market_5', 'crm_segment_5', 'crm_sub_segment_5', 'list_nationality_5', 5, 'comment_5', 5, 5);
COMMIT;
