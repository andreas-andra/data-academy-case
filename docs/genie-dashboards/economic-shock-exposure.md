# Genie Dashboard: Economic Shock Exposure Index

## Purpose

Identifies which Finnish municipalities are most vulnerable to sudden economic shocks — not by their average conditions, but by how erratically their key indicators have swung over rolling 3-year windows. Two municipalities with the same average bankruptcy rate can have very different risk profiles if one is stable and the other swings wildly. This dashboard surfaces that hidden fragility.

---

## Base Table

`data_academy_fi_06.andreas_statfin_gold.fact_economic_shock_exposure`

Short reference: `fact_economic_shock_exposure`

---

## Required Joins

- `dim_year` on `fact_economic_shock_exposure.year_id = dim_year.year_id`
- `dim_municipality` on `fact_economic_shock_exposure.municipality_id = dim_municipality.municipality_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.

---

## Column Dictionary

| Column | Type | Business Description |
|--------|------|----------------------|
| `year_id` | FK | Join key to `dim_year` |
| `municipality_id` | FK | Join key to `dim_municipality` |
| `bankruptcy_rate_cv_3y` | decimal | Volatility of bankruptcy rate per 1000 establishments over the rolling 3-year window. Weight: 35% of composite. |
| `employee_impact_cv_3y` | decimal | Volatility of bankrupt employees per 1000 personnel staff-years. Measures how erratic workforce exposure to bankruptcies has been. Weight: 25%. |
| `business_churn_cv_3y` | decimal | Volatility of establishment count year-over-year % change. High values signal unstable business formation/closure cycles. Weight: 20%. |
| `personnel_cv_3y` | decimal | Volatility of raw personnel staff-years. Flags municipalities with an unstable employment base. Weight: 10%. |
| `demographic_stability_cv_3y` | decimal | Volatility of population year-over-year % change. Captures demographic instability that compounds economic shocks. Weight: 10%. |
| `shock_exposure_composite` | decimal | Weighted sum of all five CV measures. Higher = more volatile and shock-exposed. NULL for years with fewer than 3 years of data. |
| `shock_resilience_ntile` | integer (1–4) | Quartile rank within each year on `shock_exposure_composite` ASC: 1 = most resilient, 4 = most fragile. |
| `shock_resilience_class` | string | Human-readable label: **High Resilience** (ntile 1) / **Moderate Resilience** (ntile 2) / **Fragile** (ntile 3) / **Crisis-prone** (ntile 4). |
| `bankruptcy_rate_per_1000` | decimal | Current-year snapshot: bankruptcies per 1000 establishments. Context measure for drill-down. |
| `establishments_count` | integer | Current-year establishment count. Snapshot context measure. |
| `population` | integer | Current-year population. Snapshot context measure. |
| `deaths` | integer | Current-year deaths. Snapshot context measure. |
| `death_rate_per_1000` | decimal | Current-year deaths per 1000 population. Snapshot context measure. |
| `establishments_yoy_pct` | decimal | YoY % change in establishments. Input to `business_churn_cv_3y`. NULL for first or non-consecutive municipality years. |
| `population_change_pct` | decimal | YoY % change in population. Input to `demographic_stability_cv_3y`. NULL for first or non-consecutive municipality years. |

---

## Data Coverage Notes

- **NULL handling**: All CV measures and `shock_exposure_composite` are NULL for the first two municipality-years in the dataset (rolling window requires 3 consecutive calendar years). Always filter `WHERE shock_exposure_composite IS NOT NULL` for any composite-based ranking or distribution chart.
- **business_churn_cv_3y and demographic_stability_cv_3y** additionally require 2+ non-null YoY inputs within the 3-year window. In rare cases these can be NULL even when the window has 3 rows — the other CV measures will still be populated and the composite will coalesce the missing component to 0.
- **CV interpretation**: CV = standard deviation / mean over the 3-year window. A higher CV means more volatile (more shock-exposed), not higher in absolute level. A municipality with low average bankruptcy but wildly swinging rates will score high on `bankruptcy_rate_cv_3y`.
- **High vs. Low composite**: Higher `shock_exposure_composite` = more exposed / more volatile = **worse**. Lower composite = more stable = **better**. The ntile ordering reflects this: ntile 1 (lowest composite) = High Resilience.
- **Ntile is relative to the year**: `shock_resilience_ntile` distributes municipalities into quartiles within each year. The same composite score may fall into different classes in different years as the overall distribution shifts. Do not compare raw ntile values across years — compare composite scores instead.
- **Default filter for meaningful analysis**: Filter `WHERE shock_exposure_composite IS NOT NULL` for all composite-based charts. Allow snapshot measures (`bankruptcy_rate_per_1000`, `population`, etc.) to show for all years.

---

## Headline KPIs

### Crisis-prone Municipalities (Latest Year)
Count rows where `year_id = latest year` and `shock_resilience_class = 'Crisis-prone'`. Filter `shock_exposure_composite IS NOT NULL`.

### High Resilience Municipalities (Latest Year)
Count rows where `year_id = latest year` and `shock_resilience_class = 'High Resilience'`. Filter `shock_exposure_composite IS NOT NULL`.

### Average Shock Exposure Composite (Latest Year)
Average `shock_exposure_composite` where `year_id = latest year` and `shock_exposure_composite IS NOT NULL`.

### Most Volatile Municipality (Latest Year)
Use `dim_municipality.municipality_name`. Filter `year_id = latest year` and `shock_exposure_composite IS NOT NULL`. Sort descending by `shock_exposure_composite`. Return the top municipality name and composite score.

---

## Charts

### Chart 1 — Bar Chart: Top 15 and Bottom 15 Municipalities by Shock Exposure Composite (Latest Year)
- Filter: `year_id = latest year`, `shock_exposure_composite IS NOT NULL`
- Category axis: `dim_municipality.municipality_name`
- Value: `shock_exposure_composite`
- Color by: `shock_resilience_class`
- Show the 15 highest (most exposed) and 15 lowest (most resilient) municipalities
- Narrative: Quick visual split of the most fragile and most resilient municipalities in the latest year based on the composite shock exposure index.

### Chart 2 — Stacked Bar Chart: Shock Resilience Class Distribution by Year
- Filter: `shock_exposure_composite IS NOT NULL` — excludes the first two years per municipality where the rolling window is not yet populated
- X-axis: `dim_year.year`
- Y-axis: count rows (number of municipalities per class)
- Stack: `shock_resilience_class` (High Resilience, Moderate Resilience, Fragile, Crisis-prone)
- Narrative: Shows whether Finland's overall municipal shock exposure distribution is shifting over time. Early years where CVs are not yet computable are excluded. Because ntile distributes evenly, each class will have approximately the same count within a year — but the aggregate trend across years shows whether the same municipalities persistently occupy high-risk classes.

### Chart 3 — Scatter Plot: Shock Exposure Composite vs Bankruptcy Rate Per 1000 (Latest Year)
- Filter: `year_id = latest year`, `shock_exposure_composite IS NOT NULL`, `establishments_count > 0`
- X-axis: `bankruptcy_rate_per_1000` (current-year snapshot level)
- Y-axis: `shock_exposure_composite` (volatility composite)
- Color by: `shock_resilience_class`
- Label outliers with `dim_municipality.municipality_name`
- Narrative: Distinguishes between municipalities with a persistently high bankruptcy rate (visible at high X values) and those with high volatility even at lower average rates (high Y, moderate X). Municipalities in the upper-left are the "hidden fragility" cases — stable-looking on average but volatile in practice.

### Chart 4 — Line Chart: Shock Exposure Composite Trend for Selected Municipalities
- Filter: parameterise by municipality name — default to the 5 municipalities with the highest `shock_exposure_composite` in the latest year
- Additional filter: `shock_exposure_composite IS NOT NULL`
- X-axis: `dim_year.year`
- Y-axis: `shock_exposure_composite`
- Series: `dim_municipality.municipality_name`
- Narrative: Tracks whether the most exposed municipalities are becoming more stable or continuing to deteriorate. A rising composite across years is a leading stress signal.

### Chart 5 — Heatmap: Bankruptcy Rate CV by Municipality and Year (Top 20 Most Exposed)
- Filter: limit to the 20 municipalities with the highest average `bankruptcy_rate_cv_3y` across all years; filter `bankruptcy_rate_cv_3y IS NOT NULL`
- X-axis: `dim_year.year`
- Y-axis: `dim_municipality.municipality_name`
- Color intensity: `bankruptcy_rate_cv_3y`
- Narrative: Reveals the spatial-temporal pattern of bankruptcy rate volatility. Dark cells identify the worst year for each high-exposure municipality and make multi-year persistence patterns visible at a glance.

### Chart 6 — Bar Chart: Average Component CV Breakdown for Crisis-prone Municipalities (Latest Year)
- Filter: `year_id = latest year`, `shock_resilience_class = 'Crisis-prone'`
- Calculate: average of each CV column (`bankruptcy_rate_cv_3y`, `employee_impact_cv_3y`, `business_churn_cv_3y`, `personnel_cv_3y`, `demographic_stability_cv_3y`) across Crisis-prone municipalities
- Present as a grouped or single bar chart with component names on the X-axis
- Narrative: Shows which volatility dimension is driving the Crisis-prone classification on average. If `bankruptcy_rate_cv_3y` dominates, the primary risk is erratic bankruptcy pressure; if `demographic_stability_cv_3y` or `business_churn_cv_3y` dominates, population and business formation instability are the root cause.

---

## Genie Prompts

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show the top 15 and bottom 15 municipalities by shock_exposure_composite for year = 2024 as a bar chart. Color by shock_resilience_class. Filter where shock_exposure_composite IS NOT NULL."

"Using fact_economic_shock_exposure joined to dim_year, show the count of municipalities by shock_resilience_class and year as a stacked bar chart. Filter where shock_exposure_composite IS NOT NULL."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show bankruptcy_rate_per_1000 on the X-axis vs shock_exposure_composite on the Y-axis for year = 2024 as a scatter plot. Color by shock_resilience_class. Filter where shock_exposure_composite IS NOT NULL and establishments_count > 0. Label outliers with municipality_name."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show shock_exposure_composite over time for the 5 municipalities with the highest shock_exposure_composite in year = 2024 as a multi-line chart. Filter where shock_exposure_composite IS NOT NULL."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show a heatmap of bankruptcy_rate_cv_3y by municipality_name and year for the 20 municipalities with the highest average bankruptcy_rate_cv_3y across all years. Filter where bankruptcy_rate_cv_3y IS NOT NULL."

"Using fact_economic_shock_exposure joined to dim_year, for year = 2024 and shock_resilience_class = 'Crisis-prone', calculate the average of each CV component (bankruptcy_rate_cv_3y, employee_impact_cv_3y, business_churn_cv_3y, personnel_cv_3y, demographic_stability_cv_3y) and show as a bar chart with component name on the X-axis."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, which municipalities have been classified as 'Crisis-prone' in every available year since 2022? Filter where shock_resilience_class = 'Crisis-prone' and shock_exposure_composite IS NOT NULL, then count distinct years per municipality and show those with the highest count."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, how many municipalities changed from 'High Resilience' in year = 2022 to 'Fragile' or 'Crisis-prone' in year = 2024? Self-join on municipality_id or use a pivot approach."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show the top 20 municipalities with the highest demographic_stability_cv_3y for year = 2024 as a descending bar chart. Filter where demographic_stability_cv_3y IS NOT NULL."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, show employee_impact_cv_3y vs business_churn_cv_3y for year = 2024 as a scatter plot. Color by shock_resilience_class. Label high-exposure outliers with municipality_name."

"Using fact_economic_shock_exposure joined to dim_municipality and dim_year, for municipalities where shock_resilience_class = 'Crisis-prone' in year = 2024, show establishments_yoy_pct and population_change_pct side-by-side as a grouped bar chart, sorted by shock_exposure_composite descending."

"Using fact_economic_shock_exposure joined to dim_year, what is the average shock_exposure_composite per year across all municipalities with shock_exposure_composite IS NOT NULL? Show as a line chart over time to reveal national-level volatility trends."

---

## Technical Validation

- Base table: `fact_economic_shock_exposure`
- Joins: `dim_year` (on `year_id`), `dim_municipality` (on `municipality_id`)
- No industry dimension — this fact has one row per `year × municipality` with no industry grain
- CV measures and `shock_exposure_composite` are NULL for the first two years per municipality — filter `shock_exposure_composite IS NOT NULL` for all composite-based analysis
- `shock_resilience_ntile` distributes evenly within each year via `ntile(4)` — expect approximately equal counts per class per year; do not interpret ntile values as absolute thresholds
- `shock_resilience_class` is NULL when `shock_resilience_ntile` is NULL (same NULL condition as composite)
- Snapshot measures (`bankruptcy_rate_per_1000`, `population`, `establishments_count`, `deaths`, `death_rate_per_1000`) are available for all years, not gated by the 3-year window
- Spot-check: for any given municipality, the first two rows (earliest years) should have NULL composite; the third year onward should be populated
- Spot-check: for a given year, count of rows with each `shock_resilience_class` should be approximately equal (ntile distributes evenly)

---

## Metric Usage

| Role | Column | Notes |
|------|--------|-------|
| Primary exposure metric | `shock_exposure_composite` | Weighted CV composite; higher = more volatile; NULL for early years |
| Classification | `shock_resilience_class` | High Resilience / Moderate Resilience / Fragile / Crisis-prone |
| Ntile rank | `shock_resilience_ntile` | 1–4 within year; 1 = most resilient |
| Bankruptcy volatility | `bankruptcy_rate_cv_3y` | 35% composite weight; NULL when < 3 years |
| Workforce exposure volatility | `employee_impact_cv_3y` | 25% composite weight; NULL when < 3 years |
| Business churn volatility | `business_churn_cv_3y` | 20% composite weight; requires 2+ non-null YoY inputs |
| Employment base volatility | `personnel_cv_3y` | 10% composite weight; NULL when < 3 years |
| Demographic volatility | `demographic_stability_cv_3y` | 10% composite weight; requires 2+ non-null YoY inputs |
| Snapshot context | `bankruptcy_rate_per_1000` | Current-year level — useful to distinguish high-level vs high-volatility municipalities |
| Snapshot context | `establishments_count`, `population`, `deaths`, `death_rate_per_1000` | Available for all years |
| YoY drill-down | `establishments_yoy_pct`, `population_change_pct` | Inputs to CV calculation; NULL for first municipality-year |
