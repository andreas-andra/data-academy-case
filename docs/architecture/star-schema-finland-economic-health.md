# Star Schema: Finland Economic Health

## Fact Table

- `fact_finland_economic_health`
- Grain: one row per `year`

## Dimensions

- `dim_year`
  - joined by `year_id`

## Model Shape

This fact summarizes Finland-wide yearly economic-health signals in one national trend table.

Dimension keys in the fact:

- `year_id`

Measures in the fact include:

- total bankruptcies enterprises and employees
- total establishments and personnel
- total population and deaths
- death rate
- establishment and bankruptcy growth metrics

## Modeling Note

Because the grain is just `year`, this fact is safe for direct national time-series dashboards. All measures are national-level totals or derived yearly change metrics.

## Diagram

See:

- `docs/diagrams/finland_economic_health.dbml`

## Notes

- because the grain is just `year`, this fact is safe for direct national time-series dashboards
- all measures are national-level totals or derived yearly change metrics