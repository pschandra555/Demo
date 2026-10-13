-- Vehicle Rental Management System - BCSE302L Review II
-- Execution of functions, procedures, cursors and triggers. Run AFTER 07, 08, 09 and 10.
-- Run the blocks IN THIS ORDER on freshly loaded data: the IDs shown in the report
-- (customer 13, bookings 23-25) come from the sequences.
-- Calls that must be refused run inside BEGIN ... EXCEPTION ... END blocks that print
-- "Rejected:" and the Oracle error message.

--## T_OBJECTS
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_type IN ('FUNCTION', 'PROCEDURE', 'TRIGGER')
ORDER  BY object_type, object_name;

--## T_FUNCS1
SELECT booking_id, end_date, actual_return_date,
       fn_rental_days(start_date, end_date) AS days,
       fn_calculate_rent(booking_id)        AS rent,
       fn_late_fee(booking_id)              AS late_fee,
       fn_booking_balance(booking_id)       AS balance
FROM   booking
WHERE  booking_id IN (1, 2, 4, 7, 12, 16)
ORDER  BY booking_id;

--## T_FUNCS2
SELECT customer_id, name, dob, fn_age(dob, SYSDATE) AS age_today
FROM   customer WHERE customer_id IN (4, 8, 9);
SELECT fn_is_vehicle_free(1,  TO_DATE('2026-10-21 10:00', 'YYYY-MM-DD HH24:MI'),
                              TO_DATE('2026-10-23 10:00', 'YYYY-MM-DD HH24:MI')) AS vehicle1_free,
       fn_is_vehicle_free(12, TO_DATE('2026-10-21 10:00', 'YYYY-MM-DD HH24:MI'),
                              TO_DATE('2026-10-23 10:00', 'YYYY-MM-DD HH24:MI')) AS vehicle12_free
FROM   dual;

--## T_REGISTER
EXEC sp_register_customer('Rohit Verma', '9841000113', 'rohit.verma@gmail.com', 'TN0920200045678', DATE '2032-06-30', DATE '1998-09-12', 'Velachery, Chennai');
SELECT customer_id, name, phone, license_no, registered_on FROM customer WHERE customer_id = 13;

--## T_BOOK
-- Customer 13 books the scooter (vehicle 12) at Chennai Central for 2 days from tomorrow 10:00,
-- returning it at Chennai Airport (one-way), and pays Rs 400 advance by UPI.
EXEC sp_create_booking(13, 12, 2, 1, 2, TRUNC(SYSDATE) + 1 + 10/24, TRUNC(SYSDATE) + 3 + 10/24, 400, 'UPI');
SELECT booking_id, customer_id, vehicle_id, start_date, end_date, status FROM booking WHERE booking_id = 23;
SELECT payment_id, booking_id, amount, method, payment_type FROM payment WHERE booking_id = 23;

--## T_PICKUP
EXEC sp_pickup_vehicle(23);
SELECT b.booking_id, b.status, b.start_odometer, v.vehicle_id, v.status AS vehicle_status
FROM   booking b JOIN vehicle v ON v.vehicle_id = b.vehicle_id WHERE b.booking_id = 23;

--## T_RETURN
-- Returned at Chennai Airport after driving 60 km, 3 hours after the end time.
EXEC sp_return_vehicle(23, 9120, TRUNC(SYSDATE) + 3 + 13/24, 'CASH');
SELECT booking_id, status, actual_return_date, start_odometer, end_odometer FROM booking WHERE booking_id = 23;
SELECT vehicle_id, status, branch_id, odometer FROM vehicle WHERE vehicle_id = 12;
SELECT payment_id, payment_type, amount, method FROM payment WHERE booking_id = 23 ORDER BY payment_id;

--## T_CANCEL
-- Booking 24 starts in 10 days (full refund); booking 25 starts in 5 hours (50% refund).
EXEC sp_create_booking(13, 13, 5, 3, 3, TRUNC(SYSDATE) + 10 + 9/24, TRUNC(SYSDATE) + 11 + 9/24, 400, 'CARD');
EXEC sp_cancel_booking(24);
EXEC sp_create_booking(13, 13, 5, 3, 3, SYSDATE + 5/24, SYSDATE + 1 + 5/24, 400, 'CARD');
EXEC sp_cancel_booking(25);
SELECT booking_id, payment_type, amount, method FROM payment WHERE booking_id IN (24, 25) ORDER BY payment_id;

