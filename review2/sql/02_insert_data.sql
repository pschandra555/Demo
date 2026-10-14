-- Vehicle Rental Management System - BCSE302L Review II
-- Generated from tools/make_sql.py (do not edit by hand; edit tools/model.py instead)

SET DEFINE OFF
--## INS_BRANCH
INSERT INTO branch VALUES (1, 'DriveEase Chennai Central', 'Chennai', '12 Anna Salai, Chennai', '9840100001', 'chennai.central@driveease.in');
INSERT INTO branch VALUES (2, 'DriveEase Chennai Airport', 'Chennai', 'GST Road, Meenambakkam, Chennai', '9840100002', 'chennai.airport@driveease.in');
INSERT INTO branch VALUES (3, 'DriveEase Bengaluru MG Road', 'Bengaluru', '45 MG Road, Bengaluru', '9840100003', 'blr.mgroad@driveease.in');
INSERT INTO branch VALUES (4, 'DriveEase Bengaluru Whitefield', 'Bengaluru', 'ITPL Main Road, Whitefield, Bengaluru', '9840100004', 'blr.whitefield@driveease.in');
INSERT INTO branch VALUES (5, 'DriveEase Hyderabad Hitech City', 'Hyderabad', 'Madhapur Main Road, Hyderabad', '9840100005', 'hyd.hitech@driveease.in');
INSERT INTO branch VALUES (6, 'DriveEase Secunderabad', 'Hyderabad', 'SP Road, Secunderabad', '9840100006', 'hyd.secunderabad@driveease.in');
INSERT INTO branch VALUES (7, 'DriveEase Coimbatore', 'Coimbatore', 'DB Road, RS Puram, Coimbatore', '9840100007', 'coimbatore@driveease.in');
INSERT INTO branch VALUES (8, 'DriveEase Vellore Katpadi', 'Vellore', 'Katpadi Main Road, Vellore', '9840100008', 'vellore@driveease.in');
INSERT INTO branch VALUES (9, 'DriveEase Pune Shivajinagar', 'Pune', 'FC Road, Shivajinagar, Pune', '9840100009', 'pune@driveease.in');
INSERT INTO branch VALUES (10, 'DriveEase Kochi Edappally', 'Kochi', 'NH 66, Edappally, Kochi', '9840100010', 'kochi@driveease.in');

--## INS_CATEGORY
INSERT INTO vehicle_category VALUES (1, 'Hatchback', 1500, 150, 5, 2000);
INSERT INTO vehicle_category VALUES (2, 'Sedan', 2200, 200, 5, 3000);
INSERT INTO vehicle_category VALUES (3, 'Compact SUV', 2800, 250, 5, 4000);
INSERT INTO vehicle_category VALUES (4, 'SUV', 3500, 300, 7, 5000);
INSERT INTO vehicle_category VALUES (5, 'MUV', 3200, 300, 7, 5000);
INSERT INTO vehicle_category VALUES (6, 'Luxury Sedan', 6000, 500, 5, 10000);
INSERT INTO vehicle_category VALUES (7, 'Electric Car', 3000, 250, 5, 5000);
INSERT INTO vehicle_category VALUES (8, 'Tempo Traveller', 5500, 450, 12, 8000);
INSERT INTO vehicle_category VALUES (9, 'Scooter', 500, 50, 2, 1000);
-- Motorbike: late_fee_per_hr and security_deposit are left out, so the DEFAULT values (100, 2000) are used
INSERT INTO vehicle_category (category_id, category_name, daily_rate, seating_capacity)
  VALUES (10, 'Motorbike', 800, 2);

