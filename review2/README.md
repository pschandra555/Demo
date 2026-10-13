# Vehicle Rental Management System – Review II

| File | What it is |
|---|---|
| `Vehicle_Rental_Review2_Report.docx` / `.pdf` | Review II report (28 pages with screenshot placeholders) |
| `Review2_Screenshot_Checklist.docx` / `.pdf` | Ordered list of every screenshot: what to run and what you should see |
| `sql/00 … 11, 99` | Oracle scripts, run in number order (see Section 0 of the report) |
| `screenshots/` | Save screenshots here as `fig_02.png`, `fig_03.png`, … |
| `tools/` | `build_report.py` rebuilds both DOCX files (and inserts any `screenshots/fig_NN.png`); `make_sql.py` regenerates `01_ddl.sql` / `02_insert_data.sql`; `sqlite_check.py` is a SQLite sanity check of data and queries (not an Oracle test) |

Status: the scripts have **not** been run on Oracle yet. The data, constraint tests and the 16 queries were
checked on SQLite only; the PL/SQL (functions, procedures, cursors, triggers) must be compiled and run in Oracle
while taking the screenshots.

Rebuild after adding screenshots: `python3 tools/build_report.py`, then export to PDF from Word.
