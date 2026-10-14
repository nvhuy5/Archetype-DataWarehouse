-- Sample rows for raw_intranet.strategic_task (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."strategic_task";
CREATE TABLE raw_intranet."strategic_task" (
    "strategic_task_id" integer,
    "strategic_goal_id" integer,
    "task_description" text,
    "resources" text,
    "comments" text,
    "deadline" date,
    "progress" varchar(5),
    "weight" varchar(3),
    "added_by" varchar(250),
    "added_time" timestamp
);
INSERT INTO raw_intranet."strategic_task" ("strategic_task_id", "strategic_goal_id", "task_description", "resources", "comments", "deadline", "progress", "weight", "added_by", "added_time") VALUES
    (1, 1, 'task_description_1', 'resources_1', 'comments_1', '2026-01-02', 'progr', 'wei', 'added_by_1', '2026-01-02 08:00:00'),
    (2, 2, 'task_description_2', 'resources_2', 'comments_2', '2026-01-03', 'progr', 'wei', 'added_by_2', '2026-01-03 08:00:00'),
    (3, 3, 'task_description_3', 'resources_3', 'comments_3', '2026-01-04', 'progr', 'wei', 'added_by_3', '2026-01-04 08:00:00'),
    (4, 4, '  ', '  ', '  ', '2026-01-05', '  ', '  ', '  ', '2026-01-05 08:00:00'),
    (5, 5, 'task_description_5', 'resources_5', 'comments_5', '2026-01-06', 'progr', 'wei', 'added_by_5', '2026-01-06 08:00:00');
COMMIT;
