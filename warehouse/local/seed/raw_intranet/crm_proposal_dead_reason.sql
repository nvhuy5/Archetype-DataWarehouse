-- Sample rows for raw_intranet.crm_proposal_dead_reason (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_proposal_dead_reason" (
    "crm_proposal_dead_reason_id" integer,
    "proposal_id" integer,
    "competitor" integer,
    "award_price" varchar(255),
    "crm_list_reason_id" integer,
    "other_reason" text,
    "added_by" varchar(150)
);
TRUNCATE raw_intranet."crm_proposal_dead_reason";
INSERT INTO raw_intranet."crm_proposal_dead_reason" ("crm_proposal_dead_reason_id", "proposal_id", "competitor", "award_price", "crm_list_reason_id", "other_reason", "added_by") VALUES
    (1, 1, 1, 'award_price_1', 1, 'other_reason_1', 'added_by_1'),
    (2, 2, 2, 'award_price_2', 2, 'other_reason_2', 'added_by_2'),
    (3, 3, 3, 'award_price_3', 3, 'other_reason_3', 'added_by_3'),
    (4, 4, 4, '  ', 4, '  ', '  '),
    (5, 5, 5, 'award_price_5', 5, 'other_reason_5', 'added_by_5');
COMMIT;
