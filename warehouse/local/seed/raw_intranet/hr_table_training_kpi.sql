-- Sample rows for raw_intranet.hr_table_training_kpi (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_training_kpi";
CREATE TABLE raw_intranet."hr_table_training_kpi" (
    "idhr_table_training_kpi" bigint,
    "office_id" varchar(5),
    "dept_id" varchar(5),
    "emp_code" varchar(15),
    "internal" varchar(15),
    "external" varchar(15),
    "technical" varchar(15),
    "non_technical" varchar(15),
    "total_hours_person" varchar(45),
    "trainers_facilitators" varchar(45),
    "month" varchar(45),
    "position" varchar(255),
    "course_name" varchar(255),
    "tfrom" varchar(45),
    "tto" varchar(45),
    "ctfrom" varchar(45),
    "ctto" varchar(45),
    "update_by" varchar(255),
    "total_hours_course" varchar(45),
    "total_fee_course" varchar(45)
);
INSERT INTO raw_intranet."hr_table_training_kpi" ("idhr_table_training_kpi", "office_id", "dept_id", "emp_code", "internal", "external", "technical", "non_technical", "total_hours_person", "trainers_facilitators", "month", "position", "course_name", "tfrom", "tto", "ctfrom", "ctto", "update_by", "total_hours_course", "total_fee_course") VALUES
    (1, 'offic', 'dept_', 'emp_code_1', 'internal_1', 'external_1', 'technical_1', 'non_technical_1', 'total_hours_person_1', 'trainers_facilitators_1', 'month_1', 'position_1', 'course_name_1', 'tfrom_1', 'tto_1', 'ctfrom_1', 'ctto_1', 'update_by_1', 'total_hours_course_1', 'total_fee_course_1'),
    (2, 'offic', 'dept_', 'emp_code_2', 'internal_2', 'external_2', 'technical_2', 'non_technical_2', 'total_hours_person_2', 'trainers_facilitators_2', 'month_2', 'position_2', 'course_name_2', 'tfrom_2', 'tto_2', 'ctfrom_2', 'ctto_2', 'update_by_2', 'total_hours_course_2', 'total_fee_course_2'),
    (3, 'offic', 'dept_', 'emp_code_3', 'internal_3', 'external_3', 'technical_3', 'non_technical_3', 'total_hours_person_3', 'trainers_facilitators_3', 'month_3', 'position_3', 'course_name_3', 'tfrom_3', 'tto_3', 'ctfrom_3', 'ctto_3', 'update_by_3', 'total_hours_course_3', 'total_fee_course_3'),
    (4, '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '),
    (5, 'offic', 'dept_', 'emp_code_5', 'internal_5', 'external_5', 'technical_5', 'non_technical_5', 'total_hours_person_5', 'trainers_facilitators_5', 'month_5', 'position_5', 'course_name_5', 'tfrom_5', 'tto_5', 'ctfrom_5', 'ctto_5', 'update_by_5', 'total_hours_course_5', 'total_fee_course_5');
COMMIT;
