-- Sample rows for raw_intranet.prm_budget_revisions (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh. Edit the rows when a model needs other values (joins, edge cases).
BEGIN;
DROP TABLE IF EXISTS raw_intranet."prm_budget_revisions";
CREATE TABLE raw_intranet."prm_budget_revisions" (
    "prm_budget_revisions_id" integer,
    "component_code" varchar(50),
    "type_contract" varchar(15),
    "office_id" integer,
    "currency" varchar(15),
    "value" numeric(38,4),
    "serial" integer,
    "type" varchar(15),
    "status" smallint,
    "oldrevision" integer,
    "description" varchar(500),
    "created_by" varchar(255),
    "created_at" timestamp,
    "validated_at" timestamp
);
INSERT INTO raw_intranet."prm_budget_revisions" ("prm_budget_revisions_id", "component_code", "type_contract", "office_id", "currency", "value", "serial", "type", "status", "oldrevision", "description", "created_by", "created_at", "validated_at") VALUES
    (1, 'component_code_1', 'type_contract_1', 1, 'currency_1', 1, 1, 'type_1', 1, 1, 'description_1', 'created_by_1', '2026-01-02 08:00:00', '2026-01-02 08:00:00'),
    (2, 'component_code_2', 'type_contract_2', 2, 'currency_2', 2, 2, 'type_2', 2, 2, 'description_2', 'created_by_2', '2026-01-03 08:00:00', '2026-01-03 08:00:00'),
    (3, 'component_code_3', 'type_contract_3', 3, 'currency_3', 3, 3, 'type_3', 3, 3, 'description_3', 'created_by_3', '2026-01-04 08:00:00', '2026-01-04 08:00:00'),
    (4, '  ', '  ', 4, '  ', 4, 4, '  ', 4, 4, '  ', '  ', '2026-01-05 08:00:00', '2026-01-05 08:00:00'),
    (5, 'component_code_5', 'type_contract_5', 5, 'currency_5', 5, 5, 'type_5', 5, 5, 'description_5', 'created_by_5', '2026-01-06 08:00:00', '2026-01-06 08:00:00');
COMMIT;
