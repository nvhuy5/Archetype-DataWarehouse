-- Sample rows for raw_intranet.strategic_member_of_task (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."strategic_member_of_task";
CREATE TABLE raw_intranet."strategic_member_of_task" (
    "strategic_member_of_task_id" integer,
    "strategic_task_id" integer,
    "email" varchar(250),
    "added_by" varchar(250),
    "added_time" timestamp
);
INSERT INTO raw_intranet."strategic_member_of_task" ("strategic_member_of_task_id", "strategic_task_id", "email", "added_by", "added_time") VALUES
    (1, 1, 'email_1', 'added_by_1', '2026-01-02 08:00:00'),
    (2, 2, 'email_2', 'added_by_2', '2026-01-03 08:00:00'),
    (3, 3, 'email_3', 'added_by_3', '2026-01-04 08:00:00'),
    (4, 4, '  ', '  ', '2026-01-05 08:00:00'),
    (5, 5, 'email_5', 'added_by_5', '2026-01-06 08:00:00');
COMMIT;
