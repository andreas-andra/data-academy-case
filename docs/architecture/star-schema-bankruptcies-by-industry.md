# Star Schema: Bankruptcies By Industry

## Fact Table

- `fact_bankruptcies_by_industry`
- Grain: one row per `year x industry`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_industry`
  - joined by `industry_id`

## Model Shape

This fact tracks national bankruptcy totals by industry and year.

Dimension keys in the fact:

- `year_id`
- `industry_id`

Measures in the fact include:

- bankruptcies enterprise count
- bankruptcies employee count
- annual share of total bankruptcies

## Modeling Note

Aggregate rows such as `Total` and `Industry unknown` are excluded so the fact preserves a clean industry grain.

## Diagram

See:

- `docs/diagrams/bankruptcies_by_industry.dbml`

## Notes

- this is the simplest industry-level national fact in the warehouse
- it is well suited for trend and mix-share charts