--## INS_VEHICLE
-- Odometer and branch are the current values (after the rentals loaded below).
-- Every vehicle starts as AVAILABLE; current RENTED/MAINTENANCE/RETIRED states are set at the end.
INSERT INTO vehicle VALUES (1, 'TN09AB1001', 'Maruti Suzuki', 'Swift', 2022, 'PETROL', 'MANUAL', 28530, 'AVAILABLE', 1, 1);
INSERT INTO vehicle VALUES (2, 'TN09AB1002', 'Hyundai', 'Creta', 2023, 'DIESEL', 'AUTOMATIC', 15350, 'AVAILABLE', 3, 3);
INSERT INTO vehicle VALUES (3, 'TN22CD2003', 'Toyota', 'Innova Crysta', 2021, 'DIESEL', 'MANUAL', 42780, 'AVAILABLE', 5, 2);
INSERT INTO vehicle VALUES (4, 'KA01EF3004', 'Honda', 'City', 2022, 'PETROL', 'AUTOMATIC', 18560, 'AVAILABLE', 2, 1);
INSERT INTO vehicle VALUES (5, 'KA03GH4005', 'Tata', 'Nexon EV', 2023, 'ELECTRIC', 'AUTOMATIC', 6290, 'AVAILABLE', 7, 4);
INSERT INTO vehicle VALUES (6, 'TS09JK5006', 'Toyota', 'Fortuner', 2022, 'DIESEL', 'AUTOMATIC', 31660, 'AVAILABLE', 4, 6);
INSERT INTO vehicle VALUES (7, 'TS10LM6007', 'Hyundai', 'i20', 2021, 'PETROL', 'MANUAL', 52140, 'AVAILABLE', 1, 6);
INSERT INTO vehicle VALUES (8, 'TN37NP7008', 'Maruti Suzuki', 'Dzire', 2022, 'CNG', 'MANUAL', 24190, 'AVAILABLE', 2, 7);
INSERT INTO vehicle VALUES (9, 'TN23QR8009', 'Mahindra', 'XUV700', 2023, 'DIESEL', 'MANUAL', 12400, 'AVAILABLE', 4, 8);
INSERT INTO vehicle VALUES (10, 'MH12ST9010', 'Mercedes-Benz', 'E-Class', 2023, 'PETROL', 'AUTOMATIC', 8260, 'AVAILABLE', 6, 9);
INSERT INTO vehicle VALUES (11, 'KL07UV1011', 'Force', 'Traveller', 2021, 'DIESEL', 'MANUAL', 61620, 'AVAILABLE', 8, 10);
INSERT INTO vehicle VALUES (12, 'TN09WX1012', 'Honda', 'Activa 6G', 2023, 'PETROL', 'AUTOMATIC', 9060, 'AVAILABLE', 9, 1);
INSERT INTO vehicle VALUES (13, 'KA01YZ1013', 'Royal Enfield', 'Classic 350', 2022, 'PETROL', 'MANUAL', 14180, 'AVAILABLE', 10, 3);
INSERT INTO vehicle VALUES (14, 'TN07AA0014', 'Tata', 'Indica', 2012, 'DIESEL', 'MANUAL', 189000, 'AVAILABLE', 1, 2);

--## INS_CUSTOMER
INSERT INTO customer VALUES (1, 'Aditya Raman', '9841000101', 'aditya.raman@gmail.com', 'TN0920180012345', DATE '2038-03-13', DATE '1996-03-14', 'Adyar, Chennai', DATE '2026-01-12');
INSERT INTO customer VALUES (2, 'Meera Krishnan', '9841000102', 'meera.k@gmail.com', 'TN0120120034567', DATE '2032-07-21', DATE '1990-07-22', 'T Nagar, Chennai', DATE '2026-02-03');
INSERT INTO customer VALUES (3, 'Rahul Menon', '9841000103', 'rahul.menon@yahoo.com', 'KA0120100056789', DATE '2030-11-04', DATE '1988-11-05', 'Indiranagar, Bengaluru', DATE '2026-02-18');
INSERT INTO customer VALUES (4, 'Sneha Pillai', '9841000104', 'sneha.pillai@gmail.com', 'KA0320190011223', DATE '2027-04-30', DATE '2001-01-18', 'Whitefield, Bengaluru', DATE '2026-03-07');
INSERT INTO customer VALUES (5, 'Vikram Reddy', '9841000105', 'vikram.reddy@outlook.com', 'TS0920150022334', DATE '2035-09-08', DATE '1993-09-09', 'Madhapur, Hyderabad', DATE '2026-03-22');
INSERT INTO customer VALUES (6, 'Kavya Iyer', '9841000106', 'kavya.iyer@gmail.com', 'TS1020200033445', DATE '2039-12-29', DATE '1999-12-30', 'Begumpet, Hyderabad', DATE '2026-04-10');
INSERT INTO customer VALUES (7, 'Harish Kumar', '9841000107', 'harish.kumar@gmail.com', 'TN2220080044556', DATE '2030-04-16', DATE '1985-04-17', 'Tambaram, Chennai', DATE '2026-04-25');
INSERT INTO customer VALUES (8, 'Divya Nair', '9841000108', 'divya.nair@gmail.com', 'TN3720210055667', DATE '2027-08-31', DATE '2002-06-25', 'RS Puram, Coimbatore', DATE '2026-05-09');
INSERT INTO customer VALUES (9, 'Sanjay Kulkarni', '9841000109', 'sanjay.k@gmail.com', 'MH1220050066778', DATE '2031-02-10', DATE '1979-02-11', 'Kothrud, Pune', DATE '2026-05-28');
INSERT INTO customer VALUES (10, 'Farhan Ali', '9841000110', 'farhan.ali@gmail.com', 'TN2320160077889', DATE '2036-08-07', DATE '1995-08-08', 'Katpadi, Vellore', DATE '2026-06-14');
INSERT INTO customer VALUES (11, 'Anjali Thomas', '9841000111', 'anjali.thomas@gmail.com', 'KL0720130088990', DATE '2033-09-30', DATE '1991-10-01', 'Edappally, Kochi', DATE '2026-07-02');
INSERT INTO customer VALUES (12, 'Karthik Sundar', '9841000112', 'karthik.sundar@gmail.com', 'TN0920210099001', DATE '2040-05-19', DATE '2000-05-20', 'Velachery, Chennai', DATE '2026-07-19');

