# Regional Mortality And Population Change

## Business Question

Which municipalities are losing population, how fast is that change happening, and how does mortality vary across regions over time?

## Business Value

This use case supports:

- regional demographic monitoring
- identifying municipalities with persistent population decline
- comparing death rates across municipalities and over time
- providing demographic context for business and bankruptcy analysis

## Gold Model

- Model: `fact_regional_mortality`
- Grain: one row per `year x municipality`
- Star-schema style: shared year and municipality dimensions plus regional mortality measures

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`

## Core Metrics

- `population`
  Municipality population.

- `deaths`
  Municipality deaths.

- `population_change_yoy`
  Absolute year-over-year population change.

- `population_change_pct`
  Percent year-over-year population change.

- `death_rate_per_1000`
  Deaths normalized by population.

## Key Modeling Decisions

### Gap-aware change logic

Population change metrics are only populated when the municipality has a row in the immediately prior calendar year.

This avoids treating older non-consecutive rows as year-over-year comparisons.

## Known Caveats

- first or non-consecutive municipality years have `NULL` population change fields
- this fact is demographic context, not a direct business-performance fact

## Recommended Dashboard Views

1. Latest-year municipalities by `death_rate_per_1000`
2. Latest-year municipalities by `population_change_pct`
3. Trend chart for selected municipalities
4. Quadrant view of death rate vs population change

## Example Genie Questions

- Which municipalities had the fastest population decline in the latest year?
- Which municipalities have high death rates and shrinking population?
- How has a selected municipality's population change evolved over time?