-- Sample rows for raw_intranet.crm_component (local test only; same name and columns as the Intranet MySQL table).
-- Applied by scripts/seed_local.sh: the table is created once, then its rows are replaced (the views over it stay).
-- Edit the rows when a model needs other values (joins, edge cases). Changing the columns of an existing table needs `seed_local.sh --reset`.
-- Dates that models compare with current_date are written relative to it, so they stay valid whenever the seed is applied.
BEGIN;
CREATE TABLE IF NOT EXISTS raw_intranet."crm_component" (
    "crm_component_id" integer,
    "contract_id" integer,
    "component_name" varchar(150),
    "component_code" varchar(100),
    "component_value" varchar(15),
    "currency" varchar(5),
    "total_fee_net_taxes" varchar(255),
    "create_by" varchar(200),
    "last_update" timestamp
);
TRUNCATE raw_intranet."crm_component";
INSERT INTO raw_intranet."crm_component" ("crm_component_id", "contract_id", "component_name", "component_code", "component_value", "currency", "total_fee_net_taxes", "create_by", "last_update") VALUES
    (1, 1, 'component_name_1', 'component_code_1', 'component_value', 'curre', 'total_fee_net_taxes_1', 'create_by_1', '2026-01-02 08:00:00'),
    (2, 2, 'component_name_2', 'component_code_2', 'component_value', 'curre', 'total_fee_net_taxes_2', 'create_by_2', '2026-01-03 08:00:00'),
    (3, 3, 'component_name_3', 'component_code_3', 'component_value', 'curre', 'total_fee_net_taxes_3', 'create_by_3', '2026-01-04 08:00:00'),
    (4, 4, '  ', '  ', '  ', '  ', '  ', '  ', '2026-01-05 08:00:00'),
    (5, 5, 'component_name_5', 'component_code_5', 'component_value', 'curre', 'total_fee_net_taxes_5', 'create_by_5', '2026-01-06 08:00:00');
COMMIT;