--## INS_EMPLOYEE
INSERT INTO employee VALUES (1, 'Ramesh Iyer', 'MANAGER', '9841100001', 'ramesh.iyer@driveease.in', 65000, DATE '2022-04-01', 1);
INSERT INTO employee VALUES (2, 'Divya Menon', 'AGENT', '9841100002', 'divya.menon@driveease.in', 32000, DATE '2023-06-15', 1);
INSERT INTO employee VALUES (3, 'Karthik Subramanian', 'AGENT', '9841100003', 'karthik.s@driveease.in', 30000, DATE '2023-08-01', 2);
INSERT INTO employee VALUES (4, 'Suresh Gowda', 'MANAGER', '9841100004', 'suresh.gowda@driveease.in', 62000, DATE '2022-01-10', 3);
INSERT INTO employee VALUES (5, 'Pooja Rao', 'AGENT', '9841100005', 'pooja.rao@driveease.in', 31000, DATE '2024-02-12', 3);
INSERT INTO employee VALUES (6, 'Anitha Kumar', 'AGENT', '9841100006', 'anitha.kumar@driveease.in', 29500, DATE '2024-05-20', 4);
INSERT INTO employee VALUES (7, 'Lakshmi Reddy', 'AGENT', '9841100007', 'lakshmi.reddy@driveease.in', 30500, DATE '2023-11-06', 5);
INSERT INTO employee VALUES (8, 'Venkat Rao', 'AGENT', '9841100008', 'venkat.rao@driveease.in', 29000, DATE '2024-07-01', 6);
INSERT INTO employee VALUES (9, 'Murali Krishnan', 'AGENT', '9841100009', 'murali.k@driveease.in', 28500, DATE '2024-09-16', 7);
INSERT INTO employee VALUES (10, 'Faisal Khan', 'AGENT', '9841100010', 'faisal.khan@driveease.in', 28000, DATE '2025-01-06', 8);
INSERT INTO employee VALUES (11, 'Arjun Patil', 'AGENT', '9841100011', 'arjun.patil@driveease.in', 31500, DATE '2023-03-13', 9);
INSERT INTO employee VALUES (12, 'Sneha Thomas', 'AGENT', '9841100012', 'sneha.thomas@driveease.in', 29000, DATE '2024-10-21', 10);
INSERT INTO employee VALUES (13, 'Mohan Raj', 'MECHANIC', '9841100013', 'mohan.raj@driveease.in', 27000, DATE '2022-09-05', 1);
INSERT INTO employee VALUES (14, 'Imran Pasha', 'MECHANIC', '9841100014', 'imran.pasha@driveease.in', 26500, DATE '2023-12-11', 3);
INSERT INTO employee VALUES (15, 'Nisha George', 'CASHIER', '9841100015', 'nisha.george@driveease.in', 24000, DATE '2025-03-03', 2);

--## INS_BOOKING
-- Columns: booking_id, customer_id, vehicle_id, emp_id, pickup_branch_id, return_branch_id,
--          booking_date, start_date, end_date, actual_return_date, start_odometer, end_odometer, status
INSERT INTO booking VALUES (1, 1, 1, 2, 1, 1, DATE '2026-07-28',
  TO_DATE('2026-08-02 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-04 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-04 08:30', 'YYYY-MM-DD HH24:MI'), 28000, 28380, 'COMPLETED');
