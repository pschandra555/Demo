-- Vehicle Rental Management System - BCSE302L Review II
-- Section 4.1: Functions. Run after 01_ddl.sql (they only read tables).

--## FN_AGE
-- Derived attribute "age" of CUSTOMER (Review I): age in completed years on a given date.
CREATE OR REPLACE FUNCTION fn_age (p_dob IN DATE, p_on IN DATE)
RETURN NUMBER
IS
BEGIN
  RETURN TRUNC(MONTHS_BETWEEN(p_on, p_dob) / 12);
END fn_age;
/

--## FN_DAYS
-- Derived attribute "rental_days" of BOOKING (BR-04): part of a day counts as a full day,
-- minimum one day. Minutes are rounded first so DATE arithmetic cannot add a false extra day.
CREATE OR REPLACE FUNCTION fn_rental_days (p_start IN DATE, p_end IN DATE)
RETURN NUMBER
IS
BEGIN
  RETURN GREATEST(1, CEIL(ROUND((p_end - p_start) * 1440) / 1440));
END fn_rental_days;
/

--## FN_RENT
-- Rent of a booking = rental days x daily rate of the vehicle's category (BR-04).
CREATE OR REPLACE FUNCTION fn_calculate_rent (p_booking_id IN booking.booking_id%TYPE)
RETURN NUMBER
IS
  v_rent NUMBER;
BEGIN
  SELECT fn_rental_days(b.start_date, b.end_date) * vc.daily_rate
  INTO   v_rent
  FROM   booking b
  JOIN   vehicle v           ON v.vehicle_id   = b.vehicle_id
  JOIN   vehicle_category vc ON vc.category_id = v.category_id
  WHERE  b.booking_id = p_booking_id;
  RETURN v_rent;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END fn_calculate_rent;
/

--## FN_LATE
-- Late fee (BR-05): every started hour after end_date x late_fee_per_hr. 0 if on time or not returned.
CREATE OR REPLACE FUNCTION fn_late_fee (p_booking_id IN booking.booking_id%TYPE)
RETURN NUMBER
IS
  v_minutes NUMBER;
  v_rate    vehicle_category.late_fee_per_hr%TYPE;
BEGIN
  SELECT ROUND((b.actual_return_date - b.end_date) * 1440), vc.late_fee_per_hr
  INTO   v_minutes, v_rate
  FROM   booking b
  JOIN   vehicle v           ON v.vehicle_id   = b.vehicle_id
  JOIN   vehicle_category vc ON vc.category_id = v.category_id
  WHERE  b.booking_id = p_booking_id;
  IF v_minutes IS NULL OR v_minutes <= 0 THEN
    RETURN 0;
  END IF;
  RETURN CEIL(v_minutes / 60) * v_rate;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END fn_late_fee;
/

--## FN_FREE
-- BR-02: returns 1 if the vehicle has no BOOKED/ONGOING booking overlapping the period, else 0.
CREATE OR REPLACE FUNCTION fn_is_vehicle_free (p_vehicle_id IN vehicle.vehicle_id%TYPE,
                                               p_start      IN DATE,
                                               p_end        IN DATE)
RETURN NUMBER
IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO   v_count
  FROM   booking
  WHERE  vehicle_id = p_vehicle_id
  AND    status IN ('BOOKED', 'ONGOING')
  AND    start_date < p_end
  AND    end_date   > p_start;
  IF v_count = 0 THEN
    RETURN 1;
  END IF;
  RETURN 0;
END fn_is_vehicle_free;
/

--## FN_BALANCE
-- Amount still to be collected for a COMPLETED booking:
-- rent + late fee - successful advance/final/late-fee payments. 0 for other bookings.
CREATE OR REPLACE FUNCTION fn_booking_balance (p_booking_id IN booking.booking_id%TYPE)
RETURN NUMBER
IS
  v_status booking.status%TYPE;
  v_paid   NUMBER;
BEGIN
  SELECT status INTO v_status FROM booking WHERE booking_id = p_booking_id;
  IF v_status <> 'COMPLETED' THEN
    RETURN 0;
  END IF;
  SELECT NVL(SUM(amount), 0)
  INTO   v_paid
  FROM   payment
  WHERE  booking_id = p_booking_id
  AND    txn_status = 'SUCCESS'
  AND    payment_type IN ('ADVANCE', 'FINAL', 'LATE_FEE');
  RETURN fn_calculate_rent(p_booking_id) + fn_late_fee(p_booking_id) - v_paid;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END fn_booking_balance;
/
