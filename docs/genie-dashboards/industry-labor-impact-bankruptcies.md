# Genie Dashboard: Industry Labor Impact of Bankruptcies

## Base Table
`fact_industry_labor_impact_bankruptcies`

## Required Joins
- `dim_year` on `fact_industry_labor_impact_bankruptcies.year_id = dim_year.year_id`
- `dim_municipality` on `fact_industry_labor_impact_bankruptcies.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact_industry_labor_impact_bankruptcies.industry_id = dim_industry.industry_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
Use `dim_industry.industry_name` for industry labels.

---

## Data Coverage Notes

- `yoy_bankruptcies_employees_pct` and `yoy_bankruptcies_enterprises_pct` are NULL for the first year a municipality-industry pair appears, and also NULL when the prior year is missing (sparse series guard).
- `employees_affected_per_bankruptcy` is NULL when `bankruptcies_enterprises = 0`.
- `Total` and `Industry unknown` are excluded from this fact — every row is a real industry category.
- `labor_impact_class` uses ntile(4) within each year — always ~25% of positive rows per band; use for within-year comparisons.
- `labor_impact_absolute_class` uses dataset-wide percent_rank bands — use this for cross-year trend analysis.

---

## Headline KPIs

### Industry with Highest Employee Impact Nationally (Latest Year)
Use `dim_industry.industry_name`. Filter `year_id = latest year`. Sum `bankruptcies_employees` grouped by industry, aggregated across municipalities. Return the top industry.

### Total Employees Affected Nationally (Latest Year)
Sum `bankruptcies_employees` where `year_id = latest year`. Aggregate across all municipalities and industries.

### Industry with Highest Average Employees Per Bankruptcy (Latest Year)
Use `dim_industry.industry_name`. Filter `year_id = latest year`. Average `employees_affected_per_bankruptcy` grouped by industry, aggregated across municipalities. Return the top industry and value.

### Severe Labor Impact Combinations (Latest Year)
Count rows where `year_id = latest year` and `labor_impact_class = 'Severe labor impact'`.

---

## Charts

### Chart 1 — Bar Chart: Top 10 Industries by Employees Affected (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_industry.industry_name`
- Value: sum of `bankruptcies_employees` (aggregated across municipalities)
- Sort: descending
- Narrative: Shows which industries account for the greatest employee exposure to bankruptcies nationally in the latest year.

### Chart 2 — Bar Chart: Top 10 Industries by Average Employees Per Bankruptcy (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_industry.industry_name`
- Value: average `employees_affected_per_bankruptcy` (aggregated across municipalities)
- Sort: descending
- Narrative: Highlights industries where each bankruptcy event affects many employees — signals large-employer or labour-intensive sector risk, independent of bankruptcy count.

### Chart 3 — Line Chart: Total Employees Affected Over Time (Top 5 Industries)
- Identify the 5 industries with the highest total `bankruptcies_employees` across all years (aggregated across municipalities)
- X-axis: `dim_year.year`
- Y-axis: sum of `bankruptcies_employees`
- Series: `dim_industry.industry_name`
- Narrative: Tracks whether the most employee-impacting industries are improving or worsening over time.

### Chart 4 — Heatmap: Industry × Year Employee Impact
- X-axis: `dim_year.year`
- Y-axis: `dim_industry.industry_name`
- Color: sum of `bankruptcies_employees` (aggregated across municipalities)
- Narrative: Provides a multi-year view of which industries have persistently high employee bankruptcy exposure and which years were most severe.

### Chart 5 — Stacked Bar Chart: Labor Impact Class Distribution by Year
- X-axis: `dim_year.year`
- Y-axis: count rows (number of municipality-industry combinations per class)
- Stack: `labor_impact_absolute_class`
- **Do not sum** `bankruptcies_employees` — count rows only
- Use `labor_impact_absolute_class` (not `labor_impact_class`) so the distribution can shift meaningfully across years
- Narrative: Shows whether severe labor impact cases are becoming more or less common over time.

### Chart 6 — Bar Chart: Top 20 Municipality-Industry Combinations by Employees Affected (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name` + `dim_industry.industry_name` (concatenated label)
- Value: `bankruptcies_employees`
- Sort: descending
- Filter: `labor_impact_class = 'Severe labor impact'`
- Narrative: Pinpoints the specific municipality-industry hotspots with the greatest employee exposure to bankruptcies in the latest year.

