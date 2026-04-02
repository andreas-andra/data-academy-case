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

## Industry Filter Rules

This fact preserves all source rows, including aggregate rows. Apply the correct filter per chart:

- **Municipality totals**: filter `dim_industry.industry_name = 'Total'`
- **Industry breakdown**: filter `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- **Never mix** industry detail rows and 'Total' rows in the same aggregation — this causes double-counting

---

## Headline KPIs

### Total Bankruptcies Nationally (Latest Year)
Sum `bankruptcies_enterprises` where `year_id = latest year` and `dim_industry.industry_name = 'Total'`.

### Total Employees Affected (Latest Year)
Sum `bankruptcies_employees` where `year_id = latest year` and `dim_industry.industry_name = 'Total'`.

### Municipalities with Any Bankruptcies (Latest Year)
Count distinct `municipality_id` where `year_id = latest year` and `dim_industry.industry_name = 'Total'` and `bankruptcies_enterprises > 0`.

### Most Affected Industry Nationally (Latest Year)
Use `dim_industry.industry_name`. Filter `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`. Sum `bankruptcies_enterprises` grouped by industry, return the top industry name.

---

## Charts

### Chart 1 — Bar Chart: Top 15 Municipalities by Bankruptcies (Latest Year)
- Filter: `year_id = latest year`, `dim_industry.industry_name = 'Total'`
- Category axis: `dim_municipality.municipality_name`
- Value: `bankruptcies_enterprises`
- Sort: descending by `bankruptcies_enterprises`
- Narrative: Shows which municipalities had the most total bankruptcies in the latest year using the authoritative 'Total' industry row per municipality.

### Chart 2 — Bar Chart: Top 10 Industries by Bankruptcies Nationally (Latest Year)
- Filter: `year_id = latest year`, `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- Aggregate: sum `bankruptcies_enterprises` across all municipalities, grouped by `dim_industry.industry_name`
- Sort: descending by `bankruptcies_enterprises`
- Narrative: Shows which industries account for the most nationwide bankruptcies in the latest year, with aggregate rows excluded to avoid double-counting.

### Chart 3 — Line Chart: National Total Bankruptcies Over Time
- Filter: `dim_industry.industry_name = 'Total'`
- Aggregate: sum `bankruptcies_enterprises` grouped by `dim_year.year`
- X-axis: `dim_year.year`
- Y-axis: sum of `bankruptcies_enterprises`
- Narrative: Tracks the national bankruptcy trend across all years in the dataset using municipality-level 'Total' rows summed nationally.

### Chart 4 — Bar Chart: Top 10 Industries by Employees Affected (Latest Year)
- Filter: `year_id = latest year`, `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- Aggregate: sum `bankruptcies_employees` across all municipalities, grouped by `dim_industry.industry_name`
- Sort: descending by `bankruptcies_employees`
- Narrative: Highlights industries where bankruptcies affect the largest workforce, regardless of enterprise count.

### Chart 5 — Heatmap: Municipality × Industry Bankruptcies (Latest Year)
- Filter: `year_id = latest year`, `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- Rows: `dim_municipality.municipality_name`
- Columns: `dim_industry.industry_name`
- Color: `bankruptcies_enterprises`
- Narrative: Provides a visual map of where high-bankruptcy concentrations appear across municipality-industry combinations, useful for identifying structural patterns.

### Chart 6 — Line Chart: Bankruptcies Over Time for Top 5 Industries
- Filter: `dim_industry.industry_name NOT IN ('Total', 'Industry unknown')`
- Identify the 5 industries with the highest total `bankruptcies_enterprises` across all years
- X-axis: `dim_year.year`
- Y-axis: sum of `bankruptcies_enterprises` (aggregated across municipalities)
- Series: `dim_industry.industry_name` (one line per industry)
- Narrative: Tracks how the most bankruptcy-prone industries have evolved over time nationally.

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
