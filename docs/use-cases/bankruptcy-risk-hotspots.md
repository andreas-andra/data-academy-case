# Bankruptcy Risk Hotspots

## Business Question

Which municipalities have the highest bankruptcy pressure relative to their business base, and where is that pressure accelerating?

## Business Value

This use case helps identify high-risk municipalities for:

- lending and credit assessment
- insurance risk analysis
- public-sector support targeting
- regional monitoring of economic stress

## Gold Model

- Model: `fact_bankruptcy_risk_hotspots`
- Grain: one row per `year x municipality`

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`

## Core Metrics

- `bankruptcies_per_1000_establishments`
  Primary hotspot metric. Measures bankruptcy pressure relative to local business base.

- `bankrupt_employees_per_1000_personnel`
  Shows workforce exposure to bankruptcy events.

- `bankruptcies_per_10000_population`
  Normalizes bankruptcy pressure against municipality population.

- `yoy_bankruptcies_pct`
  Year-over-year change in bankruptcy count.

- `yoy_bankruptcy_rate_pct`
  Year-over-year change in bankruptcy rate per 1000 establishments.

- `rolling_3y_avg_bankruptcy_rate`
  Smooths volatility and highlights persistent hotspots.

## Classifications

### `hotspot_risk_class`

This is a within-year ranking based on `ntile(4)`.

- Severe hotspot
- High hotspot
- Moderate hotspot
- Low hotspot

Use it for questions like:

- Which municipalities are riskiest this year?
- Which municipalities are in the top quartile right now?

Important limitation:

- It always produces roughly 25 percent of municipalities in each band for a given year.
- It is useful for relative ranking within a year, not for time-series distribution analysis.

### `hotspot_absolute_risk_class`

This uses fixed thresholds derived from dataset-wide percentiles.

Use it for questions like:

- Is Finland becoming more risky over time?
- Are more municipalities moving into severe risk bands year-over-year?

## Key Modeling Decisions

### Preventing double-counting

The model uses the authoritative `industry = 'Total'` row from the bankruptcy source for municipality totals, instead of summing industry rows.

### Relative vs absolute classification

Two classifications are intentionally included:

- one for within-year ranking
- one for cross-year trend analysis

This prevents misleading dashboard outputs.

### Stable dimension keys

- `year_id` uses the natural year value
- `municipality_id` uses a stable hash-based key

## Known Caveats

- `yoy_*` metrics are `NULL` in 2020 because there is no prior year in the dataset
- some dissolved municipalities or `Unknown` values may still appear depending on source coverage
- hotspot thresholds are descriptive and comparative, not causal or predictive

## Recommended Dashboard Views

1. Latest-year top municipalities by `bankruptcies_per_1000_establishments`
2. Distribution of `hotspot_absolute_risk_class` by year
3. Scatter plot of `bankruptcies_per_1000_establishments` vs `yoy_bankruptcy_rate_pct`
4. Ranking of hotspot industries by municipality

## Example Genie Questions

- Which municipalities had the highest bankruptcy pressure in the latest year?
- Which severe hotspots also had increasing bankruptcy rates?
- How has the count of severe absolute hotspots changed over time?
- Which industries most often appear as the hotspot industry in high-risk municipalities?