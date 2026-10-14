"""Runs every screenshot block in a real Oracle SQL*Plus session and saves the output.

Requires a running Oracle container named 'ora' (gvenzl/oracle-free) with user
rental/rental123 on FREEPDB1 and the sql/ folder mounted at /sql.

For each figure the exact SQL*Plus transcript is saved to screenshots/txt/fig_NN.txt and
drawn as a console image screenshots/fig_NN.png. Nothing in the output is edited.
"""
import os
import re
import subprocess
import sys
import textwrap

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
from figures import FIGURES, BY_KEY  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SQL = os.path.join(ROOT, 'sql')
SHOTS = os.path.join(ROOT, 'screenshots')
TXT = os.path.join(SHOTS, 'txt')
CONNECT = 'rental/rental123@FREEPDB1'
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
WIDTH = 150


def sqlplus(stdin, silent=False):
    cmd = ['docker', 'exec', '-i', '-w', '/sql', 'ora', 'sqlplus', '-L'] + (['-s'] if silent else []) + [CONNECT]
    return subprocess.run(cmd, input=stdin, capture_output=True, text=True, timeout=300).stdout


def chunk(fname, key):
    text = open(os.path.join(SQL, fname)).read()
    m = re.search(rf'^--## {key}\n(.*?)(?=^--## |\Z)', text, re.S | re.M)
    return m.group(1).strip('\n') + '\n'


def transcript(block):
    with open(os.path.join(SQL, '_fig.sql'), 'w') as f:
        f.write(block)
    out = sqlplus('SET ECHO OFF\n@00_setup_display.sql\nPROMPT ##START\nSET ECHO ON\n@_fig.sql\n'
                  'SET ECHO OFF\nPROMPT ##END\nexit\n')
    os.remove(os.path.join(SQL, '_fig.sql'))
    body = out.split('SQL> ##START\n', 1)[1].split('##END', 1)[0]
    lines = body.split('\n')
    lines[0] = re.sub(r'^(SQL> )+', 'SQL> ', lines[0])
    lines = [re.sub(r'^(SQL> )+', 'SQL> ', l) for l in lines]
    while lines and lines[-1].strip() in ('', 'SQL>', 'SQL> SQL>'):
        lines.pop()
    lines.append('SQL> ')
    return clean(lines)


def clean(lines):
    res = []
    for l in lines:
        l = l.rstrip()
        if l == '' and res and res[-1] == '':
            continue
        res.append(l)
    return res


def render(lines, path):
    font = ImageFont.truetype(FONT, 15)
    cw = font.getlength('M')
    lh = 19
    wrapped = []
    for l in lines:
        wrapped.extend(textwrap.wrap(l, WIDTH, drop_whitespace=False, replace_whitespace=False) or [''])
    cols = max(len(l) for l in wrapped)
    pad, bar = 14, 26
    w = int(pad * 2 + max(cols, 60) * cw)
    h = bar + pad * 2 + lh * len(wrapped)
    img = Image.new('RGB', (w, h), (12, 12, 12))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w, bar], fill=(46, 48, 54))
    small = ImageFont.truetype(FONT, 12)
    d.text((10, 6), 'SQL*Plus  |  rental@FREEPDB1  |  Oracle AI Database 26ai Free', font=small, fill=(210, 212, 216))
    y = bar + pad
    rejected = False
    for l in wrapped:
        if l.startswith('Rejected:'):
            rejected = True
        elif not l.strip() or l.startswith('PL/SQL'):
            rejected = False
        if rejected:
            color = (130, 210, 140)
        elif re.match(r'^(ORA-|ERROR at|SP2-|Accepted - )', l):
            color = (255, 120, 110)
        else:
            color = (204, 204, 204)
        d.text((pad, y), l, font=font, fill=color)
        y += lh
    img.save(path)


def save(fig, lines):
    no = fig['no']
    with open(os.path.join(TXT, f'fig_{no:02d}.txt'), 'w') as f:
        f.write('\n'.join(lines) + '\n')
    render(lines, os.path.join(SHOTS, f'fig_{no:02d}.png'))
    print(f'Figure {no:2d} {fig["key"]:13s} {len(lines):3d} lines')


def run_file(name, expect):
    out = sqlplus(f'@00_setup_display.sql\n@{name}\nexit\n', silent=True)
    if expect not in out or 'ORA-' in out or 'Warning' in out:
        sys.exit(f'{name} failed:\n{out[-2000:]}')


def main():
    os.makedirs(TXT, exist_ok=True)
    sqlplus('@99_cleanup.sql\nexit\n', silent=True)

    # Figure 2: run the DDL script (echo off, as in a normal @script run)
    out = sqlplus('SET ECHO OFF\n@00_setup_display.sql\nPROMPT ##START\n@01_ddl.sql\nPROMPT ##END\nexit\n')
    body = out.split('SQL> ##START\n', 1)[1].split('##END', 1)[0]
    body = [re.sub(r'^(SQL> )+', '', l) for l in body.split('\n')]
    save(BY_KEY['ddl_run'], clean(['SQL> @00_setup_display.sql', 'Session altered.', '', 'SQL> @01_ddl.sql'] + body[:-1]) + ['SQL> '])

    run_file('02_insert_data.sql', 'Commit complete.')
    order = ['sc_desc', 'sc_count', 'sc_fk', 'data_counts', 'data_vehicle', 'data_booking', 'ct1', 'ct2'] + \
            [f'q{i}' for i in range(1, 17)] + ['dml_insert', 'dml_update', 'dml_delete']
    for key in order:
        f = BY_KEY[key]
        save(f, transcript(chunk(*f['src'])))
    for name in ('07_functions.sql', '08_procedures.sql', '09_cursors.sql', '10_triggers.sql'):
        run_file(name, 'created.')
    for f in FIGURES:
        if f.get('step') == 8:
            save(f, transcript(chunk(*f['src'])))


def rerender():
    """Redraw every PNG from the saved transcripts (no database needed)."""
    for f in FIGURES:
        t = os.path.join(TXT, f"fig_{f['no']:02d}.txt")
        if os.path.exists(t):
            render(open(t).read().rstrip('\n').split('\n'), os.path.join(SHOTS, f"fig_{f['no']:02d}.png"))


if __name__ == '__main__':
    rerender() if '--render-only' in sys.argv else main()
