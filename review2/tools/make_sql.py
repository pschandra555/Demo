"""Generates sql/01_ddl.sql and sql/02_insert_data.sql from tools/model.py."""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from model import (BRANCHES, CATEGORIES, VEHICLES, CUSTOMERS, EMPLOYEES, MAINTENANCE, RETIRED, build)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SQL = os.path.join(ROOT, 'sql')


def q(s):
    return "NULL" if s is None else "'" + str(s).replace("'", "''") + "'"


def d(s):
    return f"DATE '{s}'"


def dtm(x):
    return f"TO_DATE('{x:%Y-%m-%d %H:%M}', 'YYYY-MM-DD HH24:MI')"


def num(n):
    if n is None:
        return 'NULL'
    return str(int(n)) if float(n).is_integer() else f'{n:.2f}'


DDL = """--## DDL_SEQ
-- Sequences generate IDs inside the procedures. They start after the sample data.
CREATE SEQUENCE seq_customer    START WITH {c} INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_booking     START WITH {b} INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_payment     START WITH {p} INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_maintenance START WITH {m} INCREMENT BY 1 NOCACHE;

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
"""


def main():
    bookings, payments, odo, branch, status = build()
    header = ("-- Vehicle Rental Management System - BCSE302L Review II\n"
              "-- Generated from tools/make_sql.py (do not edit by hand; edit tools/model.py instead)\n\n")
    with open(os.path.join(SQL, '01_ddl.sql'), 'w') as f:
        f.write(header + "-- Run in a fresh schema (or run 99_cleanup.sql first).\n\n")
        f.write(DDL.format(c=len(CUSTOMERS) + 1, b=max(b['id'] for b in bookings) + 1,
                           p=len(payments) + 1, m=len(MAINTENANCE) + 1))

    out = [header, "SET DEFINE OFF\n"]
    out.append("--## INS_BRANCH\n")
    for r in BRANCHES:
        out.append(f"INSERT INTO branch VALUES ({r[0]}, {q(r[1])}, {q(r[2])}, {q(r[3])}, {q(r[4])}, {q(r[5])});\n")
    out.append("\n--## INS_CATEGORY\n")
    for r in CATEGORIES:
        if r[3] is None:
            out.append("-- Motorbike: late_fee_per_hr and security_deposit are left out, so the DEFAULT values (100, 2000) are used\n")
            out.append(f"INSERT INTO vehicle_category (category_id, category_name, daily_rate, seating_capacity)\n"
                       f"  VALUES ({r[0]}, {q(r[1])}, {r[2]}, {r[4]});\n")
        else:
            out.append(f"INSERT INTO vehicle_category VALUES ({r[0]}, {q(r[1])}, {r[2]}, {r[3]}, {r[4]}, {r[5]});\n")
    out.append("\n--## INS_VEHICLE\n"
               "-- Odometer and branch are the current values (after the rentals loaded below).\n"
               "-- Every vehicle starts as AVAILABLE; current RENTED/MAINTENANCE/RETIRED states are set at the end.\n")
    for v in VEHICLES:
        out.append(f"INSERT INTO vehicle VALUES ({v[0]}, {q(v[1])}, {q(v[2])}, {q(v[3])}, {v[4]}, {q(v[5])}, "
                   f"{q(v[6])}, {odo[v[0]]}, 'AVAILABLE', {v[8]}, {branch[v[0]]});\n")
    out.append("\n--## INS_CUSTOMER\n")
    for c in CUSTOMERS:
        out.append(f"INSERT INTO customer VALUES ({c[0]}, {q(c[1])}, {q(c[2])}, {q(c[3])}, {q(c[4])}, "
                   f"{d(c[5])}, {d(c[6])}, {q(c[7])}, {d(c[8])});\n")
    out.append("\n--## INS_EMPLOYEE\n")
    for e in EMPLOYEES:
        out.append(f"INSERT INTO employee VALUES ({e[0]}, {q(e[1])}, {q(e[2])}, {q(e[3])}, {q(e[4])}, "
                   f"{e[5]}, {d(e[6])}, {e[7]});\n")
    out.append("\n--## INS_BOOKING\n"
               "-- Columns: booking_id, customer_id, vehicle_id, emp_id, pickup_branch_id, return_branch_id,\n"
               "--          booking_date, start_date, end_date, actual_return_date, start_odometer, end_odometer, status\n")
    for b in bookings:
        out.append(f"INSERT INTO booking VALUES ({b['id']}, {b['cust']}, {b['veh']}, {b['emp']}, {b['pick']}, {b['ret']}, "
                   f"{d(b['booked'].strftime('%Y-%m-%d'))},\n"
                   f"  {dtm(b['start'])}, {dtm(b['end'])},\n"
                   f"  {dtm(b['actual']) if b['actual'] else 'NULL'}, {num(b['so'])}, {num(b['eo'])}, {q(b['status'])});\n")
    out.append("\n--## INS_PAYMENT\n"
               "-- Columns: payment_id, booking_id, amount, payment_date, method, payment_type, txn_status\n")
    for p in payments:
        out.append(f"INSERT INTO payment VALUES ({p[0]}, {p[1]}, {num(p[2])}, {dtm(p[3])}, {q(p[4])}, {q(p[5])}, {q(p[6])});\n")
    out.append("\n--## INS_MAINT\n")
    for m in MAINTENANCE:
        if m[5] is None:
            out.append("-- cost is left out, so DEFAULT 0 is used (the job has not been done yet)\n")
            out.append(f"INSERT INTO maintenance (maint_id, vehicle_id, service_date, service_type, description, maint_status)\n"
                       f"  VALUES ({m[0]}, {m[1]}, {d(m[2])}, {q(m[3])}, {q(m[4])}, {q(m[6])});\n")
        else:
            out.append(f"INSERT INTO maintenance VALUES ({m[0]}, {m[1]}, {d(m[2])}, {q(m[3])}, {q(m[4])}, {m[5]}, {q(m[6])});\n")
    rented = sorted(v for v, s in status.items() if s == 'RENTED')
    maint = sorted(v for v, s in status.items() if s == 'MAINTENANCE')
    out.append("\n--## INS_STATUS\n-- Current vehicle states: two vehicles are out on rent, one is in the workshop, one is retired\n")
    out.append(f"UPDATE vehicle SET status = 'RENTED'      WHERE vehicle_id IN ({', '.join(map(str, rented))});\n")
    out.append(f"UPDATE vehicle SET status = 'MAINTENANCE' WHERE vehicle_id IN ({', '.join(map(str, maint))});\n")
    out.append(f"UPDATE vehicle SET status = 'RETIRED'     WHERE vehicle_id IN ({', '.join(map(str, RETIRED))});\n")
    out.append("\nCOMMIT;\n")
    with open(os.path.join(SQL, '02_insert_data.sql'), 'w') as f:
        f.write(''.join(out))
    print('bookings', len(bookings), 'payments', len(payments))


if __name__ == '__main__':
    main()