--## T_OVERDUE
EXEC sp_overdue_report;

--## T_DUES
EXEC sp_pending_dues;

--## T_TRG_CUSTOMER
-- Both registrations must be rejected by trg_customer_validate
BEGIN
  sp_register_customer('Arav Shah', '9000000001', NULL, 'TN0920250000001', DATE '2035-01-01', DATE '2010-01-01');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
BEGIN
  sp_register_customer('Nikhil Das', '9000000002', NULL, 'TN0920000000002', DATE '2025-01-01', DATE '1990-01-01');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/

--## T_TRG_BOOKING
-- Customer 4's licence expires on 30-APR-2027, before this rental ends
BEGIN
  sp_create_booking(4, 1, 2, 1, 1,
                    TO_DATE('2027-05-01 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2027-05-03 10:00', 'YYYY-MM-DD HH24:MI'), 1000, 'UPI');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- Vehicle 5 is RENTED (booking 17 is still ongoing)
BEGIN
  sp_create_booking(1, 5, 6, 4, 4, TRUNC(SYSDATE) + 20 + 9/24, TRUNC(SYSDATE) + 22 + 9/24, 0);
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/

--## T_TRG_MAINT
SELECT vehicle_id, reg_number, status FROM vehicle WHERE vehicle_id IN (3, 8);
-- Clutch job on vehicle 8 is finished; a new tyre job starts on vehicle 3
UPDATE maintenance SET maint_status = 'DONE', cost = 9800 WHERE maint_id = 11;
INSERT INTO maintenance (maint_id, vehicle_id, service_type, description, maint_status)
VALUES (seq_maintenance.NEXTVAL, 3, 'TYRE', 'Wheel alignment and tyre rotation', 'IN_PROGRESS');
COMMIT;
SELECT vehicle_id, reg_number, status FROM vehicle WHERE vehicle_id IN (3, 8);
-- Vehicle 3 is now in the workshop, so it cannot be booked
BEGIN
  sp_create_booking(13, 3, 3, 2, 2, TRUNC(SYSDATE) + 5 + 10/24, TRUNC(SYSDATE) + 6 + 10/24, 0);
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- Vehicle 2 is out on rent, so maintenance cannot start
BEGIN
  INSERT INTO maintenance (maint_id, vehicle_id, service_type, description, maint_status)
  VALUES (seq_maintenance.NEXTVAL, 2, 'GENERAL', 'Periodic service', 'IN_PROGRESS');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/

--## T_RULES
-- 1. BR-02: vehicle 1 already has booking 19 from 20-Oct to 22-Oct
BEGIN
  sp_create_booking(10, 1, 2, 1, 1,
                    TO_DATE('2026-10-21 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-23 10:00', 'YYYY-MM-DD HH24:MI'), 500, 'UPI');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 2. Vehicle 10 is at the Pune branch, not at Chennai Central
BEGIN
  sp_create_booking(10, 10, 2, 1, 1,
                    TO_DATE('2026-11-02 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-03 10:00', 'YYYY-MM-DD HH24:MI'), 0);
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 3. Booking 23 is already COMPLETED, so it cannot be picked up again
BEGIN
  sp_pickup_vehicle(23);
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 4. Booking 18 is ONGOING, so it cannot be cancelled
BEGIN
  sp_cancel_booking(18);
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
-- 5. Phone number already belongs to customer 1
BEGIN
  sp_register_customer('Aditya R', '9841000101', NULL, 'TN0920259999999', DATE '2036-01-01', DATE '1996-03-14');
  DBMS_OUTPUT.PUT_LINE('Accepted - rule NOT working');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Rejected: ' || REGEXP_SUBSTR(SQLERRM, '[^' || CHR(10) || ']+'));
END;
/
