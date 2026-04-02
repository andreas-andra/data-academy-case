# Genie Dashboard: Regional Mortality and Population Change

## Base Table
`fact_regional_mortality`

## Required Joins
- `dim_year` on `fact_regional_mortality.year_id = dim_year.year_id`
- `dim_municipality` on `fact_regional_mortality.municipality_id = dim_municipality.municipality_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
No industry dimension — this is a year × municipality demographic fact.

---

## Data Coverage Notes

- `population_change_yoy` and `population_change_pct` are NULL when the municipality does not have a row in the immediately prior calendar year. Filter or handle nulls before displaying these fields.
- Do not treat NULL population change as zero — NULL means the prior-year reference row is missing, not that there was no change.

---

## Headline KPIs

### Municipality with Fastest Population Decline (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year` and `population_change_pct IS NOT NULL`. Sort ascending by `population_change_pct`. Return the municipality name and value.

### Municipality with Highest Death Rate (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year`. Sort descending by `death_rate_per_1000`. Return the municipality name and value.

### National Total Deaths (Latest Year)
Sum `deaths` where `year_id = latest year`.

### Municipalities with Population Growth (Latest Year)
Count rows where `year_id = latest year` and `population_change_pct > 0`.

---

## Charts

### Chart 1 — Bar Chart: Top 20 Municipalities by Death Rate (Latest Year)
- Filter: `year_id = latest year`, `population > 0`
- Category axis: `dim_municipality.municipality_name`
- Value: `death_rate_per_1000`
- Sort: descending
- Narrative: Identifies municipalities with the highest mortality burden relative to population — a key demographic stress indicator.

### Chart 2 — Bar Chart: Bottom 20 Municipalities by Population Change Pct (Latest Year)
- Filter: `year_id = latest year`, `population_change_pct IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `population_change_pct`
- Sort: ascending (most negative first)
- Narrative: Shows which municipalities are losing population fastest — persistent decline signals long-term viability challenges.

### Chart 3 — Bar Chart: Top 20 Municipalities by Population Growth (Latest Year)
- Filter: `year_id = latest year`, `population_change_pct IS NOT NULL`, `population_change_pct > 0`
- Category axis: `dim_municipality.municipality_name`
- Value: `population_change_pct`
- Sort: descending
- Narrative: Counterpart to Chart 2 — shows which municipalities are attracting population growth.

### Chart 4 — Scatter Plot: Death Rate vs Population Change (Latest Year)
- Filter: `year_id = latest year`, `population_change_pct IS NOT NULL`, `population > 0`
- X-axis: `population_change_pct`
- Y-axis: `death_rate_per_1000`
- Label high-risk outliers with `dim_municipality.municipality_name`
- Narrative: The most analytically rich view — municipalities in the top-left quadrant (shrinking population, high death rate) face compounding demographic risk.

### Chart 5 — Line Chart: Death Rate Trend for Selected Municipalities
- Filter: parameterise by municipality name — default to the 5 municipalities with the highest latest-year `death_rate_per_1000`
- X-axis: `dim_year.year`
- Y-axis: `death_rate_per_1000`
- Series: `dim_municipality.municipality_name`
- Narrative: Tracks whether mortality pressure in high-rate municipalities is improving or worsening over time.

### Chart 6 — Line Chart: Population Change Trend for Selected Municipalities
- Filter: parameterise by municipality name — default to the 5 municipalities with the most negative latest-year `population_change_pct`
- Filter: `population_change_pct IS NOT NULL`
- X-axis: `dim_year.year`
- Y-axis: `population_change_pct`
- Series: `dim_municipality.municipality_name`
- Narrative: Tracks whether the most rapidly declining municipalities are stabilising or accelerating in population loss.

---

## Technical Validation

- Base table: `fact_regional_mortality`
- Joins: `dim_year`, `dim_municipality`
- `population_change_yoy` and `population_change_pct` are NULL for the first year or when a prior-year row is missing — always apply `IS NOT NULL` filter when displaying change fields
- `death_rate_per_1000` is always populated as long as `population > 0`

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Population | `population` | Municipality population |
| Deaths | `deaths` | Municipality death count |
| Absolute change | `population_change_yoy` | NULL when prior year is missing |
| Percent change | `population_change_pct` | NULL when prior year is missing |
| Death rate | `death_rate_per_1000` | Derived: deaths / population × 1000 |
