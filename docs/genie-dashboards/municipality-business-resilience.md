# Genie Dashboard: Municipality Business Resilience

## Base Table
`fact_municipality_resilience`

## Required Joins
- `dim_year` on `fact_municipality_resilience.year_id = dim_year.year_id`
- `dim_municipality` on `fact_municipality_resilience.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact_municipality_resilience.top_industry_id = dim_industry.industry_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
Use `dim_industry.industry_name` for the top bankruptcy industry label.

---

## Data Coverage Notes

- `resilience_score` and year-over-year fields (`yoy_population_pct`, `yoy_establishments_pct`, `yoy_personnel_pct`, `yoy_bankruptcies_pct`) are NULL for the first year in the dataset.
- `municipality_business_class` buckets: **Strong** (≥ 80), **Stable** (≥ 60), **Watchlist** (≥ 40), **Fragile** (< 40).
- Filter `year_id` to the desired year before ranking — resilience scores are relative within each year.

---

## Headline KPIs

### Fragile Municipalities (Latest Year)
Count rows where `year_id = latest year` and `municipality_business_class = 'Fragile'`.

### Strong Municipalities (Latest Year)
Count rows where `year_id = latest year` and `municipality_business_class = 'Strong'`.

### Average Resilience Score (Latest Year)
Average `resilience_score` where `year_id = latest year`.

### Municipality with Lowest Resilience Score (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year`. Sort ascending by `resilience_score`. Return the bottom municipality name and score.

---

## Charts

### Chart 1 — Bar Chart: Top 15 and Bottom 15 Municipalities by Resilience Score (Latest Year)
- Filter: `year_id = latest year`
- Category axis: `dim_municipality.municipality_name`
- Value: `resilience_score`
- Color by: `municipality_business_class`
- Show the 15 highest and 15 lowest ranked municipalities
- Narrative: Quick visual split of the strongest and most fragile municipalities in the latest year based on the composite resilience score.

### Chart 2 — Stacked Bar Chart: Municipality Business Class Distribution by Year
- Filter: `municipality_business_class IS NOT NULL` — excludes 2020 (first year has NULL class because resilience_score depends on prior-year data)
- X-axis: `dim_year.year`
- Y-axis: count rows (number of municipalities per class)
- Stack: `municipality_business_class` (Strong, Stable, Watchlist, Fragile)
- Narrative: Shows whether Finland's overall municipal health distribution is improving or deteriorating across years. 2020 is excluded because resilience_score and municipality_business_class are NULL in that year.

### Chart 3 — Scatter Plot: Resilience Score vs Bankruptcy Pressure (Latest Year)
- Filter: `year_id = latest year`, `establishments_count > 0`
- X-axis: `bankruptcies_per_1000_establishments`
- Y-axis: `resilience_score`
- Color by: `municipality_business_class`
- Label high-risk outliers with `dim_municipality.municipality_name`
- Narrative: Validates the resilience score by showing the expected negative correlation — municipalities with high bankruptcy pressure should rank lower in resilience.

### Chart 4 — Bar Chart: Most Common Top Bankruptcy Industry in Fragile Municipalities (Latest Year)
- Filter: `year_id = latest year`, `municipality_business_class = 'Fragile'`
- Join `dim_industry` on `top_industry_id`
- Group by: `dim_industry.industry_name`
- Metric: count rows (number of Fragile municipalities where the industry is the top bankruptcy industry)
- Sort: descending by count
- **Exception**: join `dim_industry` on `fact_municipality_resilience.top_industry_id = dim_industry.industry_id` — this is the correct join for top industry, not the default industry join
- Narrative: Identifies which industries most often drive bankruptcy in fragile municipalities — useful for targeted sector monitoring.

