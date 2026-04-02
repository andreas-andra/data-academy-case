# Genie Dashboard: Bankruptcies

## Base Table
`fact_bankruptcies`

## Required Joins
- `dim_year` on `fact_bankruptcies.year_id = dim_year.year_id`
- `dim_municipality` on `fact_bankruptcies.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact_bankruptcies.industry_id = dim_industry.industry_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
Use `dim_industry.industry_name` for industry labels.

---

## Data Model Notes

This fact contains only classified industry detail rows. `Total` and `Industry unknown` rows are excluded at the model level to prevent double-counting. No industry filtering is needed in queries.

For municipality totals, sum across all industry rows for a given municipality and year.
For national totals, sum across all rows for a given year.

---

## Headline KPIs

### Total Bankruptcies Nationally (Latest Year)
Sum `bankruptcies_enterprises` where `year_id = latest year`.

### Total Employees Affected (Latest Year)
Sum `bankruptcies_employees` where `year_id = latest year`.

### Municipalities with Any Bankruptcies (Latest Year)
Count distinct `municipality_id` where `year_id = latest year` and `bankruptcies_enterprises > 0`.

### Most Affected Industry Nationally (Latest Year)
Sum `bankruptcies_enterprises` grouped by `dim_industry.industry_name` for year = latest year. Return the top industry.

---

## Charts

### Chart 1 — Bar Chart: Top 15 Municipalities by Bankruptcies (Latest Year)
- Filter: `year_id = latest year`
- Aggregate: sum `bankruptcies_enterprises` grouped by `dim_municipality.municipality_name`
- Sort: descending by `bankruptcies_enterprises`
- Narrative: Shows which municipalities had the most total bankruptcies in the latest year.

### Chart 2 — Bar Chart: Top 10 Industries by Bankruptcies Nationally (Latest Year)
- Filter: `year_id = latest year`
- Aggregate: sum `bankruptcies_enterprises` across all municipalities, grouped by `dim_industry.industry_name`
- Sort: descending by `bankruptcies_enterprises`
- Narrative: Shows which industries account for the most nationwide bankruptcies in the latest year.

### Chart 3 — Line Chart: National Total Bankruptcies Over Time
- Aggregate: sum `bankruptcies_enterprises` grouped by `dim_year.year`
- X-axis: `dim_year.year`
- Y-axis: sum of `bankruptcies_enterprises`
- Narrative: Tracks the national bankruptcy trend across all years in the dataset.

### Chart 4 — Bar Chart: Top 10 Industries by Employees Affected (Latest Year)
- Filter: `year_id = latest year`
- Aggregate: sum `bankruptcies_employees` across all municipalities, grouped by `dim_industry.industry_name`
- Sort: descending by `bankruptcies_employees`
- Narrative: Highlights industries where bankruptcies affect the largest workforce, regardless of enterprise count.

### Chart 5 — Heatmap: Municipality × Industry Bankruptcies (Latest Year)
- Filter: `year_id = latest year`
- Rows: `dim_municipality.municipality_name`
- Columns: `dim_industry.industry_name`
- Color: `bankruptcies_enterprises`
- Narrative: Provides a visual map of where high-bankruptcy concentrations appear across municipality-industry combinations.

### Chart 6 — Line Chart: Bankruptcies Over Time for Top 5 Industries
- Identify the 5 industries with the highest total `bankruptcies_enterprises` across all years
- X-axis: `dim_year.year`
- Y-axis: sum of `bankruptcies_enterprises` (aggregated across municipalities)
- Series: `dim_industry.industry_name` (one line per industry)
- Narrative: Tracks how the most bankruptcy-prone industries have evolved over time nationally.

---

## Genie Prompts

"Using fact_bankruptcies joined to dim_municipality and dim_year, show the top 15 municipalities by total bankruptcies_enterprises for year = 2024 as a descending bar chart. Sum across industries."

"Using fact_bankruptcies joined to dim_industry and dim_year, show the top 10 industries by total bankruptcies_enterprises for year = 2024 as a descending bar chart. Sum across municipalities."

"Using fact_bankruptcies joined to dim_year, show total bankruptcies_enterprises by year as a line chart. Sum across all municipalities and industries."

"Using fact_bankruptcies joined to dim_industry and dim_year, show the top 10 industries by total bankruptcies_employees for year = 2024 as a descending bar chart. Sum across municipalities."

"Using fact_bankruptcies joined to dim_municipality, dim_industry, and dim_year, show bankruptcies_enterprises by municipality_name and industry_name for year = 2024 as a heatmap."

"Using fact_bankruptcies joined to dim_industry and dim_year, show bankruptcies_enterprises over time for the top 5 industries as a multi-line chart. Identify top 5 by total bankruptcies_enterprises across all years. Group by year and industry_name. Sum across municipalities."

---

## Technical Validation

- Base table: `fact_bankruptcies`
- Joins: `dim_year`, `dim_municipality`, `dim_industry`
- Default filter for municipality totals: `dim_industry.industry_name = 'Total'`
- Default filter for industry detail: `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- Never sum across both detail and Total rows — this causes double-counting

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary enterprise metric | `bankruptcies_enterprises` | Count of bankrupt enterprises |
| Primary employee metric | `bankruptcies_employees` | Employees exposed to bankruptcies |
| Municipality aggregate filter | `dim_industry.industry_name = 'Total'` | Authoritative municipality total |
| Industry detail filter | `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')` | Clean industry grain |
