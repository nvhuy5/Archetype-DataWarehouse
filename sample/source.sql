-- Simulated Intranet source: one table with a few rows (same name and columns as the real Intranet table).
CREATE TABLE IF NOT EXISTS hr_menu_department (
    id integer,
    group_id integer,
    name varchar(100),
    code varchar(3),
    description varchar(200),
    technical_dept boolean,
    business_line varchar(5),
    ds_pm smallint,
    hide varchar(1)
);

INSERT INTO hr_menu_department (id, group_id, name, code, description, technical_dept, business_line, ds_pm, hide) VALUES
 (1, 1, 'Engineering',    'ENG', 'Design and engineering',  true,  'IPE', 0, '0'),
 (2, 1, 'Infrastructure', 'INF', 'Roads and bridges',       true,  'AMP', 0, '0'),
 (3, 2, 'Human Resources','HRM', 'People and recruitment',  false, NULL,  0, '0');
