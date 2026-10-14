-- Vehicle Rental Management System - BCSE302L Review II
-- Section 4.2: Procedures. Run after 07_functions.sql. Use SET SERVEROUTPUT ON to see messages.

--## SP_REGISTER
-- FR-01: register a customer. Age and licence checks are done by trigger trg_customer_validate.
CREATE OR REPLACE PROCEDURE sp_register_customer (
  p_name           IN customer.name%TYPE,
  p_phone          IN customer.phone%TYPE,
  p_email          IN customer.email%TYPE,
  p_license_no     IN customer.license_no%TYPE,
  p_license_expiry IN customer.license_expiry%TYPE,
  p_dob            IN customer.dob%TYPE,
  p_address        IN customer.address%TYPE DEFAULT NULL
) IS
  v_id customer.customer_id%TYPE;
BEGIN
  v_id := seq_customer.NEXTVAL;
  INSERT INTO customer (customer_id, name, phone, email, license_no, license_expiry, dob, address, registered_on)
  VALUES (v_id, p_name, p_phone, p_email, p_license_no, p_license_expiry, p_dob, p_address, SYSDATE);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Customer registered. ID = ' || v_id);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20150, 'Phone, email or licence number is already registered');
END sp_register_customer;
/

--## SP_BOOK
-- FR-04 / FR-07: create a booking and record the advance payment.
-- BR-02 (no overlap) is checked here with fn_is_vehicle_free; BR-01 and BR-03 by trg_booking_validate.
CREATE OR REPLACE PROCEDURE sp_create_booking (
  p_customer_id   IN booking.customer_id%TYPE,
  p_vehicle_id    IN booking.vehicle_id%TYPE,
  p_emp_id        IN booking.emp_id%TYPE,
  p_pickup_branch IN booking.pickup_branch_id%TYPE,
  p_return_branch IN booking.return_branch_id%TYPE,
  p_start_date    IN DATE,
  p_end_date      IN DATE,
  p_advance       IN payment.amount%TYPE DEFAULT 0,
  p_method        IN payment.method%TYPE DEFAULT 'CASH'
) IS
  v_branch  vehicle.branch_id%TYPE;
  v_booking booking.booking_id%TYPE;
BEGIN
  SELECT branch_id INTO v_branch FROM vehicle WHERE vehicle_id = p_vehicle_id;
  IF v_branch <> p_pickup_branch THEN
    RAISE_APPLICATION_ERROR(-20102, 'Vehicle ' || p_vehicle_id || ' is at branch ' || v_branch ||
                                    ', not at pickup branch ' || p_pickup_branch);
  END IF;
  IF fn_is_vehicle_free(p_vehicle_id, p_start_date, p_end_date) = 0 THEN
    RAISE_APPLICATION_ERROR(-20103, 'Vehicle ' || p_vehicle_id || ' is already booked for these dates');
  END IF;

  v_booking := seq_booking.NEXTVAL;
  INSERT INTO booking (booking_id, customer_id, vehicle_id, emp_id, pickup_branch_id, return_branch_id,
                       booking_date, start_date, end_date, status)
  VALUES (v_booking, p_customer_id, p_vehicle_id, p_emp_id, p_pickup_branch, p_return_branch,
          SYSDATE, p_start_date, p_end_date, 'BOOKED');

  IF p_advance > 0 THEN
    INSERT INTO payment (payment_id, booking_id, amount, payment_date, method, payment_type, txn_status)
    VALUES (seq_payment.NEXTVAL, v_booking, p_advance, SYSDATE, p_method, 'ADVANCE', 'SUCCESS');
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Booking ' || v_booking || ' created for vehicle ' || p_vehicle_id ||
                       '. Estimated rent: Rs ' || fn_calculate_rent(v_booking) ||
                       ', advance paid: Rs ' || p_advance);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20101, 'Vehicle ' || p_vehicle_id || ' does not exist');
END sp_create_booking;
/

--## SP_PICKUP
-- FR-05: customer collects the vehicle. start_odometer is copied from the vehicle.
-- trg_booking_status_sync then marks the vehicle RENTED.
CREATE OR REPLACE PROCEDURE sp_pickup_vehicle (p_booking_id IN booking.booking_id%TYPE)
IS
  v_status  booking.status%TYPE;
  v_vstatus vehicle.status%TYPE;
  v_odo     vehicle.odometer%TYPE;
BEGIN
  SELECT b.status, v.status, v.odometer
  INTO   v_status, v_vstatus, v_odo
  FROM   booking b JOIN vehicle v ON v.vehicle_id = b.vehicle_id
  WHERE  b.booking_id = p_booking_id;
  IF v_status <> 'BOOKED' THEN
    RAISE_APPLICATION_ERROR(-20120, 'Booking ' || p_booking_id || ' is ' || v_status || ', not BOOKED');
  END IF;
  IF v_vstatus <> 'AVAILABLE' THEN
    RAISE_APPLICATION_ERROR(-20122, 'Vehicle is ' || v_vstatus || ' and cannot be handed over');
  END IF;
  UPDATE booking SET status = 'ONGOING', start_odometer = v_odo WHERE booking_id = p_booking_id;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' is now ONGOING. Start odometer: ' || v_odo);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20121, 'Booking ' || p_booking_id || ' not found');
