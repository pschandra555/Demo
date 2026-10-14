-- Vehicle Rental Management System - BCSE302L Review II
-- Section 5.2: Triggers. Run after 07_functions.sql (trg_customer_validate and
-- trg_booking_validate call fn_age).

--## TRG_CUSTOMER
-- BR-01 at registration: customer must be 21 or older and the licence must not be expired.
-- A CHECK constraint cannot use SYSDATE, so this is done in a trigger (as planned in Review I).
CREATE OR REPLACE TRIGGER trg_customer_validate
BEFORE INSERT OR UPDATE OF dob, license_expiry ON customer
FOR EACH ROW
BEGIN
  IF fn_age(:NEW.dob, SYSDATE) < 21 THEN
    RAISE_APPLICATION_ERROR(-20201, 'Customer must be at least 21 years old. Age: ' ||
                                    fn_age(:NEW.dob, SYSDATE));
  END IF;
  IF :NEW.license_expiry <= SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20202, 'Driving licence has expired on ' ||
                                    TO_CHAR(:NEW.license_expiry, 'DD-MON-YYYY'));
  END IF;
END;
/

--## TRG_BOOKING
-- BR-01 and BR-03 for every new booking: customer is 21+ on the start date, licence is valid
-- until the end date, and the vehicle is AVAILABLE (not RENTED, MAINTENANCE or RETIRED).
CREATE OR REPLACE TRIGGER trg_booking_validate
BEFORE INSERT ON booking
FOR EACH ROW
DECLARE
  v_dob     customer.dob%TYPE;
  v_expiry  customer.license_expiry%TYPE;
  v_vstatus vehicle.status%TYPE;
BEGIN
  SELECT dob, license_expiry INTO v_dob, v_expiry
  FROM   customer WHERE customer_id = :NEW.customer_id;
  IF fn_age(v_dob, :NEW.start_date) < 21 THEN
    RAISE_APPLICATION_ERROR(-20211, 'Customer is under 21 on the rental start date');
  END IF;
  IF v_expiry < :NEW.end_date THEN
    RAISE_APPLICATION_ERROR(-20212, 'Driving licence expires on ' || TO_CHAR(v_expiry, 'DD-MON-YYYY') ||
                                    ', before the rental ends');
  END IF;

  SELECT status INTO v_vstatus FROM vehicle WHERE vehicle_id = :NEW.vehicle_id;
  IF v_vstatus <> 'AVAILABLE' THEN
    RAISE_APPLICATION_ERROR(-20213, 'Vehicle ' || :NEW.vehicle_id || ' cannot be booked. Status: ' || v_vstatus);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20214, 'Customer or vehicle does not exist');
END;
/

--## TRG_SYNC
-- Keeps VEHICLE in step with BOOKING: pickup makes the vehicle RENTED; return makes it
-- AVAILABLE, moves it to the return branch (BR-07) and updates its odometer.
CREATE OR REPLACE TRIGGER trg_booking_status_sync
AFTER UPDATE OF status ON booking
FOR EACH ROW
BEGIN
  IF :OLD.status = 'BOOKED' AND :NEW.status = 'ONGOING' THEN
    UPDATE vehicle SET status = 'RENTED' WHERE vehicle_id = :NEW.vehicle_id;
  ELSIF :OLD.status = 'ONGOING' AND :NEW.status = 'COMPLETED' THEN
    UPDATE vehicle
    SET    status    = 'AVAILABLE',
           branch_id = :NEW.return_branch_id,
           odometer  = NVL(:NEW.end_odometer, odometer)
    WHERE  vehicle_id = :NEW.vehicle_id;
  END IF;
END;
/

--## TRG_MAINT
-- FR-09: a job IN_PROGRESS takes the vehicle out of the fleet (status MAINTENANCE);
-- a DONE job releases it. A vehicle that is out on rent cannot go into the workshop.
CREATE OR REPLACE TRIGGER trg_maintenance_sync
AFTER INSERT OR UPDATE OF maint_status ON maintenance
FOR EACH ROW
DECLARE
  v_vstatus vehicle.status%TYPE;
BEGIN
  IF :NEW.maint_status = 'IN_PROGRESS' THEN
    SELECT status INTO v_vstatus FROM vehicle WHERE vehicle_id = :NEW.vehicle_id;
    IF v_vstatus = 'RENTED' THEN
      RAISE_APPLICATION_ERROR(-20221, 'Vehicle ' || :NEW.vehicle_id || ' is out on rent; maintenance cannot start');
    ELSIF v_vstatus = 'AVAILABLE' THEN
      UPDATE vehicle SET status = 'MAINTENANCE' WHERE vehicle_id = :NEW.vehicle_id;
    END IF;
  ELSIF :NEW.maint_status = 'DONE' THEN
    UPDATE vehicle SET status = 'AVAILABLE'
    WHERE  vehicle_id = :NEW.vehicle_id AND status = 'MAINTENANCE';
  END IF;
END;
/
