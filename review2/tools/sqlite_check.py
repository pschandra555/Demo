"""Sanity check of the sample data and the 16 queries on SQLite.

This is NOT an Oracle test. It only confirms that the INSERT data satisfies the
PK/FK/UNIQUE/CHECK constraints, that the constraint tests fail, and what result
each query should give, so screenshots taken in Oracle can be compared with it.
Oracle date functions are emulated and SYSDATE is fixed to 13-Oct-2026 18:00.
"""
import math
import os
import re
import sqlite3
import sys
from datetime import datetime, timedelta

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SQL = os.path.join(ROOT, 'sql')
SYSDATE = datetime(2026, 10, 13, 18, 0)
EPOCH = datetime(2000, 1, 1)


def j(d):  # datetime -> day number
    return (d - EPOCH).total_seconds() / 86400


def from_j(x):
    return EPOCH + timedelta(days=x)


def parse(s):
    for f in ('%Y-%m-%d %H:%M', '%Y-%m-%d'):
        try:
            return datetime.strptime(s, f)
        except ValueError:
            pass
    raise ValueError(s)


def to_char(x, fmt):
    if x is None:
        return None
    d = from_j(x) + timedelta(seconds=0.5)
    py = fmt.replace('YYYY', '%Y').replace('MM', '%m').replace('DD', '%d').replace('Mon', '%b').replace('HH24', '%H').replace(':MI', ':%M')
    return d.strftime(py)


def add_months(x, n):
    d = from_j(x)
    m = d.month - 1 + int(n)
    y = d.year + m // 12
    m = m % 12 + 1
    day = min(d.day, [31, 29 if y % 4 == 0 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1])
    return j(d.replace(year=y, month=m, day=day))


def convert(sql):
    sql = re.sub(r"TO_DATE\('([^']+)',\s*'[^']+'\)", r"jd('\1')", sql)
    sql = re.sub(r"DATE '([^']+)'", r"jd('\1')", sql)
    sql = sql.replace('DEFAULT SYSDATE', 'DEFAULT 0').replace('SYSDATE', 'sysdate()')
    sql = re.sub(r'\bMINUS\b', 'EXCEPT', sql)
    sql = re.sub(r'\)\s*WHERE\s+ROWNUM\s*<=\s*(\d+)', r') LIMIT \1', sql)
    sql = re.sub(r'\bCEIL\(', 'ceil_(', sql)
    sql = re.sub(r'\bTRUNC\(', 'trunc_(', sql)
    return sql


def statements(text):
    out, cur = [], []
    for line in text.splitlines():
        if line.strip().startswith('--') or not line.strip():
            continue
        if line.upper().startswith(('SET ', 'CREATE SEQUENCE', 'COMMIT', 'ROLLBACK')):
            continue
        cur.append(line)
        if line.rstrip().endswith(';'):
            out.append('\n'.join(cur).rstrip().rstrip(';'))
            cur = []
    return out


def chunks(path):
    res, key, buf = {}, None, []
    for line in open(path):
        m = re.match(r'--## (\S+)', line)
        if m:
            if key:
                res[key] = ''.join(buf)
            key, buf = m.group(1), []
        elif key:
            buf.append(line)
    if key:
        res[key] = ''.join(buf)
    return res


def connect():
    con = sqlite3.connect(':memory:')
    con.execute('PRAGMA foreign_keys = ON')
    con.create_function('jd', 1, lambda s: j(parse(s)))
    con.create_function('sysdate', 0, lambda: j(SYSDATE))
    con.create_function('ceil_', 1, lambda x: None if x is None else math.ceil(round(x, 9)))
    con.create_function('trunc_', 1, lambda x: None if x is None else math.trunc(x))
    con.create_function('NVL', 2, lambda a, b: b if a is None else a)
    con.create_function('TO_CHAR', 2, to_char)
    con.create_function('ADD_MONTHS', 2, add_months)
    con.create_function('GREATEST', 2, lambda a, b: None if a is None or b is None else max(a, b))
    return con


def show(cur, rows):
    cols = [c[0] for c in cur.description]
    def fmt(v):
        if isinstance(v, float) and v > 9000 and v < 12000 and not float(v).is_integer():
            return from_j(v).strftime('%d-%b-%y %H:%M')
        if isinstance(v, float) and v > 9000 and v < 12000:
            return from_j(v).strftime('%d-%b-%y %H:%M')
        if isinstance(v, float) and v.is_integer():
            return str(int(v))
        return str(v)
    print('   ', ' | '.join(cols))
    for r in rows:
        print('   ', ' | '.join(fmt(v) for v in r))
    print(f'    ({len(rows)} rows)')


def main():
    con = connect()
    for f in ('01_ddl.sql', '02_insert_data.sql'):
        for st in statements(convert(open(os.path.join(SQL, f)).read())):
            con.execute(st)
    con.commit()
    print('Row counts:')
    for t in ('branch', 'vehicle_category', 'vehicle', 'customer', 'employee', 'booking', 'payment', 'maintenance'):
        print('   ', t, con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0])

    print('\nConstraint tests (each must fail):')
    for key in ('CT1', 'CT2'):
        for st in statements(convert(chunks(os.path.join(SQL, '04_constraint_tests.sql'))[key])):
            try:
                con.execute(st)
                print('    !! DID NOT FAIL:', st.splitlines()[0])
            except sqlite3.Error as e:
                print('    failed as expected:', type(e).__name__, e)
    con.rollback()

    print('\nQueries:')
    qs = chunks(os.path.join(SQL, '05_queries.sql'))
    for key in sorted(qs, key=lambda k: int(k[1:])):
        cur = con.execute(convert(qs[key]).strip().rstrip(';'))
        rows = cur.fetchall()
        print(f'\n{key}:')
        show(cur, rows)
    if '--dml' in sys.argv:
        print('\nDML demo:')
        for key, text in chunks(os.path.join(SQL, '06_dml_demo.sql')).items():
            print(key)
            for st in statements(convert(text)):
                cur = con.execute(st)
                if st.lstrip().upper().startswith('SELECT'):
                    show(cur, cur.fetchall())
                else:
                    print('   ', cur.rowcount, 'row(s) affected')


if __name__ == '__main__':
    main()
