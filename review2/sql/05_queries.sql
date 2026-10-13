-- Vehicle Rental Management System - BCSE302L Review II
-- Section 3: SQL queries. Run after 02_insert_data.sql and BEFORE 06_dml_demo.sql
-- (the DML demo changes a few rows). Run 00_setup_display.sql first for clean output.

--## Q1
SELECT v.vehicle_id, v.reg_number, v.brand, v.model, vc.category_name, vc.daily_rate, b.branch_name
FROM   vehicle v
JOIN   vehicle_category vc ON vc.category_id = v.category_id
JOIN   branch b            ON b.branch_id    = v.branch_id
WHERE  b.city   = 'Chennai'
AND    v.status = 'AVAILABLE'
AND    NOT EXISTS (SELECT 1 FROM booking bk
                   WHERE  bk.vehicle_id = v.vehicle_id
                   AND    bk.status IN ('BOOKED', 'ONGOING')
                   AND    bk.start_date < TO_DATE('2026-10-23 10:00', 'YYYY-MM-DD HH24:MI')
                   AND    bk.end_date   > TO_DATE('2026-10-21 10:00', 'YYYY-MM-DD HH24:MI'))
ORDER  BY vc.daily_rate;

--## Q2
SELECT b.branch_name,
       COUNT(v.vehicle_id)                                     AS fleet,
       SUM(CASE WHEN v.status = 'AVAILABLE'   THEN 1 ELSE 0 END) AS available,
       SUM(CASE WHEN v.status = 'RENTED'      THEN 1 ELSE 0 END) AS rented,
       SUM(CASE WHEN v.status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS in_maint,
       SUM(CASE WHEN v.status = 'RETIRED'     THEN 1 ELSE 0 END) AS retired
FROM   branch b
LEFT JOIN vehicle v ON v.branch_id = b.branch_id
GROUP  BY b.branch_id, b.branch_name
ORDER  BY b.branch_id;

--## Q3
SELECT br.branch_name,
       COUNT(DISTINCT bk.booking_id) AS bookings,
       SUM(CASE WHEN p.payment_type = 'REFUND' THEN -p.amount ELSE p.amount END) AS net_revenue
FROM   payment p
JOIN   booking bk ON bk.booking_id = p.booking_id
JOIN   branch  br ON br.branch_id  = bk.pickup_branch_id
WHERE  p.txn_status = 'SUCCESS'
GROUP  BY br.branch_name
ORDER  BY net_revenue DESC;

--## Q4
SELECT TO_CHAR(payment_date, 'YYYY-MM') AS month,
       SUM(CASE WHEN payment_type = 'ADVANCE'  THEN amount ELSE 0 END) AS advance,
       SUM(CASE WHEN payment_type = 'FINAL'    THEN amount ELSE 0 END) AS final,
       SUM(CASE WHEN payment_type = 'LATE_FEE' THEN amount ELSE 0 END) AS late_fee,
       SUM(CASE WHEN payment_type = 'REFUND'   THEN amount ELSE 0 END) AS refund
FROM   payment
WHERE  txn_status = 'SUCCESS'
GROUP  BY TO_CHAR(payment_date, 'YYYY-MM')
ORDER  BY month;

--## Q5
SELECT *
FROM  (SELECT c.customer_id, c.name, COUNT(DISTINCT bk.booking_id) AS bookings,
              SUM(p.amount) AS total_paid
       FROM   customer c
       JOIN   booking bk ON bk.customer_id = c.customer_id
       JOIN   payment p  ON p.booking_id   = bk.booking_id
       WHERE  p.txn_status = 'SUCCESS' AND p.payment_type <> 'REFUND'
       GROUP  BY c.customer_id, c.name
       ORDER  BY total_paid DESC)
WHERE  ROWNUM <= 3;

--## Q6
SELECT c.customer_id, c.name, SUM(p.amount) AS total_paid
FROM   customer c
JOIN   booking bk ON bk.customer_id = c.customer_id
JOIN   payment p  ON p.booking_id   = bk.booking_id
WHERE  p.txn_status = 'SUCCESS' AND p.payment_type <> 'REFUND'
GROUP  BY c.customer_id, c.name
HAVING SUM(p.amount) > (SELECT AVG(t.spent)
                        FROM  (SELECT SUM(p2.amount) AS spent
                               FROM   payment p2
                               JOIN   booking b2 ON b2.booking_id = p2.booking_id
                               WHERE  p2.txn_status = 'SUCCESS' AND p2.payment_type <> 'REFUND'
                               GROUP  BY b2.customer_id) t)
ORDER  BY total_paid DESC;

--## Q7
SELECT customer_id, name, phone FROM customer
MINUS
SELECT c.customer_id, c.name, c.phone
FROM   customer c JOIN booking bk ON bk.customer_id = c.customer_id;

--## Q8
SELECT vc.category_name,
       COUNT(DISTINCT v.vehicle_id)                     AS vehicles,
       COUNT(bk.booking_id)                             AS rentals,
       ROUND(AVG(bk.end_date - bk.start_date), 1)       AS avg_days,
       ROUND(AVG(bk.end_odometer - bk.start_odometer))  AS avg_km
FROM   vehicle_category vc
LEFT JOIN vehicle v  ON v.category_id = vc.category_id
LEFT JOIN booking bk ON bk.vehicle_id = v.vehicle_id AND bk.status = 'COMPLETED'
GROUP  BY vc.category_name
ORDER  BY rentals DESC, vc.category_name;

--## Q9
SELECT bk.booking_id, c.name AS customer, v.reg_number,
       pb.branch_name AS pickup_branch, rb.branch_name AS return_branch, bk.status
FROM   booking bk
JOIN   customer c ON c.customer_id = bk.customer_id
JOIN   vehicle  v ON v.vehicle_id  = bk.vehicle_id
JOIN   branch  pb ON pb.branch_id  = bk.pickup_branch_id
JOIN   branch  rb ON rb.branch_id  = bk.return_branch_id
WHERE  bk.pickup_branch_id <> bk.return_branch_id
ORDER  BY bk.booking_id;

--## Q10
SELECT bk.booking_id, c.name AS customer, bk.end_date, bk.actual_return_date,
       CEIL(ROUND((bk.actual_return_date - bk.end_date) * 1440) / 60) AS hours_late,
       vc.late_fee_per_hr,
       NVL(SUM(p.amount), 0) AS fee_billed
FROM   booking bk
JOIN   customer c          ON c.customer_id  = bk.customer_id
JOIN   vehicle v           ON v.vehicle_id   = bk.vehicle_id
JOIN   vehicle_category vc ON vc.category_id = v.category_id
LEFT JOIN payment p        ON p.booking_id   = bk.booking_id AND p.payment_type = 'LATE_FEE'
WHERE  bk.actual_return_date > bk.end_date
GROUP  BY bk.booking_id, c.name, bk.end_date, bk.actual_return_date, vc.late_fee_per_hr
ORDER  BY bk.booking_id;

--## Q11
SELECT p.payment_id, p.booking_id, c.name AS customer, v.reg_number,
       p.payment_type, p.amount, p.txn_status
FROM   payment p
JOIN   booking  bk ON bk.booking_id = p.booking_id
JOIN   customer c  ON c.customer_id = bk.customer_id
JOIN   vehicle  v  ON v.vehicle_id  = bk.vehicle_id
WHERE  p.txn_status IN ('PENDING', 'FAILED')
ORDER  BY p.payment_id;

--## Q12
SELECT bk.booking_id, c.name AS customer, bk.start_date,
       MAX(CASE WHEN p.payment_type = 'REFUND' THEN p.payment_date END) AS cancelled_on,
       SUM(CASE WHEN p.payment_type = 'ADVANCE' THEN p.amount ELSE 0 END) AS advance,
       SUM(CASE WHEN p.payment_type = 'REFUND'  THEN p.amount ELSE 0 END) AS refund
FROM   booking bk
JOIN   customer c ON c.customer_id = bk.customer_id
LEFT JOIN payment p ON p.booking_id = bk.booking_id
WHERE  bk.status = 'CANCELLED'
GROUP  BY bk.booking_id, c.name, bk.start_date
ORDER  BY bk.booking_id;

--## Q13
SELECT v.reg_number, v.brand || ' ' || v.model AS vehicle,
       COUNT(m.maint_id)  AS jobs,
       NVL(SUM(m.cost), 0) AS total_cost
FROM   vehicle v
LEFT JOIN maintenance m ON m.vehicle_id = v.vehicle_id
GROUP  BY v.reg_number, v.brand, v.model
HAVING NVL(SUM(m.cost), 0) > 5000
ORDER  BY total_cost DESC;

--## Q14
SELECT v.reg_number, v.brand || ' ' || v.model AS vehicle, 'RENTED' AS state,
       'With ' || c.name || ', due ' || TO_CHAR(bk.end_date, 'DD-Mon HH24:MI') AS details
FROM   vehicle v
JOIN   booking  bk ON bk.vehicle_id = v.vehicle_id AND bk.status = 'ONGOING'
JOIN   customer c  ON c.customer_id = bk.customer_id
UNION ALL
SELECT v.reg_number, v.brand || ' ' || v.model, 'MAINTENANCE',
       m.service_type || ': ' || m.description
FROM   vehicle v
JOIN   maintenance m ON m.vehicle_id = v.vehicle_id AND m.maint_status = 'IN_PROGRESS';

--## Q15
SELECT e.emp_id, e.name AS employee, br.branch_name, COUNT(bk.booking_id) AS bookings_handled
FROM   employee e
JOIN   branch br ON br.branch_id = e.branch_id
LEFT JOIN booking bk ON bk.emp_id = e.emp_id
WHERE  e.role = 'AGENT'
GROUP  BY e.emp_id, e.name, br.branch_name
HAVING COUNT(bk.booking_id) >= 2
ORDER  BY bookings_handled DESC, e.emp_id;

--## Q16
SELECT customer_id, name, phone, license_no, license_expiry,
       TRUNC(license_expiry - SYSDATE) AS days_left
FROM   customer
WHERE  license_expiry BETWEEN SYSDATE AND ADD_MONTHS(SYSDATE, 12)
ORDER  BY license_expiry;
