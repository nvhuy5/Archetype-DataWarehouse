-- Sample rows for raw_intranet.strategic_goal (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."strategic_goal";
CREATE TABLE raw_intranet."strategic_goal" (
    "strategic_goal_id" integer,
    "strategic_objective_id" integer,
    "goal" varchar(500),
    "start_date" date,
    "deadline" date,
    "level" varchar(50),
    "status" varchar(20),
    "weight_goal" varchar(4),
    "year" varchar(4),
    "priority" varchar(1)
);
INSERT INTO raw_intranet."strategic_goal" ("strategic_goal_id", "strategic_objective_id", "goal", "start_date", "deadline", "level", "status", "weight_goal", "year", "priority") VALUES
    (1, 1, 'goal_1', '2026-01-02', '2026-01-02', 'level_1', 'status_1', 'weig', 'year', 'p'),
    (2, 2, 'goal_2', '2026-01-03', '2026-01-03', 'level_2', 'status_2', 'weig', 'year', 'p'),
    (3, 3, 'goal_3', '2026-01-04', '2026-01-04', 'level_3', 'status_3', 'weig', 'year', 'p'),
    (4, 4, '  ', '2026-01-05', '2026-01-05', '  ', '  ', '  ', '  ', '  '),
    (5, 5, 'goal_5', '2026-01-06', '2026-01-06', 'level_5', 'status_5', 'weig', 'year', 'p');
COMMIT;
