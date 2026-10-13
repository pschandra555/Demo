-- Vehicle Rental Management System - BCSE302L Review II
-- Generated from tools/make_sql.py (do not edit by hand; edit tools/model.py instead)

-- Run in a fresh schema (or run 99_cleanup.sql first).

--## DDL_SEQ
-- Sequences generate IDs inside the procedures. They start after the sample data.
CREATE SEQUENCE seq_customer    START WITH 13 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_booking     START WITH 23 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_payment     START WITH 46 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_maintenance START WITH 13 INCREMENT BY 1 NOCACHE;

--## DDL_MASTER
CREATE TABLE branch (
  branch_id    NUMBER(4)     CONSTRAINT pk_branch PRIMARY KEY,
  branch_name  VARCHAR2(50)  NOT NULL CONSTRAINT uq_branch_name UNIQUE,
  city         VARCHAR2(30)  NOT NULL,
  address      VARCHAR2(120) NOT NULL,
  phone        VARCHAR2(10)  NOT NULL CONSTRAINT uq_branch_phone UNIQUE
                             CONSTRAINT ck_branch_phone CHECK (LENGTH(phone) = 10),
  email        VARCHAR2(60)  CONSTRAINT uq_branch_email UNIQUE
);

CREATE TABLE vehicle_category (
  category_id      NUMBER(3)    CONSTRAINT pk_category PRIMARY KEY,
  category_name    VARCHAR2(30) NOT NULL CONSTRAINT uq_category_name UNIQUE,
  daily_rate       NUMBER(8,2)  NOT NULL CONSTRAINT ck_category_rate CHECK (daily_rate > 0),
  late_fee_per_hr  NUMBER(7,2)  DEFAULT 100  CONSTRAINT ck_category_latefee CHECK (late_fee_per_hr >= 0),
  seating_capacity NUMBER(2)    CONSTRAINT ck_category_seats CHECK (seating_capacity BETWEEN 1 AND 15),
  security_deposit NUMBER(8,2)  DEFAULT 2000 CONSTRAINT ck_category_deposit CHECK (security_deposit >= 0)
);

CREATE TABLE vehicle (
  vehicle_id   NUMBER(5)    CONSTRAINT pk_vehicle PRIMARY KEY,
  reg_number   VARCHAR2(12) NOT NULL CONSTRAINT uq_vehicle_reg UNIQUE,
  brand        VARCHAR2(30) NOT NULL,
  model        VARCHAR2(30) NOT NULL,
  mfg_year     NUMBER(4)    CONSTRAINT ck_vehicle_year CHECK (mfg_year >= 2010),
  fuel_type    VARCHAR2(10) NOT NULL
               CONSTRAINT ck_vehicle_fuel CHECK (fuel_type IN ('PETROL', 'DIESEL', 'CNG', 'ELECTRIC')),
  transmission VARCHAR2(10) DEFAULT 'MANUAL'
               CONSTRAINT ck_vehicle_trans CHECK (transmission IN ('MANUAL', 'AUTOMATIC')),
  odometer     NUMBER(7)    DEFAULT 0 CONSTRAINT ck_vehicle_odometer CHECK (odometer >= 0),
  status       VARCHAR2(12) DEFAULT 'AVAILABLE'
               CONSTRAINT ck_vehicle_status
               CHECK (status IN ('AVAILABLE', 'RENTED', 'MAINTENANCE', 'RETIRED')),
  category_id  NUMBER(3)    NOT NULL
               CONSTRAINT fk_vehicle_category REFERENCES vehicle_category (category_id),
  branch_id    NUMBER(4)    NOT NULL CONSTRAINT fk_vehicle_branch REFERENCES branch (branch_id)
);

--## DDL_PEOPLE
CREATE TABLE customer (
  customer_id    NUMBER(6)     CONSTRAINT pk_customer PRIMARY KEY,
  name           VARCHAR2(50)  NOT NULL,
  phone          VARCHAR2(10)  NOT NULL CONSTRAINT uq_customer_phone UNIQUE,
  email          VARCHAR2(60)  CONSTRAINT uq_customer_email UNIQUE,
  license_no     VARCHAR2(16)  NOT NULL CONSTRAINT uq_customer_license UNIQUE,
  license_expiry DATE          NOT NULL,
  dob            DATE          NOT NULL,
  address        VARCHAR2(120),
  registered_on  DATE          DEFAULT SYSDATE
);
-- Age >= 21 and licence validity use SYSDATE, so they are checked by a trigger (Section 5).

