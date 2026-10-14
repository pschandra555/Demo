-- Vehicle Rental Management System - BCSE302L Review II
-- Read-only checks used as evidence for Sections 1 and 2. Run after 02_insert_data.sql.

--## SC_DESC
DESC booking
DESC payment

--## SC_COUNT
SELECT constraint_kind, COUNT(*) AS total
FROM  (SELECT CASE constraint_type
                WHEN 'P' THEN 'PRIMARY KEY'
                WHEN 'R' THEN 'FOREIGN KEY'
                WHEN 'U' THEN 'UNIQUE'
                WHEN 'C' THEN CASE WHEN constraint_name LIKE 'SYS%' THEN 'NOT NULL' ELSE 'CHECK' END
              END AS constraint_kind
       FROM   user_constraints
       WHERE  table_name IN ('BRANCH', 'VEHICLE_CATEGORY', 'VEHICLE', 'CUSTOMER',
                             'EMPLOYEE', 'BOOKING', 'PAYMENT', 'MAINTENANCE'))
GROUP  BY constraint_kind
ORDER  BY total DESC;

--## SC_FK
SELECT c.table_name, c.constraint_name, r.table_name AS refers_to, c.delete_rule
FROM   user_constraints c
JOIN   user_constraints r ON r.constraint_name = c.r_constraint_name
WHERE  c.constraint_type = 'R'
ORDER  BY c.table_name, c.constraint_name;

--## DATA_COUNTS
SELECT 'BRANCH' AS table_name, COUNT(*) AS total_rows FROM branch
UNION ALL SELECT 'VEHICLE_CATEGORY', COUNT(*) FROM vehicle_category
UNION ALL SELECT 'VEHICLE',          COUNT(*) FROM vehicle
UNION ALL SELECT 'CUSTOMER',         COUNT(*) FROM customer
UNION ALL SELECT 'EMPLOYEE',         COUNT(*) FROM employee
UNION ALL SELECT 'BOOKING',          COUNT(*) FROM booking
UNION ALL SELECT 'PAYMENT',          COUNT(*) FROM payment
UNION ALL SELECT 'MAINTENANCE',      COUNT(*) FROM maintenance;

--## DATA_VEHICLE
SELECT vehicle_id, reg_number, brand, model, fuel_type, odometer, status, category_id, branch_id
FROM   vehicle
ORDER  BY vehicle_id;

--## DATA_BOOKING
SELECT booking_id, customer_id, vehicle_id, pickup_branch_id, return_branch_id,
       start_date, end_date, status
FROM   booking
ORDER  BY booking_id;
