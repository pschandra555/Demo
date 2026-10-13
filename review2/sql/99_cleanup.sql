-- Vehicle Rental Management System - BCSE302L Review II
-- Removes every object of the project so the scripts can be run again from 01_ddl.sql.
-- Child tables are dropped first. Errors such as ORA-00942 (table does not exist) can be ignored.
DROP TRIGGER trg_maintenance_sync;
DROP TRIGGER trg_booking_status_sync;
DROP TRIGGER trg_booking_validate;
DROP TRIGGER trg_customer_validate;
DROP PROCEDURE sp_pending_dues;
DROP PROCEDURE sp_overdue_report;
DROP PROCEDURE sp_cancel_booking;
DROP PROCEDURE sp_return_vehicle;
DROP PROCEDURE sp_pickup_vehicle;
DROP PROCEDURE sp_create_booking;
DROP PROCEDURE sp_register_customer;
DROP FUNCTION fn_booking_balance;
DROP FUNCTION fn_is_vehicle_free;
DROP FUNCTION fn_late_fee;
DROP FUNCTION fn_calculate_rent;
DROP FUNCTION fn_rental_days;
DROP FUNCTION fn_age;
DROP TABLE maintenance PURGE;
DROP TABLE payment PURGE;
DROP TABLE booking PURGE;
DROP TABLE employee PURGE;
DROP TABLE customer PURGE;
DROP TABLE vehicle PURGE;
DROP TABLE vehicle_category PURGE;
DROP TABLE branch PURGE;
DROP SEQUENCE seq_customer;
DROP SEQUENCE seq_booking;
DROP SEQUENCE seq_payment;
DROP SEQUENCE seq_maintenance;
