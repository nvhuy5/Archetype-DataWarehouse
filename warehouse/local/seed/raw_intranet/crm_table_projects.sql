-- Sample rows for raw_intranet.crm_table_projects (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."crm_table_projects";
CREATE TABLE raw_intranet."crm_table_projects" (
    "idproj" integer,
    "author" varchar(255),
    "new_author" varchar(200),
    "pname" varchar(255),
    "pstatus" varchar(50),
    "ptype" integer,
    "share_users" varchar(255),
    "plocation" varchar(255),
    "pcountry" varchar(255),
    "pdesc" text,
    "gfa" varchar(200),
    "psdate" date,
    "pduration" varchar(200),
    "capex" varchar(255),
    "prepresentative" varchar(255),
    "new_prepresentative" varchar(255),
    "project_initiator" varchar(200),
    "quote_ref" varchar(100),
    "quote_date" date,
    "quote_fees" integer,
    "quote_fees_currency" varchar(200),
    "quote_fees_comments" varchar(255),
    "nb_storey" varchar(100),
    "nb_star" varchar(100),
    "nb_key" varchar(100),
    "id_office" integer,
    "id_fu_office" integer,
    "category_office" bigint,
    "crm_market_id" integer,
    "crm_segment_id" integer,
    "crm_sub_segment_id" integer,
    "pfee" varchar(100),
    "repquotation" varchar(255),
    "cdate" date,
    "pcode" varchar(50)
);
INSERT INTO raw_intranet."crm_table_projects" ("idproj", "author", "new_author", "pname", "pstatus", "ptype", "share_users", "plocation", "pcountry", "pdesc", "gfa", "psdate", "pduration", "capex", "prepresentative", "new_prepresentative", "project_initiator", "quote_ref", "quote_date", "quote_fees", "quote_fees_currency", "quote_fees_comments", "nb_storey", "nb_star", "nb_key", "id_office", "id_fu_office", "category_office", "crm_market_id", "crm_segment_id", "crm_sub_segment_id", "pfee", "repquotation", "cdate", "pcode") VALUES
    (1, 'author_1', 'new_author_1', 'pname_1', 'pstatus_1', 1, 'share_users_1', 'plocation_1', 'pcountry_1', 'pdesc_1', 'gfa_1', '2026-01-02', 'pduration_1', 'capex_1', 'prepresentative_1', 'new_prepresentative_1', 'project_initiator_1', 'quote_ref_1', '2026-01-02', 1, 'quote_fees_currency_1', 'quote_fees_comments_1', 'nb_storey_1', 'nb_star_1', 'nb_key_1', 1, 1, 1, 1, 1, 1, 'pfee_1', 'repquotation_1', '2026-01-02', 'pcode_1'),
    (2, 'author_2', 'new_author_2', 'pname_2', 'pstatus_2', 2, 'share_users_2', 'plocation_2', 'pcountry_2', 'pdesc_2', 'gfa_2', '2026-01-03', 'pduration_2', 'capex_2', 'prepresentative_2', 'new_prepresentative_2', 'project_initiator_2', 'quote_ref_2', '2026-01-03', 2, 'quote_fees_currency_2', 'quote_fees_comments_2', 'nb_storey_2', 'nb_star_2', 'nb_key_2', 2, 2, 2, 2, 2, 2, 'pfee_2', 'repquotation_2', '2026-01-03', 'pcode_2'),
    (3, 'author_3', 'new_author_3', 'pname_3', 'pstatus_3', 3, 'share_users_3', 'plocation_3', 'pcountry_3', 'pdesc_3', 'gfa_3', '2026-01-04', 'pduration_3', 'capex_3', 'prepresentative_3', 'new_prepresentative_3', 'project_initiator_3', 'quote_ref_3', '2026-01-04', 3, 'quote_fees_currency_3', 'quote_fees_comments_3', 'nb_storey_3', 'nb_star_3', 'nb_key_3', 3, 3, 3, 3, 3, 3, 'pfee_3', 'repquotation_3', '2026-01-04', 'pcode_3'),
    (4, '  ', '  ', '  ', '  ', 4, '  ', '  ', '  ', '  ', '  ', '2026-01-05', '  ', '  ', '  ', '  ', '  ', '  ', '2026-01-05', 4, '  ', '  ', '  ', '  ', '  ', 4, 4, 4, 4, 4, 4, '  ', '  ', '2026-01-05', '  '),
    (5, 'author_5', 'new_author_5', 'pname_5', 'pstatus_5', 5, 'share_users_5', 'plocation_5', 'pcountry_5', 'pdesc_5', 'gfa_5', '2026-01-06', 'pduration_5', 'capex_5', 'prepresentative_5', 'new_prepresentative_5', 'project_initiator_5', 'quote_ref_5', '2026-01-06', 5, 'quote_fees_currency_5', 'quote_fees_comments_5', 'nb_storey_5', 'nb_star_5', 'nb_key_5', 5, 5, 5, 5, 5, 5, 'pfee_5', 'repquotation_5', '2026-01-06', 'pcode_5');
COMMIT;
