-- Sample rows for raw_intranet.strategic_objective (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
DROP TABLE IF EXISTS raw_intranet."strategic_objective";
CREATE TABLE raw_intranet."strategic_objective" (
    "strategic_objective_id" integer,
    "theme" varchar(50),
    "objective" varchar(200),
    "sponsor_name" varchar(100),
    "sponsor_email" varchar(100),
    "leader_name" varchar(100),
    "leader_email" varchar(100),
    "year" varchar(4)
);
INSERT INTO raw_intranet."strategic_objective" ("strategic_objective_id", "theme", "objective", "sponsor_name", "sponsor_email", "leader_name", "leader_email", "year") VALUES
    (1, 'theme_1', 'objective_1', 'sponsor_name_1', 'sponsor_email_1', 'leader_name_1', 'leader_email_1', 'year'),
    (2, 'theme_2', 'objective_2', 'sponsor_name_2', 'sponsor_email_2', 'leader_name_2', 'leader_email_2', 'year'),
    (3, 'theme_3', 'objective_3', 'sponsor_name_3', 'sponsor_email_3', 'leader_name_3', 'leader_email_3', 'year'),
    (4, '  ', '  ', '  ', '  ', '  ', '  ', '  '),
    (5, 'theme_5', 'objective_5', 'sponsor_name_5', 'sponsor_email_5', 'leader_name_5', 'leader_email_5', 'year');
COMMIT;
