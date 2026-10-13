"""Single list of every figure in the Review II report.

Each entry drives three things: the placeholder (or real screenshot) in the report,
the figure number/caption, and the row in the screenshot checklist.

key, caption, source (sql file, chunk) or None, placeholder height in cm, run step,
what you should see.
"""

FIGURES = [
    dict(key='er', caption='ER diagram of the Vehicle Rental Management System (same as Review I)',
         image='assets/er-000.png'),

    # ---------- Section 1 ----------
    dict(key='ddl_run', caption='Running 01_ddl.sql: four sequences and eight tables created',
         run='@00_setup_display.sql\n@01_ddl.sql', h=6.0, step=1,
         expect='"Sequence created." 4 times, then "Table created." 8 times. No ORA- errors.'),
    dict(key='sc_desc', caption='Structure of the BOOKING and PAYMENT tables (DESC)',
         src=('03_check_schema_data.sql', 'SC_DESC'), h=8.0, step=3,
         expect='BOOKING: 13 columns, 8 shown as NOT NULL (7 + the primary key). PAYMENT: 7 columns, 5 NOT NULL.'),
    dict(key='sc_count', caption='Number of constraints of each kind, read from USER_CONSTRAINTS',
         src=('03_check_schema_data.sql', 'SC_COUNT'), h=5.5, step=3,
         expect='NOT NULL 34, CHECK 23, FOREIGN KEY 10, UNIQUE 10, PRIMARY KEY 8 (5 rows).'),
    dict(key='sc_fk', caption='The ten foreign keys and the table each one refers to',
         src=('03_check_schema_data.sql', 'SC_FK'), h=5.5, step=3,
         expect='10 rows. FK_PAYMENT_BOOKING shows DELETE_RULE = CASCADE; all others NO ACTION.'),
    dict(key='ct1', caption='Constraint tests 1-4: UNIQUE, CHECK and NOT NULL violations rejected',
         src=('04_constraint_tests.sql', 'CT1'), h=7.0, step=4,
         expect='ORA-00001 (UQ_VEHICLE_REG), ORA-02290 (CK_VEHICLE_FUEL), ORA-02290 (CK_BRANCH_PHONE), '
                'ORA-01400 (CUSTOMER.LICENSE_NO).'),
    dict(key='ct2', caption='Constraint tests 5-8: foreign key and table-level CHECK violations rejected',
         src=('04_constraint_tests.sql', 'CT2'), h=6.5, step=4,
         expect='ORA-02291 (FK_PAYMENT_BOOKING), ORA-02292 (FK_BOOKING_CUSTOMER), ORA-02290 (CK_BOOKING_DATES), '
                'ORA-02290 (CK_BOOKING_ODOMETER), then "Rollback complete."'),

    # ---------- Section 2 ----------
    dict(key='data_counts', caption='Row count of every table after loading 02_insert_data.sql',
         src=('03_check_schema_data.sql', 'DATA_COUNTS'), h=5.5, step=3,
         expect='BRANCH 10, VEHICLE_CATEGORY 10, VEHICLE 14, CUSTOMER 12, EMPLOYEE 15, BOOKING 22, PAYMENT 45, '
                'MAINTENANCE 12.'),
    dict(key='data_vehicle', caption='VEHICLE table after loading: current odometer, status and branch of each vehicle',
         src=('03_check_schema_data.sql', 'DATA_VEHICLE'), h=5.5, step=3,
         expect='14 rows. Vehicles 2 and 5 RENTED, 8 MAINTENANCE, 14 RETIRED, the rest AVAILABLE.'),
    dict(key='data_booking', caption='BOOKING table after loading: 16 completed, 2 ongoing, 2 booked and 2 cancelled rentals',
         src=('03_check_schema_data.sql', 'DATA_BOOKING'), h=7.5, step=3,
         expect='22 rows. Bookings 1-16 COMPLETED, 17-18 ONGOING, 19-20 BOOKED, 21-22 CANCELLED.'),
    dict(key='dml_insert', caption='INSERT: new vehicle 15 added; omitted columns take their DEFAULT values',
         src=('06_dml_demo.sql', 'DML_INSERT'), h=4.0, step=6,
         expect='"1 row created." Row shows TRANSMISSION MANUAL, ODOMETER 0, STATUS AVAILABLE, BRANCH_ID 2.'),
    dict(key='dml_update', caption='UPDATE: salary increment for two agents and change of a customer\'s contact details',
         src=('06_dml_demo.sql', 'DML_UPDATE'), h=7.0, step=6,
         expect='Salaries 32000 -> 35200 and 31000 -> 34100; "2 rows updated."; customer 7 phone 9841999107.'),
    dict(key='dml_delete', caption='DELETE: cancelled booking 22 removed; its two payments are deleted by ON DELETE CASCADE',
         src=('06_dml_demo.sql', 'DML_DELETE'), h=4.5, step=6,
         expect='Payments 41 (ADVANCE 1000) and 43 (REFUND 500) listed, "1 row deleted.", then PAYMENTS_LEFT = 0.'),

    # ---------- Section 3 ----------
    dict(key='q1', caption='Q1 output: vehicles free in Chennai from 21-Oct to 23-Oct', src=('05_queries.sql', 'Q1'), h=5.5, step=5,
         expect='3 rows: vehicle 12 (Activa, 500), 4 (City, 2200), 3 (Innova Crysta, 3200). Vehicle 1 is not listed.'),
    dict(key='q2', caption='Q2 output: fleet status of every branch', src=('05_queries.sql', 'Q2'), h=6.5, step=5,
         expect='10 rows. Hyderabad Hitech City has FLEET 0; Coimbatore has IN_MAINT 1; Chennai Airport has RETIRED 1.'),
    dict(key='q3', caption='Q3 output: net revenue collected by each pickup branch', src=('05_queries.sql', 'Q3'), h=6.0, step=5,
         expect='10 rows, highest Kochi Edappally 16500, lowest Secunderabad 1500.'),
    dict(key='q4', caption='Q4 output: month-wise collection split by payment type', src=('05_queries.sql', 'Q4'), h=5.0, step=5,
         expect='4 rows (2026-07 to 2026-10). 2026-10 shows REFUND 2500.'),
    dict(key='q5', caption='Q5 output: top three customers by amount paid', src=('05_queries.sql', 'Q5'), h=5.0, step=5,
         expect='Anjali Thomas 17500, Vikram Reddy 14900, Harish Kumar 13700.'),
    dict(key='q6', caption='Q6 output: customers who paid more than the average customer', src=('05_queries.sql', 'Q6'), h=6.0, step=5,
         expect='6 rows, from Anjali Thomas 17500 down to Meera Krishnan 11000.'),
    dict(key='q7', caption='Q7 output: registered customers who have never made a booking', src=('05_queries.sql', 'Q7'), h=3.5, step=5,
         expect='1 row: customer 12, Karthik Sundar.'),
    dict(key='q8', caption='Q8 output: rentals, average days and average distance per category', src=('05_queries.sql', 'Q8'), h=6.5, step=5,
         expect='10 rows. Hatchback, SUV and Sedan have 3 rentals each; MUV has AVG_KM 780.'),
    dict(key='q9', caption='Q9 output: one-way rentals with pickup and return branch names', src=('05_queries.sql', 'Q9'), h=4.5, step=5,
         expect='3 rows: bookings 2, 15 and 16.'),
    dict(key='q10', caption='Q10 output: late returns, hours late and late fee billed', src=('05_queries.sql', 'Q10'), h=6.0, step=5,
         expect='5 rows: bookings 2 (4 h, 1000), 4 (1 h, 250), 7 (3 h, 900), 12 (3 h, 900), 16 (2 h, 600).'),
    dict(key='q11', caption='Q11 output: payments that are pending or failed', src=('05_queries.sql', 'Q11'), h=4.5, step=5,
         expect='3 rows: payments 30 (PENDING), 38 (FAILED), 45 (PENDING).'),
    dict(key='q12', caption='Q12 output: cancelled bookings with advance and refund amounts', src=('05_queries.sql', 'Q12'), h=4.5, step=5,
         expect='2 rows: booking 21 advance 2000 refund 2000; booking 22 advance 1000 refund 500.'),
    dict(key='q13', caption='Q13 output: vehicles whose total maintenance cost is above Rs 5000', src=('05_queries.sql', 'Q13'), h=5.5, step=5,
         expect='8 rows, starting with MH12ST9010 (E-Class) 42000.'),
    dict(key='q14', caption='Q14 output: vehicles that are currently out of service and why', src=('05_queries.sql', 'Q14'), h=5.0, step=5,
         expect='3 rows: Nexon EV and Creta RENTED, Dzire MAINTENANCE.'),
    dict(key='q15', caption='Q15 output: agents who handled two or more bookings', src=('05_queries.sql', 'Q15'), h=5.5, step=5,
         expect='7 rows, Divya Menon 5 and Pooja Rao 4 at the top.'),
    dict(key='q16', caption='Q16 output: customers whose licence expires in the next 12 months', src=('05_queries.sql', 'Q16'), h=3.5, step=5,
         expect='2 rows: Sneha Pillai (30-APR-27) and Divya Nair (31-AUG-27). DAYS_LEFT depends on the run date.'),

    # ---------- Section 4 ----------
    dict(key='objects', caption='All functions, procedures and triggers compiled with status VALID',
         src=('11_transactions.sql', 'T_OBJECTS'), h=6.5, step=8,
         expect='17 rows (6 FUNCTION, 7 PROCEDURE, 4 TRIGGER), every STATUS = VALID.'),
    dict(key='funcs1', caption='fn_rental_days, fn_calculate_rent, fn_late_fee and fn_booking_balance used in a query',
         src=('11_transactions.sql', 'T_FUNCS1'), h=5.0, step=8,
         expect='Booking 2: DAYS 3, RENT 8400, LATE_FEE 1000, BALANCE 0. Booking 12: BALANCE 900. Booking 16: BALANCE 4000.'),
    dict(key='funcs2', caption='fn_age for three customers and fn_is_vehicle_free for two vehicles',
         src=('11_transactions.sql', 'T_FUNCS2'), h=5.0, step=8,
         expect='Ages 25, 24, 47 (in Oct 2026). VEHICLE1_FREE = 0 (booking 19 overlaps), VEHICLE12_FREE = 1.'),
    dict(key='register', caption='sp_register_customer: customer 13 registered',
         src=('11_transactions.sql', 'T_REGISTER'), h=4.0, step=8,
         expect='"Customer registered. ID = 13" and the new row for Rohit Verma.'),
    dict(key='book', caption='sp_create_booking: booking 23 created with a Rs 400 advance',
         src=('11_transactions.sql', 'T_BOOK'), h=5.5, step=8,
         expect='"Booking 23 created for vehicle 12. Estimated rent: Rs 1000, advance paid: Rs 400"; status BOOKED; '
                'payment 46 ADVANCE 400 UPI.'),
    dict(key='pickup', caption='sp_pickup_vehicle: booking 23 becomes ONGOING and the vehicle becomes RENTED',
         src=('11_transactions.sql', 'T_PICKUP'), h=4.0, step=8,
         expect='"Booking 23 is now ONGOING. Start odometer: 9060"; VEHICLE_STATUS = RENTED.'),
    dict(key='return', caption='sp_return_vehicle: rent, final payment and late fee for a late one-way return',
         src=('11_transactions.sql', 'T_RETURN'), h=7.0, step=8,
         expect='"Rent: Rs 1000, advance: Rs 400, final payment: Rs 600, late fee: Rs 150"; vehicle 12 AVAILABLE, '
                'BRANCH_ID 2, ODOMETER 9120; payments 46 ADVANCE 400, 47 FINAL 600, 48 LATE_FEE 150.'),
    dict(key='cancel', caption='sp_cancel_booking: full refund for early cancellation, 50% for late cancellation',
         src=('11_transactions.sql', 'T_CANCEL'), h=6.0, step=8,
         expect='Booking 24: refund Rs 400. Booking 25: refund Rs 200. Payments 49-52 listed.'),

    # ---------- Section 5 ----------
    dict(key='overdue', caption='Explicit cursor (sp_overdue_report): rentals past their end time',
         src=('11_transactions.sql', 'T_OVERDUE'), h=3.5, step=8,
         expect='Booking 17 (KA03GH4005, Kavya Iyer) and, after 15-Oct 10:00, booking 18. Hours and fee depend on the run time.'),
    dict(key='dues', caption='Cursor FOR loop (sp_pending_dues): completed bookings with money still to collect',
         src=('11_transactions.sql', 'T_DUES'), h=3.5, step=8,
         expect='Booking 12 Farhan Ali Rs 900, booking 16 Sneha Pillai Rs 4000, total Rs 4900.'),
    dict(key='trg_customer', caption='trg_customer_validate rejects an under-age customer and an expired licence',
         src=('11_transactions.sql', 'T_TRG_CUSTOMER'), h=5.0, step=8,
         expect='ORA-20201 "Customer must be at least 21 years old. Age: 16" and ORA-20202 "Driving licence has expired on 01-JAN-2025".'),
    dict(key='trg_booking', caption='trg_booking_validate rejects a short licence and a vehicle that is already rented',
         src=('11_transactions.sql', 'T_TRG_BOOKING'), h=5.5, step=8,
         expect='ORA-20212 "Driving licence expires on 30-APR-2027, before the rental ends" and '
                'ORA-20213 "Vehicle 5 cannot be booked. Status: RENTED".'),
    dict(key='trg_maint', caption='trg_maintenance_sync: vehicle 8 released, vehicle 3 sent to the workshop, two blocked actions',
         src=('11_transactions.sql', 'T_TRG_MAINT'), h=8.5, step=8,
         expect='Before: 3 AVAILABLE, 8 MAINTENANCE. After: 3 MAINTENANCE, 8 AVAILABLE. Then ORA-20213 (Status: MAINTENANCE) '
                'and ORA-20221.'),

    # ---------- Section 6 ----------
    dict(key='rules', caption='Business-rule violations rejected by the procedures',
         src=('11_transactions.sql', 'T_RULES'), h=8.0, step=8,
         expect='ORA-20103 (already booked), ORA-20102 (wrong branch), ORA-20120 (booking 23 COMPLETED), '
                'ORA-20140 (status ONGOING), ORA-20150 (already registered).'),
]

for i, f in enumerate(FIGURES, start=1):
    f['no'] = i

BY_KEY = {f['key']: f for f in FIGURES}


def fig(key):
    return f"Figure {BY_KEY[key]['no']}"
