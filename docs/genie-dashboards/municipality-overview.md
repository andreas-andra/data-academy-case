# Genie Dashboard: Municipality Overview

## Base Table
`fact_municipality_overview`

## Required Joins
- `dim_year` on `fact_municipality_overview.year_id = dim_year.year_id`
- `dim_municipality` on `fact_municipality_overview.municipality_id = dim_municipality.municipality_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
No industry dimension — bankruptcy totals in this fact are municipality-level aggregates sourced from the authoritative `industry = 'Total'` row.

---

## Headline KPIs

### National Total Bankruptcies (Latest Year)
Sum `total_bankruptcies_enterprises` where `year_id = latest year`. (Aggregates across all municipalities.)

### Average Bankruptcy Pressure (Latest Year)
Average `bankruptcies_per_1000_establishments` where `year_id = latest year` and `establishments_count > 0`.

### Municipality with Highest Bankruptcy Pressure (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year`. Sort descending by `bankruptcies_per_1000_establishments`. Return the top municipality name and value.

### Total Population Nationally (Latest Year)
Sum `population` where `year_id = latest year`.

---

## Charts

### Chart 1 — Bar Chart: Top 20 Municipalities by Bankruptcy Pressure (Latest Year)
- Filter: `year_id = latest year`, `establishments_count > 0`
- Category axis: `dim_municipality.municipality_name`
- Value: `bankruptcies_per_1000_establishments`
- Sort: descending
- Narrative: Identifies municipalities where bankruptcies are disproportionately high relative to their business base — the primary signal of local economic distress.

### Chart 2 — Bar Chart: Top 20 Municipalities by Bankruptcies Per 100k Population (Latest Year)
- Filter: `year_id = latest year`, `population > 0`
- Category axis: `dim_municipality.municipality_name`
- Value: `bankruptcies_per_100k_population`
- Sort: descending
- Narrative: An alternative bankruptcy pressure view normalised by population instead of business base — highlights municipalities where residents are most exposed to business failure.

### Chart 3 — Scatter Plot: Population vs Bankruptcy Pressure (Latest Year)
- Filter: `year_id = latest year`, `establishments_count > 0`
- X-axis: `population`
- Y-axis: `bankruptcies_per_1000_establishments`
- Label outliers with `dim_municipality.municipality_name`
- Narrative: Reveals whether high bankruptcy pressure is concentrated in small or large municipalities — small municipalities with high rates are disproportionately fragile.

### Chart 4 — Bar Chart: Top 20 Municipalities by Death Rate (Latest Year)
- Filter: `year_id = latest year`, `population > 0`
- Category axis: `dim_municipality.municipality_name`
- Value: `death_rate_per_1000`
- Sort: descending
- Narrative: Shows which municipalities have the highest mortality rates — demographic stress indicator that complements economic stress signals.

### Chart 5 — Table: Full Municipality Profile (Latest Year)
- Filter: `year_id = latest year`
- Columns: `dim_municipality.municipality_name`, `population`, `deaths`, `death_rate_per_1000`, `establishments_count`, `personnel_staff_years`, `total_bankruptcies_enterprises`, `bankruptcies_per_1000_establishments`, `bankruptcies_per_100k_population`
- Sort: descending by `bankruptcies_per_1000_establishments`
- Narrative: Complete municipality overview for screening, filtering, and drilldown.

### Chart 6 — Line Chart: Bankruptcy Pressure Trend for Selected Municipalities
- Filter: parameterise by municipality name — default to top 5 municipalities by latest-year `bankruptcies_per_1000_establishments`
- X-axis: `dim_year.year`
- Y-axis: `bankruptcies_per_1000_establishments`
- Series: `dim_municipality.municipality_name`
- Narrative: Tracks whether high-risk municipalities are improving or deteriorating over time.

---

## Technical Validation

- Base table: `fact_municipality_overview`
- Joins: `dim_year`, `dim_municipality`
- No industry join — bankruptcy totals are pre-aggregated from `industry = 'Total'` rows
- Do not join to `fact_bankruptcies` directly for industry drill-down — use `fact_industry_bankruptcy_specialization` or `fact_industry_labor_impact_bankruptcies` instead

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Population | `population` | Municipality population |
| Deaths | `deaths` | Municipality death count |
| Death rate | `death_rate_per_1000` | Derived: deaths / population × 1000 |
| Business base | `establishments_count` | Number of establishments |
| Workforce | `personnel_staff_years` | Personnel volume |
| Bankruptcy count | `total_bankruptcies_enterprises` | Municipality total from 'Total' row |
| Bankruptcy employees | `total_bankruptcies_employees` | Employees exposed |
| Establishment pressure | `bankruptcies_per_1000_establishments` | Primary bankruptcy rate metric |
| Population pressure | `bankruptcies_per_100k_population` | Alternative normalisation |
