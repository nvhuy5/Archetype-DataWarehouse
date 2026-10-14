-- Sample rows for raw_intranet.hr_table_tech_interview (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_table_tech_interview" (
    "idtech" integer,
    "id_e" integer,
    "tadate" timestamp,
    "tdatej" timestamp,
    "tinterviewer" varchar(255),
    "tevaluation" text,
    "tcomments" text,
    "tlocation" varchar(255),
    "organizer" varchar(100),
    "recommend" varchar(50),
    "vacant_position" varchar(200),
    "interviewer_position" varchar(200),
    "trequirements" varchar(255),
    "tfactors" varchar(255),
    "texperience" varchar(500),
    "tqualifications" varchar(500),
    "tdemonstation" varchar(500),
    "tweaknesses" varchar(500),
    "tstrength" varchar(500),
    "tpersonality" varchar(500),
    "precommend" varchar(5),
    "frecommend" varchar(5),
    "fnote" varchar(255),
    "pnote" varchar(255),
    "tenglish" varchar(255),
    "tlevel" varchar(255),
    "taddinfo" varchar(255),
    "office" varchar(55)
);
TRUNCATE raw_intranet."hr_table_tech_interview";
INSERT INTO raw_intranet."hr_table_tech_interview" ("idtech", "id_e", "tadate", "tdatej", "tinterviewer", "tevaluation", "tcomments", "tlocation", "organizer", "recommend", "vacant_position", "interviewer_position", "trequirements", "tfactors", "texperience", "tqualifications", "tdemonstation", "tweaknesses", "tstrength", "tpersonality", "precommend", "frecommend", "fnote", "pnote", "tenglish", "tlevel", "taddinfo", "office") VALUES
    (1, 1, '2026-01-02 08:00:00', '2026-01-02 08:00:00', 'tinterviewer_1', 'tevaluation_1', 'tcomments_1', 'tlocation_1', 'organizer_1', 'recommend_1', 'vacant_position_1', 'interviewer_position_1', 'trequirements_1', 'tfactors_1', 'texperience_1', 'tqualifications_1', 'tdemonstation_1', 'tweaknesses_1', 'tstrength_1', 'tpersonality_1', 'preco', 'freco', 'fnote_1', 'pnote_1', 'tenglish_1', 'tlevel_1', 'taddinfo_1', 'office_1'),
    (2, 2, '2026-01-03 08:00:00', '2026-01-03 08:00:00', 'tinterviewer_2', 'tevaluation_2', 'tcomments_2', 'tlocation_2', 'organizer_2', 'recommend_2', 'vacant_position_2', 'interviewer_position_2', 'trequirements_2', 'tfactors_2', 'texperience_2', 'tqualifications_2', 'tdemonstation_2', 'tweaknesses_2', 'tstrength_2', 'tpersonality_2', 'preco', 'freco', 'fnote_2', 'pnote_2', 'tenglish_2', 'tlevel_2', 'taddinfo_2', 'office_2'),
    (3, 3, '2026-01-04 08:00:00', '2026-01-04 08:00:00', 'tinterviewer_3', 'tevaluation_3', 'tcomments_3', 'tlocation_3', 'organizer_3', 'recommend_3', 'vacant_position_3', 'interviewer_position_3', 'trequirements_3', 'tfactors_3', 'texperience_3', 'tqualifications_3', 'tdemonstation_3', 'tweaknesses_3', 'tstrength_3', 'tpersonality_3', 'preco', 'freco', 'fnote_3', 'pnote_3', 'tenglish_3', 'tlevel_3', 'taddinfo_3', 'office_3'),
    (4, 4, '2026-01-05 08:00:00', '2026-01-05 08:00:00', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '),
    (5, 5, '2026-01-06 08:00:00', '2026-01-06 08:00:00', 'tinterviewer_5', 'tevaluation_5', 'tcomments_5', 'tlocation_5', 'organizer_5', 'recommend_5', 'vacant_position_5', 'interviewer_position_5', 'trequirements_5', 'tfactors_5', 'texperience_5', 'tqualifications_5', 'tdemonstation_5', 'tweaknesses_5', 'tstrength_5', 'tpersonality_5', 'preco', 'freco', 'fnote_5', 'pnote_5', 'tenglish_5', 'tlevel_5', 'taddinfo_5', 'office_5');
COMMIT;
