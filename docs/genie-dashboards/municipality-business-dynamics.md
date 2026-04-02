# Genie Dashboard: Municipality Business Dynamics

## Base Table
`fact_municipality_business_dynamics`

## Required Joins
- `dim_year` on `fact_municipality_business_dynamics.year_id = dim_year.year_id`
- `dim_municipality` on `fact_municipality_business_dynamics.municipality_id = dim_municipality.municipality_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
No industry dimension — this is a year × municipality business dynamics fact.

---

## Data Coverage Notes

- `establishments_yoy_change`, `establishments_yoy_pct`, `personnel_yoy_change`, `personnel_yoy_pct`, `population_yoy_change`, and `population_yoy_pct` are NULL for the first year in a municipality's series, or when the prior-year row is missing (sparse series guard). Always apply `IS NOT NULL` filters before displaying these fields.
- Do not treat NULL YoY fields as zero — NULL means the prior-year reference row is missing, not that there was no change.
- `rolling_3y_avg_establishments_growth_pct` is NULL when there are fewer than three consecutive years of data for a municipality.
- `business_density_class` is NULL when `establishments_per_1000_population` is NULL (i.e. population or establishments data is missing for that municipality-year).
- `growth_class` is NULL when `establishments_yoy_pct` is NULL — handle nulls before using this field in charts or filters.
- Quartile classifications (`business_density_class`, `growth_class`) are computed within each year — do not compare ntile ranks across years, use the raw measures for cross-year comparisons.

---

## Headline KPIs

### Municipality with Strongest Establishment Growth (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year` and `establishments_yoy_pct IS NOT NULL`. Sort descending by `establishments_yoy_pct`. Return the municipality name and value.

### Municipality with Strongest Establishment Decline (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year` and `establishments_yoy_pct IS NOT NULL`. Sort ascending by `establishments_yoy_pct`. Return the municipality name and value (will be negative).

### National Average Establishments per 1,000 Population (Latest Year)
Average `establishments_per_1000_population` across all municipalities where `year_id = latest year` and `establishments_per_1000_population IS NOT NULL`.

### Municipalities with Positive Establishment Growth (Latest Year)
Count rows where `year_id = latest year` and `establishments_yoy_pct > 0`.

---

## Charts

### Chart 1 — Bar Chart: Top 20 Municipalities by Establishment Density (Latest Year)
- Filter: `year_id = latest year`, `establishments_per_1000_population IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `establishments_per_1000_population`
- Sort: descending
- Limit: top 20
- Narrative: Shows which municipalities have the highest concentration of business establishments relative to their population — a proxy for local economic vibrancy and market saturation.

### Chart 2 — Bar Chart: Top 20 Municipalities by Establishment Growth % (Latest Year)
- Filter: `year_id = latest year`, `establishments_yoy_pct IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `establishments_yoy_pct`
- Sort: descending
- Limit: top 20
- Narrative: Identifies the fastest-growing local business environments in the most recent year — useful for spotting emerging economic hotspots.