### Chart 5 — Line Chart: Resilience Score Trend for Selected Municipalities
- Filter: parameterise by municipality name — default to the 5 municipalities with the lowest latest-year resilience score
- X-axis: `dim_year.year`
- Y-axis: `resilience_score`
- Series: `dim_municipality.municipality_name`
- Narrative: Tracks whether the most fragile municipalities are recovering or continuing to deteriorate over time.

### Chart 6 — Bar Chart: Year-over-Year Bankruptcy Change (Latest Year, Top 20 Worst)
- Filter: `year_id = latest year`, `yoy_bankruptcies_pct IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `yoy_bankruptcies_pct`
- Sort: descending (most increased bankruptcies at top)
- Narrative: Surfaces municipalities where bankruptcy counts spiked most sharply in the latest year — a leading deterioration signal.

---

## Genie Prompts

"Using fact_municipality_resilience joined to dim_municipality and dim_year, show resilience_score for the top 15 and bottom 15 municipalities in year = 2024 as a bar chart. Color by municipality_business_class. Filter where resilience_score IS NOT NULL."

"Using fact_municipality_resilience joined to dim_year, show the count of municipalities by municipality_business_class and year as a stacked bar chart. Filter where municipality_business_class IS NOT NULL. This excludes the first dataset year where class is NULL."

"Using fact_municipality_resilience joined to dim_municipality and dim_year, show bankruptcies_per_1000_establishments vs resilience_score for year = 2024 as a scatter plot. Color by municipality_business_class. Filter where establishments_count > 0."

"Using fact_municipality_resilience joined to dim_industry and dim_year, for year = 2024 and municipality_business_class = 'Fragile', count how many municipalities have each industry as the most common top bankruptcy industry. Join dim_industry on top_industry_id. Show as a descending bar chart with industry_name. Count rows only."

"Using fact_municipality_resilience joined to dim_municipality and dim_year, show resilience_score over time for the 5 municipalities with the lowest resilience_score in year = 2024 as a multi-line chart. Filter where resilience_score IS NOT NULL."

"Using fact_municipality_resilience joined to dim_municipality and dim_year, show the top 20 municipalities by yoy_bankruptcies_pct for year = 2024 as a descending bar chart. Filter where yoy_bankruptcies_pct IS NOT NULL."

"Using fact_municipality_resilience joined to dim_year, how many municipalities are classified as 'Fragile' in year = 2024? Filter where municipality_business_class IS NOT NULL."

"Using fact_municipality_resilience joined to dim_municipality and dim_year, show rolling_3y_avg_bankruptcy_rate over time for the 5 municipalities with the highest bankruptcies_per_1000_establishments in year = 2024 as a multi-line chart."

---

## Technical Validation

- Base table: `fact_municipality_resilience`
- Joins: `dim_year`, `dim_municipality`, `dim_industry` (on `top_industry_id`)
- The `dim_industry` join is **on `top_industry_id`**, not on a separate industry grain — this fact has one row per year × municipality
- YoY and resilience score fields are NULL for the first year — filter nulls before display
- `municipality_business_class` is derived from `resilience_score` thresholds (Strong ≥ 80, Stable ≥ 60, Watchlist ≥ 40, Fragile < 40)

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary ranking metric | `resilience_score` | 0–100 composite score, ranked within year |
| Classification | `municipality_business_class` | Strong / Stable / Watchlist / Fragile |
| Establishment pressure | `bankruptcies_per_1000_establishments` | Key bankruptcy rate input |
| Employee pressure | `bankrupt_employees_per_1000_personnel` | Workforce exposure |
| Population trend | `yoy_population_pct` | NULL for first year |
| Establishment trend | `yoy_establishments_pct` | NULL for first year |
| Personnel trend | `yoy_personnel_pct` | NULL for first year |
| Bankruptcy trend | `yoy_bankruptcies_pct` | NULL for first year |
| Rolling average | `rolling_3y_avg_bankruptcy_rate` | 3-year smoothed bankruptcy rate |
| Top industry FK | `top_industry_id` | Join to `dim_industry.industry_id` for industry name |
