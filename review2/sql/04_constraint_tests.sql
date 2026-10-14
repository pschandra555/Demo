-- Vehicle Rental Management System - BCSE302L Review II
-- Section 1.3: constraint tests. Run after 02_insert_data.sql.
-- Each statement breaks one constraint on purpose. It runs inside a small PL/SQL block that
-- catches the error and prints the first line of the message, so a correct result is a line starting with "Rejected:".

--## CT1
-- 1. UNIQUE: this registration number already belongs to vehicle 1
BEGIN
  INSERT INTO vehicle (vehicle_id, reg_number, brand, model, fuel_type, category_id, branch_id)
  VALUES (50, 'TN09AB1001', 'Maruti Suzuki', 'Baleno', 'PETROL', 1, 1);
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 2. CHECK: HYBRID is not one of the allowed fuel types
BEGIN
  INSERT INTO vehicle (vehicle_id, reg_number, brand, model, fuel_type, category_id, branch_id)
  VALUES (51, 'TN09ZZ9999', 'Toyota', 'Hyryder', 'HYBRID', 3, 1);
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 3. CHECK: branch phone must have exactly 10 digits
BEGIN
  INSERT INTO branch VALUES (50, 'DriveEase Test', 'Chennai', 'Test address', '98401', NULL);
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 4. NOT NULL: licence number is missing
BEGIN
  INSERT INTO customer (customer_id, name, phone, license_expiry, dob)
  VALUES (50, 'Test User', '9000000050', DATE '2035-01-01', DATE '1995-01-01');
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/

--## CT2
-- 5. FOREIGN KEY (child side): booking 999 does not exist
BEGIN
  INSERT INTO payment VALUES (500, 999, 1000, SYSDATE, 'CASH', 'ADVANCE', 'SUCCESS');
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 6. FOREIGN KEY (parent side): customer 1 still has bookings
BEGIN
  DELETE FROM customer WHERE customer_id = 1;
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 7. Table-level CHECK: end date before start date
BEGIN
  UPDATE booking SET end_date = start_date - 1 WHERE booking_id = 1;
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 8. Table-level CHECK (BR-08): end odometer lower than start odometer
BEGIN
  UPDATE booking SET end_odometer = 100 WHERE booking_id = 1;
  DBMS_OUTPUT.PUT_LINE('Accepted - constraint NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
ROLLBACK;
