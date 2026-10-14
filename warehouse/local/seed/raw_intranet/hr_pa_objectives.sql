-- Sample rows for raw_intranet.hr_pa_objectives (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."hr_pa_objectives" (
    "objectives_id" integer,
    "ide" integer,
    "appraisal_type" smallint,
    "year" smallint,
    "objective" text,
    "goal" varchar(50),
    "success_factor" varchar(8000),
    "smart" text,
    "action_required" text,
    "weight" integer,
    "due_date" varchar(500),
    "result_achieved" varchar(8000),
    "self_evaluation" integer,
    "manager_evaluation" integer,
    "agreed_evaluation" integer,
    "result_evaluation" integer,
    "mid_year_done" text,
    "mid_year_not_done" text,
    "mid_year_need_support" text,
    "mid_year_problem" text,
    "manager_comment" varchar(2500),
    "manager_comment_after_meeting" varchar(2500),
    "mid_year_submit_status" smallint,
    "validated" smallint,
    "mid_year_status_updated_by" varchar(255)
);
TRUNCATE raw_intranet."hr_pa_objectives";
INSERT INTO raw_intranet."hr_pa_objectives" ("objectives_id", "ide", "appraisal_type", "year", "objective", "goal", "success_factor", "smart", "action_required", "weight", "due_date", "result_achieved", "self_evaluation", "manager_evaluation", "agreed_evaluation", "result_evaluation", "mid_year_done", "mid_year_not_done", "mid_year_need_support", "mid_year_problem", "manager_comment", "manager_comment_after_meeting", "mid_year_submit_status", "validated", "mid_year_status_updated_by") VALUES
    (1, 1, 1, 1, 'objective_1', 'goal_1', 'success_factor_1', 'smart_1', 'action_required_1', 1, 'due_date_1', 'result_achieved_1', 1, 1, 1, 1, 'mid_year_done_1', 'mid_year_not_done_1', 'mid_year_need_support_1', 'mid_year_problem_1', 'manager_comment_1', 'manager_comment_after_meeting_1', 1, 1, 'mid_year_status_updated_by_1'),
    (2, 2, 2, 2, 'objective_2', 'goal_2', 'success_factor_2', 'smart_2', 'action_required_2', 2, 'due_date_2', 'result_achieved_2', 2, 2, 2, 2, 'mid_year_done_2', 'mid_year_not_done_2', 'mid_year_need_support_2', 'mid_year_problem_2', 'manager_comment_2', 'manager_comment_after_meeting_2', 2, 2, 'mid_year_status_updated_by_2'),
    (3, 3, 3, 3, 'objective_3', 'goal_3', 'success_factor_3', 'smart_3', 'action_required_3', 3, 'due_date_3', 'result_achieved_3', 3, 3, 3, 3, 'mid_year_done_3', 'mid_year_not_done_3', 'mid_year_need_support_3', 'mid_year_problem_3', 'manager_comment_3', 'manager_comment_after_meeting_3', 3, 3, 'mid_year_status_updated_by_3'),
    (4, 4, 4, 4, '  ', '  ', '  ', '  ', '  ', 4, '  ', '  ', 4, 4, 4, 4, '  ', '  ', '  ', '  ', '  ', '  ', 4, 4, '  '),
    (5, 5, 5, 5, 'objective_5', 'goal_5', 'success_factor_5', 'smart_5', 'action_required_5', 5, 'due_date_5', 'result_achieved_5', 5, 5, 5, 5, 'mid_year_done_5', 'mid_year_not_done_5', 'mid_year_need_support_5', 'mid_year_problem_5', 'manager_comment_5', 'manager_comment_after_meeting_5', 5, 5, 'mid_year_status_updated_by_5');
COMMIT;
