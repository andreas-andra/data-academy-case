# Genie Dashboard: Finland Economic Health

## Base Table
`fact_finland_economic_health`

## Required Joins
- `dim_year` on `fact_finland_economic_health.year_id = dim_year.year_id`

Use `dim_year.year` for year labels.
No municipality or industry dimension — this fact is national-level with one row per year.

---

## Data Coverage Note

Year-over-year growth fields (`new_establishments_yoy`, `establishment_growth_pct`, `bankruptcy_growth_pct`) are `NULL` for the first year in the dataset because there is no prior year to compare against. Do not treat NULL growth values as zero.

---

## Headline KPIs

### Total Bankruptcies (Latest Year)
`total_bankruptcies_enterprises` where `year_id = latest year`.

### Total Establishments (Latest Year)
`total_establishments` where `year_id = latest year`.

### Bankruptcy Growth vs Establishment Growth (Latest Year)
Compare `bankruptcy_growth_pct` and `establishment_growth_pct` for `year_id = latest year`. Present as two separate KPI tiles — do not add or subtract them.

### National Death Rate (Latest Year)
`death_rate_per_1000` where `year_id = latest year`.

---

## Charts

### Chart 1 — Line Chart: National Bankruptcies and Establishments Over Time
- X-axis: `dim_year.year`
- Primary Y-axis: `total_bankruptcies_enterprises`
- Secondary Y-axis: `total_establishments`
- Narrative: Shows whether the national bankruptcy count is rising or falling relative to the overall business base, providing a long-run health perspective.

### Chart 2 — Bar Chart: Bankruptcy Growth vs Establishment Growth by Year
- Filter: exclude the first year in the dataset (NULL growth fields)
- X-axis: `dim_year.year`
- Grouped bars per year: `bankruptcy_growth_pct` (one bar) and `establishment_growth_pct` (second bar)
- Narrative: Years where `bankruptcy_growth_pct` exceeds `establishment_growth_pct` signal business stress; years where establishment growth outpaces bankruptcy growth suggest improving conditions.

### Chart 3 — Line Chart: Death Rate Per 1000 Over Time
- X-axis: `dim_year.year`
- Y-axis: `death_rate_per_1000`
- Narrative: Tracks Finland's national mortality trend over time, providing demographic context for economic analyses.

### Chart 4 — Line Chart: Total Population and Total Deaths Over Time
- X-axis: `dim_year.year`
- Primary Y-axis: `total_population`
- Secondary Y-axis: `total_deaths`
- Narrative: Shows the absolute demographic base alongside the mortality count — useful for validating the death rate trend in Chart 3.

### Chart 5 — Bar Chart: New Establishments Year Over Year
- Filter: exclude the first year in the dataset (NULL yoy field)
- X-axis: `dim_year.year`
- Y-axis: `new_establishments_yoy`
- Color by sign: positive bars (green) for growth years, negative bars (red) for contraction years
- Narrative: Shows how many net new establishments Finland added or lost each year — a leading indicator of business climate health.

### Chart 6 — Line Chart: Personnel Staff Years Over Time
- X-axis: `dim_year.year`
- Y-axis: `total_personnel_staff_years`
- Narrative: Tracks the national labour base over time, complementing the establishments count trend.

---

## Technical Validation

- Base table: `fact_finland_economic_health`
- Joins: `dim_year` only
- Grain: one row per year — no municipality or industry dimension
- Growth fields are NULL for the first year — filter or handle nulls before display
- All measures are national-level totals

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Bankruptcy volume | `total_bankruptcies_enterprises` | National total bankruptcies per year |
| Employee exposure | `total_bankruptcies_employees` | Employees exposed to bankruptcies |
| Business base | `total_establishments` | Total establishments nationally |
| Workforce | `total_personnel_staff_years` | National personnel volume |
| Population | `total_population` | National population |
| Deaths | `total_deaths` | National deaths per year |
| Death rate | `death_rate_per_1000` | Derived: deaths / population × 1000 |
| Net new establishments | `new_establishments_yoy` | NULL for first year |
| Establishment growth | `establishment_growth_pct` | NULL for first year |
| Bankruptcy growth | `bankruptcy_growth_pct` | NULL for first year |
