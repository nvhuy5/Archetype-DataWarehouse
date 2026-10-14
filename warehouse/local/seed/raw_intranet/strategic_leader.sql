-- Sample rows for raw_intranet.strategic_leader (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."strategic_leader" (
    "strategic_leader_id" integer,
    "strategic_goal_id" integer,
    "leader_name" varchar(150),
    "leader_email" varchar(150),
    "type" smallint,
    "added_by" varchar(200),
    "added_time" timestamp
);
TRUNCATE raw_intranet."strategic_leader";
INSERT INTO raw_intranet."strategic_leader" ("strategic_leader_id", "strategic_goal_id", "leader_name", "leader_email", "type", "added_by", "added_time") VALUES
    (1, 1, 'leader_name_1', 'leader_email_1', 1, 'added_by_1', '2026-01-02 08:00:00'),
    (2, 2, 'leader_name_2', 'leader_email_2', 2, 'added_by_2', '2026-01-03 08:00:00'),
    (3, 3, 'leader_name_3', 'leader_email_3', 3, 'added_by_3', '2026-01-04 08:00:00'),
    (4, 4, '  ', '  ', 4, '  ', '2026-01-05 08:00:00'),
    (5, 5, 'leader_name_5', 'leader_email_5', 5, 'added_by_5', '2026-01-06 08:00:00');
COMMIT;
