# Genie Dashboard: Bankruptcy Trends By Industry

## Base Table
`fact_bankruptcies_by_industry`

## Required Joins
- `dim_year` on `fact_bankruptcies_by_industry.year_id = dim_year.year_id`
- `dim_industry` on `fact_bankruptcies_by_industry.industry_id = dim_industry.industry_id`

Use `dim_year.year` for year labels.
Use `dim_industry.industry_name` for industry labels.

---

## Industry Filter Rules

This fact already excludes `Total` and `Industry unknown` rows — every row represents a real industry category. No additional industry filtering is needed.

---

## Headline KPIs

### Largest Industry by Bankruptcies (Latest Year)
Use `dim_industry.industry_name`. Sum `bankruptcies_enterprises` grouped by industry where `year_id = latest year`. Return the industry with the highest value.

### Largest Industry by Employees Affected (Latest Year)
Use `dim_industry.industry_name`. Sum `bankruptcies_employees` grouped by industry where `year_id = latest year`. Return the industry with the highest value.

### Industry with Highest Share of Total (Latest Year)
Use `dim_industry.industry_name`. Filter `year_id = latest year`. Return the industry with the highest `share_of_total_pct`.

### Number of Industries Tracked (Latest Year)
Count distinct `industry_id` where `year_id = latest year`.

---

## Charts

### Chart 1 — Bar Chart: Industries by Bankruptcies Enterprises (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_industry.industry_name`
- Value: `bankruptcies_enterprises`
- Sort: descending by `bankruptcies_enterprises`
- Narrative: Shows the national industry breakdown of bankruptcies for the latest year — which sectors contribute the most.

### Chart 2 — Bar Chart: Industries by Employees Affected (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_industry.industry_name`
- Value: `bankruptcies_employees`
- Sort: descending by `bankruptcies_employees`
- Narrative: Highlights the workforce impact of bankruptcies by industry — which sectors affect the most employees when firms fail.

### Chart 3 — Line Chart: Industry Share of Total Over Time (Top 5 Industries)
- Identify the 5 industries with the highest total `bankruptcies_enterprises` across all years
- X-axis: `dim_year.year`
- Y-axis: `share_of_total_pct`
- Series: `dim_industry.industry_name` (one line per industry)
- Narrative: Tracks how each major industry's share of total national bankruptcies has shifted over time — reveals structural mix changes in the bankruptcy landscape.

### Chart 4 — Stacked Bar Chart: Annual Bankruptcy Mix by Industry
- Filter: no year filter — show all years
- X-axis: `dim_year.year`
- Y-axis: `bankruptcies_enterprises` (stacked)
- Stack: `dim_industry.industry_name`
- Narrative: Visualises how the annual total bankruptcy volume is composed across industries, and how that composition changes year by year.

### Chart 5 — Line Chart: Bankruptcies Enterprises Over Time (Top 5 Industries)
- Identify the 5 industries with the highest total `bankruptcies_enterprises` across all years
- X-axis: `dim_year.year`
- Y-axis: `bankruptcies_enterprises`
- Series: `dim_industry.industry_name`
- Narrative: Shows whether leading industries are growing or declining in bankruptcy count over the available period.

### Chart 6 — Scatter Plot: Enterprises vs Employees Affected (Latest Year)
- Filter: `year_id = latest year`
- X-axis: `bankruptcies_enterprises`
- Y-axis: `bankruptcies_employees`
- Label each point with `dim_industry.industry_name`
- Narrative: Reveals industries where bankruptcies are disproportionately employee-heavy — high employee-per-enterprise ratios signal large-firm or labour-intensive sector risk.

---

## Genie Prompts

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show bankruptcies_enterprises by industry_name for year = 2024 as a descending bar chart."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show bankruptcies_employees by industry_name for year = 2024 as a descending bar chart."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show share_of_total_pct by year for the top 5 industries as a multi-line chart. Identify top 5 industries by total bankruptcies_enterprises across all years. Group by year and industry_name."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show bankruptcies_enterprises by industry_name and year as a stacked bar chart. Show all years."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show bankruptcies_enterprises over time for the top 5 industries as a multi-line chart. Identify top 5 industries by total bankruptcies_enterprises across all years. Group by year and industry_name."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, show bankruptcies_enterprises vs bankruptcies_employees for year = 2024 as a scatter plot. Label each point with industry_name."

"Using fact_bankruptcies_by_industry joined to dim_industry and dim_year, which industry had the highest share_of_total_pct in year = 2024? Show all industries ranked by share_of_total_pct descending."

---

## Technical Validation

- Base table: `fact_bankruptcies_by_industry`
- Joins: `dim_year`, `dim_industry`
- No municipality dimension — this is a national-level fact
- `share_of_total_pct` is pre-calculated as the industry's share of all industry bankruptcies in the same year
- No additional industry row filtering required — `Total` and `Industry unknown` are already excluded

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary enterprise metric | `bankruptcies_enterprises` | National industry-year bankruptcy count |
| Primary employee metric | `bankruptcies_employees` | Employees exposed by industry-year |
| Share metric | `share_of_total_pct` | Industry share of that year's total national bankruptcies |
