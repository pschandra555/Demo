"""Sample data for the Vehicle Rental Management System (Review II).

The schema follows the Review I relational design exactly. All amounts that
depend on business rules (rent, late fee, final payment, refund) are computed
here with the same formulas used by the PL/SQL functions, so the INSERT data
is consistent with the database logic.
"""
from datetime import datetime, timedelta
import math

BRANCHES = [
    # id, name, city, address, phone, email
    (1, 'DriveEase Chennai Central', 'Chennai', '12 Anna Salai, Chennai', '9840100001', 'chennai.central@driveease.in'),
    (2, 'DriveEase Chennai Airport', 'Chennai', 'GST Road, Meenambakkam, Chennai', '9840100002', 'chennai.airport@driveease.in'),
    (3, 'DriveEase Bengaluru MG Road', 'Bengaluru', '45 MG Road, Bengaluru', '9840100003', 'blr.mgroad@driveease.in'),
    (4, 'DriveEase Bengaluru Whitefield', 'Bengaluru', 'ITPL Main Road, Whitefield, Bengaluru', '9840100004', 'blr.whitefield@driveease.in'),
    (5, 'DriveEase Hyderabad Hitech City', 'Hyderabad', 'Madhapur Main Road, Hyderabad', '9840100005', 'hyd.hitech@driveease.in'),
    (6, 'DriveEase Secunderabad', 'Hyderabad', 'SP Road, Secunderabad', '9840100006', 'hyd.secunderabad@driveease.in'),
    (7, 'DriveEase Coimbatore', 'Coimbatore', 'DB Road, RS Puram, Coimbatore', '9840100007', 'coimbatore@driveease.in'),
    (8, 'DriveEase Vellore Katpadi', 'Vellore', 'Katpadi Main Road, Vellore', '9840100008', 'vellore@driveease.in'),
    (9, 'DriveEase Pune Shivajinagar', 'Pune', 'FC Road, Shivajinagar, Pune', '9840100009', 'pune@driveease.in'),
    (10, 'DriveEase Kochi Edappally', 'Kochi', 'NH 66, Edappally, Kochi', '9840100010', 'kochi@driveease.in'),
]

# id, name, daily_rate, late_fee_per_hr (None = DEFAULT), seats, deposit (None = DEFAULT)
CATEGORIES = [
    (1, 'Hatchback', 1500, 150, 5, 2000),
    (2, 'Sedan', 2200, 200, 5, 3000),
    (3, 'Compact SUV', 2800, 250, 5, 4000),
    (4, 'SUV', 3500, 300, 7, 5000),
    (5, 'MUV', 3200, 300, 7, 5000),
    (6, 'Luxury Sedan', 6000, 500, 5, 10000),
    (7, 'Electric Car', 3000, 250, 5, 5000),
    (8, 'Tempo Traveller', 5500, 450, 12, 8000),
    (9, 'Scooter', 500, 50, 2, 1000),
    (10, 'Motorbike', 800, None, 2, None),   # uses DEFAULT 100 and DEFAULT 2000
]
CAT_DEFAULT_LATE_FEE = 100
CAT_DEFAULT_DEPOSIT = 2000

# id, reg, brand, model, year, fuel, transmission, initial odometer, category, home branch
VEHICLES = [
    (1, 'TN09AB1001', 'Maruti Suzuki', 'Swift', 2022, 'PETROL', 'MANUAL', 28000, 1, 1),
    (2, 'TN09AB1002', 'Hyundai', 'Creta', 2023, 'DIESEL', 'AUTOMATIC', 15000, 3, 1),
    (3, 'TN22CD2003', 'Toyota', 'Innova Crysta', 2021, 'DIESEL', 'MANUAL', 42000, 5, 2),
    (4, 'KA01EF3004', 'Honda', 'City', 2022, 'PETROL', 'AUTOMATIC', 18000, 2, 3),
    (5, 'KA03GH4005', 'Tata', 'Nexon EV', 2023, 'ELECTRIC', 'AUTOMATIC', 6000, 7, 4),
    (6, 'TS09JK5006', 'Toyota', 'Fortuner', 2022, 'DIESEL', 'AUTOMATIC', 31000, 4, 5),
    (7, 'TS10LM6007', 'Hyundai', 'i20', 2021, 'PETROL', 'MANUAL', 52000, 1, 6),
    (8, 'TN37NP7008', 'Maruti Suzuki', 'Dzire', 2022, 'CNG', 'MANUAL', 24000, 2, 7),
    (9, 'TN23QR8009', 'Mahindra', 'XUV700', 2023, 'DIESEL', 'MANUAL', 12000, 4, 8),
    (10, 'MH12ST9010', 'Mercedes-Benz', 'E-Class', 2023, 'PETROL', 'AUTOMATIC', 8000, 6, 9),
    (11, 'KL07UV1011', 'Force', 'Traveller', 2021, 'DIESEL', 'MANUAL', 61000, 8, 10),
    (12, 'TN09WX1012', 'Honda', 'Activa 6G', 2023, 'PETROL', 'AUTOMATIC', 9000, 9, 1),
    (13, 'KA01YZ1013', 'Royal Enfield', 'Classic 350', 2022, 'PETROL', 'MANUAL', 14000, 10, 3),
    (14, 'TN07AA0014', 'Tata', 'Indica', 2012, 'DIESEL', 'MANUAL', 189000, 1, 2),
]

