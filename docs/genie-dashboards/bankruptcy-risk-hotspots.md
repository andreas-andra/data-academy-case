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

---

## Genie Prompts

"Using fact_bankruptcy_risk_hotspots joined to dim_municipality and dim_year, show the top 15 municipalities by bankruptcies_per_1000_establishments for year = 2024 as a descending bar chart. Color by hotspot_risk_class."

"Using fact_bankruptcy_risk_hotspots joined to dim_year, show the count of municipalities by hotspot_absolute_risk_class and year as a stacked bar chart. Do not use hotspot_risk_class for this chart."

"Using fact_bankruptcy_risk_hotspots joined to dim_municipality and dim_year, show rolling_3y_avg_bankruptcy_rate over time for the 10 municipalities with the highest bankruptcies_per_1000_establishments in year = 2024 as a multi-line chart."

"Using fact_bankruptcy_risk_hotspots joined to dim_industry, count how many municipality-year rows each industry appears in as the hotspot industry across all years. Join dim_industry on hotspot_industry_id for industry names. Show as a descending bar chart. Count rows only, do not sum bankruptcies."

"Using fact_bankruptcy_risk_hotspots joined to dim_year, how many municipalities have hotspot_risk_class = 'Severe hotspot' in year = 2024?"

"Using fact_bankruptcy_risk_hotspots joined to dim_year, what is the average bankruptcies_per_1000_establishments for year = 2024?"

"Using fact_bankruptcy_risk_hotspots joined to dim_municipality and dim_year, show the top 15 municipalities by bankruptcies_per_10000_population for year = 2024 as a descending bar chart."

"Using fact_bankruptcy_risk_hotspots joined to dim_municipality and dim_year, show yoy_bankruptcy_rate_pct for year = 2024 as a bar chart for the top 20 municipalities. Sort descending. Filter where yoy_bankruptcy_rate_pct IS NOT NULL."

---

## Technical Validation

- Base table: `fact_bankruptcy_risk_hotspots`
- Joins: `dim_year`, `dim_municipality`, `dim_industry` (on `hotspot_industry_id`)
- Grain: one row per year × municipality
- `hotspot_risk_class` is ntile(4) within each year — always ~25% of municipalities per band; use for within-year comparisons only
- `hotspot_absolute_risk_class` uses dataset-wide percentile thresholds — band sizes shift year-over-year as Finland's bankruptcy rate changes; use for cross-year trend analysis
- `yoy_bankruptcies_pct` and `yoy_bankruptcy_rate_pct` are NULL for the first year in the dataset
- The `dim_industry` join is on `hotspot_industry_id` — this is the top bankruptcy industry for the municipality-year, not a standard industry grain join

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary risk metric | `bankruptcies_per_1000_establishments` | Bankruptcy rate per 1000 establishments |
| Workforce rate | `bankrupt_employees_per_1000_personnel` | Bankrupt employees per 1000 personnel |
| Population rate | `bankruptcies_per_10000_population` | Alternative normalisation by population |
| Personnel density | `personnel_per_establishment` | Average staff per establishment |
| Relative class | `hotspot_risk_class` | Severe/High/Moderate/Low hotspot — ntile(4) within year |
| Absolute class | `hotspot_absolute_risk_class` | Severe/High/Moderate/Low hotspot — fixed dataset-wide thresholds |
| Ntile value | `bankruptcy_rate_ntile` | 1=highest risk, 4=lowest; underlies `hotspot_risk_class` |
| Rolling average | `rolling_3y_avg_bankruptcy_rate` | 3-year smoothed bankruptcy rate |
| YoY enterprise change | `yoy_bankruptcies_pct` | NULL for first year |
| YoY rate change | `yoy_bankruptcy_rate_pct` | NULL for first year |
| Top industry FK | `hotspot_industry_id` | Join to `dim_industry.industry_id` |
| Top industry enterprises | `hotspot_industry_bankruptcies_enterprises` | Bankrupt enterprises in top industry |
| Top industry employees | `hotspot_industry_bankruptcies_employees` | Bankrupt employees in top industry |
