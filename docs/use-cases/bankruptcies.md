# Bankruptcies

## Business Question

Where are bankruptcies occurring, which industries are most affected, and how many enterprises and employees are involved?

## Business Value

This use case provides the reusable bankruptcy detail layer for:

- municipality-level bankruptcy monitoring
- industry breakdown analysis
- national rollups built from a common base fact
- downstream use cases that need authoritative bankruptcy detail

## Gold Model

- Model: `fact_bankruptcies`
- Grain: one row per `year x municipality x industry`
- Star-schema style: shared year, municipality, and industry dimensions with bankruptcy measures only

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`
- `dim_industry`
  - `industry_id`

## Core Metrics

- `bankruptcies_enterprises`
  Count of bankrupt enterprises for the municipality-industry-year.

- `bankruptcies_employees`
  Employees affected by bankruptcies for the municipality-industry-year.

## Key Modeling Decisions

### Classified industries only

This fact excludes `Total` and `Industry unknown` rows to prevent double-counting. Only classified industry detail rows are included. Other models that need municipality totals (e.g. `fact_municipality_overview`, `fact_bankruptcy_risk_hotspots`) source the pre-aggregated `Total` row directly from silver.

### Reusable base bankruptcy fact

This is the detailed bankruptcy base fact that supports industry breakdowns and downstream derived facts.

## Known Caveats

- `Total` and `Industry unknown` rows are excluded — use `fact_municipality_overview` or `fact_bankruptcy_risk_hotspots` for municipality-level totals
- to get national totals, sum across all rows for a given year

## Recommended Dashboard Views

1. Top municipalities by total bankruptcies in the latest year
2. Top industries nationally by bankruptcies in the latest year
3. National total bankruptcies over time
4. Municipality by industry heatmap for the latest year

## Example Genie Questions

- Which municipalities had the most bankruptcies in the latest year?
- Which industries account for the most bankruptcies nationally?
- How has the national bankruptcy total changed over time?
