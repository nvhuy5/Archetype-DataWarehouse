-- Sample rows for raw_intranet.hr_table_leave_approval (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."hr_table_leave_approval";
CREATE TABLE raw_intranet."hr_table_leave_approval" (
    "id" integer,
    "id_e" integer,
    "type" varchar(20),
    "balance" numeric(4,1),
    "from" date,
    "to" date,
    "approved" integer,
    "cuser" integer,
    "cdate" timestamp,
    "withdraw_history" text,
    "replace_by" integer,
    "force_send_to_managing_director" smallint,
    "managing_director_ide" integer
);
INSERT INTO raw_intranet."hr_table_leave_approval" ("id", "id_e", "type", "balance", "from", "to", "approved", "cuser", "cdate", "withdraw_history", "replace_by", "force_send_to_managing_director", "managing_director_ide") VALUES
    (1, 1, 'type_1', 1, '2026-01-02', '2026-01-02', 1, 1, '2026-01-02 08:00:00', 'withdraw_history_1', 1, 1, 1),
    (2, 2, 'type_2', 2, '2026-01-03', '2026-01-03', 2, 2, '2026-01-03 08:00:00', 'withdraw_history_2', 2, 2, 2),
    (3, 3, 'type_3', 3, '2026-01-04', '2026-01-04', 3, 3, '2026-01-04 08:00:00', 'withdraw_history_3', 3, 3, 3),
    (4, 4, '  ', 4, '2026-01-05', '2026-01-05', 4, 4, '2026-01-05 08:00:00', '  ', 4, 4, 4),
    (5, 5, 'type_5', 5, '2026-01-06', '2026-01-06', 5, 5, '2026-01-06 08:00:00', 'withdraw_history_5', 5, 5, 5);
COMMIT;
