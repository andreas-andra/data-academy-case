# Genie Dashboard: Population and Business Base

## Base Table
`fact_population`

## Required Joins
- `dim_year` on `fact_population.year_id = dim_year.year_id`
- `dim_municipality` on `fact_population.municipality_id = dim_municipality.municipality_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
No industry dimension — this fact is a municipality-level denominator fact.

---

## Purpose Note

`fact_population` is the foundational municipality denominator fact. It provides population, deaths, establishments, and personnel counts. It is best used for demographic monitoring and as a context layer for other analyses. For bankruptcy-combined views, prefer `fact_municipality_overview` which pre-joins these metrics with bankruptcy totals.

---

## Headline KPIs

### Total National Population (Latest Year)
Sum `population` where `year_id = latest year`.

### Total National Establishments (Latest Year)
Sum `establishments_count` where `year_id = latest year`.

### Total National Deaths (Latest Year)
Sum `deaths` where `year_id = latest year`.

### Total National Personnel Staff Years (Latest Year)
Sum `personnel_staff_years` where `year_id = latest year`.

---

## Charts

### Chart 1 — Bar Chart: Top 20 Municipalities by Population (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name`
- Value: `population`
- Sort: descending
- Narrative: Shows which municipalities have the largest populations in the latest year — the scale denominator for any per-capita analysis.

### Chart 2 — Bar Chart: Top 20 Municipalities by Establishments Count (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name`
- Value: `establishments_count`
- Sort: descending
- Narrative: Shows the distribution of the business base — complements population size to reveal whether a municipality punches above or below its demographic weight economically.

### Chart 3 — Line Chart: Total National Population Over Time
- X-axis: `dim_year.year`
- Y-axis: sum of `population`
- Narrative: Tracks the national population trend over the dataset period.

### Chart 4 — Line Chart: Total National Establishments Over Time
- X-axis: `dim_year.year`
- Y-axis: sum of `establishments_count`
- Narrative: Tracks the national business base trend — for comparison with the population trend and to contextualise bankruptcy patterns.

### Chart 5 — Scatter Plot: Population vs Establishments (Latest Year)
- Filter: `year_id = latest year`
- X-axis: `population`
- Y-axis: `establishments_count`
- Label notable outliers with `dim_municipality.municipality_name`
- Narrative: Reveals whether each municipality's business base is proportional to its population — outliers with unusually high or low establishment density stand out.

### Chart 6 — Bar Chart: Top 20 Municipalities by Personnel Staff Years (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name`
- Value: `personnel_staff_years`
- Sort: descending
- Narrative: Shows where workforce volume is concentrated — useful for weighting analysis of employee-impact facts like `fact_industry_labor_impact_bankruptcies`.

---

## Technical Validation

- Base table: `fact_population`
- Joins: `dim_year`, `dim_municipality`
- No bankruptcy or industry columns — for bankruptcy-enriched municipality data use `fact_municipality_overview`
- This fact is primarily a supporting denominator — consider it the foundation for derived metrics in other facts

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Population | `population` | Municipality population |
| Deaths | `deaths` | Municipality deaths |
| Business base | `establishments_count` | Number of establishments |
| Workforce | `personnel_staff_years` | Personnel volume in staff-years |