# id, name, phone, email, licence, expiry, dob, address, registered_on
CUSTOMERS = [
    (1, 'Aditya Raman', '9841000101', 'aditya.raman@gmail.com', 'TN0920180012345', '2038-03-13', '1996-03-14', 'Adyar, Chennai', '2026-01-12'),
    (2, 'Meera Krishnan', '9841000102', 'meera.k@gmail.com', 'TN0120120034567', '2032-07-21', '1990-07-22', 'T Nagar, Chennai', '2026-02-03'),
    (3, 'Rahul Menon', '9841000103', 'rahul.menon@yahoo.com', 'KA0120100056789', '2030-11-04', '1988-11-05', 'Indiranagar, Bengaluru', '2026-02-18'),
    (4, 'Sneha Pillai', '9841000104', 'sneha.pillai@gmail.com', 'KA0320190011223', '2027-04-30', '2001-01-18', 'Whitefield, Bengaluru', '2026-03-07'),
    (5, 'Vikram Reddy', '9841000105', 'vikram.reddy@outlook.com', 'TS0920150022334', '2035-09-08', '1993-09-09', 'Madhapur, Hyderabad', '2026-03-22'),
    (6, 'Kavya Iyer', '9841000106', 'kavya.iyer@gmail.com', 'TS1020200033445', '2039-12-29', '1999-12-30', 'Begumpet, Hyderabad', '2026-04-10'),
    (7, 'Harish Kumar', '9841000107', 'harish.kumar@gmail.com', 'TN2220080044556', '2030-04-16', '1985-04-17', 'Tambaram, Chennai', '2026-04-25'),
    (8, 'Divya Nair', '9841000108', 'divya.nair@gmail.com', 'TN3720210055667', '2027-08-31', '2002-06-25', 'RS Puram, Coimbatore', '2026-05-09'),
    (9, 'Sanjay Kulkarni', '9841000109', 'sanjay.k@gmail.com', 'MH1220050066778', '2031-02-10', '1979-02-11', 'Kothrud, Pune', '2026-05-28'),
    (10, 'Farhan Ali', '9841000110', 'farhan.ali@gmail.com', 'TN2320160077889', '2036-08-07', '1995-08-08', 'Katpadi, Vellore', '2026-06-14'),
    (11, 'Anjali Thomas', '9841000111', 'anjali.thomas@gmail.com', 'KL0720130088990', '2033-09-30', '1991-10-01', 'Edappally, Kochi', '2026-07-02'),
    (12, 'Karthik Sundar', '9841000112', 'karthik.sundar@gmail.com', 'TN0920210099001', '2040-05-19', '2000-05-20', 'Velachery, Chennai', '2026-07-19'),
]