INSERT INTO booking VALUES (2, 2, 2, 2, 1, 3, DATE '2026-08-01',
  TO_DATE('2026-08-05 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-08 10:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-08 14:00', 'YYYY-MM-DD HH24:MI'), 15000, 15350, 'COMPLETED');
INSERT INTO booking VALUES (3, 3, 4, 5, 3, 3, DATE '2026-08-06',
  TO_DATE('2026-08-10 11:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-12 11:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-12 11:00', 'YYYY-MM-DD HH24:MI'), 18000, 18210, 'COMPLETED');
INSERT INTO booking VALUES (4, 4, 5, 6, 4, 4, DATE '2026-08-10',
  TO_DATE('2026-08-14 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-17 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-17 09:40', 'YYYY-MM-DD HH24:MI'), 6000, 6290, 'COMPLETED');
INSERT INTO booking VALUES (5, 5, 6, 7, 5, 5, DATE '2026-08-15',
  TO_DATE('2026-08-20 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-23 08:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-23 08:00', 'YYYY-MM-DD HH24:MI'), 31000, 31520, 'COMPLETED');
INSERT INTO booking VALUES (6, 6, 7, 8, 6, 6, DATE '2026-08-22',
  TO_DATE('2026-08-25 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-08-26 10:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-08-26 09:30', 'YYYY-MM-DD HH24:MI'), 52000, 52140, 'COMPLETED');
INSERT INTO booking VALUES (7, 7, 3, 3, 2, 2, DATE '2026-08-27',
  TO_DATE('2026-09-01 07:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-05 07:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-05 10:00', 'YYYY-MM-DD HH24:MI'), 42000, 42780, 'COMPLETED');
INSERT INTO booking VALUES (8, 8, 8, 9, 7, 7, DATE '2026-08-30',
  TO_DATE('2026-09-03 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-05 10:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-05 10:00', 'YYYY-MM-DD HH24:MI'), 24000, 24190, 'COMPLETED');
INSERT INTO booking VALUES (9, 9, 10, 11, 9, 9, DATE '2026-09-02',
  TO_DATE('2026-09-08 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-10 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-10 09:00', 'YYYY-MM-DD HH24:MI'), 8000, 8260, 'COMPLETED');
INSERT INTO booking VALUES (10, 1, 1, 2, 1, 1, DATE '2026-09-09',
  TO_DATE('2026-09-12 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-13 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-13 09:00', 'YYYY-MM-DD HH24:MI'), 28380, 28530, 'COMPLETED');
INSERT INTO booking VALUES (11, 3, 12, 2, 1, 1, DATE '2026-09-13',
  TO_DATE('2026-09-15 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-16 08:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-16 08:00', 'YYYY-MM-DD HH24:MI'), 9000, 9060, 'COMPLETED');
INSERT INTO booking VALUES (12, 10, 9, 10, 8, 8, DATE '2026-09-14',
  TO_DATE('2026-09-18 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-21 10:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-21 13:00', 'YYYY-MM-DD HH24:MI'), 12000, 12400, 'COMPLETED');
INSERT INTO booking VALUES (13, 2, 13, 5, 3, 3, DATE '2026-09-19',
  TO_DATE('2026-09-22 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-24 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-24 09:00', 'YYYY-MM-DD HH24:MI'), 14000, 14180, 'COMPLETED');
INSERT INTO booking VALUES (14, 11, 11, 12, 10, 10, DATE '2026-09-20',
  TO_DATE('2026-09-26 06:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-09-29 06:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-09-29 06:00', 'YYYY-MM-DD HH24:MI'), 61000, 61620, 'COMPLETED');
INSERT INTO booking VALUES (15, 5, 4, 5, 3, 1, DATE '2026-09-27',
  TO_DATE('2026-10-01 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-03 09:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-10-03 09:00', 'YYYY-MM-DD HH24:MI'), 18210, 18560, 'COMPLETED');
INSERT INTO booking VALUES (16, 4, 6, 7, 5, 6, DATE '2026-09-28',
  TO_DATE('2026-10-02 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-04 10:00', 'YYYY-MM-DD HH24:MI'),
  TO_DATE('2026-10-04 12:00', 'YYYY-MM-DD HH24:MI'), 31520, 31660, 'COMPLETED');
INSERT INTO booking VALUES (17, 6, 5, 6, 4, 4, DATE '2026-10-05',
  TO_DATE('2026-10-08 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-10 09:00', 'YYYY-MM-DD HH24:MI'),
  NULL, 6290, NULL, 'ONGOING');