### Chart 3 — Bar Chart: Bottom 20 Municipalities by Establishment Growth % (Latest Year, Most Negative)
- Filter: `year_id = latest year`, `establishments_yoy_pct IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `establishments_yoy_pct`
- Sort: ascending (most negative first)
- Limit: bottom 20
- Narrative: Highlights municipalities with the sharpest contraction in their business base — sustained negative growth signals structural economic stress requiring policy attention.

### Chart 4 — Scatter Plot: Establishment Growth vs Population Growth (Latest Year)
- Filter: `year_id = latest year`, `establishments_yoy_pct IS NOT NULL`, `population_yoy_pct IS NOT NULL`
- X-axis: `population_yoy_pct`
- Y-axis: `establishments_yoy_pct`
- Label outliers with `dim_municipality.municipality_name`
- Narrative: The most analytically rich view — municipalities in the top-left quadrant (shrinking population, growing businesses) indicate a decoupling of economic and demographic trends. Municipalities in the bottom-left quadrant (shrinking population and declining businesses) face compounding structural risk.

### Chart 5 — Line Chart: Rolling 3-Year Average Establishment Growth for Top 5 Growing Municipalities
- Filter: parameterise by municipality — default to the 5 municipalities with the highest `rolling_3y_avg_establishments_growth_pct` in the latest year, where `rolling_3y_avg_establishments_growth_pct IS NOT NULL`
- X-axis: `dim_year.year`
- Y-axis: `rolling_3y_avg_establishments_growth_pct`
- Series: `dim_municipality.municipality_name`
- Filter: `rolling_3y_avg_establishments_growth_pct IS NOT NULL` (suppresses first two years of each series)
- Narrative: Tracks whether the strongest-growing municipalities are sustaining momentum or reverting to the mean — the 3-year smooth removes single-year noise to reveal durable trends.

### Chart 6 — Stacked Bar Chart: Business Density Class Distribution by Year
- Filter: `business_density_class IS NOT NULL`
- Category axis: `dim_year.year`
- Series (stack): `business_density_class` — use fixed order: High density, Above average density, Below average density, Low density
- Value: count of municipalities per density class per year
- Narrative: Shows whether the overall distribution of business density across Finnish municipalities is shifting over time — a widening gap between High and Low density classes indicates growing regional polarisation.

---

## Genie Prompts

"Using fact_municipality_business_dynamics joined to dim_municipality and dim_year, show the top 20 municipalities by establishments_per_1000_population for the latest year as a descending bar chart. Filter where establishments_per_1000_population IS NOT NULL."

"Using fact_municipality_business_dynamics joined to dim_municipality and dim_year, show the top 20 municipalities by establishments_yoy_pct for the latest year as a descending bar chart. Filter where establishments_yoy_pct IS NOT NULL."

"Using fact_municipality_business_dynamics joined to dim_municipality and dim_year, show the 20 municipalities with the most negative establishments_yoy_pct for the latest year as a bar chart sorted ascending. Filter where establishments_yoy_pct IS NOT NULL."

"Using fact_municipality_business_dynamics joined to dim_municipality and dim_year, show establishments_yoy_pct vs population_yoy_pct for the latest year as a scatter plot. Filter where establishments_yoy_pct IS NOT NULL and population_yoy_pct IS NOT NULL. Label outliers with municipality_name."

"Using fact_municipality_business_dynamics joined to dim_municipality and dim_year, show rolling_3y_avg_establishments_growth_pct over time for the 5 municipalities with the highest rolling_3y_avg_establishments_growth_pct in the latest year as a multi-line chart. Filter where rolling_3y_avg_establishments_growth_pct IS NOT NULL."

"Using fact_municipality_business_dynamics joined to dim_year, show the count of municipalities by business_density_class for each year as a stacked bar chart. Filter where business_density_class IS NOT NULL. Stack order: High density, Above average density, Below average density, Low density."

---

## Technical Validation

- Base table: `fact_municipality_business_dynamics`
- Joins: `dim_year`, `dim_municipality`
- YoY fields (`establishments_yoy_pct`, `personnel_yoy_pct`, `population_yoy_pct`, and their absolute counterparts) are NULL for the first year in each municipality's series or when the prior-year row is missing — always apply `IS NOT NULL` filter when displaying these fields
- `rolling_3y_avg_establishments_growth_pct` is NULL until a municipality has at least two prior consecutive years of YoY data
- `business_density_class` and `growth_class` are NULL when the underlying measure is NULL — do not use these as mandatory filters without IS NOT NULL guard
- Quartile classifications are partitioned by year — ranks are not comparable across years; use raw measures for trend analysis
- `establishments_per_1000_population` and `personnel_per_1000_population` are NULL when `population = 0` (NULLIF guard in SQL)
- `avg_personnel_per_establishment` is NULL when `establishments_count = 0`

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Establishment count | `establishments_count` | Total business establishments in municipality |
| Personnel volume | `personnel_staff_years` | Total personnel measured in staff-years |
| Population | `population` | Municipality population |
| Establishment density | `establishments_per_1000_population` | Establishments per 1,000 residents; NULL when population = 0 |
| Personnel density | `personnel_per_1000_population` | Staff-years per 1,000 residents; NULL when population = 0 |
| Avg establishment size | `avg_personnel_per_establishment` | Staff-years / establishments; NULL when establishments = 0 |
| Establishment absolute change | `establishments_yoy_change` | NULL when prior year is missing |
| Establishment growth % | `establishments_yoy_pct` | NULL when prior year is missing |
| Personnel absolute change | `personnel_yoy_change` | NULL when prior year is missing |
| Personnel growth % | `personnel_yoy_pct` | NULL when prior year is missing |
| Population absolute change | `population_yoy_change` | NULL when prior year is missing |
| Population growth % | `population_yoy_pct` | NULL when prior year is missing |
| Rolling growth trend | `rolling_3y_avg_establishments_growth_pct` | 3-year rolling average; NULL when fewer than 2 prior consecutive years |
| Density classification | `business_density_class` | Quartile: High density / Above average density / Below average density / Low density; NULL when density is NULL |
| Growth classification | `growth_class` | Quartile: Strong growth / Moderate growth / Moderate decline / Strong decline; NULL when YoY pct is NULL |
