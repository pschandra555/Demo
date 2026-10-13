# Vehicle Rental Management System – Review II

| File | What it is |
|---|---|
| `Vehicle_Rental_Review2_Report.docx` / `.pdf` | Review II report (28 pages, 42 screenshots from a real Oracle run) |
| `Review2_Screenshot_Checklist.docx` / `.pdf` | Ordered list of every screenshot: what to run and what you should see |
| `sql/00 … 11, 99` | Oracle scripts, run in number order (see Section 0 of the report) |
| `screenshots/` | `fig_NN.png` screenshots used in the report; `txt/` holds the exact SQL*Plus output of each |
| `tools/` | `build_report.py` rebuilds both DOCX files (and inserts any `screenshots/fig_NN.png`); `make_sql.py` regenerates `01_ddl.sql` / `02_insert_data.sql`; `sqlite_check.py` is a SQLite sanity check of data and queries (not an Oracle test) |

Status: every script was run in order on a fresh schema in Oracle AI Database 26ai Free (release 23.26,
`gvenzl/oracle-free` container) with SQL*Plus on 13-Oct-2026. All 17 PL/SQL objects compiled VALID and every
result matched the checklist. `tools/capture.py` repeats that run and redraws the screenshots from the real
SQL*Plus output (console-style images, not grabs of a Windows desktop).

Rebuild after adding screenshots: `python3 tools/build_report.py`, then export to PDF from Word.
