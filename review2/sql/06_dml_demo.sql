-- Vehicle Rental Management System - BCSE302L Review II
-- Section 2.2: INSERT / UPDATE / DELETE demonstration. Run AFTER 05_queries.sql.

--## DML_INSERT
-- A new Kia Seltos joins the Chennai Airport branch. transmission, odometer and status
-- are not given, so the DEFAULT values ('MANUAL', 0, 'AVAILABLE') are stored.
INSERT INTO vehicle (vehicle_id, reg_number, brand, model, mfg_year, fuel_type, category_id, branch_id)
VALUES (15, 'TN09YZ2015', 'Kia', 'Seltos', 2024, 'PETROL', 3, 2);
COMMIT;
SELECT vehicle_id, reg_number, brand, model, transmission, odometer, status, branch_id
FROM   vehicle WHERE vehicle_id = 15;

--## DML_UPDATE
-- 10% increment for the agents of branches 1 and 3 (the busiest branches in Q15)
SELECT emp_id, name, branch_id, salary FROM employee WHERE role = 'AGENT' AND branch_id IN (1, 3);
UPDATE employee SET salary = salary * 1.10 WHERE role = 'AGENT' AND branch_id IN (1, 3);
SELECT emp_id, name, branch_id, salary FROM employee WHERE role = 'AGENT' AND branch_id IN (1, 3);
-- Customer 7 changed phone number and address
UPDATE customer SET phone = '9841999107', address = 'Chromepet, Chennai' WHERE customer_id = 7;
SELECT customer_id, name, phone, address FROM customer WHERE customer_id = 7;
COMMIT;

--## DML_DELETE
-- Booking 22 was cancelled. Deleting it also deletes its payments (ON DELETE CASCADE).
SELECT payment_id, booking_id, payment_type, amount FROM payment WHERE booking_id = 22;
DELETE FROM booking WHERE booking_id = 22 AND status = 'CANCELLED';
SELECT COUNT(*) AS payments_left FROM payment WHERE booking_id = 22;
COMMIT;
