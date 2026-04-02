# Municipality Business Resilience

## Business Question

Which municipalities appear most resilient or fragile when population, business activity, and bankruptcy signals are considered together?

## Business Value

This use case helps identify stronger and weaker municipality business environments for:

- municipal benchmarking
- regional investment screening
- public-sector monitoring of local economic resilience
- combining several local signals into one watchlist-friendly view

## Gold Model

- Model: `fact_municipality_resilience`
- Grain: one row per `year x municipality`
- Model style: municipality-level fact with shared dimensions

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`
- `dim_industry`
  - `industry_id` used via `top_industry_id`

## Core Metrics

- `resilience_score`
  Weighted composite score from 0 to 100.

- `municipality_business_class`
  Strong, Stable, Watchlist, or Fragile bucket derived from `resilience_score`.

- `bankruptcies_per_1000_establishments`
  Local bankruptcy pressure relative to the business base.

- `bankrupt_employees_per_1000_personnel`
  Workforce exposure to bankruptcy events.

- `yoy_population_pct`, `yoy_establishments_pct`, `yoy_personnel_pct`, `yoy_bankruptcies_pct`
  Core trend indicators behind the composite view.

- `top_industry_id`
  Foreign key to `dim_industry` for the municipality's top bankruptcy industry that year.

## Key Modeling Decisions

### Composite score, not prediction

`resilience_score` is a heuristic weighted index built from percent-rank signals within each year.

It is useful for comparative monitoring, not as a validated predictive model.

### Gap-aware YoY logic

Year-over-year metrics are only populated when the municipality has a row in the immediately prior calendar year.

## Known Caveats

- `resilience_score` is `NULL` in the first year because it depends partly on year-over-year inputs
- users should treat the score as a ranking aid rather than a causal explanation

## Recommended Dashboard Views

1. Latest-year municipalities by `resilience_score`
2. Distribution of `municipality_business_class` by year
3. Scatter plot of resilience vs bankruptcy pressure
4. Breakdown of top-bankruptcy-industry patterns among fragile municipalities

## Example Genie Questions

- Which municipalities are classified as Fragile in the latest year?
- Which municipalities improved the most in resilience score year over year?
- What industries most often appear as the top bankruptcy industry in fragile municipalities?