# id, name, role, phone, email, salary, hire_date, branch
EMPLOYEES = [
    (1, 'Ramesh Iyer', 'MANAGER', '9841100001', 'ramesh.iyer@driveease.in', 65000, '2022-04-01', 1),
    (2, 'Divya Menon', 'AGENT', '9841100002', 'divya.menon@driveease.in', 32000, '2023-06-15', 1),
    (3, 'Karthik Subramanian', 'AGENT', '9841100003', 'karthik.s@driveease.in', 30000, '2023-08-01', 2),
    (4, 'Suresh Gowda', 'MANAGER', '9841100004', 'suresh.gowda@driveease.in', 62000, '2022-01-10', 3),
    (5, 'Pooja Rao', 'AGENT', '9841100005', 'pooja.rao@driveease.in', 31000, '2024-02-12', 3),
    (6, 'Anitha Kumar', 'AGENT', '9841100006', 'anitha.kumar@driveease.in', 29500, '2024-05-20', 4),
    (7, 'Lakshmi Reddy', 'AGENT', '9841100007', 'lakshmi.reddy@driveease.in', 30500, '2023-11-06', 5),
    (8, 'Venkat Rao', 'AGENT', '9841100008', 'venkat.rao@driveease.in', 29000, '2024-07-01', 6),
    (9, 'Murali Krishnan', 'AGENT', '9841100009', 'murali.k@driveease.in', 28500, '2024-09-16', 7),
    (10, 'Faisal Khan', 'AGENT', '9841100010', 'faisal.khan@driveease.in', 28000, '2025-01-06', 8),
    (11, 'Arjun Patil', 'AGENT', '9841100011', 'arjun.patil@driveease.in', 31500, '2023-03-13', 9),
    (12, 'Sneha Thomas', 'AGENT', '9841100012', 'sneha.thomas@driveease.in', 29000, '2024-10-21', 10),
    (13, 'Mohan Raj', 'MECHANIC', '9841100013', 'mohan.raj@driveease.in', 27000, '2022-09-05', 1),
    (14, 'Imran Pasha', 'MECHANIC', '9841100014', 'imran.pasha@driveease.in', 26500, '2023-12-11', 3),
    (15, 'Nisha George', 'CASHIER', '9841100015', 'nisha.george@driveease.in', 24000, '2025-03-03', 2),
]

AGENT_OF_BRANCH = {1: 2, 2: 3, 3: 5, 4: 6, 5: 7, 6: 8, 7: 9, 8: 10, 9: 11, 10: 12}