---

## Genie Prompts

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show total bankruptcies_employees by industry_name for year = 2024 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show total bankruptcies_enterprises by industry_name for year = 2024 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies joined to dim_year, show yearly total bankruptcies_employees as a line chart. Sum across all municipalities and industries. Group by year."

"Using fact_industry_labor_impact_bankruptcies joined to dim_year, show yearly total bankruptcies_enterprises as a line chart. Sum across all municipalities and industries. Group by year."

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show bankruptcies_employees by industry_name and year as a heatmap. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show the top 5 industries by total bankruptcies_employees across all years as a multi-line chart over time. Aggregate across municipalities. Group by year and industry_name."

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show average employees_affected_per_bankruptcy by industry_name for year = 2024 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies joined to dim_industry and dim_year, show rolling_3y_avg_employees_per_bankruptcy by industry_name and year as a multi-line chart for the top 5 industries by total bankruptcies_employees. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies joined to dim_year, show labor_impact_absolute_class distribution by year as a stacked bar chart. Count rows only, do not sum bankruptcies_employees."

"Using fact_industry_labor_impact_bankruptcies joined to dim_year, show labor_impact_class distribution by year as a stacked bar chart. Count rows only, do not sum bankruptcies_employees."

"Using fact_industry_labor_impact_bankruptcies joined to dim_municipality, dim_industry, and dim_year, for dim_municipality.municipality_name = 'Helsinki', show bankruptcies_employees by industry_name and year as a stacked bar chart."

"Using fact_industry_labor_impact_bankruptcies joined to dim_municipality, dim_industry, and dim_year, find the top 20 municipality-industry combinations for year = 2024 where labor_impact_class = 'Severe labor impact'. Sort by bankruptcies_employees descending. Show municipality_name, industry_name, and bankruptcies_employees."

"Using fact_industry_labor_impact_bankruptcies joined to dim_year, how many municipality-industry combinations have labor_impact_class = 'Severe labor impact' in year = 2024?"

---

## Technical Validation

- Base table: `fact_industry_labor_impact_bankruptcies`
- Joins: `dim_year`, `dim_municipality`, `dim_industry`
- Grain: one row per year × municipality × industry
- `Total` and `Industry unknown` are already excluded — no additional industry filter needed
- `labor_impact_class` is ntile(4) within each year — always ~25% per band; use for within-year peer comparisons
- `labor_impact_absolute_class` uses fixed dataset-wide percent_rank bands — use for cross-year trend analysis
- YoY fields are NULL for the first year and when prior-year row is missing — always apply `IS NOT NULL` filter when displaying YoY columns
- `employees_affected_per_bankruptcy` is NULL when `bankruptcies_enterprises = 0`
- Municipality names must be filtered via `dim_municipality.municipality_name`, not as a raw string on the fact table

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary labor metric | `bankruptcies_employees` | Employees exposed to bankruptcies |
| Volume metric | `bankruptcies_enterprises` | Count of bankrupt enterprises |
| Intensity metric | `employees_affected_per_bankruptcy` | NULL when bankruptcies_enterprises = 0 |
| Municipality share | `share_of_municipality_bankrupt_employees_pct` | Industry's share of municipality employee impact |
| National industry share | `share_of_national_industry_bankrupt_employees_pct` | Municipality's share of national industry employee impact |
| YoY employee change | `yoy_bankruptcies_employees_pct` | NULL for first/non-consecutive years |
| YoY enterprise change | `yoy_bankruptcies_enterprises_pct` | NULL for first/non-consecutive years |
| Rolling avg employees | `rolling_3y_avg_bankruptcies_employees` | 3-year smoothed employee impact |
| Rolling avg intensity | `rolling_3y_avg_employees_per_bankruptcy` | 3-year ratio-of-sums intensity |
| Ntile value | `labor_impact_ntile` | 1=highest impact, 4=lowest; raw value underlying labor_impact_class |
| Relative class | `labor_impact_class` | Severe/High/Moderate/Low — ntile(4) within year |
| Absolute class | `labor_impact_absolute_class` | No labor impact / Low / Moderate / High / Severe — fixed cross-year bands |
