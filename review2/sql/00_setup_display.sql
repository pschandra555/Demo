-- Vehicle Rental Management System - BCSE302L Review II
-- Run this once at the start of every SQL*Plus session (before taking screenshots).
-- It only changes how results are displayed; it does not change any data.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 150
SET PAGESIZE 100
SET NUMWIDTH 9
SET FEEDBACK ON
SET DEFINE OFF
SET TAB OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YY HH24:MI';

COLUMN name            FORMAT A18
COLUMN customer        FORMAT A16
COLUMN employee        FORMAT A20
COLUMN phone           FORMAT A10
COLUMN reg_number      FORMAT A10
COLUMN brand           FORMAT A13
COLUMN model           FORMAT A13
COLUMN vehicle         FORMAT A26
COLUMN category_name   FORMAT A15
COLUMN branch_name     FORMAT A31
COLUMN pickup_branch   FORMAT A31
COLUMN return_branch   FORMAT A31
COLUMN status          FORMAT A11
COLUMN state           FORMAT A11
COLUMN details         FORMAT A48
COLUMN transmission    FORMAT A12
COLUMN payment_type    FORMAT A12
COLUMN txn_status      FORMAT A10
COLUMN method          FORMAT A10
COLUMN license_no      FORMAT A15
COLUMN address         FORMAT A20
COLUMN month           FORMAT A7
COLUMN role            FORMAT A8
COLUMN object_name     FORMAT A26
COLUMN object_type     FORMAT A11
COLUMN constraint_kind FORMAT A15
COLUMN table_name      FORMAT A16
COLUMN constraint_name FORMAT A22
COLUMN delete_rule     FORMAT A11
COLUMN fuel_type       FORMAT A9
COLUMN refers_to       FORMAT A17
COLUMN vehicle_status     FORMAT A14
COLUMN start_date         FORMAT A15
COLUMN end_date           FORMAT A15
COLUMN actual_return_date FORMAT A18
COLUMN cancelled_on       FORMAT A15
COLUMN registered_on      FORMAT A15
COLUMN license_expiry     FORMAT A15
COLUMN dob                FORMAT A15
COLUMN payment_date       FORMAT A15