CREATE TABLE employee (
  emp_id     NUMBER(5)    CONSTRAINT pk_employee PRIMARY KEY,
  name       VARCHAR2(50) NOT NULL,
  role       VARCHAR2(15) NOT NULL
             CONSTRAINT ck_employee_role CHECK (role IN ('MANAGER', 'AGENT', 'MECHANIC', 'CASHIER')),
  phone      VARCHAR2(10) NOT NULL CONSTRAINT uq_employee_phone UNIQUE,
  email      VARCHAR2(60) CONSTRAINT uq_employee_email UNIQUE,
  salary     NUMBER(9,2)  CONSTRAINT ck_employee_salary CHECK (salary > 0),
  hire_date  DATE         DEFAULT SYSDATE,
  branch_id  NUMBER(4)    NOT NULL CONSTRAINT fk_employee_branch REFERENCES branch (branch_id)
);

--## DDL_BOOKING
CREATE TABLE booking (
  booking_id         NUMBER(7) CONSTRAINT pk_booking PRIMARY KEY,
  customer_id        NUMBER(6) NOT NULL CONSTRAINT fk_booking_customer REFERENCES customer (customer_id),
  vehicle_id         NUMBER(5) NOT NULL CONSTRAINT fk_booking_vehicle  REFERENCES vehicle (vehicle_id),
  emp_id             NUMBER(5) NOT NULL CONSTRAINT fk_booking_employee REFERENCES employee (emp_id),
  pickup_branch_id   NUMBER(4) NOT NULL CONSTRAINT fk_booking_pickup   REFERENCES branch (branch_id),
  return_branch_id   NUMBER(4) NOT NULL CONSTRAINT fk_booking_return   REFERENCES branch (branch_id),
  booking_date       DATE      DEFAULT SYSDATE,
  start_date         DATE      NOT NULL,
  end_date           DATE      NOT NULL,
  actual_return_date DATE,
  start_odometer     NUMBER(7),
  end_odometer       NUMBER(7),
  status             VARCHAR2(12) DEFAULT 'BOOKED'
                     CONSTRAINT ck_booking_status
                     CHECK (status IN ('BOOKED', 'ONGOING', 'COMPLETED', 'CANCELLED')),
  CONSTRAINT ck_booking_dates    CHECK (end_date > start_date),
  CONSTRAINT ck_booking_return   CHECK (actual_return_date >= start_date),
  CONSTRAINT ck_booking_odometer CHECK (end_odometer >= start_odometer)
);

--## DDL_CHILD
CREATE TABLE payment (
  payment_id   NUMBER(8)    CONSTRAINT pk_payment PRIMARY KEY,
  booking_id   NUMBER(7)    NOT NULL CONSTRAINT fk_payment_booking
                            REFERENCES booking (booking_id) ON DELETE CASCADE,
  amount       NUMBER(9,2)  NOT NULL CONSTRAINT ck_payment_amount CHECK (amount > 0),
  payment_date DATE         DEFAULT SYSDATE,
  method       VARCHAR2(12) NOT NULL
               CONSTRAINT ck_payment_method CHECK (method IN ('CASH', 'CARD', 'UPI', 'NETBANKING')),
  payment_type VARCHAR2(10) NOT NULL
               CONSTRAINT ck_payment_type CHECK (payment_type IN ('ADVANCE', 'FINAL', 'LATE_FEE', 'REFUND')),
  txn_status   VARCHAR2(10) DEFAULT 'SUCCESS'
               CONSTRAINT ck_payment_status CHECK (txn_status IN ('SUCCESS', 'PENDING', 'FAILED'))
);

CREATE TABLE maintenance (
  maint_id     NUMBER(6)     CONSTRAINT pk_maintenance PRIMARY KEY,
  vehicle_id   NUMBER(5)     NOT NULL CONSTRAINT fk_maintenance_vehicle REFERENCES vehicle (vehicle_id),
  service_date DATE          DEFAULT SYSDATE,
  service_type VARCHAR2(20)  NOT NULL
               CONSTRAINT ck_maint_type
               CHECK (service_type IN ('GENERAL', 'REPAIR', 'TYRE', 'ACCIDENT', 'INSURANCE')),
  description  VARCHAR2(200),
  cost         NUMBER(9,2)   DEFAULT 0 CONSTRAINT ck_maint_cost CHECK (cost >= 0),
  maint_status VARCHAR2(12)  DEFAULT 'SCHEDULED'
               CONSTRAINT ck_maint_status CHECK (maint_status IN ('SCHEDULED', 'IN_PROGRESS', 'DONE'))
);
