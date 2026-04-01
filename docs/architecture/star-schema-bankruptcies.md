# Star Schema: Bankruptcies

## Fact Table

- `fact_bankruptcies`
- Grain: one row per `year x municipality x industry`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_municipality`
  - joined by `municipality_id`
- `dim_industry`
  - joined by `industry_id`

## Model Shape

This is the base bankruptcy fact for the warehouse.

Dimension keys in the fact:

- `year_id`
- `municipality_id`
- `industry_id`

Measures in the fact include:

- bankruptcies enterprise count
- bankruptcies employee count

## Modeling Note

The implemented fact keeps the natural `year` value as a helper column alongside `year_id`.

It also preserves the source's full industry coverage, including rows such as `Total` and `Industry unknown`.

## Diagram

See:

- `docs/diagrams/bankruptcies.dbml`

## Notes

- downstream use cases should filter aggregate industry rows when they need a clean industry grain
- this is the reusable detailed bankruptcy fact that several derived facts build on