# Bookings. return_time None = not returned. km = distance driven (completed only).
# extra: dict with advance amount/method, payment overrides, cancel time.
BOOKINGS = [
    # id cust veh pick ret booked       start              end                return             km   status
    (1, 1, 1, 1, 1, '2026-07-28', '2026-08-02 09:00', '2026-08-04 09:00', '2026-08-04 08:30', 380, 'COMPLETED', dict(adv=1000, m='UPI', fm='UPI')),
    (2, 2, 2, 1, 3, '2026-08-01', '2026-08-05 10:00', '2026-08-08 10:00', '2026-08-08 14:00', 350, 'COMPLETED', dict(adv=3000, m='CARD', fm='CARD')),
    (3, 3, 4, 3, 3, '2026-08-06', '2026-08-10 11:00', '2026-08-12 11:00', '2026-08-12 11:00', 210, 'COMPLETED', dict(adv=1000, m='CASH', fm='CASH')),
    (4, 4, 5, 4, 4, '2026-08-10', '2026-08-14 09:00', '2026-08-17 09:00', '2026-08-17 09:40', 290, 'COMPLETED', dict(adv=2000, m='UPI', fm='UPI')),
    (5, 5, 6, 5, 5, '2026-08-15', '2026-08-20 08:00', '2026-08-23 08:00', '2026-08-23 08:00', 520, 'COMPLETED', dict(adv=3000, m='CARD', fm='CARD')),
    (6, 6, 7, 6, 6, '2026-08-22', '2026-08-25 10:00', '2026-08-26 10:00', '2026-08-26 09:30', 140, 'COMPLETED', dict(adv=500, m='CASH', fm='CASH')),
    (7, 7, 3, 2, 2, '2026-08-27', '2026-09-01 07:00', '2026-09-05 07:00', '2026-09-05 10:00', 780, 'COMPLETED', dict(adv=4000, m='NETBANKING', fm='NETBANKING')),
    (8, 8, 8, 7, 7, '2026-08-30', '2026-09-03 10:00', '2026-09-05 10:00', '2026-09-05 10:00', 190, 'COMPLETED', dict(adv=1000, m='UPI', fm='UPI')),
    (9, 9, 10, 9, 9, '2026-09-02', '2026-09-08 09:00', '2026-09-10 09:00', '2026-09-10 09:00', 260, 'COMPLETED', dict(adv=5000, m='CARD', fm='CARD')),
    (10, 1, 1, 1, 1, '2026-09-09', '2026-09-12 09:00', '2026-09-13 09:00', '2026-09-13 09:00', 150, 'COMPLETED', dict(adv=500, m='UPI', fm='UPI')),
    (11, 3, 12, 1, 1, '2026-09-13', '2026-09-15 08:00', '2026-09-16 08:00', '2026-09-16 08:00', 60, 'COMPLETED', dict(adv=200, m='CASH', fm='CASH')),
    (12, 10, 9, 8, 8, '2026-09-14', '2026-09-18 10:00', '2026-09-21 10:00', '2026-09-21 13:00', 400, 'COMPLETED', dict(adv=3000, m='UPI', fm='UPI', late_status='PENDING')),
    (13, 2, 13, 3, 3, '2026-09-19', '2026-09-22 09:00', '2026-09-24 09:00', '2026-09-24 09:00', 180, 'COMPLETED', dict(adv=400, m='CASH', fm='CASH')),
    (14, 11, 11, 10, 10, '2026-09-20', '2026-09-26 06:00', '2026-09-29 06:00', '2026-09-29 06:00', 620, 'COMPLETED', dict(adv=5000, m='NETBANKING', fm='NETBANKING')),
    (15, 5, 4, 3, 1, '2026-09-27', '2026-10-01 09:00', '2026-10-03 09:00', '2026-10-03 09:00', 350, 'COMPLETED', dict(adv=1000, m='CARD', fm='CARD')),
    (16, 4, 6, 5, 6, '2026-09-28', '2026-10-02 10:00', '2026-10-04 10:00', '2026-10-04 12:00', 140, 'COMPLETED', dict(adv=3000, m='UPI', fm='CARD', final_status='FAILED')),
    (17, 6, 5, 4, 4, '2026-10-05', '2026-10-08 09:00', '2026-10-10 09:00', None, 0, 'ONGOING', dict(adv=2000, m='UPI')),
    (18, 8, 2, 3, 3, '2026-10-08', '2026-10-11 10:00', '2026-10-15 10:00', None, 0, 'ONGOING', dict(adv=3000, m='CARD')),
    (19, 9, 1, 1, 1, '2026-10-12', '2026-10-20 10:00', '2026-10-22 10:00', None, 0, 'BOOKED', dict(adv=1000, m='UPI')),
    (20, 7, 10, 9, 9, '2026-10-12', '2026-10-25 09:00', '2026-10-27 09:00', None, 0, 'BOOKED', dict(adv=4000, m='CARD', adv_status='PENDING')),
    (21, 3, 3, 2, 2, '2026-09-30', '2026-10-05 10:00', '2026-10-07 10:00', None, 0, 'CANCELLED', dict(adv=2000, m='CARD', cancel='2026-10-02 18:00')),
    (22, 11, 8, 7, 7, '2026-10-06', '2026-10-09 08:00', '2026-10-11 08:00', None, 0, 'CANCELLED', dict(adv=1000, m='UPI', cancel='2026-10-09 03:00')),
]

# id, vehicle, date, type, description, cost (None = DEFAULT 0), status
MAINTENANCE = [
    (1, 1, '2026-07-20', 'GENERAL', 'Periodic service and oil change', 3500, 'DONE'),
    (2, 2, '2026-07-25', 'TYRE', 'Front tyre replacement', 8200, 'DONE'),
    (3, 3, '2026-08-28', 'GENERAL', '40000 km service', 4500, 'DONE'),
    (4, 4, '2026-08-20', 'REPAIR', 'AC compressor repair', 6800, 'DONE'),
    (5, 5, '2026-09-02', 'REPAIR', 'Battery coolant pump replaced', 12500, 'DONE'),
    (6, 6, '2026-09-10', 'GENERAL', 'Periodic service', 5200, 'DONE'),
    (7, 7, '2026-09-14', 'TYRE', 'All four tyres replaced', 14400, 'DONE'),
    (8, 9, '2026-09-05', 'ACCIDENT', 'Front bumper repair after minor collision', 18500, 'DONE'),
    (9, 10, '2026-09-15', 'INSURANCE', 'Annual insurance renewal', 42000, 'DONE'),
    (10, 13, '2026-10-02', 'GENERAL', 'Chain and brake service', 1800, 'DONE'),
    (11, 8, '2026-10-10', 'REPAIR', 'Clutch plate replacement', 9500, 'IN_PROGRESS'),
    (12, 11, '2026-10-18', 'TYRE', 'Rear tyre change', None, 'SCHEDULED'),
]

