-- Vehicle Rental Management System - BCSE302L Review II
-- Section 5.1: Cursors. Run after 07_functions.sql.

--## CUR_OVERDUE
-- Explicit cursor: lists every ONGOING booking whose end date has passed (vehicle not returned)
-- and the late fee building up so far (BR-05). Uses OPEN, FETCH, CLOSE, %NOTFOUND and %ROWCOUNT.
CREATE OR REPLACE PROCEDURE sp_overdue_report
IS
  CURSOR c_overdue IS
    SELECT b.booking_id, c.name, c.phone, v.reg_number, b.end_date, vc.late_fee_per_hr
    FROM   booking b
    JOIN   customer c          ON c.customer_id  = b.customer_id
    JOIN   vehicle v           ON v.vehicle_id   = b.vehicle_id
    JOIN   vehicle_category vc ON vc.category_id = v.category_id
    WHERE  b.status = 'ONGOING'
    AND    b.end_date < SYSDATE
    ORDER  BY b.end_date;
  r_row   c_overdue%ROWTYPE;
  v_hours NUMBER;
  v_fee   NUMBER;
  v_total NUMBER := 0;
BEGIN
  OPEN c_overdue;
  LOOP
    FETCH c_overdue INTO r_row;
    EXIT WHEN c_overdue%NOTFOUND;
    v_hours := CEIL(ROUND((SYSDATE - r_row.end_date) * 1440) / 60);
    v_fee   := v_hours * r_row.late_fee_per_hr;
    v_total := v_total + v_fee;
    DBMS_OUTPUT.PUT_LINE('Booking ' || r_row.booking_id || ' | ' || r_row.reg_number || ' | ' ||
                         r_row.name || ' (' || r_row.phone || ') | due ' ||
                         TO_CHAR(r_row.end_date, 'DD-Mon HH24:MI') || ' | ' ||
                         v_hours || ' h late | fee so far Rs ' || v_fee);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(c_overdue%ROWCOUNT || ' overdue booking(s). Total late fee so far: Rs ' || v_total);
  CLOSE c_overdue;
END sp_overdue_report;
/

--## CUR_DUES
-- Cursor FOR loop: goes through all COMPLETED bookings and prints the ones that still have
-- money to collect (FR-11 "pending dues"). The balance comes from fn_booking_balance.
CREATE OR REPLACE PROCEDURE sp_pending_dues
IS
  CURSOR c_completed IS
    SELECT b.booking_id, c.name, c.phone
    FROM   booking b JOIN customer c ON c.customer_id = b.customer_id
    WHERE  b.status = 'COMPLETED'
    ORDER  BY b.booking_id;
  v_balance NUMBER;
  v_count   NUMBER := 0;
  v_total   NUMBER := 0;
BEGIN
  FOR r IN c_completed LOOP
    v_balance := fn_booking_balance(r.booking_id);
    IF v_balance > 0 THEN
      v_count := v_count + 1;
      v_total := v_total + v_balance;
      DBMS_OUTPUT.PUT_LINE('Booking ' || r.booking_id || ' | ' || r.name || ' (' || r.phone ||
                           ') | balance Rs ' || v_balance);
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(v_count || ' booking(s) with pending dues. Total: Rs ' || v_total);
END sp_pending_dues;
/