INSERT INTO booking VALUES (18, 8, 2, 5, 3, 3, DATE '2026-10-08',
  TO_DATE('2026-10-11 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-15 10:00', 'YYYY-MM-DD HH24:MI'),
  NULL, 15350, NULL, 'ONGOING');
INSERT INTO booking VALUES (19, 9, 1, 2, 1, 1, DATE '2026-10-12',
  TO_DATE('2026-10-20 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-22 10:00', 'YYYY-MM-DD HH24:MI'),
  NULL, NULL, NULL, 'BOOKED');
INSERT INTO booking VALUES (20, 7, 10, 11, 9, 9, DATE '2026-10-12',
  TO_DATE('2026-10-25 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-27 09:00', 'YYYY-MM-DD HH24:MI'),
  NULL, NULL, NULL, 'BOOKED');
INSERT INTO booking VALUES (21, 3, 3, 3, 2, 2, DATE '2026-09-30',
  TO_DATE('2026-10-05 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-07 10:00', 'YYYY-MM-DD HH24:MI'),
  NULL, NULL, NULL, 'CANCELLED');
INSERT INTO booking VALUES (22, 11, 8, 9, 7, 7, DATE '2026-10-06',
  TO_DATE('2026-10-09 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-10-11 08:00', 'YYYY-MM-DD HH24:MI'),
  NULL, NULL, NULL, 'CANCELLED');