END sp_pickup_vehicle;
/

--## SP_RETURN
-- FR-06 / FR-07: vehicle returned. Computes rent and late fee, records FINAL and LATE_FEE payments.
-- trg_booking_status_sync makes the vehicle AVAILABLE at the return branch (BR-07).
CREATE OR REPLACE PROCEDURE sp_return_vehicle (
  p_booking_id   IN booking.booking_id%TYPE,
  p_end_odometer IN booking.end_odometer%TYPE,
  p_return_time  IN DATE DEFAULT SYSDATE,
  p_method       IN payment.method%TYPE DEFAULT 'CASH'
) IS
  v_status    booking.status%TYPE;
  v_start_odo booking.start_odometer%TYPE;
  v_rent      NUMBER;
  v_late      NUMBER;
  v_advance   NUMBER;
  v_due       NUMBER;
BEGIN
  SELECT status, start_odometer INTO v_status, v_start_odo
  FROM   booking WHERE booking_id = p_booking_id;
  IF v_status <> 'ONGOING' THEN
    RAISE_APPLICATION_ERROR(-20130, 'Booking ' || p_booking_id || ' is ' || v_status || ', not ONGOING');
  END IF;
  IF p_end_odometer < v_start_odo THEN
    RAISE_APPLICATION_ERROR(-20131, 'End odometer cannot be less than start odometer ' || v_start_odo);
  END IF;

  UPDATE booking
  SET    actual_return_date = p_return_time, end_odometer = p_end_odometer, status = 'COMPLETED'
  WHERE  booking_id = p_booking_id;

  v_rent := fn_calculate_rent(p_booking_id);
  v_late := fn_late_fee(p_booking_id);
  SELECT NVL(SUM(amount), 0) INTO v_advance
  FROM   payment
  WHERE  booking_id = p_booking_id AND payment_type = 'ADVANCE' AND txn_status = 'SUCCESS';
  v_due := v_rent - v_advance;

  IF v_due > 0 THEN
    INSERT INTO payment (payment_id, booking_id, amount, payment_date, method, payment_type, txn_status)
    VALUES (seq_payment.NEXTVAL, p_booking_id, v_due, p_return_time, p_method, 'FINAL', 'SUCCESS');
  END IF;
  IF v_late > 0 THEN
    INSERT INTO payment (payment_id, booking_id, amount, payment_date, method, payment_type, txn_status)
    VALUES (seq_payment.NEXTVAL, p_booking_id, v_late, p_return_time, p_method, 'LATE_FEE', 'SUCCESS');
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' completed. Rent: Rs ' || v_rent ||
                       ', advance: Rs ' || v_advance || ', final payment: Rs ' || GREATEST(v_due, 0) ||
                       ', late fee: Rs ' || v_late);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20132, 'Booking ' || p_booking_id || ' not found');
END sp_return_vehicle;
/

--## SP_CANCEL
-- FR-08 / BR-06: cancel a BOOKED booking. Full refund of the advance if cancelled 24 hours or more
-- before pickup, otherwise 50%. The refund goes back by the same method as the advance.
CREATE OR REPLACE PROCEDURE sp_cancel_booking (
  p_booking_id  IN booking.booking_id%TYPE,
  p_cancel_time IN DATE DEFAULT SYSDATE
) IS
  v_status  booking.status%TYPE;
  v_start   booking.start_date%TYPE;
  v_advance NUMBER;
  v_method  payment.method%TYPE;
  v_refund  NUMBER;
BEGIN
  SELECT status, start_date INTO v_status, v_start FROM booking WHERE booking_id = p_booking_id;
  IF v_status <> 'BOOKED' THEN
    RAISE_APPLICATION_ERROR(-20140, 'Only a BOOKED booking can be cancelled. Current status: ' || v_status);
  END IF;

  SELECT NVL(SUM(amount), 0), MIN(method) INTO v_advance, v_method
  FROM   payment
  WHERE  booking_id = p_booking_id AND payment_type = 'ADVANCE' AND txn_status = 'SUCCESS';

  IF v_start - p_cancel_time >= 1 THEN
    v_refund := v_advance;                 -- 24 hours or more before pickup
  ELSE
    v_refund := ROUND(v_advance * 0.5, 2); -- late cancellation
  END IF;

  UPDATE booking SET status = 'CANCELLED' WHERE booking_id = p_booking_id;
  IF v_refund > 0 THEN
    INSERT INTO payment (payment_id, booking_id, amount, payment_date, method, payment_type, txn_status)
    VALUES (seq_payment.NEXTVAL, p_booking_id, v_refund, p_cancel_time, v_method, 'REFUND', 'SUCCESS');
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' cancelled. Advance: Rs ' || v_advance ||
                       ', refund: Rs ' || v_refund);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20141, 'Booking ' || p_booking_id || ' not found');
END sp_cancel_booking;
/
