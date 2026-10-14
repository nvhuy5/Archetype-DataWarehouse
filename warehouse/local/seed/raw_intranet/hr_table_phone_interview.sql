-- Sample rows for raw_intranet.hr_table_phone_interview (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_phone_interview";
CREATE TABLE raw_intranet."hr_table_phone_interview" (
    "hr_table_phone_interview_id" integer,
    "idm" varchar(50),
    "birthday" date,
    "nationality" varchar(200),
    "family_status" varchar(200),
    "education" varchar(500),
    "current_location" varchar(200),
    "current_position_detail" text,
    "technical_specialty" text,
    "reason_leaving" varchar(200),
    "personality" varchar(100),
    "current_salary" varchar(200),
    "expectations" varchar(200),
    "availabilities" varchar(200),
    "recommend" varchar(30),
    "interview_date" date,
    "interviewer" varchar(100),
    "precommend" varchar(45),
    "frecommend" varchar(45),
    "pnote" varchar(45),
    "fnote" varchar(45),
    "vacant_position" varchar(55),
    "family_childs" varchar(55)
);
INSERT INTO raw_intranet."hr_table_phone_interview" ("hr_table_phone_interview_id", "idm", "birthday", "nationality", "family_status", "education", "current_location", "current_position_detail", "technical_specialty", "reason_leaving", "personality", "current_salary", "expectations", "availabilities", "recommend", "interview_date", "interviewer", "precommend", "frecommend", "pnote", "fnote", "vacant_position", "family_childs") VALUES
    (1, 'md5_1', '2026-01-02', 'nationality_1', 'family_status_1', 'education_1', 'current_location_1', 'current_position_detail_1', 'technical_specialty_1', 'reason_leaving_1', 'personality_1', 'current_salary_1', 'expectations_1', 'availabilities_1', 'recommend_1', '2026-01-02', 'interviewer_1', 'precommend_1', 'frecommend_1', 'pnote_1', 'fnote_1', 'vacant_position_1', 'family_childs_1'),
    (2, 'md5_2', '2026-01-03', 'nationality_2', 'family_status_2', 'education_2', 'current_location_2', 'current_position_detail_2', 'technical_specialty_2', 'reason_leaving_2', 'personality_2', 'current_salary_2', 'expectations_2', 'availabilities_2', 'recommend_2', '2026-01-03', 'interviewer_2', 'precommend_2', 'frecommend_2', 'pnote_2', 'fnote_2', 'vacant_position_2', 'family_childs_2'),
    (3, 'md5_3', '2026-01-04', 'nationality_3', 'family_status_3', 'education_3', 'current_location_3', 'current_position_detail_3', 'technical_specialty_3', 'reason_leaving_3', 'personality_3', 'current_salary_3', 'expectations_3', 'availabilities_3', 'recommend_3', '2026-01-04', 'interviewer_3', 'precommend_3', 'frecommend_3', 'pnote_3', 'fnote_3', 'vacant_position_3', 'family_childs_3'),
    (4, 'md5_4', '2026-01-05', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '2026-01-05', '  ', '  ', '  ', '  ', '  ', '  ', '  '),
    (5, 'md5_5', '2026-01-06', 'nationality_5', 'family_status_5', 'education_5', 'current_location_5', 'current_position_detail_5', 'technical_specialty_5', 'reason_leaving_5', 'personality_5', 'current_salary_5', 'expectations_5', 'availabilities_5', 'recommend_5', '2026-01-06', 'interviewer_5', 'precommend_5', 'frecommend_5', 'pnote_5', 'fnote_5', 'vacant_position_5', 'family_childs_5');
COMMIT;
