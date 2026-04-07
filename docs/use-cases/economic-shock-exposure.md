# Economic Shock Exposure Index

## Business Question

Which municipalities are most vulnerable to sudden economic shocks — measured by volatility of bankruptcy rates, business churn, and demographic indicators over rolling 3-year windows?

## Business Value

This use case enables risk-based municipal targeting for:

- identifying municipalities that appear stable on average but have high economic volatility (hidden fragility)
- public policy intervention and regional development planning
- lending risk assessment and investment screening
- early warning detection of municipalities shifting toward crisis-prone status

## Gold Model

- Model: `fact_economic_shock_exposure`
- Grain: one row per `year x municipality`
- Model style: municipality-level fact with shared dimensions

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`

## Core Metrics

- `bankruptcy_rate_cv_3y`
  Rolling 3-year coefficient of variation of bankruptcies per 1000 establishments. Captures how erratic bankruptcy pressure has been over recent years.

- `employee_impact_cv_3y`
  Rolling 3-year CV of bankrupt employees per 1000 personnel staff-years. Measures workforce exposure volatility.

- `business_churn_cv_3y`
  Rolling 3-year CV of year-over-year establishment count changes. High values signal unstable business formation/closure cycles.

- `personnel_cv_3y`
  Rolling 3-year CV of raw personnel staff-years. Flags municipalities with volatile employment bases.

- `demographic_stability_cv_3y`
  Rolling 3-year CV of population year-over-year change. Captures demographic instability that compounds economic shocks.

- `shock_exposure_composite`
  Weighted composite of the five CV measures (0.35 bankruptcy + 0.25 employee impact + 0.20 business churn + 0.10 personnel + 0.10 demographic). Higher values indicate greater shock exposure.

- `shock_resilience_ntile`
  Quartile ranking within each year (1 = most resilient, 4 = most fragile) based on `shock_exposure_composite`.

- `shock_resilience_class`
  Human-readable classification: High Resilience, Moderate Resilience, Fragile, or Crisis-prone.

- `bankruptcy_rate_per_1000`, `establishments_count`, `population`, `deaths`, `death_rate_per_1000`
  Current-year snapshot measures providing dashboard context alongside volatility metrics.

- `establishments_yoy_pct`, `population_change_pct`
  Year-over-year component measures that feed into CV calculations, exposed for drill-down analysis.

## Key Modeling Decisions

### Coefficient of variation, not raw averages

The model uses CV (standard deviation / mean) over a rolling 3-year window rather than raw averages. This isolates volatility — two municipalities with the same average bankruptcy rate can have very different risk profiles if one is stable and the other swings wildly.

### Weighted composite with domain-driven weights

`shock_exposure_composite` applies fixed weights (bankruptcy rate 35%, employee impact 25%, business churn 20%, personnel 10%, demographic 10%) reflecting the relative importance of each volatility dimension to economic shock exposure.

### Guard rails on sparse data

CV measures are NULL when fewer than 3 consecutive years of data exist. Business churn and demographic CVs additionally require 2+ non-null YoY inputs within the window — preventing misleading single-point standard deviations.

## Known Caveats

- All CV measures and `shock_exposure_composite` are NULL for the first two municipality-years
- `shock_resilience_ntile` distributes municipalities into quartiles within each year, so the same composite score may fall into different classes across years
- The rolling window assumes consecutive annual data; CVs may span non-adjacent years if the source contains year gaps (unlikely for Finnish municipal data)

## Recommended Dashboard Views

1. Latest-year municipalities by `shock_resilience_class` on a map or ranked list
2. Year-over-year movement of municipalities between resilience classes
3. Scatter plot of `shock_exposure_composite` vs `bankruptcy_rate_per_1000`
4. Top 10 municipalities with the highest `bankruptcy_rate_cv_3y`
5. Component CV breakdown for a selected municipality over time

## Example Genie Questions

- Which municipalities are classified as Crisis-prone in the latest year?
- Which municipalities moved from High Resilience to Fragile or Crisis-prone in the past 3 years?
- What is the average shock exposure composite for municipalities with more than 50,000 population?
- Which municipalities have the highest bankruptcy rate volatility but low overall bankruptcy rates?
- How many municipalities are in each shock resilience class this year?
- Which Crisis-prone municipalities also have declining population?
- What are the top 10 municipalities by business churn volatility?
- Which municipalities improved their shock resilience class compared to last year?
- Is there a relationship between demographic instability and bankruptcy rate volatility?
- Which small municipalities (population under 10,000) are classified as Crisis-prone?
