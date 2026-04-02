# Genie Dashboard: Bankruptcy Risk Hotspots

## Base Table
`fact_bankruptcy_risk_hotspots`

## Required Joins
- `dim_year` on `fact_bankruptcy_risk_hotspots.year_id = dim_year.year_id`
- `dim_municipality` on `fact_bankruptcy_risk_hotspots.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact_bankruptcy_risk_hotspots.hotspot_industry_id = dim_industry.industry_id`

Use `dim_year.year` for display labels where needed.
Use `dim_municipality.municipality_name` for municipality labels.
Use `dim_industry.industry_name` for hotspot industry labels.

---

## Headline KPIs

### Total Severe Hotspot Municipalities (Latest Year)
Count rows from `fact_bankruptcy_risk_hotspots` where `year_id = latest year` and `hotspot_risk_class = 'Severe hotspot'`.

### National Average bankruptcies_per_1000_establishments (Latest Year)
Average `bankruptcies_per_1000_establishments` where `year_id = latest year`.

### Municipality with Highest bankruptcies_per_1000_establishments (Latest Year)
Use `dim_municipality.municipality_name` after joining `dim_municipality`. Sort descending by `bankruptcies_per_1000_establishments` and return the top municipality for the latest year.

---

## Charts

### Chart 1 — Bar Chart: Top 15 Municipalities by bankruptcies_per_1000_establishments
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name`
- Value: `bankruptcies_per_1000_establishments`
- Color by: `hotspot_risk_class`

### Chart 2 — Heat Map or Ranked Table: hotspot_absolute_risk_class Distribution by Year
- Group by: `dim_year.year` and `hotspot_absolute_risk_class`
- Metric: count municipalities (count rows)
- **Do not use** `hotspot_risk_class` for this chart because it always creates equal yearly bands
- **Must use** `hotspot_absolute_risk_class` so the distribution can shift over time

### Chart 3 — Line Chart: rolling_3y_avg_bankruptcy_rate Over Time
- Filter: top 10 municipalities with the highest latest-year `bankruptcies_per_1000_establishments`
- X-axis: `dim_year.year`
- Y-axis: `rolling_3y_avg_bankruptcy_rate`
- Series: `dim_municipality.municipality_name`

### Chart 4 — Bar Chart: Hotspot Industry Frequency
- Use `dim_industry.industry_name` after joining `dim_industry`
- Count how many municipality-year rows each industry appears in as `hotspot_industry_id`
- **Do not** count `bankruptcies_employees` or `bankruptcies_enterprises` for this chart
- This chart answers: which industries most often appear as the top bankruptcy industry across municipalities
