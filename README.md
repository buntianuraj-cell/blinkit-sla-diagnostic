# Blinkit SLA Diagnostic

## Problem
Why are some Blinkit orders delivered late? This project diagnoses SLA breaches using SQL.

## Files
- `generate_data.py` - Creates fake Blinkit orders data
- `analysis.py` - Runs Python analysis
- `sql/01_foundations.sql` - Basic filtering & cleaning
- `sql/02_joins_aggregates.sql` - Joins & city-wise SLA
- `sql/03_window_functions.sql` - Ranking & running totals
- `sql/04_cte_subquery_case.sql` - CTEs, subqueries & delay buckets

## Key Finding
Late deliveries are concentrated in specific cities and peak hours, not random.
