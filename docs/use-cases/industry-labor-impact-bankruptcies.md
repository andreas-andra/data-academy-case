# Industry Labor Impact Bankruptcies

## Business Question

Which industries and municipality-industry combinations are associated with the largest employee impact from bankruptcy events, and how does that impact change over time?

## Business Value

This use case helps analyze labor-market exposure to bankruptcies for:

- regional economic monitoring
- labor and workforce risk analysis
- municipal support targeting
- industry stress assessment
- identifying large-employer failure patterns

## Gold Model

- Model: `fact_industry_labor_impact_bankruptcies`
- Grain: one row per `year x municipality x industry`
- Star-schema style: foreign keys and measures only; descriptive names come from dimensions

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`
- `dim_industry`
  - `industry_id`

## Core Metrics

- `bankruptcies_employees`
  Primary labor impact metric. Measures how many employees are affected by bankruptcy events.

- `bankruptcies_enterprises`
  Count of bankrupt enterprises for the municipality-industry-year combination.

- `employees_affected_per_bankruptcy`
  Ratio of employees affected to bankrupt enterprises for the row.

- `share_of_municipality_bankrupt_employees_pct`
  Shows how much of a municipality's total bankruptcy-related employee impact comes from a single industry.

- `share_of_national_industry_bankrupt_employees_pct`
  Shows how much a municipality-industry combination contributes to total national labor impact in that industry.

- `yoy_bankruptcies_employees_pct`
  Year-over-year change in employee impact.

- `yoy_bankruptcies_enterprises_pct`
  Year-over-year change in bankrupt enterprise count.

- `rolling_3y_avg_bankruptcies_employees`
  Smooths annual volatility in employee impact.

- `rolling_3y_avg_employees_per_bankruptcy`
  Three-year ratio-of-sums view of labor impact per bankruptcy event.

## Classifications

### `labor_impact_class`

This is a within-year ranking based on `ntile(4)`.

- Severe labor impact
- High labor impact
- Moderate labor impact
- Low labor impact

Use it for questions like:

- Which municipality-industry combinations are most severe this year?
- Which rows are in the top quartile of employee impact in the latest year?

Important limitation:

- It always produces equal quartile buckets within each year by design.
- It is useful for relative ranking within a year, not for cross-year distribution analysis.

### `labor_impact_absolute_class`

This is the trend-safe classification.

- `No labor impact` when `bankruptcies_employees = 0`
- positive rows are assigned to fixed dataset-wide global quartile bands across all years combined

Use it for questions like:

- Is labor impact becoming more severe over time?
- Are more municipality-industry rows moving into higher labor impact bands?

## Key Modeling Decisions

### Relative vs trend-safe classification

Two classifications are intentionally included:

- one for within-year ranking
- one for cross-year trend analysis

This prevents misleading dashboard outputs.

### Gap-aware YoY logic

The `yoy_*` metrics are only populated when the previous row is exactly the prior calendar year.

This avoids comparing a row in one year to an earlier non-consecutive year and still calling it year-over-year.

### Ratio-of-sums for impact-per-bankruptcy analysis

The rolling `employees per bankruptcy` metric is calculated as a ratio-of-sums, not an average of yearly ratios.

Dashboard aggregations should follow the same logic:

- `sum(bankruptcies_employees) / sum(bankruptcies_enterprises)`

### Excluding non-analytic industry rows

The model excludes:

- `industry = 'Total'`
- `industry = 'Industry unknown'`

This preserves a clean industry grain and avoids double-counting.

## Known Caveats

- `yoy_*` metrics are `NULL` when there is no prior-year row for the same municipality-industry combination
- `labor_impact_class` is not appropriate for time-series class-distribution analysis
- `labor_impact_absolute_class` is the correct class field for trend interpretation
- dashboard tools that want municipality or industry names must join through the dimensions

## Recommended Dashboard Views

1. Latest-year total `bankruptcies_employees` by industry
2. Latest-year total `bankruptcies_enterprises` by industry
3. Yearly total `bankruptcies_employees` and `bankruptcies_enterprises`
4. Heatmap of `bankruptcies_employees` by industry and year
5. `employees per bankruptcy` by industry using ratio-of-sums
6. Distribution of `labor_impact_absolute_class` by year
7. Municipality-industry severe cases for the latest year

## Example Genie Questions

- Which industries had the highest employee impact from bankruptcies in the latest year?
- Which municipality-industry combinations are classified as severe labor impact this year?
- How has the distribution of `labor_impact_absolute_class` changed over time?
- Which industries have the highest employees affected per bankruptcy when aggregated nationally?
- For Helsinki, which industries drove the largest employee impact from bankruptcies?