--## INS_PAYMENT
-- Columns: payment_id, booking_id, amount, payment_date, method, payment_type, txn_status
INSERT INTO payment VALUES (1, 1, 1000, TO_DATE('2026-07-28 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (2, 2, 3000, TO_DATE('2026-08-01 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (3, 1, 2000, TO_DATE('2026-08-04 08:30', 'YYYY-MM-DD HH24:MI'), 'UPI', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (4, 3, 1000, TO_DATE('2026-08-06 11:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (5, 2, 5400, TO_DATE('2026-08-08 14:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (6, 2, 1000, TO_DATE('2026-08-08 14:01', 'YYYY-MM-DD HH24:MI'), 'CARD', 'LATE_FEE', 'SUCCESS');
INSERT INTO payment VALUES (7, 4, 2000, TO_DATE('2026-08-10 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (8, 3, 3400, TO_DATE('2026-08-12 11:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (9, 5, 3000, TO_DATE('2026-08-15 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (10, 4, 7000, TO_DATE('2026-08-17 09:40', 'YYYY-MM-DD HH24:MI'), 'UPI', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (11, 4, 250, TO_DATE('2026-08-17 09:41', 'YYYY-MM-DD HH24:MI'), 'UPI', 'LATE_FEE', 'SUCCESS');
INSERT INTO payment VALUES (12, 6, 500, TO_DATE('2026-08-22 11:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (13, 5, 7500, TO_DATE('2026-08-23 08:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (14, 6, 1000, TO_DATE('2026-08-26 09:30', 'YYYY-MM-DD HH24:MI'), 'CASH', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (15, 7, 4000, TO_DATE('2026-08-27 11:00', 'YYYY-MM-DD HH24:MI'), 'NETBANKING', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (16, 8, 1000, TO_DATE('2026-08-30 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (17, 9, 5000, TO_DATE('2026-09-02 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (18, 7, 8800, TO_DATE('2026-09-05 10:00', 'YYYY-MM-DD HH24:MI'), 'NETBANKING', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (19, 8, 3400, TO_DATE('2026-09-05 10:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (20, 7, 900, TO_DATE('2026-09-05 10:01', 'YYYY-MM-DD HH24:MI'), 'NETBANKING', 'LATE_FEE', 'SUCCESS');
INSERT INTO payment VALUES (21, 10, 500, TO_DATE('2026-09-09 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (22, 9, 7000, TO_DATE('2026-09-10 09:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (23, 10, 1000, TO_DATE('2026-09-13 09:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (24, 11, 200, TO_DATE('2026-09-13 11:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (25, 12, 3000, TO_DATE('2026-09-14 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (26, 11, 300, TO_DATE('2026-09-16 08:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (27, 13, 400, TO_DATE('2026-09-19 11:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (28, 14, 5000, TO_DATE('2026-09-20 11:00', 'YYYY-MM-DD HH24:MI'), 'NETBANKING', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (29, 12, 7500, TO_DATE('2026-09-21 13:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (30, 12, 900, TO_DATE('2026-09-21 13:01', 'YYYY-MM-DD HH24:MI'), 'UPI', 'LATE_FEE', 'PENDING');
INSERT INTO payment VALUES (31, 13, 1200, TO_DATE('2026-09-24 09:00', 'YYYY-MM-DD HH24:MI'), 'CASH', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (32, 15, 1000, TO_DATE('2026-09-27 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (33, 16, 3000, TO_DATE('2026-09-28 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (34, 14, 11500, TO_DATE('2026-09-29 06:00', 'YYYY-MM-DD HH24:MI'), 'NETBANKING', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (35, 21, 2000, TO_DATE('2026-09-30 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (36, 21, 2000, TO_DATE('2026-10-02 18:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'REFUND', 'SUCCESS');
INSERT INTO payment VALUES (37, 15, 3400, TO_DATE('2026-10-03 09:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'FINAL', 'SUCCESS');
INSERT INTO payment VALUES (38, 16, 4000, TO_DATE('2026-10-04 12:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'FINAL', 'FAILED');
INSERT INTO payment VALUES (39, 16, 600, TO_DATE('2026-10-04 12:01', 'YYYY-MM-DD HH24:MI'), 'CARD', 'LATE_FEE', 'SUCCESS');
INSERT INTO payment VALUES (40, 17, 2000, TO_DATE('2026-10-05 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (41, 22, 1000, TO_DATE('2026-10-06 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (42, 18, 3000, TO_DATE('2026-10-08 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (43, 22, 500, TO_DATE('2026-10-09 03:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'REFUND', 'SUCCESS');
INSERT INTO payment VALUES (44, 19, 1000, TO_DATE('2026-10-12 11:00', 'YYYY-MM-DD HH24:MI'), 'UPI', 'ADVANCE', 'SUCCESS');
INSERT INTO payment VALUES (45, 20, 4000, TO_DATE('2026-10-12 11:00', 'YYYY-MM-DD HH24:MI'), 'CARD', 'ADVANCE', 'PENDING');

--## INS_MAINT
INSERT INTO maintenance VALUES (1, 1, DATE '2026-07-20', 'GENERAL', 'Periodic service and oil change', 3500, 'DONE');
INSERT INTO maintenance VALUES (2, 2, DATE '2026-07-25', 'TYRE', 'Front tyre replacement', 8200, 'DONE');
INSERT INTO maintenance VALUES (3, 3, DATE '2026-08-28', 'GENERAL', '40000 km service', 4500, 'DONE');
INSERT INTO maintenance VALUES (4, 4, DATE '2026-08-20', 'REPAIR', 'AC compressor repair', 6800, 'DONE');
INSERT INTO maintenance VALUES (5, 5, DATE '2026-09-02', 'REPAIR', 'Battery coolant pump replaced', 12500, 'DONE');
INSERT INTO maintenance VALUES (6, 6, DATE '2026-09-10', 'GENERAL', 'Periodic service', 5200, 'DONE');
INSERT INTO maintenance VALUES (7, 7, DATE '2026-09-14', 'TYRE', 'All four tyres replaced', 14400, 'DONE');
INSERT INTO maintenance VALUES (8, 9, DATE '2026-09-05', 'ACCIDENT', 'Front bumper repair after minor collision', 18500, 'DONE');
INSERT INTO maintenance VALUES (9, 10, DATE '2026-09-15', 'INSURANCE', 'Annual insurance renewal', 42000, 'DONE');
INSERT INTO maintenance VALUES (10, 13, DATE '2026-10-02', 'GENERAL', 'Chain and brake service', 1800, 'DONE');
INSERT INTO maintenance VALUES (11, 8, DATE '2026-10-10', 'REPAIR', 'Clutch plate replacement', 9500, 'IN_PROGRESS');
-- cost is left out, so DEFAULT 0 is used (the job has not been done yet)
INSERT INTO maintenance (maint_id, vehicle_id, service_date, service_type, description, maint_status)
  VALUES (12, 11, DATE '2026-10-18', 'TYRE', 'Rear tyre change', 'SCHEDULED');

--## INS_STATUS
-- Current vehicle states: two vehicles are out on rent, one is in the workshop, one is retired
UPDATE vehicle SET status = 'RENTED'      WHERE vehicle_id IN (2, 5);
UPDATE vehicle SET status = 'MAINTENANCE' WHERE vehicle_id IN (8);
UPDATE vehicle SET status = 'RETIRED'     WHERE vehicle_id IN (14);

COMMIT;