RETIRED = [14]


def dt(s):
    return datetime.strptime(s, '%Y-%m-%d %H:%M') if ' ' in s else datetime.strptime(s, '%Y-%m-%d')


def rental_days(start, end):
    minutes = round((end - start).total_seconds() / 60)
    return max(1, math.ceil(minutes / 1440))


def late_hours(end, actual):
    if actual is None:
        return 0
    minutes = round((actual - end).total_seconds() / 60)
    return math.ceil(max(minutes, 0) / 60)


def cat_of(vehicle_id):
    v = next(v for v in VEHICLES if v[0] == vehicle_id)
    return next(c for c in CATEGORIES if c[0] == v[8])


def late_fee_rate(cat):
    return cat[3] if cat[3] is not None else CAT_DEFAULT_LATE_FEE


def build():
    """Return derived state: booking rows, payment rows, final vehicle state."""
    odo = {v[0]: v[7] for v in VEHICLES}
    branch = {v[0]: v[9] for v in VEHICLES}
    status = {v[0]: 'AVAILABLE' for v in VEHICLES}
    bookings, payments = [], []
    pid = 0

    def pay(bid, amount, when, method, ptype, st='SUCCESS'):
        nonlocal pid
        pid += 1
        payments.append((pid, bid, amount, when, method, ptype, st))

    # Bookings are processed in start order so odometers chain correctly
    for b in sorted(BOOKINGS, key=lambda r: dt(r[6])):
        bid, cust, veh, pick, ret, booked, s, e, r, km, st, x = b
        assert branch[veh] == pick, f'booking {bid}: vehicle {veh} not at branch {pick}'
        s, e = dt(s), dt(e)
        r = dt(r) if r else None
        start_odo = end_odo = None
        if st in ('COMPLETED', 'ONGOING'):
            start_odo = odo[veh]
        if st == 'COMPLETED':
            end_odo = start_odo + km
            odo[veh] = end_odo
            branch[veh] = ret
        if st == 'ONGOING':
            status[veh] = 'RENTED'
        bookings.append(dict(id=bid, cust=cust, veh=veh, emp=AGENT_OF_BRANCH[pick], pick=pick, ret=ret,
                             booked=dt(booked), start=s, end=e, actual=r, so=start_odo, eo=end_odo, status=st, x=x))
    bookings.sort(key=lambda d: d['id'])

    # Payments in time order (booking date for advances, return time for final)
    events = []
    for bk in bookings:
        x, cat = bk['x'], cat_of(bk['veh'])
        events.append((bk['booked'] + timedelta(hours=11), bk['id'], x['adv'], x['m'], 'ADVANCE', x.get('adv_status', 'SUCCESS')))
        if bk['status'] == 'COMPLETED':
            rent = rental_days(bk['start'], bk['end']) * cat[2]
            final = rent - x['adv']
            events.append((bk['actual'], bk['id'], final, x['fm'], 'FINAL', x.get('final_status', 'SUCCESS')))
            lh = late_hours(bk['end'], bk['actual'])
            if lh:
                events.append((bk['actual'] + timedelta(minutes=1), bk['id'], lh * late_fee_rate(cat), x['fm'],
                               'LATE_FEE', x.get('late_status', 'SUCCESS')))
        if bk['status'] == 'CANCELLED':
            c = dt(x['cancel'])
            refund = x['adv'] if (bk['start'] - c) >= timedelta(days=1) else round(x['adv'] * 0.5, 2)
            events.append((c, bk['id'], refund, x['m'], 'REFUND', 'SUCCESS'))
    for ev in sorted(events, key=lambda t: (t[0], t[1])):
        pay(ev[1], ev[2], ev[0], ev[3], ev[4], ev[5])

    for m in MAINTENANCE:
        if m[6] == 'IN_PROGRESS':
            status[m[1]] = 'MAINTENANCE'
    for v in RETIRED:
        status[v] = 'RETIRED'
    return bookings, payments, odo, branch, status
